class BPClassificationService {
  static String classify(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    } else if (systolic < 130 && diastolic < 80) {
      return 'Elevated';
    } else if (systolic < 140 || diastolic < 90) {
      return 'Hypertension Stage 1';
    } else if (systolic < 180 || diastolic < 120) {
      return 'Hypertension Stage 2';
    } else {
      return 'Hypertensive Crisis';
    }
  }

  static List<String> getMedicationRecommendations(String classification) {
    switch (classification) {
      case 'Normal':
      case 'Elevated':
        return [
          'Maintain a healthy lifestyle',
          'Regular exercise',
          'Balanced diet'
        ];
      case 'Hypertension Stage 1':
        return ['Lifestyle changes', 'Consider low-dose medication'];
      case 'Hypertension Stage 2':
        return ['Combination of two medications', 'Regular monitoring'];
      case 'Hypertensive Crisis':
        return [
          'Seek immediate medical attention',
          'Emergency medication as prescribed'
        ];
      default:
        return ['Consult with your healthcare provider'];
    }
  }
}
