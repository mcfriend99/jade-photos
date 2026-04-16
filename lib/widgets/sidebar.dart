import 'package:flutter/material.dart';
import 'package:jade_gallery/widgets/sidebar_button.dart';

import '../color.dart';

class SidebarNav extends StatefulWidget {
  final double width;
  final double height;
  final int startId;
  final int? selectedId;
  final List<Widget> children;
  final Function(int, String)? onChange;

  const SidebarNav({
    super.key,
    this.width = 250,
    this.selectedId,
    this.height = double.maxFinite,
    this.startId = 0,
    this.children = const <Widget>[],
    this.onChange,
  });

  @override
  State<SidebarNav> createState() => _SidebarNavState();
}

class _SidebarNavState extends State<SidebarNav> {
  int _selectedIndex = 1;
  int _startId = 0;
  
  @override
  void initState() {
    if(widget.selectedId != null) {
      _selectedIndex = widget.selectedId!;

      if(_selectedIndex < widget.startId && widget.startId != 0) {
        throw Exception('startId cannot be less than selectedId');
      } else if(widget.startId == 0) {
        _startId = widget.selectedId! + 0xFFFF;
      }
    } else {
      _selectedIndex = _startId = widget.startId;
    }
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int buttonId = _startId;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: BoxBorder.fromLTRB(right: BorderSide(color: borderColor)),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: widget.children.map((child) {
          if (child is SidebarButton) {
            final thisButtonId = child.id ?? buttonId;

            // increment button id irrespective so that we can always avoid 
            // user sequential class
            buttonId += 0xFF;

            return SidebarButton(
              label: child.label,
              icon: child.icon,
              isSelected: _selectedIndex == thisButtonId,
              onTap: () {
                setState(() {
                  _selectedIndex = thisButtonId;
                });

                widget.onChange?.call(thisButtonId, child.label);
                child.onTap?.call();
              },
            );
          }

          return child;
        }).toList(),
      ),
    );
  }
}
