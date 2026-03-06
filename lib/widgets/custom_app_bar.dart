import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({super.key, this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        AppConstants.appBarTitle,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
