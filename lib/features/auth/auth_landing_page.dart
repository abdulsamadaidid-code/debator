import 'package:debator/features/auth/auth_surface.dart';
import 'package:flutter/material.dart';

class DebatorWelcomePage extends StatelessWidget {
  const DebatorWelcomePage({
    super.key,
    required this.isDemoMode,
    required this.onPrimaryAction,
    this.onSecondaryAction,
  });

  final bool isDemoMode;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final primaryLabel = isDemoMode ? 'Enter demo' : 'Create account';
    final secondaryLabel = isDemoMode ? 'Browse topics' : 'Sign in';
    final secondaryIcon = isDemoMode
        ? Icons.explore_rounded
        : Icons.login_rounded;

    return DebatorAuthFrame(
      eyebrow: isDemoMode ? 'Demo mode' : 'Debator',
      title: isDemoMode
          ? 'Try Debator as a guided preview of the arena.'
          : 'A debate arena built for people who want the full argument.',
      subtitle: isDemoMode
          ? 'You can move through the product as if it were live, with the same structure, cards, and topic-first flow that a real account would see.'
          : 'Debator keeps disagreement structured: clear propositions, explicit sides, readable rounds, and a space that rewards evidence instead of noise.',
      primaryAction: FilledButton.icon(
        onPressed: onPrimaryAction,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(primaryLabel),
      ),
      secondaryAction: onSecondaryAction == null
          ? const SizedBox.shrink()
          : OutlinedButton.icon(
              onPressed: onSecondaryAction,
              icon: Icon(secondaryIcon),
              label: Text(secondaryLabel),
            ),
      supportingColumn: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First impressions',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              DebatorAuthStat(
                label: isDemoMode ? 'Preview screens' : 'Live debates',
                value: isDemoMode ? '5' : '12',
              ),
              DebatorAuthStat(label: 'Structured rounds', value: '3'),
              DebatorAuthStat(label: 'Topic tracks', value: '10'),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DebatorAuthSectionHeader(
                    eyebrow: isDemoMode ? 'Demo flow' : 'Why people stay',
                    title: isDemoMode
                        ? 'The demo shows the same product rhythm you will use later.'
                        : 'Debates are easier to follow when they start with structure.',
                    description: isDemoMode
                        ? 'The goal is to let you feel the transitions between discovery, participation, and profile without needing a backend yet.'
                        : 'Debator keeps the proposition at the center, so you can jump into the topic, the stance, and the actual reasoning without fighting the UI.',
                  ),
                  const SizedBox(height: 18),
                  const DebatorFeatureCard(
                    icon: Icons.my_library_books_rounded,
                    title: 'Clear motions',
                    description:
                        'Every debate starts from a proposition, not a vague comment thread.',
                  ),
                  const SizedBox(height: 12),
                  const DebatorFeatureCard(
                    icon: Icons.rule_rounded,
                    title: 'Readable rounds',
                    description:
                        'Arguments are framed like arguments, so readers can scan and compare both sides.',
                  ),
                  const SizedBox(height: 12),
                  const DebatorFeatureCard(
                    icon: Icons.shield_outlined,
                    title: 'Consent-based participation',
                    description:
                        'People join a side only when they want to argue there, which keeps the product deliberate.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DebatorAuthSectionHeader(
                    eyebrow: 'Start exploring',
                    title: 'Browse the topics that already feel alive.',
                    description:
                        'Use the same product whether you want to read, argue, or just see where the strongest disagreement is happening.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _TopicPreviewChip(label: 'Religion'),
                      _TopicPreviewChip(label: 'Science'),
                      _TopicPreviewChip(label: 'Ethics'),
                      _TopicPreviewChip(label: 'Politics'),
                      _TopicPreviewChip(label: 'Technology'),
                      _TopicPreviewChip(label: 'Philosophy'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@Deprecated('Use DebatorWelcomePage')
class DebatorLandingPage extends DebatorWelcomePage {
  const DebatorLandingPage({
    super.key,
    required super.isDemoMode,
    required super.onPrimaryAction,
    super.onSecondaryAction,
  });
}

class _TopicPreviewChip extends StatelessWidget {
  const _TopicPreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), avatar: const Icon(Icons.circle, size: 8));
  }
}
