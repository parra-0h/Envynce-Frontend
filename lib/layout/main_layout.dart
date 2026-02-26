import 'package:flutter/material.dart';
import 'topbar.dart';
import 'sidebar.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      drawer: !isDesktop ? const Drawer(child: Sidebar()) : null,
      body: Row(
        children: [
          if (isDesktop) const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const Topbar(),
                Expanded(
                  child: Container(
                    color: AppTheme.backgroundColor,
                    child: child, // child is already the routed view
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
