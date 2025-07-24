// mood_utils.dart
String getMoodEmoji(int mood) {
  switch (mood) {
    case 1:
      return '😢'; // Very sad
    case 2:
      return '😟'; // Sad
    case 3:
      return '😐'; // Neutral
    case 4:
      return '🙂'; // Happy
    case 5:
      return '😁'; // Very happy
    default:
      return '🤔';
  }
}

String getMoodLabel(int mood) {
  switch (mood) {
    case 1:
      return 'Very Sad';
    case 2:
      return 'Sad';
    case 3:
      return 'Neutral';
    case 4:
      return 'Happy';
    case 5:
      return 'Very Happy';
    default:
      return 'Unknown';
  }
}
