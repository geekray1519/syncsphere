import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/theme/app_spacing.dart';
import 'package:syncsphere/widgets/empty_state_widget.dart';
import 'package:syncsphere/widgets/sync_job_card.dart';
import '../../l10n/app_localizations.dart';

/// Folders list — sync folder management (tab 1 in AppShell).
class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SyncProvider syncProvider = context.watch<SyncProvider>();
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabFolders),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Typically triggers a refresh in syncProvider
          // await syncProvider.refreshJobs();
        },
        child: syncProvider.jobs.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight - 100,
                  child: EmptyStateWidget(
                    icon: Icons.folder_open_rounded,
                    title: l10n.noFoldersTitle,
                    description: l10n.noFoldersAction,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                itemCount: syncProvider.jobs.length,
                itemBuilder: (BuildContext context, int index) {
                  final SyncJob job = syncProvider.jobs[index];
                  return SyncJobCard(
                    job: job,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/folder-detail',
                        arguments: job,
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/wizard');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
