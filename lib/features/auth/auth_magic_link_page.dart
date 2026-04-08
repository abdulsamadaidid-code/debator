import 'package:debator/features/auth/auth_surface.dart';
import 'package:flutter/material.dart';

class DebatorAuthPage extends StatefulWidget {
  const DebatorAuthPage({
    super.key,
    required this.onSendMagicLink,
    required this.onBack,
    this.isSubmitting = false,
    this.helperMessage,
  });

  final Future<void> Function(String email) onSendMagicLink;
  final VoidCallback onBack;
  final bool isSubmitting;
  final String? helperMessage;

  @override
  State<DebatorAuthPage> createState() => _DebatorAuthPageState();
}

class _DebatorAuthPageState extends State<DebatorAuthPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await widget.onSendMagicLink(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DebatorAuthFrame(
      eyebrow: 'Magic link',
      title: 'Sign in with the email address you want tied to your debates.',
      subtitle:
          'Debator uses a passwordless entry flow so the first step stays frictionless and the identity stays simple.',
      primaryAction: FilledButton.icon(
        onPressed: widget.isSubmitting ? null : _submit,
        icon: widget.isSubmitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send_rounded),
        label: Text(widget.isSubmitting ? 'Sending link' : 'Send magic link'),
      ),
      secondaryAction: OutlinedButton.icon(
        onPressed: widget.onBack,
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text('Back'),
      ),
      supportingColumn: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happens next',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const _StepTile(
            icon: Icons.mail_rounded,
            title: 'We send a one-time link',
            description:
                'No password. No account lockout. Just a quick email check.',
          ),
          const SizedBox(height: 10),
          const _StepTile(
            icon: Icons.lock_open_rounded,
            title: 'You tap the link',
            description:
                'The link returns you directly to Debator and preserves the current flow.',
          ),
          const SizedBox(height: 10),
          const _StepTile(
            icon: Icons.account_tree_rounded,
            title: 'You enter the arena',
            description:
                'Your profile, follows, and debate activity can grow from one identity.',
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
                  eyebrow: 'Sign in',
                  title: 'Open the inbox you use for Debator.',
                  description:
                      'We will send a temporary sign-in link to this email address.',
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'you@example.com',
                  ),
                  validator: _validateEmail,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (widget.helperMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.82,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.helperMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.76),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.82),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This sign-in flow is now wired for the product shell. On native devices, Debator is prepared to receive the magic-link callback and continue into onboarding.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.76,
                            ),
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

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Enter the email address you want to use.';
    }

    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.secondary),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
