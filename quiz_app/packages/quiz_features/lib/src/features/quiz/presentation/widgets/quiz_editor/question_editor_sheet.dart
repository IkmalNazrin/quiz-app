import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_features/quiz_features.dart';

class QuestionEditorSheet extends ConsumerStatefulWidget {
  final String? quizId;
  final int index;
  final QuestionEntity question;

  const QuestionEditorSheet({
    super.key,
    required this.quizId,
    required this.index,
    required this.question,
  });

  static Future<void> show(BuildContext context, String? quizId, int index,
      QuestionEntity question) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          QuestionEditorSheet(quizId: quizId, index: index, question: question),
    );
  }

  @override
  ConsumerState<QuestionEditorSheet> createState() =>
      _QuestionEditorSheetState();
}

class _QuestionEditorSheetState extends ConsumerState<QuestionEditorSheet> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late int _correctAnswerIndex;
  late String _difficulty;
  late double _timer;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.question);
    _optionControllers = widget.question.options
        .map((o) => TextEditingController(text: o))
        .toList();
    _correctAnswerIndex = widget.question.correctAnswerIndex;
    _difficulty = widget.question.difficulty;
    _timer = widget.question.timer.toDouble();
    _imageUrl = widget.question.imageUrl;
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await image.readAsBytes();
        final ext = image.name.split('.').last;
        final path = 'quiz_${widget.quizId ?? 'new'}/q_${widget.index}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        
        final storage = ref.read(storageServiceProvider);
        final publicUrl = await storage.uploadImage('quiz-assets', path, bytes);

        setState(() {
          _imageUrl = publicUrl;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _save() {
    final updated = QuestionEntity(
      question: _questionController.text,
      options: _optionControllers.map((c) => c.text).toList(),
      correctAnswerIndex: _correctAnswerIndex,
      difficulty: _difficulty,
      timer: _timer.round(),
      imageUrl: _imageUrl,
    );
    ref
        .read(quizEditorProvider(widget.quizId).notifier)
        .updateQuestion(widget.index, updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageHeader(),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Question ${widget.index + 1}',
                          style: AppTypography.h3),
                      if (_isUploading)
                        const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _questionController,
                    label: 'Question Content',
                    hintText: 'Ask something interesting...',
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Text('OPTIONS (Select the correct one)',
                      style: AppTypography.label
                          .copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.md),
                  ...List.generate(
                      _optionControllers.length, (i) => _buildOptionField(i)),
                  SizedBox(height: AppSpacing.xl),
                  _buildSettingsRow(),
                  SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: 'Save Question',
                    type: AppButtonType.premium,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return GestureDetector(
      onTap: _pickImage,
      child: AppCard(
        height: 180,
        width: double.infinity,
        color: AppColors.background.withValues(alpha: 0.5),
        showBorder: true,
        padding: EdgeInsets.zero,
        child: _imageUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: CircleAvatar(
                      backgroundColor: Colors.black38,
                      child: IconButton(
                        icon: Icon(Icons.edit_rounded,
                            color: Colors.white, size: 18),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              )
            : _buildImagePlaceholder(),
      ),
    ).animate().fadeIn();
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_rounded,
            size: 48, color: AppColors.primary),
        SizedBox(height: AppSpacing.sm),
        Text('Add Header Image',
            style: AppTypography.label.copyWith(color: AppColors.primary)),
        Text('Boosts quiz strength by 20%',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }

  Widget _buildOptionField(int index) {
    final isCorrect = _correctAnswerIndex == index;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: AppTextField(
        controller: _optionControllers[index],
        hintText: 'Option ${index + 1}',
        maxLength: 80,
        prefixIcon: Radio<int>(
          value: index,
          // ignore: deprecated_member_use
          groupValue: _correctAnswerIndex,
          // ignore: deprecated_member_use
          onChanged: (v) => setState(() => _correctAnswerIndex = v!),
          fillColor: WidgetStateProperty.all(AppColors.success),
        ),
        suffixIcon: isCorrect
            ? Icon(Icons.check_circle, color: AppColors.success)
            : null,
      ),
    );
  }

  Widget _buildSettingsRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Difficulty',
                  style: AppTypography.label
                      .copyWith(color: AppColors.textSecondary)),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                items: ['Easy', 'Medium', 'Hard']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _difficulty = v!),
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Timer: ${_timer.round()}s',
                  style: AppTypography.label
                      .copyWith(color: AppColors.textSecondary)),
              Slider(
                value: _timer,
                min: 5,
                max: 60,
                divisions: 11,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withValues(alpha: 0.1),
                onChanged: (v) => setState(() => _timer = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
