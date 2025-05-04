import 'package:dotted_border/dotted_border.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
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
  String? _error; // lỗi chung (delete)

  // --- phần units ---
  bool _isLoadingUnits = true;
  String? _errorUnits;
  List<Map<String, dynamic>> _units = [];

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    // Khởi tạo loading state
    setState(() {
      _isLoadingUnits = true;
      _errorUnits = null;
    });

    final idValue = widget.knowledge['id'] as String?;
    if (idValue == null) {
      setState(() {
        _errorUnits = 'Invalid knowledge ID';
        _isLoadingUnits = false;
      });
      return;
    }

    try {
      final api = ApiBase();
      final resp = await api.getKnowledgeUnits(
        knowledgeId: idValue,
        q: '',
        order: 'DESC',
        orderField: 'createdAt',
        offset: 0,
        limit: 20,
      );
      final data = resp['data'] as List<dynamic>;
      final units = data.map((e) {
        return {
          'id': e['id'],
          'name': e['name'],
          'createdAt': e['createdAt'],
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _units = units;
        _isLoadingUnits = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorUnits = 'Failed to load units: $e';
        _isLoadingUnits = false;
      });
    }
  }

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
        setState(() {
          _error = 'Could not delete this item.';
          _isDeleting = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = 'Error: $e';
          _isDeleting = false;
        });
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
            // reload units
            _fetchUnits();
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
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
            Text(label, style: AppFontStyles.poppinsTextBold()),
            const SizedBox(height: 2),
            Text(value, style: AppFontStyles.poppinsRegular(fontSize: 12)),
          ],
        ),
      );
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: spacing8),
      backgroundColor: ColorConst.backgroundWhiteColor,
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
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lỗi delete (nếu có)
              if (_error != null) ...[
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 8),
              ],

              // Thông tin cơ bản
              buildItem('Name', data['knowledgeName'] as String? ?? '-'),
              buildItem('Description', data['description'] as String? ?? '-'),
              Row(
                children: [
                  Expanded(child: buildItem('Created Date', createdStr)),
                  const SizedBox(width: 16),
                  Expanded(child: buildItem('Updated Date', updatedStr)),
                ],
              ),
              const Divider(height: 24),

              // Phần Units
              Text('Units', style: AppFontStyles.poppinsTextBold(fontSize: 14)),
              const SizedBox(height: 8),

              if (_isLoadingUnits)
                const Center(child: CircularProgressIndicator())
              else if (_errorUnits != null)
                Text(_errorUnits!,
                    style: const TextStyle(color: Colors.red, fontSize: 12))
              else if (_units.isEmpty)
                Text('No units found.',
                    style: AppFontStyles.poppinsRegular(fontSize: 12))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _units.map((unit) {
                    final dt = DateTime.tryParse(unit['createdAt'] ?? '');
                    final dtStr =
                        dt != null ? DateFormat('yyyy-MM-dd').format(dt) : '-';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(unit['name'] ?? '-',
                                style: AppFontStyles.poppinsRegular()),
                          ),
                          Text('Created: $dtStr',
                              style:
                                  AppFontStyles.poppinsTextBold(fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const Divider(height: 24),

              // Hết phần Units
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        SizedBox(
          width: double.infinity,
          child: DottedBorder(
            color: ColorConst.textHighlightColor,
            borderType: BorderType.RRect,
            dashPattern: [4, 2],
            radius: Radius.circular(radius12),
            child: InkWell(
              onTap: _handleAddSource,
              child: Container(
                height: spacing32,
                alignment: Alignment.center,
                child: Text(
                  '+ Add knowledge source',
                  style: AppFontStyles.poppinsRegular(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: spacing48),
        Padding(
          padding: const EdgeInsets.only(bottom: spacing8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GradientFormButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
                isActiveButton: false,
              ),
              Padding(
                padding: const EdgeInsets.only(left: spacing12),
                child: GradientFormButton(
                  isLoading: _isDeleting,
                  text: 'Delete',
                  onPressed: () async => _isDeleting ? null : _handleDelete(),
                  isActiveButton: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
