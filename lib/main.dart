import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Pribadi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  String? _error;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = null);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotesPage(username: _email.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = null);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotesPage(username: _email.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          final form = Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selamat datang 👋',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Email harus diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().length < 6)
                      ? 'Min. 6 karakter'
                      : null,
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: const Text('Masuk'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _register,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Daftar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLandscape
                ? Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                          ),
                          child: SingleChildScrollView(child: form),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                          ),
                          child: SingleChildScrollView(child: form),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  final String username;
  const NotesPage({super.key, required this.username});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  List<String> notes = [];

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _error = null);
    setState(() {
      notes.add(text);
      _controller.clear();
    });
  }

  void _delete(int index) {
    setState(() {
      notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Pribadi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Go back to LoginPage
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text('Halo, ${widget.username}'),
            ),
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          final inputArea = Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tulis catatan...',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addNote,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
              ],
            ),
          );

          final listArea = Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: ValueKey(notes[index]),
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete),
                  ),
                  secondaryBackground: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) => _delete(index),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 2,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.note),
                      title: Text(notes[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _delete(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLandscape
                ? Row(
                    children: [
                      Expanded(child: inputArea),
                      const SizedBox(width: 16),
                      listArea,
                    ],
                  )
                : Column(
                    children: [inputArea, const SizedBox(height: 12), listArea],
                  ),
          );
        },
      ),
    );
  }
}
