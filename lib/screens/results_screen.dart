import 'package:flutter/material.dart';
import 'package:hyper_app/services/bp_classification_service.dart';

class ResultScreen extends StatelessWidget {
  final int systolic;
  final int diastolic;

  const ResultScreen(
      {Key? key, required this.systolic, required this.diastolic})
      : super(key: key);

  Color _getClassificationColor(String classification) {
    switch (classification.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'elevated':
        return Colors.orange;
      case 'hypertension stage 1':
        return Colors.deepOrange;
      case 'hypertension stage 2':
        return Colors.red;
      case 'hypertensive crisis':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildResultCard(BuildContext context, String classification) {
    final color = _getClassificationColor(classification);
    final recommendations =
        BPClassificationService.getMedicationRecommendations(classification);
    final isNormal = classification.toLowerCase() == 'normal';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isNormal ? Icons.check_circle : Icons.warning,
                  color: color,
                  size: 32,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    classification,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Blood Pressure Reading',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BPValueWidget(
                  label: 'Systolic',
                  value: systolic,
                  color: color,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '/',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                _BPValueWidget(
                  label: 'Diastolic',
                  value: diastolic,
                  color: color,
                ),
              ],
            ),
            if (recommendations.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              ...recommendations.map((rec) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right, color: color),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(rec),
                        ),
                      ],
                    ),
                  )),
            ],
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/medications');
                  Navigator.pushReplacementNamed(
                    context,
                    '/medications',
                    arguments: {
                      'classification': classification,
                      'classificationColor': color,
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classification =
        BPClassificationService.classify(systolic, diastolic);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Results'),
        elevation: 0,
        backgroundColor: _getClassificationColor(classification),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildResultCard(context, classification),
              // SizedBox(height: 20),
              // TextButton(
              //   child: Text('Save Results'),
              //   onPressed: () {},
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BPValueWidget extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _BPValueWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
