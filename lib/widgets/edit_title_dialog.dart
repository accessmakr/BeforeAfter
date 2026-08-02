import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Simple dialog to edit a comparison title.
class EditTitleDialog extends StatefulWidget {
  final String initialTitle;
  const EditTitleDialog({super.key, required this.initialTitle});

  @override
  State<EditTitleDialog> createState() => _EditTitleDialogState();
}

class _EditTitleDialogState extends State<EditTitleDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
      title: Text(
        'Edit Title',
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter comparison name',
          filled: true,
          fillColor: isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) Navigator.pop(context, text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
