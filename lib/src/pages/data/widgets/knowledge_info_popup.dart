import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/pages/data/widgets/knowledge_source_options_popup.dart';

class KnowledgeInfoPopup extends StatefulWidget {
  final Map<String, dynamic> knowledge;
  final VoidCallback onDeleted;

  const KnowledgeInfoPopup({
    Key? key,
    required this.knowledge,
    required this.onDeleted,
  }) : super(key: key);

  @override
  State<KnowledgeInfoPopup> createState() => _KnowledgeInfoPopupState();
}

class _KnowledgeInfoPopupState extends State<KnowledgeInfoPopup> {
  bool _isDeleting = false;
  String? _error;

  Future<void> _handleDelete() async {
    setState(() {
      _isDeleting = true;
      _error = null;
    });

    final idValue = widget.knowledge['id'];
    if (idValue == null || idValue is! String) {
      setState(() {
        _error = 'Invalid ID';
        _isDeleting = false;
      });
      return;
    }

    try {
      final api = ApiBase();
      final success = await api.deleteKnowledge(idValue);
      if (success) {
        widget.onDeleted();
        Navigator.of(context).pop();
      } else {
        setState(() => _error = 'Could not delete this item.');
      }
    } catch (e) {
      setState(() => _error = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _handleAddSource() {
    KnowledgeSourceOptionsPopup.build(
      context,
      knowledgeId: widget.knowledge['id'] as String,
      onLocalFileSelected: (knowledgeId, paths) {
        for (final path in paths) {
          ApiBase()
              .uploadKnowledgeLocalFile(
            knowledgeId: knowledgeId,
            filePath: path,
          )
              .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Upload successful!")),
            );
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${e.toString()}")),
            );
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.knowledge;
    final createdAt = DateTime.tryParse(data['createdAt'] ?? '');
    final updatedAt = DateTime.tryParse(data['updatedAt'] ?? '');
    final createdStr =
        createdAt != null ? DateFormat('yyyy-MM-dd').format(createdAt) : '-';
    final updatedStr =
        updatedAt != null ? DateFormat('yyyy-MM-dd').format(updatedAt) : '-';

    Widget buildItem(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppFontStyles.poppinsTextBold(fontSize: 14)),
            const SizedBox(height: 2),
            Text(value, style: AppFontStyles.poppinsRegular(fontSize: 12)),
          ],
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.info_outline,
              size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text('Knowledge Details',
              style: AppFontStyles.poppinsTitleBold(fontSize: 16)),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 380, maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Text(_error!,
                    style: TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 8),
              ],
              buildItem('Name', data['knowledgeName'] as String? ?? '-'),
              buildItem('Description', data['description'] as String? ?? '-'),
              Row(
                children: [
                  Expanded(child: buildItem('Created Date', createdStr)),
                  const SizedBox(width: 16),
                  Expanded(child: buildItem('Updated Date', updatedStr)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: buildItem(
                          'Units', data['numUnits']?.toString() ?? '0')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: buildItem(
                          'Total Size', data['totalSize']?.toString() ?? '0')),
                ],
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleAddSource,
            child: const Text('Add Source', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isDeleting ? null : _handleDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : const Text('Delete', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }
}
