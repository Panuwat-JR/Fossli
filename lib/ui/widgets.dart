import 'package:flutter/material.dart';

class Glass extends StatelessWidget {
  const Glass({super.key, required this.child, this.padding, this.radius});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.65),
        borderRadius: BorderRadius.circular(radius ?? 18),
        boxShadow: const [BoxShadow(blurRadius: 24, color: Color(0x1F000000), offset: Offset(0, 12))],
        border: Border.all(color: Colors.black12.withOpacity(.05)),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.icon});
  final String text; final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w800);
    return Row(children: [
      if (icon != null) Icon(icon, size: 18), if (icon != null) const SizedBox(width: 8),
      Text(text, style: t),
    ]);
  }
}
