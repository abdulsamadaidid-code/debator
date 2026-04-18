import 'package:debator/features/auth/auth_surface.dart';
import 'package:flutter/material.dart';

class DebatorOnboardingPage extends StatefulWidget {
  const DebatorOnboardingPage({
    super.key,
    required this.onComplete,
    required this.email,
    this.initialDisplayName,
    this.initialHandle,
    required this.onSignOut,
  });

  final Future<void> Function({
    required String displayName,
    required String handle,
  })
  onComplete;
  final String email;
  final String? initialDisplayName;
  final String? initialHandle;
  final Future<void> Function() onSignOut;

  @override
  State<DebatorOnboardingPage> createState() => _DebatorOnboardingPageState();
}

class _DebatorOnboardingPageState extends State<DebatorOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _handleController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialDisplayName ?? '',
    );
    _handleController = TextEditingController(
      text: _normalizeHandle(widget.initialHandle ?? ''),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _handleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await widget.onComplete(
      displayName: _displayNameController.text.trim(),
      handle: _normalizeHandle(_handleController.text.trim()),
    );
  }

  String _normalizeHandle(String handle) {
    final trimmed = handle.trim();
    if (trimmed.startsWith('@')) {
      return trimmed.substring(1);
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DebatorAuthFrame(
      eyebrow: 'Onboarding',
      title:
          'Shape the first debates you see and the identity you bring into them.',
      subtitle:
          'Pick a display name, claim a handle, and keep the early profile setup lightweight so the product still feels quick to join.',
      primaryAction: FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('Finish setup'),
      ),
      secondaryAction: OutlinedButton.icon(
        onPressed: () async {
          await widget.onSignOut();
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign out'),
      ),
      supportingColumn: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account context',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.alternate_email_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Signed in as', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.76,
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
          const SizedBox(height: 10),
          const DebatorNormCard(
            icon: Icons.person_rounded,
            title: 'Identity first',
            description:
                'A display name and handle make the debate trail easier to follow.',
          ),
          const SizedBox(height: 10),
          const DebatorNormCard(
            icon: Icons.stream_rounded,
            title: 'Topic continuity',
            description:
                'The profile can later evolve into follows, drafts, and saved debates.',
          ),
          const SizedBox(height: 10),
          const DebatorNormCard(
            icon: Icons.verified_user_rounded,
            title: 'Ready for trust signals',
            description:
                'This setup flow can later expand into moderation, reputation, and account settings.',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DebatorAuthSectionHeader(
                  eyebrow: 'Profile setup',
                  title: 'Give the arena a name it can remember.',
                  description:
                      'This is a presentation-only profile step. Later it can become reputation, bios, and richer account preferences.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    hintText: 'Ariana',
                  ),
                  validator: _validateDisplayName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _handleController,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.username],
                  decoration: const InputDecoration(
                    labelText: 'Handle',
                    hintText: 'debatefan',
                    prefixText: '@',
                  ),
                  validator: _validateHandle,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.82),
                    ),
                  ),
                  child: Text(
                    'Debator will later use this step for profile completion, followed topics, and moderation context. For now it keeps the surface friendly and easy to test.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.76),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _QuickLabel(label: 'Email-linked identity'),
                    _QuickLabel(label: 'Topic-ready profile'),
                    _QuickLabel(label: 'Moderation-aware'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateDisplayName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Enter a display name.';
    }
    if (name.length < 2) {
      return 'Use at least 2 characters.';
    }
    return null;
  }

  String? _validateHandle(String? value) {
    final handle = _normalizeHandle(value ?? '');
    if (handle.isEmpty) {
      return 'Enter a handle.';
    }
    if (handle.length < 3) {
      return 'Use at least 3 characters.';
    }
    final handlePattern = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!handlePattern.hasMatch(handle)) {
      return 'Use letters, numbers, dots, or underscores only.';
    }
    return null;
  }
}

class _QuickLabel extends StatelessWidget {
  const _QuickLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.82),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
