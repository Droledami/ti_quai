import 'package:flutter/material.dart';

class DismissibleBackground extends StatelessWidget {
  const DismissibleBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(7)
        ),
        child: Row(
          children: [
            Icon(Icons.delete),
            Expanded(flex: 8,child: SizedBox.shrink()),
            Icon(Icons.delete),
          ],
        ),
      ),
    );
  }
}