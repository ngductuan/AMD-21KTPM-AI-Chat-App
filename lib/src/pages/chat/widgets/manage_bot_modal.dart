import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_knowledge_source_popup.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/widgets/input_form_field.dart';
import 'package:flutter/material.dart';

class ManageBotModal extends StatefulWidget {
  final dynamic botData;
  final Function endCallback;
  final String activeButtonText;

  const ManageBotModal({
    super.key,
    this.botData,
    required this.endCallback,
    required this.activeButtonText,
  });

  @override
  State<ManageBotModal> createState() => _ManageBotModalState();
}

class _ManageBotModalState extends State<ManageBotModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _instructionController;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;
  bool _isSubmit = false;
  String botSelectedId = '';

  @override
  void initState() {
    super.initState();

    // Initialize with empty strings as fallback
    String name = '';
    String instructions = '';
    String description = '';

    // Safely extract values if botData exists and is a Map
    if (widget.botData != null) {
      final Map<String, dynamic> jsonResponse = json.decode(widget.botData);

      botSelectedId = jsonResponse['id']?.toString() ?? '';

      name = jsonResponse['assistantName']?.toString() ?? '';
      instructions = jsonResponse['instructions']?.toString() ?? '';
      description = jsonResponse['description']?.toString() ?? '';
    }

    _nameController = TextEditingController(text: name);
    _instructionController = TextEditingController(text: instructions);
    _descriptionController = TextEditingController(text: description);
  }

  void clearTextFields() {
    _nameController.clear();
    _instructionController.clear();
    _descriptionController.clear();
  }

  // Hàm hiển thị thông báo thành công
  void exitWindow() {
    if (mounted && Navigator.of(context).canPop()) {
      clearTextFields();
      Navigator.pop(context);
    }
  }

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
                      '${widget.activeButtonText} Your Own Bot',
                      style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize16),
                    ),
                    SizedBox(
                      width: spacing32,
                      height: spacing32,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          size: spacing20,
                        ),
                        onPressed: () => exitWindow(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: spacing24),

                // Name Field
                SizedBox(
                  height: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InputFormField.build('Name', 'Enter a name for your bot',
                            required: true, controller: _nameController, isSubmit: _isSubmit),

                        SizedBox(height: spacing24),

                        // Instructions Field
                        InputFormField.build('Instructions (Optional)', 'Enter instructions for the bot',
                            controller: _instructionController, maxLines: 6),

                        SizedBox(height: spacing24),

                        // Knowledge Base Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Knowledge base (Optional)', style: AppFontStyles.poppinsTextBold()),
                            SizedBox(height: spacing4),
                            Text(
                              'Enhance your bot’s responses by adding custom knowledge',
                              style:
                                  AppFontStyles.poppinsRegular(fontSize: fontSize14, color: ColorConst.textGrayColor),
                            ),
                            SizedBox(height: spacing20),
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
                                        ? '+ Add knowledge source'
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
                          ],
                        ),

                        SizedBox(height: spacing4),

                        ExpansionTile(
                          title: Text('Advanced Options', style: AppFontStyles.poppinsTextBold()),
                          shape: Border(), // Removes the top divider
                          tilePadding: EdgeInsets.all(0),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: InputFormField.build('Description (Optional)',
                                  'Enter a description for your bot (e.g \'A helpful customer support assistant\')',
                                  controller: _descriptionController, maxLines: 6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: spacing16),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GradientFormButton(
                      text: 'Cancel',
                      onPressed: () => exitWindow(),
                      isActiveButton: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: spacing12),
                      child: GradientFormButton(
                        isLoading: _isLoading,
                        text: widget.activeButtonText,
                        onPressed: () async {
                          setState(() {
                            _isSubmit = true;
                          });

                          if (_nameController.text.isEmpty) {
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });

                          await widget.endCallback({
                            'assistantName': _nameController.text,
                            'description': _descriptionController.text,
                            'instructions': _instructionController.text,
                          }, exitWindow);

                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
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
