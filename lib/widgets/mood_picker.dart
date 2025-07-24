import 'package:flutter/material.dart';

class MoodPicker extends StatelessWidget {
  final Function(int) onMoodSelected;
  final int selectedMood;

  const MoodPicker({super.key, required this.onMoodSelected, required this.selectedMood});

  @override
  Widget build(BuildContext context) {
    final moods = ['😞', '😐', '😊', '😁', '🤩'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(moods.length, (index) {
        return IconButton(
          icon: Text(
            moods[index],
            style: TextStyle(fontSize: selectedMood == index + 1 ? 30 : 24),
          ),
          onPressed: () => onMoodSelected(index + 1),
        );
      }),
    );
  }
}
