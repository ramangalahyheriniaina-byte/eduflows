import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/course_model.dart';

class DashboardViewModel extends ChangeNotifier {
  // ETAT =====================
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<Course> _courses = []; // DÉPART VIDE
  bool _isLoading = false;

  // Donnee statique
  final List<String> _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  final List<String> _weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  //GETTER =====================
  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  bool get hasCourses => _courses.isNotEmpty;
  List<String> get months => _months;
  List<String> get weekdays => _weekdays;

  List<Course> get activeCourses =>
      _courses.where((course) => course.checked).toList();

  List<Course> get inactiveCourses =>
      _courses.where((course) => !course.checked).toList();

  int get totalStudents =>
      _courses.fold(0, (sum, course) => sum + course.students);

  // CONSTRUCTEUR =====================
  DashboardViewModel() {
    _loadInitialData();
  }

  //INITIALISATION =====================
  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // DÉPART VIDE - plus de données fictives
    _courses = [];

    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _isLoading = false;
    notifyListeners();
  }

  //METHODES DU CALENDRIER =====================
  String getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    notifyListeners();
  }

  //GESTION DES COURS =====================
  Future<void> addNewCourse({
    required String title,
    required String code,
    required String teacher,
    required String level,
    String category = 'Général',
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulation d'un appel API
    await Future.delayed(const Duration(milliseconds: 300));

    final newCourse = Course(
      id: _courses.isNotEmpty ? _courses.last.id + 1 : 1,
      title: title,
      code: code,
      category: category,
      teacher: teacher,
      level: level,
      students: 0,
      progress: 0.0,
      checked: true,
      color: _getRandomColor(),
    );

    _courses.add(newCourse);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> editCourse(Course course, {
    String? newTitle,
    String? newCode,
    String? newTeacher,
    String? newLevel,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course.copyWith(
        title: newTitle ?? course.title,
        code: newCode ?? course.code,
        teacher: newTeacher ?? course.teacher,
        level: newLevel ?? course.level,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCourse(Course course) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _courses.removeWhere((c) => c.id == course.id);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleCourseStatus(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course.copyWith(checked: !course.checked);
      notifyListeners();
    }
  }
  //Choix du programme
  IconData getCourseIcon(String category) {
    switch (category.toLowerCase()) {
      case 'Phyton':
        return Icons.science;
      case 'ia':
        return Icons.psychology;
      case 'système':
        return Icons.computer;
      case 'programmation':
        return Icons.code;
      default:
        return Icons.school;
    }
  }

  //METHODES UTILITAIRES =====================
  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[_courses.length % colors.length];
  }
}