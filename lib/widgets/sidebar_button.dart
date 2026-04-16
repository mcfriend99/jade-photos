import 'package:flutter/material.dart';
import 'package:jade_gallery/color.dart';

class SidebarButton extends StatelessWidget {
  final int? id;
  final IconData? icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const SidebarButton({
    super.key,
    required this.label,
    this.id,
    this.icon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Material(
        color: isSelected ? selectedColor : Colors.transparent,
        child: InkWell(
          hoverColor: isSelected ? selectedColor : altHoverColor,
          splashColor: borderColor.withAlpha(85),
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                icon != null
                    ? Icon(
                        icon!,
                        size: 20,
                        color: isSelected ? accentBlue : normalColor,
                      )
                    : SizedBox(width: 0, height: 0),

                SizedBox(width: 8),

                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? accentBlue : normalColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
