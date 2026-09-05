#!/usr/bin/env python3
"""Compare fresh golden runs against the unchanged private-primary baseline.

A matching nonzero result means KNOWN_BASELINE_FAILURE, never golden approval.
No expected PNGs are modified. This helper tests committed HEAD only.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

BASELINE = "e1dd57073d9fef27e2166d399e9b929b4f72da8b"


def summarize(log, returncode, root):
    tests, completed, done = {}, {}, []
    for line in log.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(event, dict):
            continue
        if event.get("type") == "testStart":
            tests[event["test"]["id"]] = event["test"]["name"]
        elif event.get("type") == "testDone":
            completed[event["testID"]] = event
        elif event.get("type") == "done":
            done.append(event)
    if len(done) != 1 or not completed or any(i not in tests for i in completed):
        raise ValueError("Incomplete/empty test protocol; cannot qualify golden result")
    if returncode not in (0, 1) or done[0].get("success") != (returncode == 0):
        raise ValueError("Aborted or inconsistent test process")
    failed = sorted(tests[i] for i, e in completed.items() if e["result"] != "success")
    counts = {"total": len(completed), "passed": len(completed) - len(failed),
              "failed": len(failed), "skipped": sum(bool(e.get("skipped")) for e in completed.values())}
    if bool(failed) != bool(returncode):
        raise ValueError("Exit status and individual results disagree")
    images = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sorted(root.glob("manyui/test/**/failures/*_testImage.png"))}
    if failed and not images:
        raise ValueError("Failing golden run produced no fresh failure images")
    return {"exit_status": returncode, "counts": counts, "failed_test_names": failed,
            "failure_images_sha256": images}


def compare(baseline, candidate):
    if baseline != candidate:
        raise ValueError("Golden result differs from immutable baseline; review required (including improvements)")
    return "KNOWN_BASELINE_FAILURE" if candidate["exit_status"] else "GOLDENS_PASS"


def run(root, output, revision, env):
    root.mkdir()
    archive = output / (root.name + ".tar")
    with archive.open("wb") as stream:
        subprocess.run(["git", "archive", revision], check=True, stdout=stream)
    subprocess.run(["tar", "-xf", str(archive), "-C", str(root)], check=True)
    subprocess.run(["flutter", "pub", "get"], cwd=root, env=env, check=True)
    result = subprocess.run(["flutter", "test", "--no-pub", "--tags=golden", "--machine"],
                            cwd=root / "manyui", env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (output / (root.name + ".log")).write_text(result.stdout)
    return summarize(result.stdout, result.returncode, root)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    os.chdir(repo)
    version = subprocess.check_output(["flutter", "--version"], text=True)
    if "Flutter 3.41.0 " not in version or "Dart 3.11.0" not in version:
        raise SystemExit("Provisioned original Flutter 3.41.0 / Dart 3.11.0 required")
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
    output = args.output.absolute()
    output.mkdir(parents=True, exist_ok=False)
    env = {**os.environ, "PUB_CACHE": str(output / "pub-cache"),
           "DASH__SUPPRESS_ANALYTICS": "true", "FLUTTER_SUPPRESS_ANALYTICS": "true"}
    baseline = run(output / "baseline", output, BASELINE, env)
    candidate = run(output / "candidate", output, revision, env)
    evidence = {"baseline_revision": BASELINE, "candidate_revision": revision,
                "sdk": version, "baseline": baseline, "candidate": candidate}
    (output / "evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    status = compare(baseline, candidate)
    print(status + ": " + json.dumps(candidate["counts"]))
    if status == "KNOWN_BASELINE_FAILURE":
        print("Goldens still fail. This diagnostic verifies no change from the baseline; owner rendering qualification remains pending.")
    print("Evidence: " + str(output / "evidence.json"))


if __name__ == "__main__":
    main()
