import 'package:flutter/material.dart';
import '../../../data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showActions;

  const CourseCard({
    super.key,
    required this.course,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Barre de statut à gauche - UTILISE "checked" au lieu de "isActive"
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: course.checked ? Colors.green : Colors.orange, // CHANGÉ ICI
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                  right: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Icône du cours
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: course.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCourseIcon(course.category),
                color: course.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Informations du cours
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
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
                  Text(
                    course.teacher,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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

            // Menu d'options
            if (showActions && (onEdit != null || onDelete != null))
              PopupMenuButton(
                icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[500]),
                itemBuilder: (context) => [
                  if (onEdit != null)
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
                  if (onDelete != null)
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
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCourseIcon(String category) {
    switch (category.toLowerCase()) {
      case 'science':
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
}