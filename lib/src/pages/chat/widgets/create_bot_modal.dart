import 'package:dotted_border/dotted_border.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_knowledge_source_popup.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/widgets/input_form_field.dart';
import 'package:flutter/material.dart';

class CreateBotModal extends StatefulWidget {
  const CreateBotModal({super.key});

  @override
  State<CreateBotModal> createState() => _CreateBotModalState();
}

class _CreateBotModalState extends State<CreateBotModal> {
  List<String> _selectedPaths = [];
  List<Map<String, String>> _importedWebSources = [];

  void _pickSources() {
    SelectKnowledgeSourcePopup.build(
      context,
      onLocalFilesSelected: (paths) {
        setState(() => _selectedPaths = paths);
      },
      onWebSourceSelected: (name, url) {
        setState(() {
          _importedWebSources.add({'name': name, 'url': url});
        });
      },
    );
  }

  void _removeLocalPath(String path) {
    setState(() => _selectedPaths.remove(path));
  }

  void _removeWebSource(Map<String, String> source) {
    setState(() => _importedWebSources.remove(source));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: ColorConst.backgroundWhiteColor,
            borderRadius: BorderRadius.circular(radius12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(padding16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Your Own Bot',
                      style: AppFontStyles.poppinsTitleSemiBold(
                          fontSize: fontSize16),
                    ),
                    SizedBox(
                      width: spacing32,
                      height: spacing32,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          size: spacing20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: spacing24),

                // Name Field
                InputFormField.build(
                  'Name',
                  'Enter a name for your bot',
                  required: true,
                ),

                const SizedBox(height: spacing24),

                // Instructions Field
                InputFormField.build(
                  'Instructions (Optional)',
                  'Enter instructions for the bot',
                  maxLines: 6,
                ),

                const SizedBox(height: spacing16),

                // Knowledge base selection
                Text(
                  'Knowledge Base (Optional)',
                  style: AppFontStyles.poppinsTextBold(),
                ),
                const SizedBox(height: spacing8),
                DottedBorder(
                  borderType: BorderType.RRect,
                  dashPattern: [4, 2],
                  radius: Radius.circular(radius12),
                  child: InkWell(
                    onTap: _pickSources,
                    child: Container(
                      height: spacing32,
                      alignment: Alignment.center,
                      child: Text(
                        _selectedPaths.isEmpty && _importedWebSources.isEmpty
                            ? '+ Add sources'
                            :
                            // show summary count
                            '${_selectedPaths.length} file(s), ${_importedWebSources.length} web source(s) selected',
                        style: AppFontStyles.poppinsRegular(),
                      ),
                    ),
                  ),
                ),

                if (_selectedPaths.isNotEmpty) ...[
                  const SizedBox(height: spacing8),
                  Wrap(
                    spacing: spacing8,
                    children: _selectedPaths.map((p) {
                      final name = p.split('/').last;
                      return Chip(
                        label: Text(name, overflow: TextOverflow.ellipsis),
                        onDeleted: () => _removeLocalPath(p),
                      );
                    }).toList(),
                  ),
                ],

                if (_importedWebSources.isNotEmpty) ...[
                  const SizedBox(height: spacing8),
                  Wrap(
                    spacing: spacing8,
                    children: _importedWebSources.map((src) {
                      return InputChip(
                        label: Text(
                          src['name']!,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onDeleted: () => _removeWebSource(src),
                        avatar: Icon(Icons.link, size: spacing16),
                        onPressed: () {
                          // optionally handle tap to open URL
                        },
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: spacing24),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GradientFormButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isActiveButton: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: spacing12),
                      child: GradientFormButton(
                        text: 'Create',
                        onPressed: () {
                          // TODO: submit with _selectedPaths and _importedWebSources
                        },
                        isActiveButton: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
