import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Administrateur/presentation/views/dashboard_view.dart';
import '../../Administrateur/presentation/views/programme_view.dart';
import '../../Administrateur/presentation/views/gestion_cours_view.dart';
import '../../Administrateur/presentation/views/gestion_profs_view.dart';
import '../../Administrateur/presentation/views/retour_eleves_view.dart';
import '../auth/auth_provider.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  // ===== PAGES =====
  static final List<Widget> _pages = [
    const DashboardView(),
    const ProgrammeView(),
    const GestionCours(),
    const GestionProfs(),
    const RetourEleves(),
  ];

  static final List<String> _pageTitles = [
    'Dashboard',
    'Programme scolaire',
    'Gestion des cours',
    'Gestion des profs',
    'Retour des élèves',
  ];

  static final List<IconData> _pageIcons = [
    Icons.dashboard,
    Icons.calendar_today,
    Icons.school,
    Icons.person,
    Icons.feedback,
  ];

  // ===== LOGOUT =====
  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.of(context).size.width < 600;

    if (mobile) {
      // ===== MOBILE =====
      return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: _buildMobileNavigationBar(),
      );
    }

    // ===== DESKTOP =====
    return Scaffold(
      body: Row(
        children: [
          _buildDesktopSidebar(context),
          Expanded(
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F9FC),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                title: Text(
                  _pageTitles[_selectedIndex],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Color(0xFF6BA5BD)),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              body: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== SIDEBAR DESKTOP =====================
  Widget _buildDesktopSidebar(BuildContext context) {
    const sidebarColor = Color(0xFF6BA5BD);
    const activeBg = Color(0xFFEAF4F8);
    const activeText = Color(0xFF2C3E50);

    return Container(
      width: 260,
      color: sidebarColor,
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('lib/assets/images/logo.png'),
                ),

                SizedBox(height: 12),
                Text(
                  'EduManager',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Administration',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // ===== MENU =====
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _pageTitles.length,
              itemBuilder: (context, index) {
                final bool selected = _selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? activeBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _pageIcons[index],
                      color: selected ? activeText : Colors.white,
                    ),
                    title: Text(
                      _pageTitles[index],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? activeText : Colors.white,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                    },
                  ),
                );
              },
            ),
          ),

          // ===== FOOTER =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: sidebarColor),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Administrateur',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      'Déconnexion',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: sidebarColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== MOBILE NAVIGATION =====================
  Widget _buildMobileNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6BA5BD),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Programme',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Cours',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feedback),
          label: 'Retour',
        ),
      ],
    );
  }
}
