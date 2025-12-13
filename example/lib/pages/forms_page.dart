import 'package:flutter/widgets.dart';
import 'package:manyui/manyui.dart';

import 'page_section.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final MController<bool> _check = MController<bool>(true);
  final MController<bool> _switch = MController<bool>(false);
  final MController<String?> _radio = MController<String?>('flat');
  final MController<double> _slider = MController<double>(0.4);
  final MController<String> _text = MController<String>('');
  final MController<DateTime?> _date = MController<DateTime?>(null);
  final MController<String> _otp = MController<String>('');
  final MController<String?> _select = MController<String?>(null);

  final FocusNode _labeledCheckFocus = FocusNode();

  @override
  void dispose() {
    _check.dispose();
    _switch.dispose();
    _radio.dispose();
    _slider.dispose();
    _text.dispose();
    _date.dispose();
    _otp.dispose();
    _select.dispose();
    _labeledCheckFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageSection(
      title: 'Forms',
      subtitle:
          'Button, Checkbox, Switch, Radio, Slider, TextField, DateField, OTPField, Select, Label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Demo(
            label: 'MButton — every variant, two sizes',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                MButton(onPressed: () {}, child: const Text('Primary')),
                MButton(
                  variant: MButtonVariant.secondary,
                  onPressed: () {},
                  child: const Text('Secondary'),
                ),
                MButton(
                  variant: MButtonVariant.destructive,
                  onPressed: () {},
                  child: const Text('Destructive'),
                ),
                MButton(
                  variant: MButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Outline'),
                ),
                MButton(
                  variant: MButtonVariant.ghost,
                  onPressed: () {},
                  child: const Text('Ghost'),
                ),
                const MButton(onPressed: null, child: Text('Disabled')),
                MButton(
                  size: MButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Small'),
                ),
                MButton(
                  size: MButtonSize.lg,
                  onPressed: () {},
                  child: const Text('Large'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          DemoGrid(
            children: <Widget>[
              Demo(
                label: 'MCheckbox + MLabel',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MCheckbox(
                      controller: _check,
                      focusNode: _labeledCheckFocus,
                    ),
                    const SizedBox(width: 8),
                    MLabel(
                      'Email me about updates',
                      focusNode: _labeledCheckFocus,
                    ),
                  ],
                ),
              ),
              const Demo(
                label: 'MCheckbox — disabled',
                child: MCheckbox(initialValue: true, enabled: false),
              ),
              Demo(
                label: 'MSwitch',
                child: MSwitch(controller: _switch),
              ),
              const Demo(
                label: 'MSwitch — disabled',
                child: MSwitch(initialValue: true, enabled: false),
              ),
              Demo(
                label: 'MRadioGroup',
                child: MRadioGroup<String>(
                  controller: _radio,
                  initialValue: 'flat',
                  onChanged: (_) {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      MRadio<String>(value: 'flat'),
                      SizedBox(width: 6),
                      Text('Flat'),
                      SizedBox(width: 16),
                      MRadio<String>(value: 'tree'),
                      SizedBox(width: 6),
                      Text('Tree'),
                      SizedBox(width: 16),
                      MRadio<String>(value: 'grid', enabled: false),
                      SizedBox(width: 6),
                      Text('Grid (disabled)'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Demo(
            label: 'MSlider',
            child: SizedBox(
              width: 320,
              child: MSlider(controller: _slider, divisions: 10),
            ),
          ),
          const SizedBox(height: 32),
          DemoGrid(
            children: <Widget>[
              Demo(
                label: 'MTextField',
                child: SizedBox(
                  width: 280,
                  child: MTextField(
                    controller: _text,
                    placeholder: 'name@example.com',
                  ),
                ),
              ),
              const Demo(
                label: 'MTextField — error',
                child: SizedBox(
                  width: 280,
                  child: MTextField(
                    initialValue: 'not-an-email',
                    error: true,
                  ),
                ),
              ),
              Demo(
                label: 'MDateField',
                child: SizedBox(
                  width: 220,
                  child: MDateField(
                    controller: _date,
                    placeholder: 'YYYY-MM-DD',
                  ),
                ),
              ),
              const Demo(
                label: 'MDateField — disabled',
                child: SizedBox(
                  width: 220,
                  child: MDateField(placeholder: 'YYYY-MM-DD', enabled: false),
                ),
              ),
              Demo(
                label: 'MOTPField — 6 digits',
                child: MOTPField(controller: _otp, length: 6),
              ),
              Demo(
                label: 'MSelect',
                child: SizedBox(
                  width: 220,
                  child: MSelect<String>(
                    controller: _select,
                    placeholder: 'Pick a fruit',
                    items: const <MSelectItem<String>>[
                      MSelectItem<String>(value: 'apple', label: 'Apple'),
                      MSelectItem<String>(value: 'banana', label: 'Banana'),
                      MSelectItem<String>(value: 'cherry', label: 'Cherry'),
                      MSelectItem<String>(
                        value: 'durian',
                        label: 'Durian (out of stock)',
                        enabled: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
