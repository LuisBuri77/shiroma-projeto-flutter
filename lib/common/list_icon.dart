
import 'package:flutter/material.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';

class ListIcon extends StatelessWidget {
  const ListIcon({ this.text, this.iconData, this.onTap, this.highlighted});

  final String text;
  final IconData iconData;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: highlighted? BaseColors('color1') : BaseColors('color2'),
        ),
      ),
      leading: Icon(
        iconData,
        size: 30,
        color: highlighted? BaseColors('color1') : BaseColors('color2'),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
    );
  }
}
