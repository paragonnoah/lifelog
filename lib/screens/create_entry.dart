import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../mood_utils.dart';

class CreateEntry extends StatefulWidget {
  const CreateEntry({super.key});

  @override
  State<CreateEntry> createState() => _CreateEntryState();
}

class _CreateEntryState extends State<CreateEntry> {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  double mood = 3;
  String? error;

  Future<void> _submit() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => error = 'User not logged in');
      return;
    }

    final now = DateTime.now().toUtc();
    final todayMidnight = DateTime.utc(now.year, now.month, now.day);

    final existing = await supabase
        .from('entries')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', todayMidnight.toIso8601String());

    if (existing.isNotEmpty) {
      setState(() => error = 'You already wrote an entry today.');
      return;
    }

    await supabase.from('entries').insert({
      'title': titleCtrl.text,
      'body': bodyCtrl.text,
      'mood': mood.toInt(),
      'user_id': user.id,
    });

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentMood = mood.toInt();

    return Scaffold(
      appBar: AppBar(title: const Text('New Entry')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Body'),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Mood: ${getMoodLabel(currentMood)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  getMoodEmoji(currentMood),
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            Slider(
              value: mood,
              onChanged: (v) => setState(() => mood = v),
              min: 1,
              max: 5,
              divisions: 4,
              label: getMoodLabel(currentMood),
            ),
            const SizedBox(height: 10),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
