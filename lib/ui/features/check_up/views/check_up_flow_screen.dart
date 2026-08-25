import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/services/check_up_pdf_service.dart';
import '../../../../data/services/gemini_analysis_service.dart';
import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/check_up_analysis.dart';
import '../../../../domain/models/ultrasound_attachment.dart';
import '../view_models/check_up_view_model.dart';

class HerAlthColors {
  static const background = Color(0xFFFCF5F5);
  static const card = Colors.white;
  static const ink = Color(0xFF2C2C2C);
  static const muted = Color(0xFF6E6E6E);
  static const secondary = Color(0xFF8E8E8E);
  static const rose = Color(0xFF9E385A);
  static const pink = Color(0xFFE88A8A);
  static const palePink = Color(0xFFFCF0F0);
  static const disclaimer = Color(0xFFFCF0F0);
  static const softBorder = Color(0xFFE5D9D9);
  static const divider = Color(0xFFF2ECEC);
  static const upload = Color(0xFFF2ECEC);
  static const disabled = Color(0xFFE5D9D9);
}

class HerAlthTextStyles {
  static const brand = TextStyle(
    fontFamily: 'serif',
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: HerAlthColors.rose,
  );
  static const hero = TextStyle(
    fontFamily: 'serif',
    fontSize: 32,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: HerAlthColors.ink,
  );
  static const pageTitle = TextStyle(
    fontFamily: 'serif',
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: HerAlthColors.ink,
  );
  static const body = TextStyle(
    fontSize: 15,
    height: 1.5,
    color: HerAlthColors.muted,
  );
  static const small = TextStyle(
    fontSize: 12,
    height: 1.35,
    color: HerAlthColors.muted,
  );
  static const cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: HerAlthColors.ink,
  );
  static const cardBody = TextStyle(
    fontSize: 13,
    height: 1.3,
    color: HerAlthColors.muted,
  );
  static const stepNumber = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: HerAlthColors.rose,
  );
  static const disclaimer = TextStyle(
    fontSize: 12,
    height: 1.45,
    color: HerAlthColors.muted,
  );
  static const section = TextStyle(
    fontSize: 12,
    letterSpacing: 1.2,
    fontWeight: FontWeight.bold,
    color: HerAlthColors.secondary,
  );
}

class HerAlthShadows {
  static const soft = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}

class HerAlthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  const HerAlthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: leading ?? const SizedBox.shrink(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? HerAlthColors.disabled
              : HerAlthColors.rose,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class HerAlthDisclaimerBanner extends StatelessWidget {
  const HerAlthDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: HerAlthColors.disclaimer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: HerAlthColors.rose),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'HerAlth does not diagnose. Results are informational and should be reviewed with a healthcare professional.',
              style: HerAlthTextStyles.disclaimer,
            ),
          ),
        ],
      ),
    );
  }
}

class FlowHeader extends StatelessWidget {
  final int step;
  final VoidCallback onBack;

