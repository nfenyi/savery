part of 'widgets.dart';

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  const CircularIconButton({
    required this.icon,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          alignment: Alignment.center,

          // padding: EdgeInsets.symmetric(vertical: 20),
          side: const BorderSide(
            width: 1,
            color: AppColors.neutral300,
          ),
        ),
        child: FaIcon(
          icon,
          color: color,
          size: 15,
        ),
      ),
    );
  }
}
