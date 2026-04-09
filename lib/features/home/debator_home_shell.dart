import 'dart:ui';

import 'package:debator/app/theme/topic_style.dart';
import 'package:debator/domain/models/debate_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers/app_providers.dart';
import 'debator_view_model.dart';

class DebatorHomeShell extends ConsumerWidget {
  const DebatorHomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(debatorViewModelProvider);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;

            if (viewModel.isLoading) {
              return const _LoadingScaffold();
            }

            if (viewModel.errorMessage != null) {
              return _ErrorScaffold(
                message: viewModel.errorMessage!,
                onRetry: viewModel.initialize,
              );
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: !isDesktop,
              bottomNavigationBar: isDesktop
                  ? null
                  : _MobileBottomNavigationBar(
                      selectedIndex: viewModel.selectedTabIndex,
                      onDestinationSelected: viewModel.selectTab,
                    ),
              body: Stack(
                children: [
                  const _ArenaBackground(),
                  SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isDesktop)
                          _DesktopSidebar(
                            selectedIndex: viewModel.selectedTabIndex,
                            onDestinationSelected: viewModel.selectTab,
                            liveDebateCount: viewModel.liveDebateCount,
                          ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 0 : 18,
                              isDesktop ? 18 : 16,
                              isDesktop ? 24 : 18,
                              0,
                            ),
                            child: Column(
                              children: [
                                _ShellHeader(
                                  selectedIndex: viewModel.selectedTabIndex,
                                  onCreatePressed: () => viewModel.selectTab(2),
                                ),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 1260,
                                      ),
                                      child: IndexedStack(
                                        index: viewModel.selectedTabIndex,
                                        children: [
                                          _DiscoverTab(
                                            viewModel: viewModel,
                                            isDesktop: isDesktop,
                                            onOpenDebate: (debate) {
                                              _openDebateDetail(
                                                context,
                                                debate.id,
                                              );
                                            },
                                          ),
                                          _TopicsTab(
                                            viewModel: viewModel,
                                            isDesktop: isDesktop,
                                            onOpenDebate: (debate) {
                                              _openDebateDetail(
                                                context,
                                                debate.id,
                                              );
                                            },
                                          ),
                                          _CreateDebateTab(
                                            viewModel: viewModel,
                                            isDesktop: isDesktop,
                                            onOpenDebate: (debate) {
                                              _openDebateDetail(
                                                context,
                                                debate.id,
                                              );
                                            },
                                          ),
                                          _ProfileTab(
                                            viewModel: viewModel,
                                            isDesktop: isDesktop,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openDebateDetail(BuildContext context, String debateId) {
    context.push('/debate/$debateId');
  }
}

class DebateDetailPage extends ConsumerWidget {
  const DebateDetailPage({super.key, required this.debateId});

  final String debateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(debatorViewModelProvider);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final debate = viewModel.debateById(debateId);
        if (debate == null) {
          return const Scaffold(
            body: Center(child: Text('That debate could not be found.')),
          );
        }

        final topic = viewModel.topicById(debate.topicId);
        final topicStyle = topicStyleFor(debate.topicId);
        final forRatio = debate.totalSupport == 0
            ? 0.5
            : debate.forSupport / debate.totalSupport;

        return Scaffold(
          appBar: AppBar(title: const Text('Debate detail')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1040;
              return _AdaptiveScrollbar(
                enabled: isWide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailHeroCard(
                            debate: debate,
                            topicName: topic?.name ?? 'Open arena',
                            topicStyle: topicStyle,
                            isJoining: viewModel.isJoining(debate.id),
                            onJoin: (side) async {
                              await viewModel.joinDebate(
                                debateId: debate.id,
                                side: side,
                              );
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You are now on the ${side.label.toLowerCase()} side.',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 22),
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _RoundsCard(
                                    debate: debate,
                                    topicStyle: topicStyle,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    children: [
                                      _ScoreboardCard(
                                        debate: debate,
                                        forRatio: forRatio,
                                      ),
                                      const SizedBox(height: 18),
                                      _ParticipantsCard(debate: debate),
                                      const SizedBox(height: 18),
                                      _JudgingCard(
                                        judgingPrompt: debate.judgingPrompt,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _ScoreboardCard(
                                  debate: debate,
                                  forRatio: forRatio,
                                ),
                                const SizedBox(height: 18),
                                _RoundsCard(
                                  debate: debate,
                                  topicStyle: topicStyle,
                                ),
                                const SizedBox(height: 18),
                                _ParticipantsCard(debate: debate),
                                const SizedBox(height: 18),
                                _JudgingCard(
                                  judgingPrompt: debate.judgingPrompt,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab({
    required this.viewModel,
    required this.isDesktop,
    required this.onOpenDebate,
  });

  final DebatorViewModel viewModel;
  final bool isDesktop;
  final ValueChanged<Debate> onOpenDebate;

  @override
  Widget build(BuildContext context) {
    final featuredTopics = viewModel.topics.take(6).toList();
    return _AdaptiveScrollbar(
      enabled: isDesktop,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: _tabBottomPadding(isDesktop)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroPanel(
              onBrowseTopics: () => viewModel.selectTab(1),
              onCreateDebate: () => viewModel.selectTab(2),
            ),
            const SizedBox(height: 22),
            _ResponsiveWrapGrid(
              maxColumns: 3,
              minItemWidth: 240,
              children: [
                _MetricCard(
                  title: 'Live debates',
                  value: '${viewModel.liveDebateCount}',
                  subtitle: 'Active propositions being argued right now',
                  icon: Icons.graphic_eq_rounded,
                ),
                _MetricCard(
                  title: 'Audience',
                  value: '${viewModel.totalAudience}',
                  subtitle: 'People watching and rating active debates',
                  icon: Icons.groups_rounded,
                ),
                _MetricCard(
                  title: 'Open seats',
                  value: '${viewModel.openSeatCount}',
                  subtitle: 'Debates still looking for the other side',
                  icon: Icons.gavel_rounded,
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionHeading(
              title: 'Trending topics',
              subtitle: 'Every conversation here starts with a clear arena.',
              actionLabel: 'See all topics',
              onAction: () => viewModel.selectTab(1),
            ),
            const SizedBox(height: 14),
            _ResponsiveWrapGrid(
              maxColumns: 3,
              minItemWidth: 260,
              children: [
                for (final topic in featuredTopics)
                  _TopicCard(
                    topic: topic,
                    onTap: () => viewModel.openTopic(topic.id),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionHeading(
              title: 'Debates heating up',
              subtitle: 'This is where structured disagreement feels alive.',
            ),
            const SizedBox(height: 14),
            Column(
              children: [
                for (final debate in viewModel.featuredDebates) ...[
                  _DebateCard(
                    debate: debate,
                    topic: viewModel.topicById(debate.topicId),
                    compact: false,
                    onTap: () => onOpenDebate(debate),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicsTab extends StatefulWidget {
  const _TopicsTab({
    required this.viewModel,
    required this.isDesktop,
    required this.onOpenDebate,
  });

  final DebatorViewModel viewModel;
  final bool isDesktop;
  final ValueChanged<Debate> onOpenDebate;

  @override
  State<_TopicsTab> createState() => _TopicsTabState();
}

class _TopicsTabState extends State<_TopicsTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.viewModel.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTopic = widget.viewModel.selectedTopic;
    final debates = widget.viewModel.filteredDebates;

    return _AdaptiveScrollbar(
      enabled: widget.isDesktop,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: _tabBottomPadding(widget.isDesktop)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse the arena',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Filter by topic, scan active propositions, and jump into a debate that already wants logic.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.74),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _searchController,
                      onChanged: widget.viewModel.setSearchQuery,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search debates, propositions, or summaries',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text('All topics'),
                          selected: selectedTopic == null,
                          onSelected: (_) => widget.viewModel.selectTopic(null),
                        ),
                        for (final topic in widget.viewModel.topics)
                          ChoiceChip(
                            label: Text(topic.name),
                            selected: selectedTopic?.id == topic.id,
                            onSelected: (_) => widget.viewModel.selectTopic(
                              selectedTopic?.id == topic.id ? null : topic.id,
                            ),
                          ),
                      ],
                    ),
                    if (selectedTopic != null) ...[
                      const SizedBox(height: 18),
                      _SelectedTopicBanner(topic: selectedTopic),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionHeading(
              title: selectedTopic == null
                  ? 'Ongoing debates'
                  : '${selectedTopic.name} debates',
              subtitle: debates.isEmpty
                  ? 'Nothing matches the current filter yet.'
                  : '${debates.length} structured debates ready to open.',
            ),
            const SizedBox(height: 14),
            if (debates.isEmpty)
              const _EmptyStateCard(
                title: 'No debates match this filter yet',
                description:
                    'Try another topic, clear the search, or launch a new debate yourself.',
              )
            else
              _ResponsiveWrapGrid(
                maxColumns: 3,
                minItemWidth: 320,
                children: [
                  for (final debate in debates)
                    _DebateCard(
                      debate: debate,
                      topic: widget.viewModel.topicById(debate.topicId),
                      compact: true,
                      onTap: () => widget.onOpenDebate(debate),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CreateDebateTab extends ConsumerStatefulWidget {
  const _CreateDebateTab({
    required this.viewModel,
    required this.isDesktop,
    required this.onOpenDebate,
  });

  final DebatorViewModel viewModel;
  final bool isDesktop;
  final ValueChanged<Debate> onOpenDebate;

  @override
  ConsumerState<_CreateDebateTab> createState() => _CreateDebateTabState();
}

class _CreateDebateTabState extends ConsumerState<_CreateDebateTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _propositionController;
  late final TextEditingController _overviewController;
  late final TextEditingController _judgingPromptController;
  late final TextEditingController _openingStatementController;

  DebateSide _startingSide = DebateSide.forSide;
  DebateFormat _selectedFormat = DebateFormat.structured;
  String? _selectedTopicId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _propositionController = TextEditingController();
    _overviewController = TextEditingController();
    _judgingPromptController = TextEditingController(
      text:
          'Judge the side with the clearest logic, strongest evidence, and fairest rebuttal.',
    );
    _openingStatementController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _propositionController.dispose();
    _overviewController.dispose();
    _judgingPromptController.dispose();
    _openingStatementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider);
    final viewerProfile = ref.watch(currentViewerProfileProvider);
    final topics = widget.viewModel.topics;
    final effectiveTopicId =
        _selectedTopicId ?? (topics.isNotEmpty ? topics.first.id : null);

    return _AdaptiveScrollbar(
      enabled: widget.isDesktop,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: _tabBottomPadding(widget.isDesktop)),
        child: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Launch a debate',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    appConfig.isMock
                        ? 'Create a proposition, choose your side, and publish the first round. Demo mode keeps the data local so you can test the debate loop quickly.'
                        : 'Create a proposition, choose your side, and publish the first round under your Debator identity.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.76),
                    ),
                  ),
                  if (viewerProfile != null) ...[
                    const SizedBox(height: 16),
                    _InlineIdentityNotice(
                      title: appConfig.isMock
                          ? 'Publishing as the demo debator'
                          : 'Publishing from your account',
                      description: appConfig.isMock
                          ? '${viewerProfile.handle} keeps this preview coherent while you test the product loop.'
                          : '${viewerProfile.displayName} ${viewerProfile.handle} will appear on the opening round and debate roster.',
                    ),
                  ],
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useTwoColumns = constraints.maxWidth >= 860;
                      final shortFieldWidth = useTwoColumns
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: shortFieldWidth,
                            child: TextFormField(
                              key: const Key('create-title-field'),
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Debate title',
                                hintText: 'Moral Compass',
                              ),
                              validator: _requiredField,
                            ),
                          ),
                          SizedBox(
                            width: shortFieldWidth,
                            child: DropdownButtonFormField<String>(
                              initialValue: effectiveTopicId,
                              decoration: const InputDecoration(
                                labelText: 'Topic',
                              ),
                              items: [
                                for (final topic in topics)
                                  DropdownMenuItem<String>(
                                    value: topic.id,
                                    child: Text(topic.name),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedTopicId = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: shortFieldWidth,
                            child: DropdownButtonFormField<DebateFormat>(
                              initialValue: _selectedFormat,
                              decoration: const InputDecoration(
                                labelText: 'Debate format',
                              ),
                              items: [
                                for (final format in DebateFormat.values)
                                  DropdownMenuItem<DebateFormat>(
                                    value: format,
                                    child: Text(format.label),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedFormat = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: shortFieldWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Starting side',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 10),
                                SegmentedButton<DebateSide>(
                                  showSelectedIcon: false,
                                  segments: const [
                                    ButtonSegment<DebateSide>(
                                      value: DebateSide.forSide,
                                      label: Text('For'),
                                    ),
                                    ButtonSegment<DebateSide>(
                                      value: DebateSide.against,
                                      label: Text('Against'),
                                    ),
                                  ],
                                  selected: {_startingSide},
                                  onSelectionChanged: (selection) {
                                    setState(() {
                                      _startingSide = selection.first;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const _FormSectionHeading(
                    title: 'Frame the motion',
                    subtitle:
                        'Make the proposition crisp, define the tension, and tell voters how to judge it.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('create-proposition-field'),
                    controller: _propositionController,
                    decoration: const InputDecoration(
                      labelText: 'Proposition',
                      hintText: 'Morality can exist without religion.',
                    ),
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('create-overview-field'),
                    controller: _overviewController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Overview',
                      hintText:
                          'Explain the core tension and what the debate should focus on.',
                    ),
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _judgingPromptController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'How should the audience judge it?',
                    ),
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 16),
                  const _FormSectionHeading(
                    title: 'Publish the opening case',
                    subtitle:
                        'Your first statement should sound like a debater opening the round, not a comment in a thread.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('create-opening-field'),
                    controller: _openingStatementController,
                    minLines: 5,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      labelText: 'Opening statement',
                      hintText:
                          'Write the first case you want readers to respond to.',
                    ),
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: widget.viewModel.isCreating
                            ? null
                            : () => _submit(
                                context,
                                effectiveTopicId: effectiveTopicId,
                              ),
                        icon: const Icon(Icons.rocket_launch_rounded),
                        label: Text(
                          widget.viewModel.isCreating
                              ? 'Launching...'
                              : 'Launch debate',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset draft'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  Future<void> _submit(
    BuildContext context, {
    required String? effectiveTopicId,
  }) async {
    if (!_formKey.currentState!.validate() || effectiveTopicId == null) {
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final openDebate = widget.onOpenDebate;

    final draft = DebateDraft(
      title: _titleController.text.trim(),
      proposition: _propositionController.text.trim(),
      topicId: effectiveTopicId,
      overview: _overviewController.text.trim(),
      startingSide: _startingSide,
      format: _selectedFormat,
      openingStatement: _openingStatementController.text.trim(),
      judgingPrompt: _judgingPromptController.text.trim(),
    );

    final createdDebate = await widget.viewModel.createDebate(draft);
    if (!mounted) {
      return;
    }

    _reset();

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Debate launched into the arena.')),
    );

    openDebate(createdDebate);
  }

  void _reset() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _propositionController.clear();
    _overviewController.clear();
    _openingStatementController.clear();
    _judgingPromptController.text =
        'Judge the side with the clearest logic, strongest evidence, and fairest rebuttal.';
    setState(() {
      _selectedTopicId = null;
      _startingSide = DebateSide.forSide;
      _selectedFormat = DebateFormat.structured;
    });
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab({required this.viewModel, required this.isDesktop});

  final DebatorViewModel viewModel;
  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    final viewerProfile = ref.watch(currentViewerProfileProvider);
    final yourDebates = viewerProfile == null
        ? const <Debate>[]
        : viewModel.debatesForParticipantHandle(viewerProfile.handle);
    final exploredTopics = yourDebates
        .map((debate) => viewModel.topicById(debate.topicId)?.name)
        .whereType<String>()
        .toSet()
        .length;
    final title = appConfig.isMock
        ? 'Demo identity'
        : (viewerProfile?.displayName ?? 'Your account');
    final subtitle = appConfig.isMock
        ? 'This preview keeps one consistent debator identity so the product loop still feels real.'
        : '${viewerProfile?.handle ?? '@debator'} • ${viewerProfile?.email ?? 'Signed in'}';

    return _AdaptiveScrollbar(
      enabled: isDesktop,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: _tabBottomPadding(isDesktop)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isStacked = constraints.maxWidth < 620;

                    return Flex(
                      direction: isStacked ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F6A67), Color(0xFFC96A33)],
                            ),
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        SizedBox(
                          width: isStacked ? 0 : 18,
                          height: isStacked ? 18 : 0,
                        ),
                        if (isStacked)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.76),
                                    ),
                              ),
                            ],
                          )
                        else
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.76),
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _ProfilePill(
                                      icon: Icons.verified_user_rounded,
                                      label: viewerProfile == null
                                          ? 'Profile loading'
                                          : 'Rating ${viewerProfile.rating}',
                                    ),
                                    _ProfilePill(
                                      icon: appConfig.isMock
                                          ? Icons.explore_rounded
                                          : Icons.cloud_done_rounded,
                                      label: appConfig.isMock
                                          ? 'Demo identity'
                                          : 'Live identity',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (!appConfig.isMock && viewerProfile != null) ...[
                          SizedBox(
                            width: isStacked ? 0 : 18,
                            height: isStacked ? 18 : 0,
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => context.push('/account'),
                            icon: const Icon(Icons.settings_rounded),
                            label: const Text('Account'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            _ResponsiveWrapGrid(
              maxColumns: 3,
              minItemWidth: 240,
              children: [
                _MetricCard(
                  title: 'Debates launched',
                  value: '${yourDebates.length}',
                  subtitle: appConfig.isMock
                      ? 'Debates touched by the demo identity in this preview'
                      : 'Debates tied to your current account identity',
                  icon: Icons.rocket_launch_rounded,
                ),
                _MetricCard(
                  title: 'Topics explored',
                  value: '$exploredTopics',
                  subtitle: appConfig.isMock
                      ? 'Different arenas you have already touched'
                      : 'Topics your account has already entered',
                  icon: Icons.hub_rounded,
                ),
                _MetricCard(
                  title: 'Environment',
                  value: appConfig.environment.value,
                  subtitle: appConfig.isMock
                      ? 'Preview mode with local sample data'
                      : 'Live auth and database wiring active',
                  icon: appConfig.isMock
                      ? Icons.explore_rounded
                      : Icons.cloud_done_rounded,
                ),
              ],
            ),
            const SizedBox(height: 22),
            _SectionHeading(
              title: 'What this community should reward',
              subtitle:
                  'The product works best when disagreement stays rigorous and consent-based.',
            ),
            const SizedBox(height: 14),
            const _PrincipleCard(
              icon: Icons.rule_rounded,
              title: 'Debate only where debate is welcome',
              description:
                  'The whole point of Debator is consent. People open the app because they want structured disagreement.',
            ),
            const SizedBox(height: 12),
            const _PrincipleCard(
              icon: Icons.fact_check_rounded,
              title: 'Arguments should be judged on quality',
              description:
                  'The audience should reward reasoning, evidence, and fair rebuttal instead of raw aggression.',
            ),
            const SizedBox(height: 12),
            const _PrincipleCard(
              icon: Icons.balance_rounded,
              title: 'Strong communities separate heat from harm',
              description:
                  'MVP moderation can start simple, but the product should always steer toward thoughtful conflict rather than chaos.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ArenaBackground extends StatelessWidget {
  const _ArenaBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F2E8), Color(0xFFF2E5D6), Color(0xFFF0EEE8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -20,
            child: _GlowOrb(
              size: 280,
              color: const Color(0xFF0F6A67).withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            left: -80,
            top: 160,
            child: _GlowOrb(
              size: 220,
              color: const Color(0xFFC96A33).withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            bottom: -100,
            right: 100,
            child: _GlowOrb(
              size: 260,
              color: const Color(0xFF204C7A).withValues(alpha: 0.10),
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
        boxShadow: [BoxShadow(blurRadius: 120, spreadRadius: 12, color: color)],
      ),
    );
  }
}

class _AdaptiveScrollbar extends StatelessWidget {
  const _AdaptiveScrollbar({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Scrollbar(thumbVisibility: true, child: child);
  }
}

class _ResponsiveWrapGrid extends StatelessWidget {
  const _ResponsiveWrapGrid({
    required this.children,
    required this.maxColumns,
    required this.minItemWidth,
  });

  final List<Widget> children;
  final int maxColumns;
  final double minItemWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final availableWidth = constraints.maxWidth;
        final estimatedColumns =
            ((availableWidth + spacing) / (minItemWidth + spacing)).floor();
        final columns = estimatedColumns.clamp(1, maxColumns);
        final itemWidth = columns == 1
            ? availableWidth
            : (availableWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.liveDebateCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int liveDebateCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Wordmark(),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.14),
                  ),
                  child: const Icon(Icons.bolt_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$liveDebateCount live arenas are active right now.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: NavigationRail(
              extended: true,
              minExtendedWidth: 240,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: Text('Discover'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum_rounded),
                  label: Text('Topics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded),
                  label: Text('Create'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.92),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.86),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Design direction',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Not social media with arguments. A place built for people who actually want the debate.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBottomNavigationBar extends StatelessWidget {
  const _MobileBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.92),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF112B37).withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore_rounded),
                    label: 'Discover',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.forum_outlined),
                    selectedIcon: Icon(Icons.forum_rounded),
                    label: 'Topics',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    selectedIcon: Icon(Icons.add_circle_rounded),
                    label: 'Create',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F6A67), Color(0xFFC96A33)],
            ),
          ),
          child: const Icon(Icons.forum_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debator',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Structured disagreement',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.selectedIndex,
    required this.onCreatePressed,
  });

  final int selectedIndex;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final title = switch (selectedIndex) {
      0 => 'Discover',
      1 => 'Topics',
      2 => 'Create',
      _ => 'Profile',
    };
    final subtitle = switch (selectedIndex) {
      0 => 'Find the debates already attracting strong cases.',
      1 => 'Filter by arena and open the propositions you care about.',
      2 => 'Publish a proposition and invite the other side in.',
      _ => 'See your identity, account status, and community principles.',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isStacked = constraints.maxWidth < 680;

            return Flex(
              direction: isStacked ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isStacked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.72),
                              ),
                        ),
                      ),
                    ],
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.72),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: isStacked ? 0 : 16, height: isStacked ? 16 : 0),
                FilledButton.icon(
                  onPressed: onCreatePressed,
                  icon: const Icon(Icons.add_circle_rounded),
                  label: const Text('New debate'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InlineIdentityNotice extends StatelessWidget {
  const _InlineIdentityNotice({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.84),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_circle_rounded, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.icon, required this.label});

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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.onBrowseTopics,
    required this.onCreateDebate,
  });

  final VoidCallback onBrowseTopics;
  final VoidCallback onCreateDebate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final titleSize = isCompact ? 30.0 : 38.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF123A4A), Color(0xFF0F6A67), Color(0xFFC96A33)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF173247).withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: 40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isCompact ? 22 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Text(
                        'The social network for people who actually want the debate',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        'A home for arguments that actually want structure.',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: titleSize,
                          height: 1.02,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        'Debator is built around consent-based debate: pick a topic, open a proposition, join a side, and argue in rounds instead of chaos.',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.5,
                            ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: onBrowseTopics,
                          icon: const Icon(Icons.travel_explore_rounded),
                          label: const Text('Browse arenas'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onCreateDebate,
                          icon: const Icon(Icons.rocket_launch_rounded),
                          label: const Text('Start a debate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.14),
                  ),
                  child: Icon(icon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSectionHeading extends StatelessWidget {
  const _FormSectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainer.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.76),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 620;

        return Flex(
          direction: stacked ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stacked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(width: stacked ? 0 : 16, height: stacked ? 8 : 0),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        );
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.onTap});

  final DebateTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final topicStyle = topicStyleFor(topic.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          topicStyle.primaryColor,
                          topicStyle.accentColor,
                        ],
                      ),
                    ),
                    child: Icon(topicStyle.icon, color: Colors.white),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(topic.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                topic.tagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.76),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                topic.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.45,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedTopicBanner extends StatelessWidget {
  const _SelectedTopicBanner({required this.topic});

  final DebateTopic topic;

  @override
  Widget build(BuildContext context) {
    final topicStyle = topicStyleFor(topic.id);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            topicStyle.primaryColor.withValues(alpha: 0.92),
            topicStyle.accentColor.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 560;

          return Flex(
            direction: stacked ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                child: Icon(topicStyle.icon, color: Colors.white),
              ),
              SizedBox(width: stacked ? 0 : 14, height: stacked ? 14 : 0),
              if (stacked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.name,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                )
              else
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DebateCard extends StatelessWidget {
  const _DebateCard({
    required this.debate,
    required this.topic,
    required this.compact,
    required this.onTap,
  });

  final Debate debate;
  final DebateTopic? topic;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final topicStyle = topicStyleFor(debate.topicId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: topicStyle.primaryColor.withValues(alpha: 0.10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          topicStyle.icon,
                          size: 18,
                          color: topicStyle.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(topic?.name ?? 'Arena'),
                      ],
                    ),
                  ),
                  _SmallBadge(
                    label: debate.status.label,
                    foregroundColor: _statusColor(context, debate.status),
                    backgroundColor: _statusColor(
                      context,
                      debate.status,
                    ).withValues(alpha: 0.14),
                  ),
                  _SmallBadge(
                    label: debate.format.label,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.10),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                debate.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.76),
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                debate.proposition,
                style: GoogleFonts.spaceGrotesk(
                  textStyle: Theme.of(context).textTheme.titleLarge,
                  fontSize: compact ? 23 : 27,
                  fontWeight: FontWeight.w700,
                  height: 1.18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                debate.overview,
                maxLines: compact ? 4 : 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: [
                  _MetaStat(
                    icon: Icons.thumb_up_alt_outlined,
                    label: '${debate.forSupport} for',
                  ),
                  _MetaStat(
                    icon: Icons.thumb_down_alt_outlined,
                    label: '${debate.againstSupport} against',
                  ),
                  _MetaStat(
                    icon: Icons.visibility_outlined,
                    label: '${debate.watchingNow} watching',
                  ),
                  _MetaStat(
                    icon: Icons.schedule_rounded,
                    label: _timeAgo(debate.createdAt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaStat extends StatelessWidget {
  const _MetaStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.62),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.search_off_rounded),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrincipleCard extends StatelessWidget {
  const _PrincipleCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
              ),
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.74),
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

class _DetailHeroCard extends StatelessWidget {
  const _DetailHeroCard({
    required this.debate,
    required this.topicName,
    required this.topicStyle,
    required this.isJoining,
    required this.onJoin,
  });

  final Debate debate;
  final String topicName;
  final TopicStyle topicStyle;
  final bool isJoining;
  final ValueChanged<DebateSide> onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [topicStyle.primaryColor, topicStyle.accentColor],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroBadge(label: topicName, icon: topicStyle.icon),
                    _HeroBadge(
                      label: debate.status.label,
                      icon: Icons.graphic_eq_rounded,
                    ),
                    _HeroBadge(
                      label: debate.format.label,
                      icon: Icons.rule_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  debate.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  debate.proposition,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: compact ? 29 : 34,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    debate.overview,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.52,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: isJoining
                          ? null
                          : () => onJoin(DebateSide.forSide),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: topicStyle.primaryColor,
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: Text(isJoining ? 'Joining...' : 'Join for'),
                    ),
                    FilledButton.icon(
                      onPressed: isJoining
                          ? null
                          : () => onJoin(DebateSide.against),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: const Text('Join against'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ScoreboardCard extends StatelessWidget {
  const _ScoreboardCard({required this.debate, required this.forRatio});

  final Debate debate;
  final double forRatio;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audience lean',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _AudienceScore(
                    label: 'For',
                    value: debate.forSupport,
                    color: const Color(0xFF0F6A67),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AudienceScore(
                    label: 'Against',
                    value: debate.againstSupport,
                    color: const Color(0xFFC96A33),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: forRatio,
                backgroundColor: const Color(
                  0xFFC96A33,
                ).withValues(alpha: 0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF0F6A67),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: [
                _MetaStat(
                  icon: Icons.visibility_rounded,
                  label: '${debate.watchingNow} watching now',
                ),
                _MetaStat(
                  icon: Icons.people_alt_rounded,
                  label: '${debate.participants.length} participants',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceScore extends StatelessWidget {
  const _AudienceScore({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Text('$value', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _RoundsCard extends StatelessWidget {
  const _RoundsCard({required this.debate, required this.topicStyle});

  final Debate debate;
  final TopicStyle topicStyle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Argument rounds',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final round in debate.rounds) ...[
              _RoundTile(round: round, topicStyle: topicStyle),
              if (round != debate.rounds.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  const _RoundTile({required this.round, required this.topicStyle});

  final DebateRound round;
  final TopicStyle topicStyle;

  @override
  Widget build(BuildContext context) {
    final sideColor = switch (round.side) {
      DebateSide.forSide => const Color(0xFF0F6A67),
      DebateSide.against => const Color(0xFFC96A33),
      DebateSide.undecided => topicStyle.primaryColor,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: sideColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: sideColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _SmallBadge(
                label: round.label,
                foregroundColor: sideColor,
                backgroundColor: sideColor.withValues(alpha: 0.12),
              ),
              Text(
                '${round.speakerName} ${round.speakerHandle}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            round.summary,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 12),
          Text(
            round.evidenceNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsCard extends StatelessWidget {
  const _ParticipantsCard({required this.debate});

  final Debate debate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Participants', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final participant in debate.participants) ...[
              _ParticipantRow(participant: participant),
              if (participant != debate.participants.last)
                const Divider(height: 20),
            ],
            if (debate.needsOpponent) ...[
              const Divider(height: 24),
              Text(
                'This debate still has room for the other side.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({required this.participant});

  final DebateParticipant participant;

  @override
  Widget build(BuildContext context) {
    final sideColor = switch (participant.side) {
      DebateSide.forSide => const Color(0xFF0F6A67),
      DebateSide.against => const Color(0xFFC96A33),
      DebateSide.undecided => Theme.of(context).colorScheme.tertiary,
    };

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: sideColor.withValues(alpha: 0.14),
          child: Text(
            participant.name.characters.first,
            style: TextStyle(color: sideColor, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participant.name,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${participant.handle} • ${participant.side.label}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.72),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _SmallBadge(
          label: '${participant.rating}',
          foregroundColor: sideColor,
          backgroundColor: sideColor.withValues(alpha: 0.12),
        ),
      ],
    );
  }
}

class _JudgingCard extends StatelessWidget {
  const _JudgingCard({required this.judgingPrompt});

  final String judgingPrompt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How the audience should judge',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SelectableText(
              judgingPrompt,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _ArenaBackground(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Wordmark(),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 14),
                Text(
                  'Opening the arena...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(BuildContext context, DebateStatus status) {
  return switch (status) {
    DebateStatus.live => const Color(0xFF0F6A67),
    DebateStatus.scheduled => Theme.of(context).colorScheme.tertiary,
    DebateStatus.closed => Theme.of(context).colorScheme.onSurface,
  };
}

String _timeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}

double _tabBottomPadding(bool isDesktop) {
  return isDesktop ? 28 : 112;
}
