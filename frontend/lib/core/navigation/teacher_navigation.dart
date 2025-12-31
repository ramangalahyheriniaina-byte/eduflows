// lib/core/navigation/teacher_navigation.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/models.dart';

class TeacherNavigation extends StatefulWidget {
  final User user;
  const TeacherNavigation({super.key, required this.user});

  @override
  State<TeacherNavigation> createState() => _TeacherNavigationState();
}

class _TeacherNavigationState extends State<TeacherNavigation> {
  int _selectedIndex = 0;

  // Titres des pages
  static final List<String> _pageTitles = [
    'Emploi du temps',
    'Mes Cours',
    'Notes',
    'Élèves',
  ];

  // Icônes des pages
  static final List<IconData> _pageIcons = [
    Icons.schedule,
    Icons.assignment,
    Icons.grade,
    Icons.people,
  ];

  // Contenu des pages (à remplacer par vos vues réelles)
  final List<Widget> _pages = [
    _buildTimetablePage(),
    _buildCoursesPage(),
    _buildGradesPage(),
    _buildStudentsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.of(context).size.width < 600;

    if (mobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Prof - ${widget.user.name}'),
          backgroundColor: const Color(0xFF4CAF50), // Vert pour prof
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _showNotifications(),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: _buildMobileNavigationBar(),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            // SIDEBAR  GAUCHE POUR PROF (version desktop)
            _buildDesktopSidebar(),
            
            // CONTENU PRINCIPAL
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: Text(
                    _pageTitles[_selectedIndex],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.grey),
                      onPressed: () => _showNotifications(),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.grey),
                      onPressed: () => _showProfile(),
                    ),
                  ],
                ),
                body: _pages[_selectedIndex],
              ),
            ),
          ],
        ),
      );
    }
  }

  // ===================== SIDEBAR DESKTOP =====================
  Widget _buildDesktopSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF4CAF50).withOpacity(0.95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EN-TÊTE
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EduManager',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professeur',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white30),

          // MENU
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _pageTitles.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: Icon(
                      _pageIcons[index],
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                    title: Text(
                      _pageTitles[index],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                      ),
                    ),
                    tileColor: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () => setState(() => _selectedIndex = index),
                  ),
                );
              },
            ),
          ),

          // BOUTON DÉCONNEXION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white30)),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(
                'Deconnexion',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== NAVIGATION MOBILE =====================
  Widget _buildMobileNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Planning',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Cours',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grade),
          label: 'Notes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Élèves',
        ),
      ],
    );
  }

  // ===================== PAGES DE CONTENU =====================
  static Widget _buildTimetablePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emploi du temps',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildScheduleCard('Lundi', '9h-11h', 'Mathématiques', 'Salle 201'),
          _buildScheduleCard('Mardi', '14h-16h', 'Physique', 'Salle 105'),
          _buildScheduleCard('Mercredi', '10h-12h', 'Informatique', 'Lab 3'),
          _buildScheduleCard('Jeudi', '8h-10h', 'Mathématiques', 'Salle 201'),
          _buildScheduleCard('Vendredi', '13h-15h', 'Projet', 'Salle 301'),
        ],
      ),
    );
  }

  static Widget _buildCoursesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes Cours',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildCourseCard('Mathématiques Avancées', 'L1 - 45 étudiants'),
          _buildCourseCard('Introduction à la Physique', 'L2 - 32 étudiants'),
          _buildCourseCard('Programmation Python', 'M1 - 28 étudiants'),
          _buildCourseCard('Algorithmique', 'L3 - 40 étudiants'),
        ],
      ),
    );
  }

  static Widget _buildGradesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestion des Notes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.warning, color: Colors.orange),
                    title: Text('Notes en attente'),
                    subtitle: Text('3 copies à corriger'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Corriger maintenant'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStudentsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes Élèves',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStudentCard('Jean Dupont', 'Mathématiques', '75%'),
          _buildStudentCard('Marie Martin', 'Physique', '88%'),
          _buildStudentCard('Pierre Leroy', 'Informatique', '92%'),
          _buildStudentCard('Sophie Bernard', 'Mathématiques', '65%'),
        ],
      ),
    );
  }

  // ===================== WIDGETS UTILITAIRES =====================
  static Widget _buildScheduleCard(String day, String time, String course, String room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              day.substring(0, 3),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ),
        title: Text(course),
        subtitle: Text('$time • $room'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  static Widget _buildCourseCard(String course, String details) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school,
            color: Color(0xFF4CAF50),
          ),
        ),
        title: Text(course),
        subtitle: Text(details),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  static Widget _buildStudentCard(String name, String course, String progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF4CAF50),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Text(course),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            progress,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== ACTIONS =====================
  void _showNotifications() {
    // TODO: Implémenter la vue des notifications
  }

  void _showProfile() {
    // TODO: Implémenter la vue du profil
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}