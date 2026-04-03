import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DebatorAuthBackdrop extends StatelessWidget {
  const DebatorAuthBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F1E7), Color(0xFFF3E5D5), Color(0xFFF2EEE8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -30,
            child: _GlowOrb(
              size: 300,
              color: const Color(0xFF0F6A67).withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            left: -90,
            top: 180,
            child: _GlowOrb(
              size: 240,
              color: const Color(0xFFCB6B36).withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -120,
            right: 120,
            child: _GlowOrb(
              size: 280,
              color: const Color(0xFF255D85).withValues(alpha: 0.10),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class DebatorAuthFrame extends StatelessWidget {
  const DebatorAuthFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryAction,
    required this.secondaryAction,
    required this.body,
    this.eyebrow = 'Debator',
    this.supportingColumn,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget primaryAction;
  final Widget secondaryAction;
  final Widget body;
  final Widget? supportingColumn;

  @override
  Widget build(BuildContext context) {
    return DebatorAuthBackdrop(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final horizontalPadding = constraints.maxWidth >= 1200
                ? 56.0
                : 20.0;
            final topPadding = constraints.maxWidth >= 980 ? 28.0 : 20.0;

            final content = isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _IntroPanel(
                          eyebrow: eyebrow,
                          title: title,
                          subtitle: subtitle,
                          primaryAction: primaryAction,
                          secondaryAction: secondaryAction,
                          supportingColumn: supportingColumn,
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 540),
                            child: body,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _IntroPanel(
                        eyebrow: eyebrow,
                        title: title,
                        subtitle: subtitle,
                        primaryAction: primaryAction,
                        secondaryAction: secondaryAction,
                        supportingColumn: supportingColumn,
                      ),
                      const SizedBox(height: 18),
                      body,
                    ],
                  );

            return Scrollbar(
              thumbVisibility: isWide,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1260),
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.primaryAction,
    required this.secondaryAction,
    this.supportingColumn,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget primaryAction;
  final Widget secondaryAction;
  final Widget? supportingColumn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandBadge(eyebrow: eyebrow),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              textStyle: theme.textTheme.displaySmall,
              fontWeight: FontWeight.w700,
              height: 0.98,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.76),
                height: 1.52,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pill(icon: Icons.balance_rounded, label: 'Structured debate'),
              _Pill(
                icon: Icons.mark_chat_read_rounded,
                label: 'Topic-first flow',
              ),
              _Pill(icon: Icons.shield_rounded, label: 'Built for consent'),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [primaryAction, secondaryAction],
          ),
          if (supportingColumn != null) ...[
            const SizedBox(height: 24),
            supportingColumn!,
          ],
        ],
      ),
    );
  }
}

class DebatorAuthSectionHeader extends StatelessWidget {
  const DebatorAuthSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.0,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class DebatorFeatureCard extends StatelessWidget {
  const DebatorFeatureCard({
    super.key,
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
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
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

class DebatorTopicPill extends StatelessWidget {
  const DebatorTopicPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }
}

class DebatorNormCard extends StatelessWidget {
  const DebatorNormCard({
    super.key,
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 14),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DebatorAuthStat extends StatelessWidget {
  const DebatorAuthStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                textStyle: theme.textTheme.headlineMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.eyebrow});

  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.86),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.82),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(blurRadius: 120, spreadRadius: 18, color: color)],
      ),
    );
  }
}
