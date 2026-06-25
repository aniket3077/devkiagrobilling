import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../bloc/navigation/navigation_event.dart';
import '../bloc/navigation/navigation_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
import '../../domain/entities/app_user.dart';
import 'dashboard_page.dart';
import 'inventory_page.dart';
import 'customers_page.dart';
import 'users_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'billing_page.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationBloc()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;
          final isUserAdmin = user == null || user.role == UserRole.admin;

          return BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, state) {
              final isMobile = MediaQuery.of(context).size.width < 768;
              
              Widget activePage;
              switch (state.currentSection) {
                case AdminSection.dashboard:
                  activePage = const DashboardPage();
                  break;
                case AdminSection.users:
                  activePage = isUserAdmin ? const UsersPage() : const DashboardPage();
                  break;
                case AdminSection.inventory:
                  activePage = const InventoryPage();
                  break;
                case AdminSection.customers:
                  activePage = const CustomersPage();
                  break;
                case AdminSection.reports:
                  activePage = isUserAdmin ? const ReportsPage() : const DashboardPage();
                  break;
                case AdminSection.settings:
                  activePage = isUserAdmin ? const SettingsPage() : const DashboardPage();
                  break;
              }

              if (isMobile) {
                int currentIndex = 0;
                switch (state.currentSection) {
                  case AdminSection.dashboard:
                    currentIndex = 0;
                    break;
                  case AdminSection.inventory:
                    currentIndex = 1;
                    break;
                  case AdminSection.customers:
                    currentIndex = 2;
                    break;
                  case AdminSection.reports:
                    currentIndex = 3;
                    break;
                  case AdminSection.users:
                  case AdminSection.settings:
                    currentIndex = 4;
                    break;
                }

                return Scaffold(
                  body: activePage,
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: currentIndex,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Colors.grey,
                    showUnselectedLabels: true,
                    onTap: (index) {
                      if (index == 0) {
                        context.read<NavigationBloc>().add(NavigateToSection(AdminSection.dashboard));
                      } else if (index == 1) {
                        context.read<NavigationBloc>().add(NavigateToSection(AdminSection.inventory));
                      } else if (index == 2) {
                        context.read<NavigationBloc>().add(NavigateToSection(AdminSection.customers));
                      } else if (index == 3) {
                        if (isUserAdmin) {
                          context.read<NavigationBloc>().add(NavigateToSection(AdminSection.reports));
                        } else {
                          _showMobileMenu(context, isUserAdmin);
                        }
                      } else if (index == 4) {
                        _showMobileMenu(context, isUserAdmin);
                      }
                    },
                    items: [
                      const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                      const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
                      const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
                      if (isUserAdmin)
                        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.menu),
                        label: isUserAdmin ? 'Menu' : 'More',
                      ),
                    ],
                  ),
                );
              }

              return Scaffold(
                body: Row(
                  children: [
                    _AdminSidebar(isUserAdmin: isUserAdmin),
                    Expanded(
                      child: activePage,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showMobileMenu(BuildContext context, bool isUserAdmin) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (isUserAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF10B981)),
                  title: const Text('Staff Management', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    context.read<NavigationBloc>().add(NavigateToSection(AdminSection.users));
                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Color(0xFF10B981)),
                  title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    context.read<NavigationBloc>().add(NavigateToSection(AdminSection.settings));
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final bool isUserAdmin;

  const _AdminSidebar({required this.isUserAdmin});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF071B12), // Slate 900 -> Premium Dark Forest Green
      child: SizedBox(
        width: 260,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: const Row(
                children: [
                  Icon(Icons.eco_outlined, color: Color(0xFF34C759), size: 32),
                  SizedBox(width: 12),
                  Text(
                    'DEVKI AGRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            // New Sale button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BillingPage()),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text('NEW SALE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006C47), // Emerald -> Forest Green primary
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [
                  const _SidebarItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    section: AdminSection.dashboard,
                  ),
                  const _SidebarItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventory',
                    section: AdminSection.inventory,
                  ),
                  const _SidebarItem(
                    icon: Icons.people_outline,
                    title: 'Customers',
                    section: AdminSection.customers,
                  ),
                  if (isUserAdmin) ...[
                    const _SidebarItem(
                      icon: Icons.person_add_alt_1_outlined,
                      title: 'Users',
                      section: AdminSection.users,
                    ),
                    const _SidebarItem(
                      icon: Icons.bar_chart_outlined,
                      title: 'Reports',
                      section: AdminSection.reports,
                    ),
                    const _SidebarItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      section: AdminSection.settings,
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
              onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final AdminSection section;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final isSelected = state.currentSection == section;
        final activeColor = const Color(0xFF34C759); // Leaf Green accent
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: ListTile(
            onTap: () => context.read<NavigationBloc>().add(NavigateToSection(section)),
            leading: Icon(icon, color: isSelected ? activeColor : Colors.grey[400]),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            tileColor: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          ),
        );
      },
    );
  }
}
