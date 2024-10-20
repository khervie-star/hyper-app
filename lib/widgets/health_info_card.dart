import 'package:flutter/material.dart';

class HealthInfoCard extends StatelessWidget {
  const HealthInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Recommendations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.monitor_heart,
              title: 'Regular BP Monitoring',
              description:
                  'Self-monitoring with a reliable BP monitor at home.',
            ),
            const Divider(),
            _buildInfoItem(
              icon: Icons.bed,
              title: 'Sleep',
              description:
                  'Aim for 7-9 hours of good-quality sleep per night, as poor sleep can contribute to hypertension.',
            ),
            const Divider(),
            _buildInfoItem(
              icon: Icons.local_hospital,
              title: 'Consultation with Doctor',
              description:
                  'Regular check-ups to ensure BP is controlled and to adjust medications as needed.',
            ),
            const Divider(),
            _buildInfoItem(
              icon: Icons.health_and_safety,
              title: 'Health Conditions',
              description:
                  'Address other conditions like diabetes, high cholesterol, or kidney disease, as they can worsen BP.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
