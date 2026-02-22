import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/widgets/sync_mode_selector.dart';
import 'package:syncsphere/widgets/connection_type_selector.dart';
import 'package:syncsphere/l10n/app_localizations.dart';
import 'package:syncsphere/theme/app_spacing.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  int _currentStep = 0;

  String _jobName = '';
  SyncMode _syncMode = SyncMode.twoWay;
  String _sourcePath = '';
  String _targetPath = '';
  ConnectionType _connectionType = ConnectionType.local;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final steps = <Step>[
      Step(
        title: Text(l10n.setupWizardStep1),
        content: _buildModeStep(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(l10n.setupWizardStep2),
        content: _buildFoldersStep(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(l10n.setupWizardStep3),
        content: _buildConnectionStep(),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(l10n.setupWizardStep4),
        content: _buildReviewStep(),
        isActive: _currentStep >= 3,
        state: _currentStep == 3 ? StepState.editing : StepState.indexed,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.setupWizardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: theme.colorScheme.primary,
            onSurface: theme.colorScheme.onSurface,
          ),
        ),
        child: Stepper(
          type: MediaQuery.of(context).size.width > 600 ? StepperType.horizontal : StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 1) {
              if (!_formKey.currentState!.validate() || _sourcePath.isEmpty || _targetPath.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.errorGeneral)),
                );
                return;
              }
            }

            if (_currentStep < steps.length - 1) {
              setState(() => _currentStep += 1);
            } else {
              _saveJob();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.pop(context);
            }
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == steps.length - 1;
            return Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xxl,
                bottom: AppSpacing.xxl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: details.onStepContinue,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                      ),
                      child: Text(
                        isLastStep ? l10n.createNewJob : l10n.next,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                        ),
                        child: Text(l10n.back, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: steps,
        ),
      ),
    );
  }

  Widget _buildModeStep() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepCard(
          icon: Icons.sync_alt_rounded,
          title: l10n.setupWizardStep1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.syncModeTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(AppSpacing.xl),
              SyncModeSelector(
                selectedMode: _syncMode,
                onSelected: (mode) => setState(() => _syncMode = mode),
              ),
            ],
          ),
        ),
      ].animate(interval: 50.ms).fadeIn().slideX(begin: 0.1),
    );
  }

  Widget _buildFoldersStep() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            icon: Icons.folder_copy_rounded,
            title: l10n.setupWizardStep2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.setupWizardStep2,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(AppSpacing.xl),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.jobName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    filled: true,
                  ),
                  initialValue: _jobName,
                  onChanged: (val) => _jobName = val,
                  validator: (val) => val == null || val.isEmpty ? l10n.errorGeneral : null,
                ),
                const Gap(AppSpacing.xl),
                _buildFolderSelector(
                  label: l10n.sourceFolder,
                  icon: Icons.folder_shared_rounded,
                  value: _sourcePath,
                  onPick: () => _pickFolder(isSource: true),
                ),
                const Gap(AppSpacing.lg),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const Gap(AppSpacing.lg),
                _buildFolderSelector(
                  label: l10n.targetFolder,
                  icon: Icons.create_new_folder_rounded,
                  value: _targetPath,
                  onPick: () => _pickFolder(isSource: false),
                ),
              ],
            ),
          ),
        ].animate(interval: 50.ms).fadeIn().slideX(begin: 0.1),
      ),
    );
  }

  Widget _buildConnectionStep() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepCard(
          icon: Icons.device_hub_rounded,
          title: l10n.setupWizardStep3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.connectionType,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(AppSpacing.xl),
              ConnectionTypeSelector(
                selectedType: _connectionType,
                onSelected: (type) => setState(() => _connectionType = type),
              ),
            ],
          ),
        ),
      ].animate(interval: 50.ms).fadeIn().slideX(begin: 0.1),
    );
  }

  Widget _buildReviewStep() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepCard(
          icon: Icons.check_circle_outline_rounded,
          title: l10n.setupWizardStep4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.setupWizardStep4,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(AppSpacing.xl),
              Card.filled(
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReviewItem(label: l10n.jobName, value: _jobName.isEmpty ? '---' : _jobName),
                      const Divider(height: AppSpacing.xxl),
                      _ReviewItem(label: l10n.syncModeTitle, value: _syncMode.name),
                      const Divider(height: AppSpacing.xxl),
                      _ReviewItem(label: l10n.connectionType, value: _connectionType.name),
                      const Divider(height: AppSpacing.xxl),
                      _ReviewItem(label: l10n.sourceFolder, value: _sourcePath.isEmpty ? '---' : _sourcePath),
                      const Gap(AppSpacing.sm),
                      const Icon(Icons.arrow_downward_rounded, size: AppSpacing.iconSm),
                      const Gap(AppSpacing.sm),
                      _ReviewItem(label: l10n.targetFolder, value: _targetPath.isEmpty ? '---' : _targetPath),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ].animate(interval: 50.ms).fadeIn().slideX(begin: 0.1),
    );
  }

  Future<void> _pickFolder({required bool isSource}) async {
    final String? selectedPath = await FilePicker.platform.getDirectoryPath();
    if (selectedPath == null || selectedPath.isEmpty || !mounted) {
      return;
    }

    setState(() {
      if (isSource) {
        _sourcePath = selectedPath;
      } else {
        _targetPath = selectedPath;
      }
    });
  }

  Widget _buildFolderSelector({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onPick,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bool hasValue = value.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasValue
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: hasValue
              ? theme.colorScheme.primary.withValues(alpha: 0.45)
              : theme.colorScheme.outlineVariant,
          width: hasValue ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSpacing.iconLg,
              color: hasValue
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const Gap(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(AppSpacing.xs),
                  Text(
                    hasValue ? value : l10n.noFolderSelected,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hasValue
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: onPick,
              icon: const Icon(Icons.search_rounded),
              label: Text(l10n.browseFolder),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    size: AppSpacing.iconMd,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }

  void _saveJob() {
    final job = SyncJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _jobName.isEmpty ? 'New Sync Job' : _jobName,
      sourcePath: _sourcePath,
      targetPath: _targetPath,
      syncMode: _syncMode,
      compareMode: CompareMode.timeAndSize,
      connectionType: _connectionType,
      scheduleType: ScheduleType.manual,
      filterInclude: const [],
      filterExclude: const [],
      versioningType: VersioningType.none,
      createdAt: DateTime.now(),
    );

    context.read<SyncProvider>().addJob(job);
    Navigator.pop(context);
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
