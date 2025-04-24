import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';

class CreateKnowledgePopup extends StatefulWidget {
  /// callback để trả về object vừa tạo lên DataScreen
  final void Function(Map<String, dynamic> newKnowledge) onCreated;

  const CreateKnowledgePopup({Key? key, required this.onCreated})
      : super(key: key);

  @override
  State<CreateKnowledgePopup> createState() => _CreateKnowledgePopupState();
}

class _CreateKnowledgePopupState extends State<CreateKnowledgePopup> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSubmitting = false;
  String? _apiError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _apiError = null;
    });

    try {
      final api = ApiBase();
      final newKb = await api.createKnowledge(
        knowledgeName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );
      widget.onCreated(newKb);
      Navigator.of(context).pop();
    } catch (e) {
      // parse message from API
      try {
        final errStr = e.toString();
        final jsonStart = errStr.indexOf('{');
        if (jsonStart != -1) {
          final jsonPart = errStr.substring(jsonStart);
          final Map<String, dynamic> errJson = jsonDecode(jsonPart);
          if (errJson['details'] is List) {
            _apiError = (errJson['details'] as List)
                .map((d) => d['issue'] as String)
                .join('\n');
          } else if (errJson['message'] != null) {
            _apiError = errJson['message'] as String;
          }
        }
      } catch (_) {
        _apiError ??= 'Failed to create knowledge';
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(
        'Create a Knowledge Base',
        style: AppFontStyles.poppinsTextBold(fontSize: fontSize18),
      ),
      content: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_apiError != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _apiError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Knowledge Base Name *',
                  hintText: 'Enter a unique name for your knowledge base',
                ),
                maxLength: 50,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'This field is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText:
                      'Briefly describe the purpose of this knowledge base (e.g., Jarvis AI\'s knowledge base,...)',
                ),
                maxLines: 4,
                maxLength: 500,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'This field is required'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        GradientFormButton(
          text: 'Create',
          isActiveButton: !_isSubmitting,
          onPressed: () {
            if (!_isSubmitting) {
              _handleCreate();
            }
          },
        ),
      ],
    );
  }
}
