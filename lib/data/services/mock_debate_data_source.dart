import 'dart:math' as math;

import 'package:debator/data/services/debate_data_source.dart';
import 'package:debator/domain/models/debate_models.dart';

class MockDebateDataSource implements DebateDataSource {
  MockDebateDataSource() : _topics = _buildTopics(), _debates = _buildDebates();

  static const _demoUserName = 'You';
  static const _demoHandle = '@you';

  final List<DebateTopic> _topics;
  List<Debate> _debates;

  @override
  Future<List<DebateTopic>> fetchTopics() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<DebateTopic>.unmodifiable(_topics);
  }

  @override
  Future<List<Debate>> fetchDebates() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    return List<Debate>.unmodifiable(_debates);
  }

  @override
  Future<Debate> createDebate(DebateDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final now = DateTime.now();

    final createdDebate = Debate(
      id: 'debate-${now.microsecondsSinceEpoch}',
      title: draft.title,
      proposition: draft.proposition,
      overview: draft.overview,
      topicId: draft.topicId,
      status: DebateStatus.live,
      format: draft.format,
      createdAt: now,
      judgingPrompt: draft.judgingPrompt,
      forSupport: draft.startingSide == DebateSide.forSide ? 1 : 0,
      againstSupport: draft.startingSide == DebateSide.against ? 1 : 0,
      watchingNow: 12,
      participants: [
        DebateParticipant(
          id: 'prototype-user',
          name: _demoUserName,
          handle: _demoHandle,
          side: draft.startingSide,
          rating: 1280,
        ),
      ],
      rounds: [
        DebateRound(
          id: 'round-${now.microsecondsSinceEpoch}',
          label: 'Opening case',
          speakerName: _demoUserName,
          speakerHandle: _demoHandle,
          side: draft.startingSide,
          summary: draft.openingStatement,
          evidenceNote: 'Demo draft submitted locally from the product preview.',
        ),
      ],
    );

    _debates = [createdDebate, ..._debates];
    return createdDebate;
  }

  @override
  Future<Debate> joinDebate({
    required String debateId,
    required DebateSide side,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final index = _debates.indexWhere((debate) => debate.id == debateId);
    if (index == -1) {
      throw StateError('Debate $debateId was not found.');
    }

    final debate = _debates[index];
    final participants = List<DebateParticipant>.from(debate.participants);
    var forSupport = debate.forSupport;
    var againstSupport = debate.againstSupport;

    final existingIndex = participants.indexWhere(
      (participant) => participant.handle == _demoHandle,
    );

    if (existingIndex == -1) {
      participants.add(
        DebateParticipant(
          id: 'prototype-user',
          name: _demoUserName,
          handle: _demoHandle,
          side: side,
          rating: 1280,
        ),
      );
      if (side == DebateSide.forSide) {
        forSupport += 1;
      } else if (side == DebateSide.against) {
        againstSupport += 1;
      }
    } else {
      final existing = participants[existingIndex];
      if (existing.side == side) {
        return debate;
      }
      if (existing.side == DebateSide.forSide) {
        forSupport = math.max(0, forSupport - 1);
      }
      if (existing.side == DebateSide.against) {
        againstSupport = math.max(0, againstSupport - 1);
      }
      if (side == DebateSide.forSide) {
        forSupport += 1;
      }
      if (side == DebateSide.against) {
        againstSupport += 1;
      }
      participants[existingIndex] = existing.copyWith(side: side);
    }

    final updated = debate.copyWith(
      participants: participants,
      forSupport: forSupport,
      againstSupport: againstSupport,
      watchingNow: debate.watchingNow + 1,
    );

    _debates[index] = updated;
    return updated;
  }
}

