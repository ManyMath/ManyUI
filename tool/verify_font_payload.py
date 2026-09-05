#!/usr/bin/env python3
"""Verify pub-selected fonts/notices and an extracted-package Flutter asset bundle."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = ROOT / "manyui_assets"
NOTICES = ["NOTICE", "fonts/inter/OFL.txt", "fonts/inter/PROVENANCE.json",
           "fonts/jetbrains-mono/OFL.txt", "fonts/jetbrains-mono/PROVENANCE.json",
           "fonts/latinmodern/GUST-FONT-LICENSE.txt", "fonts/latinmodern/NOTICE-LatinModern-fonts.txt"]


def run(command, cwd, log):
    executable = shutil.which(command[0])
    if executable is None:
        raise RuntimeError(f"Missing provisioned tool: {command[0]}")
    with log.open("w") as output:
        subprocess.run([executable, *command[1:]], cwd=cwd, stdout=output,
                       stderr=subprocess.STDOUT, check=True)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    dart = shutil.which("dart")
    if dart is None:
        raise RuntimeError("Provision Dart 3.13.2 before checking publication archives")
    version = subprocess.check_output([dart, "--version"], stderr=subprocess.STDOUT, text=True)
    if "Dart SDK version: 3.13.2 " not in version:
        raise RuntimeError("This archive capability is verified with Dart 3.13.2; use that provisioned SDK")
    output = args.output.absolute()
    output.mkdir(parents=True, exist_ok=False)
    archive = output / "manyui_assets.tar.gz"
    run(["dart", "pub", "publish", f"--to-archive={archive}"], PACKAGE, output / "archive.log")
    if not archive.is_file() or archive.stat().st_size == 0:
        raise RuntimeError("Pub did not produce the expected package archive")
    extracted = output / "package"
    extracted.mkdir()
    with tarfile.open(archive) as payload:
        if any(item.issym() or item.islnk() for item in payload.getmembers()):
            raise ValueError("Unexpected link in font package archive")
        payload.extractall(extracted, filter="data")
    expected = {path: digest(PACKAGE / path) for path in NOTICES}
    expected.update({path.relative_to(PACKAGE).as_posix(): digest(path)
                     for path in (PACKAGE / "fonts").rglob("*") if path.suffix in {".otf", ".ttf"}})
    for name, sha in expected.items():
        if digest(extracted / name) != sha:
            raise ValueError(f"Archive differs from reviewed font source: {name}")
    for family in ("inter", "jetbrains-mono"):
        directory = extracted / "fonts" / family
        evidence = json.loads((directory / "PROVENANCE.json").read_text())
        checks = dict(evidence["source_font_files_sha256"])
        checks["OFL.txt"] = evidence["license"]["sha256"]
        for name, sha in checks.items():
            if Path(name).name != name or digest(directory / name) != sha:
                raise ValueError(f"Font or license differs from provenance: {family}/{name}")
    consumer = output / "consumer"
    run(["flutter", "create", "--no-pub", "--platforms=linux", "--project-name=font_consumer", str(consumer)],
        output, output / "create.log")
    manifest = consumer / "pubspec.yaml"
    manifest.write_text(manifest.read_text().replace("dependencies:\n", "dependencies:\n  manyui_assets:\n    path: ../package\n", 1))
    run(["flutter", "pub", "get"], consumer, output / "pub-get.log")
    run(["flutter", "build", "bundle", "--debug", "--no-pub"], consumer, output / "bundle.log")
    bundled = consumer / "build/flutter_assets/packages/manyui_assets"
    for name, sha in expected.items():
        if digest(bundled / name) != sha:
            raise ValueError(f"Application bundle omitted or changed font/license: {name}")
    evidence = {"status": "passed", "scope": "Actual pub-selected package and extracted-package Flutter asset bundle; no deployment/publication",
                "source_revision": subprocess.check_output(["git", "-C", str(ROOT), "rev-parse", "HEAD"], text=True).strip(),
                "source_dirty": bool(subprocess.check_output(["git", "-C", str(ROOT), "status", "--porcelain"])),
                "archive_sha256": digest(archive), "verified_payload_files_sha256": expected}
    (output / "evidence.json").write_text(json.dumps(evidence, sort_keys=True, indent=2) + "\n")
    print(json.dumps(evidence, sort_keys=True, indent=2))


if __name__ == "__main__":
    main()
