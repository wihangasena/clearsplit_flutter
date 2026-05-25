import 'package:flutter/material.dart';

import '../app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _avatarCtrl;
  String _color = '#2563EB';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final me = widget.controller.personById(widget.controller.state.me)!;
    _nameCtrl = TextEditingController(text: me.name);
    _avatarCtrl = TextEditingController(text: me.avatar);
    _color = me.color;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final err = await widget.controller.updateProfile(
      displayName: _nameCtrl.text.trim(),
      avatar: _avatarCtrl.text.trim(),
      color: _color,
    );
    setState(() => _saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _avatarCtrl,
                  decoration: const InputDecoration(labelText: 'Avatar (emoji)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Avatar required' : null,
                ),
                const SizedBox(height: 12),
                const Text('Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final hex in ['#2563EB', '#10B981', '#8B5CF6', '#EF4444', '#F59E0B', '#0EA5E9'])
                      ChoiceChip(
                        label: Container(width: 24, height: 24, decoration: BoxDecoration(color: Color(int.parse('0xff' + hex.substring(1))), shape: BoxShape.circle)),
                        selected: _color == hex,
                        onSelected: (_) => setState(() => _color = hex),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
