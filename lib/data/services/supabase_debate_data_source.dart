import 'dart:math' as math;

import 'package:debator/data/services/debate_data_source.dart';
import 'package:debator/domain/models/debate_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDebateDataSource implements DebateDataSource {
  SupabaseDebateDataSource({required SupabaseClient client}) : _client = client;

  static const _openingLabel = 'Opening case';

  final SupabaseClient _client;

  @override
  Future<List<DebateTopic>> fetchTopics() async {
    final rows = await _client
        .from('topics')
        .select()
        .order('sort_order')
        .order('name');

    return rows.map(_mapTopic).toList(growable: false);
  }

  @override
  Future<List<Debate>> fetchDebates() async {
    final rows = await _client
        .from('debates')
        .select(_debateSelect)
        .order('created_at', ascending: false);

    return rows.map(_mapDebate).toList(growable: false);
  }

  @override
  Future<Debate> createDebate(DebateDraft draft) async {
    final user = _requireUser();

    final insertedDebate = await _client
        .from('debates')
        .insert({
          'created_by': user.id,
          'topic_id': draft.topicId,
          'title': draft.title,
          'proposition': draft.proposition,
          'overview': draft.overview,
          'status': 'live',
          'format': _formatValue(draft.format),
          'judging_prompt': draft.judgingPrompt,
          'watching_now': 1,
        })
        .select('id')
        .single();

    final debateId = insertedDebate['id'] as String;

    await _client.from('debate_participants').upsert({
      'debate_id': debateId,
      'profile_id': user.id,
      'side': _sideValue(draft.startingSide),
      'rating_snapshot': 1200,
    }, onConflict: 'debate_id,profile_id');

    await _client.from('debate_votes').upsert({
      'debate_id': debateId,
      'voter_id': user.id,
      'side': _sideValue(draft.startingSide),
    }, onConflict: 'debate_id,voter_id');

    await _client.from('debate_rounds').insert({
      'debate_id': debateId,
      'speaker_profile_id': user.id,
      'side': _sideValue(draft.startingSide),
      'label': _openingLabel,
      'summary': draft.openingStatement,
      'evidence_note': 'Opening statement submitted from Debator.',
      'round_order': 1,
    });

    return _fetchDebateById(debateId);
  }

  @override
  Future<Debate> joinDebate({
    required String debateId,
    required DebateSide side,
  }) async {
    final user = _requireUser();

    await _client.from('debate_participants').upsert({
      'debate_id': debateId,
      'profile_id': user.id,
      'side': _sideValue(side),
      'rating_snapshot': 1200,
    }, onConflict: 'debate_id,profile_id');

    await _client.from('debate_votes').upsert({
      'debate_id': debateId,
      'voter_id': user.id,
      'side': _sideValue(side),
    }, onConflict: 'debate_id,voter_id');

    final existingDebate = await _client
        .from('debates')
        .select('watching_now')
        .eq('id', debateId)
        .single();

    final watchingNow = (existingDebate['watching_now'] as int?) ?? 0;

    await _client
        .from('debates')
        .update({'watching_now': math.max(1, watchingNow + 1)})
        .eq('id', debateId);

    return _fetchDebateById(debateId);
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError(
        'Authentication is required before you can create or join debates.',
      );
    }
    return user;
  }

  Future<Debate> _fetchDebateById(String debateId) async {
    final row = await _client
        .from('debates')
        .select(_debateSelect)
        .eq('id', debateId)
        .single();

    return _mapDebate(row);
  }

  DebateTopic _mapTopic(Map<String, dynamic> row) {
    return DebateTopic(
      id: row['id'] as String,
      name: row['name'] as String,
      tagline: row['tagline'] as String,
      description: row['description'] as String,
    );
  }

  Debate _mapDebate(Map<String, dynamic> row) {
    final voteRows = (row['debate_votes'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final participantRows =
        (row['debate_participants'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
    final roundRows = (row['debate_rounds'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    final forSupport = voteRows.where((vote) => vote['side'] == 'for').length;
    final againstSupport = voteRows
        .where((vote) => vote['side'] == 'against')
        .length;

    final participants = participantRows
        .map(_mapParticipant)
        .toList(growable: false);
    final rounds =
        (roundRows..sort(
              (left, right) => ((left['round_order'] as int?) ?? 0).compareTo(
                (right['round_order'] as int?) ?? 0,
              ),
            ))
            .map(_mapRound)
            .toList(growable: false);

    return Debate(
      id: row['id'] as String,
      title: row['title'] as String,
      proposition: row['proposition'] as String,
      overview: row['overview'] as String,
      topicId: row['topic_id'] as String,
      status: _statusFromValue(row['status'] as String),
      format: _formatFromValue(row['format'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      judgingPrompt: row['judging_prompt'] as String,
      forSupport: forSupport,
      againstSupport: againstSupport,
      watchingNow: (row['watching_now'] as int?) ?? 0,
      participants: participants,
      rounds: rounds,
    );
  }

  DebateParticipant _mapParticipant(Map<String, dynamic> row) {
    final profile = (row['profile'] as Map<String, dynamic>? ?? const {});

    return DebateParticipant(
      id: (profile['id'] ?? row['profile_id'] ?? row['id']) as String,
      name: (profile['display_name'] ?? 'Debator') as String,
      handle: (profile['handle'] ?? '@debator') as String,
      side: _sideFromValue(row['side'] as String),
      rating: (row['rating_snapshot'] as int?) ?? 1200,
    );
  }

  DebateRound _mapRound(Map<String, dynamic> row) {
    final profile = (row['profile'] as Map<String, dynamic>? ?? const {});

    return DebateRound(
      id: row['id'] as String,
      label: row['label'] as String,
      speakerName: (profile['display_name'] ?? 'Debator') as String,
      speakerHandle: (profile['handle'] ?? '@debator') as String,
      side: _sideFromValue(row['side'] as String),
      summary: row['summary'] as String,
      evidenceNote: (row['evidence_note'] as String?) ?? '',
    );
  }

  static const String _debateSelect = '''
id,
title,
proposition,
overview,
topic_id,
status,
format,
created_at,
judging_prompt,
watching_now,
debate_votes (
  side
),
debate_participants (
  id,
  profile_id,
  side,
  rating_snapshot,
  profile:profiles!debate_participants_profile_id_fkey (
    id,
    display_name,
    handle
  )
),
debate_rounds (
  id,
  label,
  side,
  summary,
  evidence_note,
  round_order,
  speaker_profile_id,
  profile:profiles!debate_rounds_speaker_profile_id_fkey (
    id,
    display_name,
    handle
  )
)
''';
}

DebateStatus _statusFromValue(String value) {
  return switch (value) {
    'live' => DebateStatus.live,
    'scheduled' => DebateStatus.scheduled,
    'closed' => DebateStatus.closed,
    _ => DebateStatus.live,
  };
}

String _formatValue(DebateFormat format) {
  return switch (format) {
    DebateFormat.quickfire => 'quickfire',
    DebateFormat.structured => 'structured',
    DebateFormat.tribunal => 'tribunal',
  };
}

DebateFormat _formatFromValue(String value) {
  return switch (value) {
    'quickfire' => DebateFormat.quickfire,
    'structured' => DebateFormat.structured,
    'tribunal' => DebateFormat.tribunal,
    _ => DebateFormat.structured,
  };
}

String _sideValue(DebateSide side) {
  return switch (side) {
    DebateSide.forSide => 'for',
    DebateSide.against => 'against',
    DebateSide.undecided => 'undecided',
  };
}

DebateSide _sideFromValue(String value) {
  return switch (value) {
    'for' => DebateSide.forSide,
    'against' => DebateSide.against,
    'undecided' => DebateSide.undecided,
    _ => DebateSide.undecided,
  };
}