List<DebateTopic> _buildTopics() {
  return const [
    DebateTopic(
      id: 'religion',
      name: 'Religion',
      tagline: 'Doctrine, scripture, and meaning.',
      description:
          'Arguments about faith, theology, comparative religion, and spiritual claims.',
    ),
    DebateTopic(
      id: 'science',
      name: 'Science',
      tagline: 'Claims that survive evidence.',
      description:
          'Debates about physics, biology, medicine, climate, and the scientific method.',
    ),
    DebateTopic(
      id: 'philosophy',
      name: 'Philosophy',
      tagline: 'Logic, consciousness, and truth.',
      description:
          'Metaphysics, epistemology, free will, identity, and the structure of arguments.',
    ),
    DebateTopic(
      id: 'politics',
      name: 'Politics',
      tagline: 'Power, policy, and public systems.',
      description:
          'Political theory, government design, voting systems, and current policy.',
    ),
    DebateTopic(
      id: 'ethics',
      name: 'Ethics',
      tagline: 'What should we permit or prohibit?',
      description:
          'Moral frameworks, social dilemmas, justice, fairness, and applied ethics.',
    ),
    DebateTopic(
      id: 'technology',
      name: 'Technology',
      tagline: 'Innovation with tradeoffs.',
      description:
          'AI, software, privacy, platforms, hardware, and the effect of tools on society.',
    ),
    DebateTopic(
      id: 'history',
      name: 'History',
      tagline: 'Interpretation shaped by evidence.',
      description:
          'Historical causation, revisionism, legacy, and lessons from past events.',
    ),
    DebateTopic(
      id: 'culture',
      name: 'Culture',
      tagline: 'Stories, values, and identity.',
      description:
          'Media, norms, language, education, and how communities define themselves.',
    ),
    DebateTopic(
      id: 'sports',
      name: 'Sports',
      tagline: 'Competition deserves analysis too.',
      description:
          'Rules, strategy, officiating, player legacy, and how sport changes over time.',
    ),
    DebateTopic(
      id: 'economics',
      name: 'Economics',
      tagline: 'Markets, incentives, and inequality.',
      description:
          'Growth, labor, redistribution, scarcity, and what efficient systems should optimize.',
    ),
  ];
}

