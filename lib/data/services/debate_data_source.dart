import 'package:debator/domain/models/debate_models.dart';

abstract class DebateDataSource {
  Future<List<DebateTopic>> fetchTopics();

  Future<List<Debate>> fetchDebates();

  Future<Debate> createDebate(DebateDraft draft);

  Future<Debate> joinDebate({
    required String debateId,
    required DebateSide side,
  });
}
