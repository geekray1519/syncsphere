import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/l10n/app_localizations.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/widgets/sync_job_card.dart';
import 'package:syncsphere/widgets/empty_state_widget.dart';
import 'package:syncsphere/widgets/ad_banner_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.devices_rounded),
            onPressed: () => Navigator.pushNamed(context, '/devices'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Gap(8),
        ],
      ),
      body: Consumer<SyncProvider>(
        builder: (context, syncProvider, child) {
          final jobs = syncProvider.syncJobs;

          return Column(
            children: [
              const AdBannerWidget(),
              Expanded(
                child: jobs.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.sync_rounded,
                        title: l10n.welcomeTitle,
                        description: l10n.noSyncJobsDesc,
                        actionLabel: l10n.createNewJob,
                        onAction: () {
                          Navigator.pushNamed(context, '/wizard');
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () async {},
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: jobs.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                                    child: Card.filled(
                                      color: theme.colorScheme.primaryContainer,
                                      margin: EdgeInsets.zero,
                                      child: InkWell(
                                        onTap: () => Navigator.pushNamed(context, '/server'),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.cast_connected,
                                                size: 32,
                                                color: theme.colorScheme.onPrimaryContainer,
                                              ),
                                              const Gap(16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      l10n.serverTitle,
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: theme.colorScheme.onPrimaryContainer,
                                                      ),
                                                    ),
                                                    Text(
                                                      l10n.directPcSync,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).animate().fadeIn().slideX(begin: 0.1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 24.0),
                                    child: Text(
                                      l10n.syncJobs,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ).animate().fadeIn().slideX(begin: -0.1),
                                ],
                              );
                            }
                            final job = jobs[index - 1];
                            return SyncJobCard(
                              job: job,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/sync-detail',
                                  arguments: job,
                                );
                              },
                              // onStart removed
                            ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<SyncProvider>(
        builder: (context, syncProvider, child) {
          if (syncProvider.syncJobs.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/wizard');
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.createNewJob, style: const TextStyle(fontWeight: FontWeight.bold)),
          ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack);
        },
      ),
    );
  }
}
