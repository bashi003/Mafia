import 'package:flutter/material.dart';
import 'role_reveal_screen.dart';

class PlayerNameInputScreen extends StatefulWidget {
  final List<String> roles;

  const PlayerNameInputScreen({super.key, required this.roles});

  @override
  State<PlayerNameInputScreen> createState() => _PlayerNameInputScreenState();
}

class _PlayerNameInputScreenState extends State<PlayerNameInputScreen> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _controllers.addAll(
      List.generate(widget.roles.length, (_) => TextEditingController()),
    );
    _focusNodes.addAll(List.generate(widget.roles.length, (_) => FocusNode()));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void startReveal() {
    final names = _controllers.map((c) => c.text.trim()).toList();
    if (names.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all player names.")),
      );
      return;
    }

    final Map<String, String> assignedRoles = {};
    for (int i = 0; i < names.length; i++) {
      assignedRoles[names[i]] = widget.roles[i];
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                RoleRevealScreen(rolesMap: assignedRoles, playerNames: names),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Player Names")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.roles.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _controllers[index],
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Player ${index + 1}',
                        filled: true,
                        fillColor: Colors.white,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: startReveal,
                icon: const Icon(Icons.visibility),
                label: const Text("Reveal Roles"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
