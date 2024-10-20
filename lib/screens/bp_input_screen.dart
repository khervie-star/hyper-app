import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_app/services/bp_service.dart';
import 'package:provider/provider.dart';

class BPInputScreen extends StatefulWidget {
  const BPInputScreen({
    super.key,
  });

  @override
  _BPInputScreenState createState() => _BPInputScreenState();
}

class _BPInputScreenState extends State<BPInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _saveReading() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final bpService = Provider.of<BPService>(context, listen: false);

      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      final timestamp = DateTime.now();

      final reading = BPReading(
          systolic: systolic, diastolic: diastolic, timestamp: timestamp);

      await bpService.addBPReading(reading);

      // Navigate to result screen
      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: {
          'systolic': systolic,
          'diastolic': diastolic,
          'timestamp': timestamp,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving reading. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String? _validateBP(String? value, String type) {
    if (value == null || value.isEmpty) {
      return 'Please enter $type pressure';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (type == 'systolic') {
      if (number < 70 || number > 250) {
        return 'Systolic should be between 70 and 250';
      }
    } else {
      if (number < 40 || number > 150) {
        return 'Diastolic should be between 40 and 150';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Blood Pressure'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions Card
                  // ... (previous code remains the same until the Card widget)

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'How to Measure',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'Sit quietly for 5 minutes before measuring',
                                Icons.timer_outlined,
                              ),
                              SizedBox(height: 8),
                              _buildInfoRow(
                                'Keep your arm at heart level',
                                Icons.height_outlined,
                              ),
                              SizedBox(height: 8),
                              _buildInfoRow(
                                'Keep feet flat on the floor',
                                Icons.accessibility_new_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  Text(
                    'Systolic Pressure',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _systolicController,
                    decoration: InputDecoration(
                      hintText: 'Enter systolic pressure (top number)',
                      prefixIcon: Icon(Icons.trending_up),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) => _validateBP(value, 'systolic'),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Diastolic Pressure',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _diastolicController,
                    decoration: InputDecoration(
                      hintText: 'Enter diastolic pressure (bottom number)',
                      prefixIcon: Icon(Icons.trending_down),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) => _validateBP(value, 'diastolic'),
                  ),
                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveReading,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Chek status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this helper method in the class
  Widget _buildInfoRow(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).primaryColor.withOpacity(0.6),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }
}
