import 'package:flutter/material.dart';

class TimerFormWidget extends StatelessWidget {
  const TimerFormWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onChangeTitle,
    required this.onChangeDescription,
  });

  final String title;
  final String description;
  final ValueChanged<String> onChangeTitle;
  final ValueChanged<String> onChangeDescription;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTitleField(),
            const SizedBox(
              height: 8,
            ),
            _buildDescriptionField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
        maxLength: 30,
        maxLines: 1,
        initialValue: title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Title',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: onChangeTitle,
        validator: (title) {
          return title != null && title.isEmpty
              ? 'The Title Cannot be empty'
              : null;
        });
  }

  Widget _buildDescriptionField() {
    return TextFormField(
        maxLength: 150,
        maxLines: 3,
        initialValue: description,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Description',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: onChangeDescription,
        validator: (desc) {
          return desc != null && desc.isEmpty
              ? 'The Title Cannot be empty'
              : null;
        });
  }
}
