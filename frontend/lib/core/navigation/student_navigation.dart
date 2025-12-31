// lib/core/navigation/student_navigation.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/models.dart';

class StudentNavigation extends StatefulWidget {
  final User user;
  const StudentNavigation({super.key, required this.user});

  @override
  State<StudentNavigation> createState() => _StudentNavigationState();
}

class _StudentNavigationState extends State<StudentNavigation> {
  int _selectedIndex = 0;

  static final List<String> _pageTitles = [
    'Emploi du temps',
    'Mes Cours',
    'Devoirs',
    'Notes',
  ];

  static final List<IconData> _pageIcons = [
    Icons.schedule,
    Icons.book,
    Icons.assignment_turned_in,
    Icons.grade,
  ];

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.of(context).size.width < 600;

    if (mobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Étudiant - ${widget.user.name}'),
          backgroundColor: const Color(0xFF2196F3),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: _buildCurrentPage(),
        bottomNavigationBar: _buildMobileNavigationBar(),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            // SIDEBAR GAUCHE  ÉTUDIANT
            _buildDesktopSidebar(context),
            
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
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.account_circle, color: Colors.grey),
                      onSelected: (value) {
                        if (value == 'logout') {
                          _logout(context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Déconnexion', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                body: _buildCurrentPage(),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF2196F3).withOpacity(0.95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EduFlwos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Étudiant',
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

          // BOUTON DECONNEXION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white30)),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2196F3),
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

  Widget _buildMobileNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2196F3),
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
          icon: Icon(Icons.book),
          label: 'Cours',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          label: 'Devoirs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grade),
          label: 'Notes',
        ),
      ],
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0: return _buildTimetablePage();
      case 1: return _buildCoursesPage();
      case 2: return _buildAssignmentsPage();
      case 3: return _buildGradesPage();
      default: return const Center(child: Text('Page non trouvée'));
    }
  }

  Widget _buildTimetablePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Mon Emploi du temps', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildClassCard('Mathématiques', '9h-11h', 'Salle 201', 'Prof. Dupont'),
          _buildClassCard('Physique', '14h-16h', 'Salle 105', 'Prof. Martin'),
        ],
      ),
    );
  }

  Widget _buildCoursesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Mes Cours', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildCourseItem('Mathématiques Avancées', '75%'),
          _buildCourseItem('Physique Quantique', '88%'),
        ],
      ),
    );
  }

  Widget _buildAssignmentsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Mes Devoirs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildAssignmentCard('Devoir Mathématiques', 'À rendre: 15/12', true),
          _buildAssignmentCard('Projet Physique', 'Rendu', false),
        ],
      ),
    );
  }

  Widget _buildGradesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Mes Notes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildGradeCard('Mathématiques', '16/20', 'Bien'),
          _buildGradeCard('Physique', '18/20', 'Très bien'),
        ],
      ),
    );
  }

  Widget _buildClassCard(String subject, String time, String room, String teacher) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule, color: Color(0xFF2196F3)),
        title: Text(subject),
        subtitle: Text('$time • $room\n$teacher'),
      ),
    );
  }

  Widget _buildCourseItem(String course, String progress) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, color: Color(0xFF2196F3)),
        title: Text(course),
        subtitle: LinearProgressIndicator(
          value: double.parse(progress.replaceAll('%', '')) / 100,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
        ),
        trailing: Text(progress),
      ),
    );
  }

  Widget _buildAssignmentCard(String title, String deadline, bool isPending) {
    return Card(
      child: ListTile(
        leading: Icon(
          isPending ? Icons.warning : Icons.check_circle,
          color: isPending ? Colors.orange : Colors.green,
        ),
        title: Text(title),
        subtitle: Text(deadline),
        trailing: isPending 
            ? ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                child: const Text('Rendre', style: TextStyle(color: Colors.white)),
              )
            : const Icon(Icons.check, color: Colors.green),
      ),
    );
  }

  Widget _buildGradeCard(String subject, String grade, String comment) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.grade, color: Color(0xFF2196F3)),
        title: Text(subject),
        subtitle: Text(comment),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            grade,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
          ),
        ),
      ),
    );
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deconnexion'),
          ),
        ],
      ),
    );
  }
}