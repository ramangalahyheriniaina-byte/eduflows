import 'package:flutter/material.dart';

class Course {
  final int id;
  final String title;
  final String code;
  final String category;
  final String teacher;
  final String level;
  final int students;
  final double progress;
  final bool checked;
  final Color color;

  Course({
    required this.id,
    required this.title,
    required this.code,
    required this.category,
    required this.teacher,
    required this.level,
    required this.students,
    required this.progress,
    required this.checked,
    required this.color,
  });

  Course copyWith({
    int? id,
    String? title,
    String? code,
    String? category,
    String? teacher,
    String? level, 
    int? students,
    double? progress,
    bool? checked,
    Color? color,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      category: category ?? this.category,
      teacher: teacher ?? this.teacher,
      level: level ?? this.level,
      students: students ?? this.students,
      progress: progress ?? this.progress,
      checked: checked ?? this.checked,
      color: color ?? this.color,
    );
  }
}