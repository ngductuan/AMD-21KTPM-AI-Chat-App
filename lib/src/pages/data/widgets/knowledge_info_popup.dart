import 'package:flutter/material.dart';
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
        setState(() => _error = 'Cannot delete this knowledge.');
      }
    } catch (e) {
      setState(() => _error = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _handleAddSource() {
    // Open the select source popup
    KnowledgeSourceOptionsPopup.build(
      context,
      knowledgeId: widget.knowledge['id'] as String, // ← truyền vào đây
      onLocalFileSelected: (knowledgeId, paths) {
        // paths là List<String> đường dẫn đến file
        // gọi API upload từng file
        for (final p in paths) {
          ApiBase()
              .uploadKnowledgeLocalFile(
            knowledgeId: knowledgeId,
            filePath: p,
          )
              .then((resp) {
            // xử lý thành công, có thể show toast
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Upload thành công!")),
            );
          }).catchError((e) {
            // xử lý lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi: ${e.toString()}")),
            );
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.knowledge;
    return AlertDialog(
      scrollable: true,
      title: Text(
        'Knowledge Details',
        style: AppFontStyles.poppinsTitleBold(),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Text(
            k['knowledgeName'] as String? ?? '-',
            style: AppFontStyles.poppinsTextBold(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            k['description'] as String? ?? '-',
            style: AppFontStyles.poppinsRegular(),
          ),
        ],
      ),
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: padding16, vertical: spacing8),
      actions: [
        // Add knowledge source button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleAddSource,
            icon: const Icon(Icons.add),
            label: const Text('Add knowledge source'),
          ),
        ),

        // Cancel and Delete button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            const SizedBox(width: spacing12),
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
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}
