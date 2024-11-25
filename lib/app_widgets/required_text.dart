part of 'widgets.dart';

class RequiredText extends StatelessWidget {
  final String text;
  final bool isRequired;
  const RequiredText(this.text, {super.key, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isRequired,
      replacement: AppText(
        text: text,
        weight: FontWeight.bold,
      ),
      child: Row(
        children: [
          AppText(
            text: text,
            weight: FontWeight.bold,
          ),
          const Gap(10),
          const FaIcon(
            FontAwesomeIcons.asterisk,
            color: Colors.red,
            size: 8,
          )
        ],
      ),
    );
  }
}
