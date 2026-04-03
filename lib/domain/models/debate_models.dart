enum DebateSide {
  forSide,
  against,
  undecided,
}

extension DebateSideLabels on DebateSide {
  String get label => switch (this) {
        DebateSide.forSide => 'For',
        DebateSide.against => 'Against',
        DebateSide.undecided => 'Undecided',
      };
}

enum DebateStatus {
  live,
  scheduled,
  closed,
}

extension DebateStatusLabels on DebateStatus {
  String get label => switch (this) {
        DebateStatus.live => 'Live',
        DebateStatus.scheduled => 'Scheduled',
        DebateStatus.closed => 'Closed',
      };
}

enum DebateFormat {
  quickfire,
  structured,
  tribunal,
}

extension DebateFormatLabels on DebateFormat {
  String get label => switch (this) {
        DebateFormat.quickfire => 'Quickfire',
        DebateFormat.structured => 'Structured',
        DebateFormat.tribunal => 'Tribunal',
      };

  String get description => switch (this) {
        DebateFormat.quickfire =>
          'Fast turn-taking with concise cases and rebuttals.',
        DebateFormat.structured =>
          'Opening case, rebuttal, and closing summary rounds.',
        DebateFormat.tribunal =>
          'Audience-driven debate judged on evidence and precision.',
      };
}

class DebateTopic {
  const DebateTopic({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
}

class DebateParticipant {
  const DebateParticipant({
    required this.id,
    required this.name,
    required this.handle,
    required this.side,
    required this.rating,
  });

  final String id;
  final String name;
  final String handle;
  final DebateSide side;
  final int rating;

  DebateParticipant copyWith({
    String? id,
    String? name,
    String? handle,
    DebateSide? side,
    int? rating,
  }) {
    return DebateParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      side: side ?? this.side,
      rating: rating ?? this.rating,
    );
  }
}

class DebateRound {
  const DebateRound({
    required this.id,
    required this.label,
    required this.speakerName,
    required this.speakerHandle,
    required this.side,
    required this.summary,
    required this.evidenceNote,
  });

  final String id;
  final String label;
  final String speakerName;
  final String speakerHandle;
  final DebateSide side;
  final String summary;
  final String evidenceNote;
}

class Debate {
  const Debate({
    required this.id,
    required this.title,
    required this.proposition,
    required this.overview,
    required this.topicId,
    required this.status,
    required this.format,
    required this.createdAt,
    required this.judgingPrompt,
    required this.forSupport,
    required this.againstSupport,
    required this.watchingNow,
    required this.participants,
    required this.rounds,
  });

  final String id;
  final String title;
  final String proposition;
  final String overview;
  final String topicId;
  final DebateStatus status;
  final DebateFormat format;
  final DateTime createdAt;
  final String judgingPrompt;
  final int forSupport;
  final int againstSupport;
  final int watchingNow;
  final List<DebateParticipant> participants;
  final List<DebateRound> rounds;

  int get totalSupport => forSupport + againstSupport;

  bool get needsOpponent {
    final activeSides = participants
        .where((participant) => participant.side != DebateSide.undecided)
        .map((participant) => participant.side)
        .toSet();
    return activeSides.length < 2;
  }

  Debate copyWith({
    String? id,
    String? title,
    String? proposition,
    String? overview,
    String? topicId,
    DebateStatus? status,
    DebateFormat? format,
    DateTime? createdAt,
    String? judgingPrompt,
    int? forSupport,
    int? againstSupport,
    int? watchingNow,
    List<DebateParticipant>? participants,
    List<DebateRound>? rounds,
  }) {
    return Debate(
      id: id ?? this.id,
      title: title ?? this.title,
      proposition: proposition ?? this.proposition,
      overview: overview ?? this.overview,
      topicId: topicId ?? this.topicId,
      status: status ?? this.status,
      format: format ?? this.format,
      createdAt: createdAt ?? this.createdAt,
      judgingPrompt: judgingPrompt ?? this.judgingPrompt,
      forSupport: forSupport ?? this.forSupport,
      againstSupport: againstSupport ?? this.againstSupport,
      watchingNow: watchingNow ?? this.watchingNow,
      participants: participants ?? this.participants,
      rounds: rounds ?? this.rounds,
    );
  }
}

class DebateDraft {
  const DebateDraft({
    required this.title,
    required this.proposition,
    required this.topicId,
    required this.overview,
    required this.startingSide,
    required this.format,
    required this.openingStatement,
    required this.judgingPrompt,
  });

  final String title;
  final String proposition;
  final String topicId;
  final String overview;
  final DebateSide startingSide;
  final DebateFormat format;
  final String openingStatement;
  final String judgingPrompt;
}
