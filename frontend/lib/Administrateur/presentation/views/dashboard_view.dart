import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/dashboard_viewmodel.dart';
import '../../data/models/course_model.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool mobile = MediaQuery.of(context).size.width < 600;

          return Scaffold(
            appBar: mobile ? AppBar(
              title: const Text('Dashboard'),
              backgroundColor: const Color(0xFF6BA5BD),
              elevation: 0,
            ) : null,

            body: SafeArea(
              child: SingleChildScrollView(
                padding: mobile ? const EdgeInsets.all(12) : const EdgeInsets.all(20),
                child: mobile
                    ? _buildMobileLayout(context, viewModel)
                    : _buildDesktopLayout(context, viewModel),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===================== VERSION DESKTOP =====================
  Widget _buildDesktopLayout(BuildContext context, DashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDesktopHeader(viewModel),
        const SizedBox(height: 20),
        _buildDesktopTopSection(context, viewModel),
        const SizedBox(height: 20),
        if (viewModel.hasCourses) _buildDesktopProgressSection(viewModel),
      ],
    );
  }

  // ===================== HEADER DESKTOP =====================
Widget _buildDesktopHeader(DashboardViewModel viewModel) {
  final now = DateTime.now();
  final dayName = viewModel.getDayName(now.weekday);
  final monthName = viewModel.months[now.month - 1];
  final formattedDate = '$dayName, ${now.day} $monthName ${now.year}';

  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bonjour, Admin 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        
      ],
    ),
  );
}

  // ===================== TOP SECTION DESKTOP =====================
  Widget _buildDesktopTopSection(BuildContext context, DashboardViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDesktopCurrentCourseSection(context, viewModel)),
        const SizedBox(width: 20),
        SizedBox(width: 320, child: _buildDesktopCalendarSection(viewModel)),
      ],
    );
  }

  Widget _buildDesktopCurrentCourseSection(BuildContext context, DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current course',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${viewModel.courses.length} cours',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // STATS - Afficher même si vide
          Row(
            children: [
              _buildStatCard('Cours actifs', viewModel.activeCourses.length, Icons.play_circle, Colors.green),
              const SizedBox(width: 10),
              _buildStatCard('Cours inactifs', viewModel.inactiveCourses.length, Icons.pause_circle, Colors.orange),
              const SizedBox(width: 10),
              _buildStatCard('Total élèves', viewModel.totalStudents, Icons.people, Colors.blue),
            ],
          ),

          const SizedBox(height: 20),

          // TITRE SECTION
          const Text(
            'Cours récents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // EMPTY STATE OU LISTE DES COURS
          if (viewModel.hasCourses)
            ...viewModel.courses.take(3).map((course) {
              return _buildDesktopCourseCard(context, course, viewModel);
            }).toList()
          else
            _buildDesktopEmptyState(context, viewModel),

          const SizedBox(height: 20),

          // BOUTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _addNewCourseDialog(context, viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BA5BD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouveau cours'),
              ),

              if (viewModel.hasCourses)
                ElevatedButton(
                  onPressed: () => _showAllCoursesDialog(context, viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  ),
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== EMPTY STATE DESKTOP =====================
  Widget _buildDesktopEmptyState(BuildContext context, DashboardViewModel viewModel) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        // REMPLACER BorderStyle.dashed par BorderStyle.solid avec strokeAlign
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
          style: BorderStyle.solid,
          // Option: ajouter strokeAlign pour un effet différent
          // strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 50,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun cours pour le moment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Commencez par créer votre premier cours pour gérer votre planning',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _addNewCourseDialog(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BA5BD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Créer mon premier cours'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const Spacer(),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCourseCard(BuildContext context, Course course, DashboardViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: course.checked ? Colors.green : Colors.orange,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(4),
                right: Radius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: course.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              viewModel.getCourseIcon(course.category),
              color: course.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: course.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.code,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: course.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        course.teacher,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Icon(Icons.school, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      course.level,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${course.students} élèves',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(course.progress * 100).round()}% complété',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[500]),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Modifier'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18),
                    SizedBox(width: 8),
                    Text('Supprimer'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _editCourseDialog(context, course, viewModel);
              } else if (value == 'delete') {
                _deleteCourseDialog(context, course, viewModel);
              }
            },
          ),
        ],
      ),
    );
  }

  // ===================== PROGRESS SECTION DESKTOP =====================
  Widget _buildDesktopProgressSection(DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avancement des cours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: const [
              SizedBox(width: 40, child: Text('#', style: TextStyle(color: Colors.grey))),
              Expanded(flex: 3, child: Text('Nom cours', style: TextStyle(color: Colors.grey))),
              Expanded(flex: 4, child: Text('Avancement', style: TextStyle(color: Colors.grey))),
              SizedBox(width: 90, child: Text('Pourcentage', style: TextStyle(color: Colors.grey))),
            ],
          ),
          const Divider(height: 30),

          ...viewModel.courses.take(4).map((course) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _desktopProgressRow(course),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _desktopProgressRow(Course course) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            course.code,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),

        Expanded(
          flex: 3,
          child: Text(
            course.title,
            style: const TextStyle(fontSize: 14),
          ),
        ),

        Expanded(
          flex: 4,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: course.progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: course.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                left: (course.progress * 220).clamp(0, 220),
                child: const CircleAvatar(
                  radius: 3,
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 15),

        SizedBox(
          width: 90,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: course.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${(course.progress * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: course.color,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== CALENDAR DESKTOP =====================
  Widget _buildDesktopCalendarSection(DashboardViewModel viewModel) {
    final monthName = '${viewModel.months[viewModel.currentMonth.month - 1]} ${viewModel.currentMonth.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: viewModel.previousMonth,
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: viewModel.nextMonth,
                    icon: const Icon(Icons.chevron_right),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildDesktopWeekDays(viewModel),
          const SizedBox(height: 10),
          _buildDesktopCalendarGrid(viewModel),
        ],
      ),
    );
  }

  Widget _buildDesktopWeekDays(DashboardViewModel viewModel) {
    return Row(
      children: viewModel.weekdays.map((day) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopCalendarGrid(DashboardViewModel viewModel) {
    final firstDay = viewModel.currentMonth;
    final lastDay = DateTime(viewModel.currentMonth.year, viewModel.currentMonth.month + 1, 0);
    final totalDays = lastDay.day;
    final startingWeekday = (firstDay.weekday + 6) % 7;

    final now = DateTime.now();
    final isCurrentMonth = viewModel.currentMonth.year == now.year &&
        viewModel.currentMonth.month == now.month;

    return Container(
      margin: const EdgeInsets.all(1),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0,
        ),
        itemCount: 42,
        itemBuilder: (context, index) {
          final dayNumber = index - startingWeekday + 1;

          if (dayNumber < 1 || dayNumber > totalDays) {
            return Container();
          }

          final isToday = isCurrentMonth && dayNumber == now.day;
          final isSelected = isCurrentMonth && dayNumber == viewModel.selectedDate.day;

          return GestureDetector(
            onTap: () {
              viewModel.selectDate(DateTime(
                viewModel.currentMonth.year,
                viewModel.currentMonth.month,
                dayNumber,
              ));
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6BA5BD)
                    : isToday
                    ? const Color(0xFF6BA5BD).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===================== VERSION MOBILE =====================
  Widget _buildMobileLayout(BuildContext context, DashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER mobile (déjà géré par AppBar)
        const SizedBox(height: 8),

        // STATS
        _buildMobileStatsSection(viewModel),
        const SizedBox(height: 16),

        // COURS RÉCENTS (avec empty state)
        _buildMobileCoursesSection(context, viewModel),
        const SizedBox(height: 16),

        // CALENDRIER
        _buildMobileCalendarSection(viewModel),
        const SizedBox(height: 16),

        // PROGRESS SECTION (seulement si cours existent)
        if (viewModel.hasCourses) _buildMobileProgressSection(viewModel),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMobileStatsSection(DashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current course',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${viewModel.courses.length} cours'),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats en colonne
            _buildMobileStatItem('Cours actifs', viewModel.activeCourses.length,
                Icons.play_circle_filled, Colors.green),
            const SizedBox(height: 12),
            _buildMobileStatItem('Cours inactifs', viewModel.inactiveCourses.length,
                Icons.pause_circle_filled, Colors.orange),
            const SizedBox(height: 12),
            _buildMobileStatItem('Total élèves', viewModel.totalStudents,
                Icons.people, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStatItem(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCoursesSection(BuildContext context, DashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cours récents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (viewModel.hasCourses)
              ...viewModel.courses.take(3).map((course) {
                return _buildMobileCourseItem(context, course, viewModel);
              }).toList()
            else
              _buildMobileEmptyState(context, viewModel),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addNewCourseDialog(context, viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BA5BD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nouveau cours'),
                  ),
                ),
                const SizedBox(width: 8),
                if (viewModel.hasCourses)
                  ElevatedButton(
                    onPressed: () => _showAllCoursesDialog(context, viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Tout voir'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileEmptyState(BuildContext context, DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        // CORRIGER ICI AUSSI
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucun cours',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre premier cours pour commencer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addNewCourseDialog(context, viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BA5BD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Créer un cours'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCourseItem(BuildContext context, Course course, DashboardViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        _showCourseDetails(context, course, viewModel);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Indicateur de statut
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: course.checked ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: course.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                viewModel.getCourseIcon(course.category),
                color: course.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.teacher,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.school, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        course.level,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(course.progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: course.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCalendarSection(DashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${viewModel.months[viewModel.currentMonth.month - 1]} ${viewModel.currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: viewModel.previousMonth,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      onPressed: viewModel.nextMonth,
                      icon: const Icon(Icons.chevron_right, size: 20),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMobileCalendarGrid(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCalendarGrid(DashboardViewModel viewModel) {
    final firstDay = viewModel.currentMonth;
    final lastDay = DateTime(viewModel.currentMonth.year, viewModel.currentMonth.month + 1, 0);
    final totalDays = lastDay.day;
    final startingWeekday = (firstDay.weekday + 6) % 7;

    final now = DateTime.now();
    final isCurrentMonth = viewModel.currentMonth.year == now.year &&
        viewModel.currentMonth.month == now.month;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayNumber = index - startingWeekday + 1;

        if (dayNumber < 1 || dayNumber > totalDays) {
          return Container();
        }

        final isToday = isCurrentMonth && dayNumber == now.day;
        final isSelected = isCurrentMonth && dayNumber == viewModel.selectedDate.day;

        return GestureDetector(
          onTap: () {
            viewModel.selectDate(DateTime(
              viewModel.currentMonth.year,
              viewModel.currentMonth.month,
              dayNumber,
            ));
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6BA5BD)
                  : isToday
                  ? const Color(0xFF6BA5BD).withOpacity(0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              dayNumber.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileProgressSection(DashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avancement des cours',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...viewModel.courses.take(3).map((course) {
              return _buildMobileProgressRow(course);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileProgressRow(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                child: Text(
                  course.code,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  course.title,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: course.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(course.progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: course.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: course.progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: course.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== DIALOGUES =====================
  void _addNewCourseDialog(BuildContext context, DashboardViewModel viewModel) {
    final titleController = TextEditingController();
    final codeController = TextEditingController();
    final teacherController = TextEditingController();
    final levelController = TextEditingController();
    String selectedCategory = 'Général';

    final categories = [
      'Général',
      'Science',
      'IA',
      'Système',
      'Programmation',
      'Mathématiques',
      'Physique',
      'Chimie',
      'Informatique',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Créer un nouveau cours'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du cours *',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Mathématiques Avancées',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code du cours *',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: MATH-301',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: teacherController,
                  decoration: const InputDecoration(
                    labelText: 'Professeur *',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Prof. Dupont',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: levelController,
                  decoration: const InputDecoration(
                    labelText: 'Niveau *',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: L1, M1, Master, etc.',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedCategory = newValue;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    codeController.text.isEmpty ||
                    teacherController.text.isEmpty ||
                    levelController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs obligatoires'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                viewModel.addNewCourse(
                  title: titleController.text,
                  code: codeController.text,
                  teacher: teacherController.text,
                  level: levelController.text,
                  category: selectedCategory,
                );
                Navigator.pop(context);
                _showSuccessMessage(context, 'Cours créé avec succès!');
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  void _editCourseDialog(BuildContext context, Course course, DashboardViewModel viewModel) {
    final titleController = TextEditingController(text: course.title);
    final codeController = TextEditingController(text: course.code);
    final teacherController = TextEditingController(text: course.teacher);
    final levelController = TextEditingController(text: course.level);
    String selectedCategory = course.category;

    final categories = [
      'Général',
      'Science',
      'IA',
      'Système',
      'Programmation',
      'Mathématiques',
      'Physique',
      'Chimie',
      'Informatique',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le cours'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du cours *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code du cours *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: teacherController,
                  decoration: const InputDecoration(
                    labelText: 'Professeur *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: levelController,
                  decoration: const InputDecoration(
                    labelText: 'Niveau *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedCategory = newValue;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    codeController.text.isEmpty ||
                    teacherController.text.isEmpty ||
                    levelController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs obligatoires'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                viewModel.editCourse(course,
                  newTitle: titleController.text,
                  newCode: codeController.text,
                  newTeacher: teacherController.text,
                  newLevel: levelController.text,
                );
                Navigator.pop(context);
                _showSuccessMessage(context, 'Cours modifié avec succès!');
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourseDialog(BuildContext context, Course course, DashboardViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le cours'),
          content: Text('Êtes-vous sûr de vouloir supprimer "${course.title}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.deleteCourse(course);
                Navigator.pop(context);
                _showSuccessMessage(context, 'Cours supprimé avec succès!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showAllCoursesDialog(BuildContext context, DashboardViewModel viewModel) {
    final bool mobile = MediaQuery.of(context).size.width < 600;

    if (mobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tous les cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.courses.length,
                    itemBuilder: (context, index) {
                      final course = viewModel.courses[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: course.color.withOpacity(0.2),
                          child: Text(
                            course.code.substring(0, 2),
                            style: TextStyle(
                              color: course.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(course.title),
                        subtitle: Text('${course.teacher} • ${course.level}'),
                        trailing: Text(
                          '${(course.progress * 100).round()}%',
                          style: TextStyle(
                            color: course.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _editCourseDialog(context, course, viewModel);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxHeight: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tous les cours',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: viewModel.courses.length,
                      itemBuilder: (context, index) {
                        final course = viewModel.courses[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: course.color.withOpacity(0.2),
                            child: Text(
                              course.code.substring(0, 2),
                              style: TextStyle(
                                color: course.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(course.title),
                          subtitle: Text('${course.teacher} • ${course.level}'),
                          trailing: Text(
                            '${(course.progress * 100).round()}%',
                            style: TextStyle(
                              color: course.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _editCourseDialog(context, course, viewModel);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // ===================== BOTTOM SHEET MOBILE =====================
  void _showCourseDetails(BuildContext context, Course course, DashboardViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: course.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      viewModel.getCourseIcon(course.category),
                      color: course.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${course.code} • ${course.level}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildDetailRow('Professeur', course.teacher, Icons.person),
              _buildDetailRow('Catégorie', course.category, Icons.category),
              _buildDetailRow('Élèves', '${course.students}', Icons.people),
              _buildDetailRow('Progression', '${(course.progress * 100).round()}%', Icons.trending_up),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editCourseDialog(context, course, viewModel);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteCourseDialog(context, course, viewModel);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Supprimer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== MÉTHODES UTILITAIRES =====================
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}