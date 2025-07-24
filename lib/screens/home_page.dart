import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_entry.dart';
import 'entry_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SupabaseClient supabase;
  List<dynamic> entries = [];

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return; // Or redirect to login
    }

    final res = await supabase
        .from('entries')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() => entries = res);
  }

  void _logout() async {
    await supabase.auth.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Journal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: entries.isEmpty
            ? const Center(
                child: Text('No entries yet', style: TextStyle(fontSize: 16)),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      title: Text(
                        e['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        e['created_at'].toString().substring(0, 10),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        'Mood: ${e['mood']}',
                        style: const TextStyle(fontSize: 14, color: Colors.deepPurple),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EntryDetail(entry: e),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEntry()),
          );
          _loadEntries();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
