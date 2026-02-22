import 'package:flutter/material.dart';
import 'package:syncsphere/theme/app_spacing.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    this.height = AppSpacing.progressBarHeight,
    this.showPercentage = false,
  });

  final double progress;
  final double height;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (showPercentage) ...<Widget>[
          Text(
            '${(progress * 100).clamp(0, 100).toInt()}%',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: AppSpacing.animNormal,
            builder: (BuildContext context, double value, Widget? child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: height,
                backgroundColor: colorScheme.primaryContainer,
                color: colorScheme.primary,
              );
            },
          ),
        ),
      ],
    );
  }
}
