import 'package:flutter/material.dart';
import '../models/user_model.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;

  const DocumentCard({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _buildDocumentIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        document.size,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        document.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildStatusChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentIcon() {
    IconData iconData;
    Color iconColor;

    if (document.name.endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (document.name.endsWith('.docx') ||
        document.name.endsWith('.doc')) {
      iconData = Icons.description;
      iconColor = Colors.blue;
    } else if (document.name.endsWith('.pptx') ||
        document.name.endsWith('.ppt')) {
      iconData = Icons.slideshow;
      iconColor = Colors.orange;
    } else if (document.name.endsWith('.xlsx') ||
        document.name.endsWith('.xls')) {
      iconData = Icons.table_chart;
      iconColor = Colors.green;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    Color textColor;

    if (document.status == 'Printed') {
      chipColor = Colors.green[100]!;
      textColor = Colors.green[800]!;
    } else if (document.status == 'Pending') {
      chipColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
    } else {
      chipColor = Colors.grey[100]!;
      textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        document.status,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
