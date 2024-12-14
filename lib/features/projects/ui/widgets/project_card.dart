import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';

class ProjectCard extends StatefulWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  _ProjectCardState createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late bool isPinned;

  @override
  void initState() {
    super.initState();
    isPinned = widget.project.isFlag; // Initialize with the project's pinned state
  }

  void togglePin() {
    setState(() {
      isPinned = !isPinned;
    });
    // You can implement additional logic to handle pin/unpin here
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = widget.project.startDate != null
        ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(widget.project.startDate!))
        : 'N/A';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Card Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  widget.project.pictureUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Title
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Start Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),

                    // Warning Count
                    if (widget.project.warnings > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            const Icon(Icons.warning,
                                size: 12, color: Colors.red),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.project.warnings} Warnings',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Pin/Unpin Button
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: togglePin,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isPinned ? Theme.of(context).primaryColor : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPinned ? 'Unpin' : 'Pin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