  const FlowHeader({super.key, required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 43,
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: HerAlthColors.ink,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              const Spacer(),
              Text('STEP $step OF 3', style: HerAlthTextStyles.section),
              const Spacer(),
              const SizedBox(width: 32),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: step / 3,
          minHeight: 3,
          backgroundColor: HerAlthColors.disabled,
          valueColor: const AlwaysStoppedAnimation(HerAlthColors.rose),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class FlowScaffold extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  final Widget child;
  final Widget? bottom;

  const FlowScaffold({
    super.key,
    required this.step,
    required this.onBack,
    required this.child,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerAlthColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: FlowHeader(step: step, onBack: onBack),
                ),
                Expanded(child: child),
                if (bottom != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                    child: bottom,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _physicalSymptoms = [
  'Cramps',
  'Headache',
  'Acne',
  'Hair loss',
  'Fatigue',
  'Bloating',
  'Back pain',
  'Breast tenderness',
  'Stomach pain',
  'Vaginal itching',
  'Irregular bleeding',
  'Weight change',
];

const _moodSymptoms = [
  'Anxious',
  'Low mood',
  'Irritable',
  'Insomnia',
  'Brain fog',
  'Low libido',
];

class SymptomSelectionScreen extends StatefulWidget {
  final CheckUpViewModel viewModel;

  const SymptomSelectionScreen({super.key, required this.viewModel});

  @override
  State<SymptomSelectionScreen> createState() => _SymptomSelectionScreenState();
}

class _SymptomSelectionScreenState extends State<SymptomSelectionScreen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.viewModel.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return FlowScaffold(
          step: 1,
          onBack: () => Navigator.pop(context),
          bottom: HerAlthPrimaryButton(
            label: 'Continue',
            onPressed: widget.viewModel.selectedSymptoms.isEmpty
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/ultrasound'),
                      builder: (_) =>
                          UltrasoundUploadScreen(viewModel: widget.viewModel),
                    ),
                  ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What are you noticing?',
                  style: HerAlthTextStyles.pageTitle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select all that apply',
                  style: HerAlthTextStyles.body,
                ),
                const SizedBox(height: 28),
                _SymptomGroup(
                  title: 'PHYSICAL',
                  symptoms: _physicalSymptoms,
                  selected: widget.viewModel.selectedSymptoms,
                  onToggle: widget.viewModel.toggleSymptom,
                ),
                const SizedBox(height: 28),
                _SymptomGroup(
                  title: 'MOOD & SLEEP',
                  symptoms: _moodSymptoms,
                  selected: widget.viewModel.selectedSymptoms,
                  onToggle: widget.viewModel.toggleSymptom,
                ),
                const SizedBox(height: 17),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TextField(
                      controller: _notesController,
                      maxLength: 200,
                      maxLines: 4,
                      onChanged: widget.viewModel.setNotes,
                      decoration: InputDecoration(
                        hintText: 'Anything else? (optional)',
                        hintStyle: const TextStyle(
                          color: HerAlthColors.secondary,
                          fontSize: 15,
                        ),
                        counterText: '',
                        filled: true,
                        fillColor: HerAlthColors.card,
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          18,
                          16,
                          26,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 10,
                      child: Text(
                        '${widget.viewModel.notes.length} / 200',
                        style: HerAlthTextStyles.small.copyWith(
                          color: HerAlthColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.viewModel.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _InlineError(message: widget.viewModel.errorMessage!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SymptomGroup extends StatelessWidget {
  final String title;
  final List<String> symptoms;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _SymptomGroup({
    required this.title,
    required this.symptoms,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: HerAlthTextStyles.section),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptoms
              .map(
                (symptom) => _SymptomChip(
                  label: symptom,
                  selected: selected.contains(symptom),
                  onTap: () => onToggle(symptom),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SymptomChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SymptomChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? HerAlthColors.rose : HerAlthColors.palePink,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            selected ? '✓ $label' : label,
            style: TextStyle(
              fontSize: 14,
              color: selected ? Colors.white : HerAlthColors.ink,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class UltrasoundUploadScreen extends StatefulWidget {
  final CheckUpViewModel viewModel;

  const UltrasoundUploadScreen({super.key, required this.viewModel});

  @override
  State<UltrasoundUploadScreen> createState() => _UltrasoundUploadScreenState();
}

class _UltrasoundUploadScreenState extends State<UltrasoundUploadScreen> {
  final _imagePicker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      final file = result?.files.single;
      if (file == null || file.bytes == null) return;
      await widget.viewModel.setUltrasound(
        fileName: file.name,
        bytes: file.bytes!,
      );
    } catch (_) {
      widget.viewModel.clearError();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('We could not open that file. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickCamera() async {
    setState(() => _isPicking = true);
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      await widget.viewModel.setUltrasound(
        fileName: image.name.isEmpty ? 'ultrasound_camera.jpg' : image.name,
        bytes: await image.readAsBytes(),
      );
    } catch (_) {
      widget.viewModel.clearError();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera access was cancelled or unavailable.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickGallery() async {
    setState(() => _isPicking = true);
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      await widget.viewModel.setUltrasound(
        fileName: image.name.isEmpty ? 'ultrasound_gallery.jpg' : image.name,
        bytes: await image.readAsBytes(),
      );
    } catch (_) {
      widget.viewModel.clearError();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gallery access was cancelled or unavailable.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return FlowScaffold(
          step: 2,
          onBack: () => Navigator.pop(context),
          bottom: Column(
            children: [
              HerAlthPrimaryButton(
                label: _isPicking ? 'Checking file...' : 'Continue',
                onPressed: _isPicking
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/review'),
                          builder: (_) =>
                              ReviewAnalysisScreen(viewModel: widget.viewModel),
                        ),
                      ),
              ),
              TextButton(
                onPressed: _isPicking
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/review'),
                          builder: (_) =>
                              ReviewAnalysisScreen(viewModel: widget.viewModel),
                        ),
                      ),
                child: const Text(
                  'Skip this step',
                  style: TextStyle(color: HerAlthColors.ink),
                ),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have an ultrasound?',
                  style: HerAlthTextStyles.pageTitle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Optional. It helps HerAlth give richer context.',
                  style: HerAlthTextStyles.body,
                ),
                const SizedBox(height: 28),
                InkWell(
                  onTap: _isPicking ? null : _pickFile,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: double.infinity,
                    height: 238,
                    decoration: BoxDecoration(
                      color: HerAlthColors.upload,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: _isPicking
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: HerAlthColors.rose,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: HerAlthColors.palePink,
                                child: Icon(
                                  Icons.file_upload_outlined,
                                  size: 34,
                                  color: HerAlthColors.rose,
                                ),
                              ),
                              SizedBox(height: 17),
                              Text(
                                'Drop or select a file',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: HerAlthColors.ink,
                                ),
                              ),
                              SizedBox(height: 7),
                              Text(
                                'JPG, PNG or PDF · max 10 MB',
                                style: HerAlthTextStyles.small,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineAction(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: _isPicking ? null : _pickCamera,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _OutlineAction(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: _isPicking ? null : _pickGallery,
                      ),
                    ),
                  ],
                ),
                if (widget.viewModel.ultrasound != null) ...[
                  const SizedBox(height: 22),
                  _AttachmentCard(
                    attachment: widget.viewModel.ultrasound!,
                    onRemove: widget.viewModel.removeUltrasound,
                  ),
                ],
                if (widget.viewModel.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _InlineError(message: widget.viewModel.errorMessage!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: HerAlthColors.ink,
        minimumSize: const Size.fromHeight(55),
        side: const BorderSide(color: HerAlthColors.softBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final UltrasoundAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentCard({required this.attachment, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: attachment.isPdf
                      ? const ColoredBox(
                          color: HerAlthColors.palePink,
                          child: Icon(
                            Icons.picture_as_pdf_outlined,
                            color: HerAlthColors.rose,
                          ),
                        )
                      : Image.memory(attachment.bytes, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attachment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatBytes(attachment.sizeBytes)} · uploaded ✓',
                      style: const TextStyle(
                        color: Color(0xFF6AA586),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                color: HerAlthColors.ink,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: const LinearProgressIndicator(
              value: 1,
              minHeight: 4,
              backgroundColor: HerAlthColors.palePink,
              valueColor: AlwaysStoppedAnimation(HerAlthColors.rose),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class ReviewAnalysisScreen extends StatefulWidget {
  final CheckUpViewModel viewModel;

  const ReviewAnalysisScreen({super.key, required this.viewModel});

  @override
  State<ReviewAnalysisScreen> createState() => _ReviewAnalysisScreenState();
}

class _ReviewAnalysisScreenState extends State<ReviewAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadCycleContext();
  }

  Future<void> _analyze() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/processing'),
        builder: (_) => AnalysisProcessingScreen(viewModel: widget.viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final cycle = widget.viewModel.cycleContext;
        return FlowScaffold(
          step: 3,
          onBack: () => Navigator.pop(context),
          bottom: Column(
            children: [
              const HerAlthDisclaimerBanner(),
              const SizedBox(height: 14),
              HerAlthPrimaryButton(
                label: '✦  Analyze',
                onPressed: widget.viewModel.isAnalyzing ? null : _analyze,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to analyze',
                  style: HerAlthTextStyles.pageTitle,
                ),
                const SizedBox(height: 26),
                _ReviewCard(
                  title: 'SYMPTOMS',
                  onEdit: () => Navigator.popUntil(
                    context,
                    (route) =>
                        route.settings.name == '/symptoms' || route.isFirst,
                  ),
                  footer:
                      '${widget.viewModel.selectedSymptoms.length} selected',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.viewModel.selectedSymptoms
                        .map((symptom) => _ReviewPill(label: symptom))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 26),
                _ReviewCard(
                  title: 'CYCLE CONTEXT',
                  onEdit: () => _showCycleInfo(context),
                  child: Column(
                    children: [
                      _ReviewRow(
                        label: 'Cycle day',
                        value: '${cycle.cycleDay}',
                      ),
                      _ReviewRow(label: 'Phase', value: cycle.phase),
                      _ReviewRow(
                        label: 'Avg cycle',
                        value: '${cycle.averageCycleLength} days',
                      ),
                      _ReviewRow(
                        label: 'Last period',
                        value: cycle.lastPeriod == null
                            ? 'Not logged'
                            : _formatDate(cycle.lastPeriod!),
                      ),
                      _ReviewRow(
                        label: 'Regularity',
                        value: cycle.regularity,
                        last: true,
                      ),
                    ],
                  ),
                ),
                if (widget.viewModel.ultrasound != null) ...[
                  const SizedBox(height: 26),
                  _ReviewAttachment(attachment: widget.viewModel.ultrasound!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCycleInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cycle context comes from your private HerAlth logs.'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final Widget child;
  final String? footer;

  const _ReviewCard({
    required this.title,
    required this.onEdit,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 17),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: HerAlthTextStyles.section),
              const Spacer(),
              TextButton(
                onPressed: onEdit,
                child: const Text(
                  'EDIT',
                  style: TextStyle(fontSize: 11, color: HerAlthColors.rose),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
          if (footer != null) ...[
            const SizedBox(height: 12),
            Text(footer!, style: HerAlthTextStyles.small),
          ],
        ],
      ),
    );
  }
}

class _ReviewPill extends StatelessWidget {
  final String label;

  const _ReviewPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: HerAlthColors.palePink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: HerAlthColors.ink),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: HerAlthColors.divider)),
      ),
      child: Row(
        children: [
          Text(label, style: HerAlthTextStyles.body.copyWith(fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: HerAlthColors.ink),
          ),
        ],
      ),
    );
  }
}

class _ReviewAttachment extends StatelessWidget {
  final UltrasoundAttachment attachment;

  const _ReviewAttachment({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Row(
        children: [
          Icon(
            attachment.isPdf
                ? Icons.picture_as_pdf_outlined
                : Icons.description_outlined,
            color: HerAlthColors.muted,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: HerAlthColors.ink),
            ),
          ),
          const Text(
            'EDIT',
            style: TextStyle(fontSize: 11, color: HerAlthColors.rose),
          ),
        ],
      ),
    );
  }
}

class AnalysisProcessingScreen extends StatefulWidget {
  final CheckUpViewModel viewModel;

  const AnalysisProcessingScreen({super.key, required this.viewModel});

  @override
  State<AnalysisProcessingScreen> createState() =>
      _AnalysisProcessingScreenState();
}

class _AnalysisProcessingScreenState extends State<AnalysisProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    Future<void>.microtask(_runAnalysis);
  }

  Future<void> _runAnalysis() async {
    try {
      final analysis = await widget.viewModel.analyzeCurrentCheckUp();
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultsScreen(
            viewModel: widget.viewModel,
            analysis: analysis,
          ),
        ),
      );
    } on CheckUpValidationException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on GeminiAnalysisException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              widget.viewModel.errorMessage ??
              'Something went wrong while analyzing. Please try again.',
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerAlthColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const Spacer(),
                _AnalysisOrb(animation: _controller),
                if (_error != null) ...[
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _InlineError(message: _error!),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _runAnalysis,
                    child: const Text(
                      'Try again',
                      style: TextStyle(color: HerAlthColors.rose),
                    ),
                  ),
                ],
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 26),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 13,
                        color: HerAlthColors.secondary,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'You will get a notification when analysis finishes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: HerAlthColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisOrb extends StatelessWidget {
  final Animation<double> animation;

  const _AnalysisOrb({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return SizedBox(
          width: 290,
          height: 290,
          child: CustomPaint(
            painter: AnalysisOrbPainter(progress: animation.value),
            child: const Center(
              child: Text('Analyzing...', style: HerAlthTextStyles.pageTitle),
            ),
          ),
        );
      },
    );
  }
}

class AnalysisOrbPainter extends CustomPainter {
  final double progress;

  const AnalysisOrbPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = Paint()
      ..color = const Color(0x66E88A8A)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final inner = Paint()
      ..color = HerAlthColors.pink
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final pink = Paint()
      ..color = HerAlthColors.pink
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 140, outer);
    canvas.drawCircle(center, 102, inner);
    canvas.drawCircle(
      center,
      56,
      Paint()
        ..color = HerAlthColors.palePink
        ..style = PaintingStyle.fill,
    );
    final point = Offset(
      center.dx + 140 * math.cos(progress * 6.283),
      center.dy + 140 * math.sin(progress * 6.283),
    );
    canvas.drawCircle(point, 3, pink);
    final line = Paint()
      ..color = HerAlthColors.pink.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx - 90, center.dy + 31),
      Offset(center.dx + 90, center.dy + 31),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant AnalysisOrbPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class AnalysisResultsScreen extends StatefulWidget {
  final CheckUpViewModel? viewModel;
  final CheckUpAnalysis analysis;
  final CycleContextSnapshot? cycleContext;
  final CheckUp? checkUp;
  final bool closeToRoot;
  final CheckUpReportExporter? reportExporter;

  const AnalysisResultsScreen({
    super.key,
    this.viewModel,
    required this.analysis,
    this.cycleContext,
    this.checkUp,
    this.closeToRoot = true,
    this.reportExporter,
  });

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  late final CheckUpReportExporter _reportExporter;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _reportExporter = widget.reportExporter ?? DeviceCheckUpReportExporter();
  }

  @override
  Widget build(BuildContext context) {
    final cycle =
        widget.cycleContext ??
        widget.viewModel?.cycleContext ??
        const CycleContextSnapshot.defaults();
    return Scaffold(
      backgroundColor: HerAlthColors.background,
      appBar: AppBar(
        backgroundColor: HerAlthColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            if (widget.closeToRoot) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.close_rounded),
          color: HerAlthColors.ink,
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: _isExporting ? null : () => _sharePdf(cycle),
            icon: const Icon(Icons.ios_share_outlined),
            color: HerAlthColors.ink,
          ),
          IconButton(
            tooltip: 'Download',
            onPressed: _isExporting ? null : () => _downloadPdf(cycle),
            icon: const Icon(Icons.download_outlined),
            color: HerAlthColors.ink,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResultSummary(analysis: widget.analysis),
                  const SizedBox(height: 28),
                  const Text(
                    'WHAT HERALTH OBSERVED',
                    style: HerAlthTextStyles.section,
                  ),
                  const SizedBox(height: 15),
                  _ObservedCard(signals: widget.analysis.observedSignals),
                  const SizedBox(height: 28),
                  const Text(
                    'POSSIBLE EXPLANATIONS',
                    style: HerAlthTextStyles.section,
                  ),
                  const SizedBox(height: 15),
                  ...widget.analysis.possibleExplanations.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ExplanationCard(explanation: item),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'YOUR CYCLE CONTEXT',
                    style: HerAlthTextStyles.section,
                  ),
                  const SizedBox(height: 15),
                  _CycleChart(cycle: cycle),
                  const SizedBox(height: 22),
                  const HerAlthDisclaimerBanner(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  CheckUpReportData _reportData(CycleContextSnapshot cycle) {
    return CheckUpReportData(
      analysis: widget.analysis,
      cycleContext: cycle,
      checkUp: widget.checkUp ?? widget.viewModel?.lastAnalyzedCheckUp,
    );
  }

  Future<void> _sharePdf(CycleContextSnapshot cycle) async {
    setState(() => _isExporting = true);
    try {
      await _reportExporter.share(_reportData(cycle));
    } on Exception {
      if (!mounted) return;
      _showMessage('Unable to share the PDF. Please try again.');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _downloadPdf(CycleContextSnapshot cycle) async {
    setState(() => _isExporting = true);
    try {
      final path = await _reportExporter.download(_reportData(cycle));
      if (!mounted || path == null) return;
      _showMessage('PDF saved to $path');
    } on Exception {
      if (!mounted) return;
      _showMessage('Unable to save the PDF. Please try again.');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ResultSummary extends StatelessWidget {
  final CheckUpAnalysis analysis;

  const _ResultSummary({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFFFF3DF),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE79C35),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                analysis.attention.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  color: Color(0xFFE49A35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            analysis.headline,
            style: HerAlthTextStyles.pageTitle.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            analysis.summary,
            style: HerAlthTextStyles.body.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 22),
          const Divider(color: HerAlthColors.divider),
          const SizedBox(height: 18),
          Text(
            'Signal strength · ${analysis.signalStrength}',
            style: HerAlthTextStyles.small.copyWith(color: HerAlthColors.ink),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: analysis.signalPercent / 100,
              minHeight: 4,
              backgroundColor: HerAlthColors.softBorder,
              valueColor: const AlwaysStoppedAnimation(HerAlthColors.rose),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObservedCard extends StatelessWidget {
  final List<ObservedSignal> signals;

  const _ObservedCard({required this.signals});

  @override
  Widget build(BuildContext context) {
    final items = signals.isEmpty
        ? const [
            ObservedSignal(
              title: 'Your selected symptoms',
              detail: 'Reported in this check-up for context.',
              icon: 'insight',
            ),
          ]
        : signals;
    return Container(
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Column(
        children: items
            .map(
              (signal) =>
                  _ObservedRow(signal: signal, last: signal == items.last),
            )
            .toList(),
      ),
    );
  }
}

class _ObservedRow extends StatelessWidget {
  final ObservedSignal signal;
  final bool last;

  const _ObservedRow({required this.signal, required this.last});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: HerAlthColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(signal.icon), color: HerAlthColors.rose, size: 21),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: HerAlthColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  signal.detail,
                  style: HerAlthTextStyles.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String icon) {
    return switch (icon.toLowerCase()) {
      'calendar' => Icons.calendar_month_outlined,
      'skin' => Icons.face_retouching_natural_outlined,
      'trend' => Icons.insights_outlined,
      _ => Icons.auto_graph_outlined,
    };
  }
}

class _ExplanationCard extends StatelessWidget {
  final PossibleExplanation explanation;

  const _ExplanationCard({required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  explanation.name,
                  style: HerAlthTextStyles.pageTitle.copyWith(fontSize: 19),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: HerAlthColors.palePink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  explanation.tag.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    color: HerAlthColors.rose,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            explanation.description,
            style: HerAlthTextStyles.body.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CycleChart extends StatelessWidget {
  final CycleContextSnapshot cycle;

  const _CycleChart({required this.cycle});

  @override
  Widget build(BuildContext context) {
    final lengths = cycle.cycleLengths.take(6).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CYCLE LENGTH (DAYS)', style: HerAlthTextStyles.section),
          const SizedBox(height: 16),
          if (lengths.isEmpty)
            const SizedBox(
              height: 72,
              child: Center(
                child: Text(
                  'No cycle history recorded yet.',
                  style: HerAlthTextStyles.cardBody,
                ),
              ),
            )
          else
            SizedBox(
              height: 104,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: lengths.asMap().entries.map((entry) {
                  final height =
                      36 + ((entry.value - 24).clamp(0, 12) * 4).toDouble();
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.value}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: HerAlthColors.muted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color: HerAlthColors.rose,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'C${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: HerAlthColors.muted,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          const Divider(color: HerAlthColors.divider, height: 1),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HerAlthColors.disclaimer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: HerAlthColors.rose),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: HerAlthColors.rose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
