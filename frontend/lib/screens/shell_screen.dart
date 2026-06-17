import 'package:flutter/material.dart';

import 'admin_screen.dart';
import 'chat_screen.dart';
import 'community_screen.dart';
import 'dashboard_screen.dart';
import 'marketplace_screen.dart';
import 'portfolio_screen.dart';
import 'projects_screen.dart';
import 'wallet_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    MarketplaceScreen(),
    ProjectsScreen(),
    CommunityScreen(),
    WalletScreen(),
    PortfolioScreen(),
    ChatScreen(),
    AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    const destinations = [
      NavigationDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard),
          label: 'Home'),
      NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Skills'),
      NavigationDestination(
          icon: Icon(Icons.workspaces_outline),
          selectedIcon: Icon(Icons.workspaces),
          label: 'Projects'),
      NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum),
          label: 'Community'),
      NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet),
          label: 'Wallet'),
      NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Portfolio'),
      NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Chat'),
      NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin'),
    ];

    if (width >= 840) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: width >= 1100,
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label)))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _screens[_index]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations,
      ),
    );
  }
}
