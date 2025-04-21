import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';

class KnowledgeInfoPopup extends StatefulWidget {
  final Map<String, dynamic> knowledge;

  /// callback khi xóa thành công (để cha remove khỏi list)
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

    // lấy id, fallback nếu key khác
    final idValue = widget.knowledge['id'];
    if (idValue == null || idValue is! String) {
      setState(() {
        _error = 'Invalid ID';
        _isDeleting = false;
      });
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    final k = widget.knowledge;
    return AlertDialog(
      scrollable: true,
      title: Text('Knowledge Details', style: AppFontStyles.poppinsTitleBold()),
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
          // Chỉ show 2 field: Name và Description
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
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
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
    );
  }
}
