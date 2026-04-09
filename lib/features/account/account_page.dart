import 'package:debator/app/config/app_config.dart';
import 'package:debator/app/providers/app_providers.dart';
import 'package:debator/domain/models/debate_models.dart';
import 'package:debator/domain/models/viewer_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DebatorAccountPage extends ConsumerWidget {
  const DebatorAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    final viewerProfile = ref.watch(currentViewerProfileProvider);
    final viewModel = ref.watch(debatorViewModelProvider);
    final yourDebates = viewerProfile == null
        ? const <Debate>[]
        : viewModel.debatesForParticipantHandle(viewerProfile.handle);
    final exploredTopics = yourDebates
        .map((debate) => viewModel.topicById(debate.topicId)?.name)
        .whereType<String>()
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F2E8), Color(0xFFF2E5D6), Color(0xFFF0EEE8)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AccountHero(
                      viewerProfile: viewerProfile,
                      environmentLabel: appConfig.environment.value,
                      onSignOut: appConfig.isMock
                          ? null
                          : () async {
                              await ref.read(sessionControllerProvider).signOut();
                              if (!context.mounted) {
                                return;
                              }
                              context.go('/welcome');
                            },
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _AccountMetricCard(
                          title: 'Debates',
                          value: '${yourDebates.length}',
                          subtitle: appConfig.isMock
                              ? 'Debates touched in demo mode'
                              : 'Debates tied to your current account',
                          icon: Icons.rocket_launch_rounded,
                        ),
                        _AccountMetricCard(
                          title: 'Topics explored',
                          value: '$exploredTopics',
                          subtitle: 'Distinct arenas you have already entered',
                          icon: Icons.hub_rounded,
                        ),
                        _AccountMetricCard(
                          title: 'Rating',
                          value: '${viewerProfile?.rating ?? 0}',
                          subtitle: appConfig.isMock
                              ? 'Demo reputation snapshot'
                              : 'Current profile rating snapshot',
                          icon: Icons.stars_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 900;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _AccountPreferencesCard(
                                  appConfig: appConfig,
                                  viewerProfile: viewerProfile,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: _AccountStatusCard(
                                  appConfig: appConfig,
                                  viewerProfile: viewerProfile,
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _AccountPreferencesCard(
                              appConfig: appConfig,
                              viewerProfile: viewerProfile,
                            ),
                            const SizedBox(height: 18),
                            _AccountStatusCard(
                              appConfig: appConfig,
                              viewerProfile: viewerProfile,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    _AccountFootprintCard(
                      debates: yourDebates,
                      topicNameForId: (topicId) => viewModel.topicById(topicId)?.name,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({
    required this.viewerProfile,
    required this.environmentLabel,
    required this.onSignOut,
  });

  final ViewerProfile? viewerProfile;
  final String environmentLabel;
  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLiveSession = onSignOut != null && viewerProfile != null;
    final viewer = viewerProfile;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isStacked = constraints.maxWidth < 680;

            return Flex(
              direction: isStacked ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F6A67), Color(0xFFC96A33)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    viewer == null
                        ? '?'
                        : viewer.firstName.characters.first.toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: isStacked ? 0 : 18,
                  height: isStacked ? 18 : 0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewerProfile?.displayName ?? 'Account unavailable',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        viewer == null
                            ? 'Debator is still loading your identity.'
                            : '${viewer.handle} • ${viewer.email}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _AccountPill(
                            icon: hasLiveSession
                                ? Icons.verified_user_rounded
                                : Icons.explore_rounded,
                            label: hasLiveSession
                                ? 'Live session'
                                : 'Demo identity',
                          ),
                          _AccountPill(
                            icon: Icons.settings_input_component_rounded,
                            label: environmentLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onSignOut != null) ...[
                  SizedBox(
                    width: isStacked ? 0 : 18,
                    height: isStacked ? 18 : 0,
                  ),
                  OutlinedButton.icon(
                    onPressed: () async => onSignOut!.call(),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountMetricCard extends StatelessWidget {
  const _AccountMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 320,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(value, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountPreferencesCard extends StatelessWidget {
  const _AccountPreferencesCard({
    required this.appConfig,
    required this.viewerProfile,
  });

  final AppConfig appConfig;
  final ViewerProfile? viewerProfile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account preferences', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'These settings are the next layer after identity. For now, the page makes the product direction explicit even before every preference is live.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 18),
            const _PreferenceRow(
              icon: Icons.notifications_active_rounded,
              title: 'Debate alerts',
              description: 'Followed debates, replies, and side-join activity.',
            ),
            const SizedBox(height: 12),
            const _PreferenceRow(
              icon: Icons.topic_rounded,
              title: 'Topic follows',
              description: 'Choose which arenas should shape your home feed.',
            ),
            const SizedBox(height: 12),
            _PreferenceRow(
              icon: Icons.badge_rounded,
              title: 'Public identity',
              description: viewerProfile == null
                  ? 'Identity details will appear here once the session is available.'
                  : 'Your public debate identity is ${viewerProfile!.handle}.',
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({
    required this.appConfig,
    required this.viewerProfile,
  });

  final AppConfig appConfig;
  final ViewerProfile? viewerProfile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session status', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              appConfig.isMock
                  ? 'This build is running in preview mode. Use it to inspect flows and interaction rhythm.'
                  : 'This build is connected to Supabase auth and is prepared for native magic-link return handling.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 18),
            _StatusTile(
              label: 'Environment',
              value: appConfig.environment.value,
            ),
            const SizedBox(height: 12),
            _StatusTile(
              label: 'Auth callback',
              value: appConfig.authCallbackUrl,
            ),
            const SizedBox(height: 12),
            _StatusTile(
              label: 'Profile state',
              value: viewerProfile == null ? 'Loading' : 'Ready',
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountFootprintCard extends StatelessWidget {
  const _AccountFootprintCard({
    required this.debates,
    required this.topicNameForId,
  });

  final List<Debate> debates;
  final String? Function(String topicId) topicNameForId;

  @override
  Widget build(BuildContext context) {
    final visibleDebates = debates.take(5).toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Debate footprint', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              debates.isEmpty
                  ? 'No debates are tied to this identity yet.'
                  : 'A quick snapshot of the debates this identity has already touched.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 18),
            if (visibleDebates.isEmpty)
              const _EmptyAccountState()
            else
              Column(
                children: [
                  for (final debate in visibleDebates) ...[
                    _FootprintRow(
                      title: debate.title,
                      proposition: debate.proposition,
                      topic: topicNameForId(debate.topicId) ?? 'Open arena',
                    ),
                    if (debate != visibleDebates.last) const Divider(height: 24),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FootprintRow extends StatelessWidget {
  const _FootprintRow({
    required this.title,
    required this.proposition,
    required this.topic,
  });

  final String title;
  final String proposition;
  final String topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.forum_rounded, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                proposition,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                topic,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: theme.colorScheme.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPill extends StatelessWidget {
  const _AccountPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.84),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _EmptyAccountState extends StatelessWidget {
  const _EmptyAccountState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Once you create or join debates, your footprint will appear here.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}
