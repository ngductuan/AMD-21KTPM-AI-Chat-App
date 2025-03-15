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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: spacing24),

                // Name Field
                InputFormField.build('Name', 'Enter a name for your bot', required: true),

                SizedBox(height: spacing24),

                // Instructions Field
                InputFormField.build('Instructions (Optional)', 'Enter instructions for the bot', maxLines: 6),

                SizedBox(height: spacing24),

                // Knowledge Base Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Knowledge base (Optional)', style: AppFontStyles.poppinsTextBold()),
                    SizedBox(height: spacing4),
                    Text(
                      'Enhance your bot’s responses by adding custom knowledge',
                      style: AppFontStyles.poppinsRegular(fontSize: fontSize14, color: ColorConst.textGrayColor),
                    ),
                    SizedBox(height: spacing20),
                    Center(
                      child: DottedBorder(
                        strokeWidth: 1,
                        dashPattern: [4, 2], // Dashed pattern
                        borderType: BorderType.RRect, // Rounded rectangle
                        radius: Radius.circular(radius12), // Border radius
                        color: ColorConst.textHighlightColor,
                        child: SizedBox(
                          width: double.infinity,
                          height: spacing32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              overlayColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(radius12),
                              ),
                            ),
                            onPressed: () {
                              // Open the SelectKnowledgeSourcePopup
                              SelectKnowledgeSourcePopup.build(context);
                            },
                            child: Text(
                              "+ Add knowledge source",
                              style: AppFontStyles.poppinsTextBold(),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(height: spacing60),

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
                        onPressed: () {},
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
