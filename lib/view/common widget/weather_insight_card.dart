import 'package:flutter/material.dart';


Widget weatherInsightCard({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            height: 1.5,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
