import 'package:flutter/material.dart';

import '../color.dart';

class AccessBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget> actions;

  const AccessBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundStartColor,
        border: BoxBorder.fromLTRB(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ?leading,
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // textAlign: TextAlign.center,
              ),
            ),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