List<Debate> _buildDebates() {
  final now = DateTime.now();

  return [
    Debate(
      id: 'morality-without-religion',
      title: 'Moral Compass',
      proposition: 'Morality can exist without religion.',
      overview:
          'A structured ethics debate on whether moral obligations need divine grounding or whether secular frameworks are enough.',
      topicId: 'religion',
      status: DebateStatus.live,
      format: DebateFormat.structured,
      createdAt: now.subtract(const Duration(hours: 2)),
      judgingPrompt:
          'Judge the side that best explains moral obligation, accountability, and consistency.',
      forSupport: 48,
      againstSupport: 39,
      watchingNow: 112,
      participants: const [
        DebateParticipant(
          id: 'u1',
          name: 'Amina Noor',
          handle: '@amina',
          side: DebateSide.forSide,
          rating: 1540,
        ),
        DebateParticipant(
          id: 'u2',
          name: 'David Cole',
          handle: '@dcole',
          side: DebateSide.against,
          rating: 1490,
        ),
      ],
      rounds: const [
        DebateRound(
          id: 'r1',
          label: 'Opening case',
          speakerName: 'Amina Noor',
          speakerHandle: '@amina',
          side: DebateSide.forSide,
          summary:
              'Moral rules can emerge from human flourishing, reciprocity, and harm reduction without invoking revelation.',
          evidenceNote:
              'References secular ethics, game theory, and cross-cultural overlap in moral intuitions.',
        ),
        DebateRound(
          id: 'r2',
          label: 'Opening rebuttal',
          speakerName: 'David Cole',
          speakerHandle: '@dcole',
          side: DebateSide.against,
          summary:
              'Without a transcendent source, moral duties become preferences with no ultimate authority over the individual.',
          evidenceNote:
              'Draws from divine command theory and critiques moral realism without metaphysical grounding.',
        ),
      ],
    ),
    Debate(
      id: 'ai-job-creation',
      title: 'Automation Dividend',
      proposition:
          'AI will create more jobs than it destroys over the next decade.',
      overview:
          'A technology and economics debate about labor displacement, new categories of work, and the pace of skill shifts.',
      topicId: 'technology',
      status: DebateStatus.live,
      format: DebateFormat.tribunal,
      createdAt: now.subtract(const Duration(hours: 5)),
      judgingPrompt:
          'Judge on labor market evidence, transition costs, and whether net job creation matters more than disruption.',
      forSupport: 61,
      againstSupport: 73,
      watchingNow: 184,
      participants: const [
        DebateParticipant(
          id: 'u3',
          name: 'Elias Grant',
          handle: '@elias',
          side: DebateSide.forSide,
          rating: 1620,
        ),
        DebateParticipant(
          id: 'u4',
          name: 'Ruth Kamau',
          handle: '@ruthk',
          side: DebateSide.against,
          rating: 1575,
        ),
      ],
      rounds: const [
        DebateRound(
          id: 'r3',
          label: 'Opening case',
          speakerName: 'Elias Grant',
          speakerHandle: '@elias',
          side: DebateSide.forSide,
          summary:
              'General-purpose technologies tend to create supporting industries and entirely new services once adoption scales.',
          evidenceNote:
              'Compares AI to prior automation waves and highlights productivity spillovers.',
        ),
        DebateRound(
          id: 'r4',
          label: 'Cross-exam',
          speakerName: 'Ruth Kamau',
          speakerHandle: '@ruthk',
          side: DebateSide.against,
          summary:
              'Job creation is meaningless if transition speed outpaces retraining, concentrates gains, and permanently weakens bargaining power.',
          evidenceNote:
              'Frames the issue around worker leverage, not just total employment count.',
        ),
      ],
    ),
    Debate(
      id: 'free-will-illusion',
      title: 'Choice or Chemistry',
      proposition: 'Free will is an illusion.',
      overview:
          'A philosophy and science debate about determinism, agency, consciousness, and responsibility.',
      topicId: 'philosophy',
      status: DebateStatus.live,
      format: DebateFormat.structured,
      createdAt: now.subtract(const Duration(days: 1, hours: 1)),
      judgingPrompt:
          'Judge the stronger account of agency: explanatory power, lived experience, and implications for responsibility.',
      forSupport: 77,
      againstSupport: 68,
      watchingNow: 95,
      participants: const [
        DebateParticipant(
          id: 'u5',
          name: 'Milo Chen',
          handle: '@milo',
          side: DebateSide.forSide,
          rating: 1680,
        ),
        DebateParticipant(
          id: 'u6',
          name: 'Salma Yusuf',
          handle: '@salma',
          side: DebateSide.against,
          rating: 1705,
        ),
      ],
      rounds: const [
        DebateRound(
          id: 'r5',
          label: 'Opening case',
          speakerName: 'Milo Chen',
          speakerHandle: '@milo',
          side: DebateSide.forSide,
          summary:
              'Every conscious choice arises from prior causes the self did not author, making libertarian freedom incoherent.',
          evidenceNote:
              'References causal chains, neuroscientific timing arguments, and critiques of contra-causal choice.',
        ),
        DebateRound(
          id: 'r6',
          label: 'Rebuttal',
          speakerName: 'Salma Yusuf',
          speakerHandle: '@salma',
          side: DebateSide.against,
          summary:
              'Agency can remain real under a compatibilist model where reflective control, not metaphysical randomness, grounds responsibility.',
          evidenceNote:
              'Distinguishes coercion from self-governed action and argues determinism does not erase ownership.',
        ),
      ],
    ),
    Debate(
      id: 'gene-editing-enhancement',
      title: 'Enhanced Humanity',
      proposition: 'Gene editing for human enhancement should be legal.',
      overview:
          'A science and ethics debate on whether enhancement uses of CRISPR should be regulated, restricted, or permitted.',
      topicId: 'science',
      status: DebateStatus.live,
      format: DebateFormat.quickfire,
      createdAt: now.subtract(const Duration(days: 1, hours: 7)),
      judgingPrompt:
          'Judge based on consent, inequality, public health risk, and the line between therapy and enhancement.',
      forSupport: 42,
      againstSupport: 64,
      watchingNow: 76,
      participants: const [
        DebateParticipant(
          id: 'u7',
          name: 'Leah Park',
          handle: '@leah',
          side: DebateSide.forSide,
          rating: 1450,
        ),
        DebateParticipant(
          id: 'u8',
          name: 'Harun Warsame',
          handle: '@harun',
          side: DebateSide.against,
          rating: 1515,
        ),
      ],
      rounds: const [
        DebateRound(
          id: 'r7',
          label: 'Quickfire 1',
          speakerName: 'Leah Park',
          speakerHandle: '@leah',
          side: DebateSide.forSide,
          summary:
              'If safe enhancement exists, banning it simply privileges those with existing advantages while blocking broader access.',
          evidenceNote:
              'Focuses on autonomy and fairness through regulated access rather than prohibition.',
        ),
        DebateRound(
          id: 'r8',
          label: 'Quickfire 2',
          speakerName: 'Harun Warsame',
          speakerHandle: '@harun',
          side: DebateSide.against,
          summary:
              'Enhancement markets pressure parents, deepen class divides, and make consent impossible for future persons.',
          evidenceNote:
              'Separates therapeutic correction from social arms races.',
        ),
      ],
    ),
    Debate(
      id: 'ranked-choice-voting',
      title: 'Ballot Design',
      proposition:
          'Ranked-choice voting would improve democracy more than it complicates it.',
      overview:
          'A politics debate on representation, strategic voting, coalition incentives, and voter comprehension.',
      topicId: 'politics',
      status: DebateStatus.live,
      format: DebateFormat.structured,
      createdAt: now.subtract(const Duration(days: 2)),
      judgingPrompt:
          'Judge on democratic legitimacy, strategic behavior, voter confusion, and practical implementation.',
      forSupport: 53,
      againstSupport: 31,
      watchingNow: 58,
      participants: const [
        DebateParticipant(
          id: 'u9',
          name: 'Nadia Green',
          handle: '@nadia',
          side: DebateSide.forSide,
          rating: 1470,
        ),
      ],
      rounds: const [
        DebateRound(
          id: 'r9',
          label: 'Opening case',
          speakerName: 'Nadia Green',
          speakerHandle: '@nadia',
          side: DebateSide.forSide,
          summary:
              'Ranked ballots reduce spoiler effects and reward candidates who can build broader legitimacy.',
          evidenceNote:
              'Frames the reform as a way to reduce zero-sum incentives.',
        ),
      ],
    ),
    Debate(
      id: 'var-improved-football',
      title: 'Video Review',
      proposition: 'VAR has improved football more than it has harmed it.',
      overview:
          'A sports debate about accuracy, flow, emotional disruption, and the meaning of fairness in officiating.',
      topicId: 'sports',
      status: DebateStatus.scheduled,
      format: DebateFormat.quickfire,
      createdAt: now.subtract(const Duration(days: 3, hours: 3)),
      judgingPrompt:
          'Judge on fairness, entertainment, pace of play, and whether accuracy is worth interruption.',
      forSupport: 18,
      againstSupport: 25,
      watchingNow: 40,
      participants: const [
        DebateParticipant(
          id: 'u10',
          name: 'Yara Bell',
          handle: '@yarab',
          side: DebateSide.forSide,
          rating: 1310,
        ),
        DebateParticipant(
          id: 'u11',
          name: 'Kojo Mensah',
          handle: '@kojo',
          side: DebateSide.against,
          rating: 1365,
        ),
      ],
      rounds: const [
        DebateRound(
          id: 'r10',
          label: 'Preview',
          speakerName: 'Moderator',
          speakerHandle: '@arena',
          side: DebateSide.undecided,
          summary:
              'Debate begins tonight with a focus on the balance between emotional spontaneity and officiating accuracy.',
          evidenceNote: 'Prototype session waiting on live kickoff.',
        ),
      ],
    ),
  ];
}
