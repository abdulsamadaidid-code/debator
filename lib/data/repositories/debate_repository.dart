import 'package:debator/data/services/debate_data_source.dart';
import 'package:debator/domain/models/debate_models.dart';

class DebateRepository {
  DebateRepository({required DebateDataSource dataSource})
    : _dataSource = dataSource;

  final DebateDataSource _dataSource;

  List<DebateTopic> _topics = const [];
  List<Debate> _debates = const [];

  List<DebateTopic> get topics => List<DebateTopic>.unmodifiable(_topics);

  List<Debate> get debates => List<Debate>.unmodifiable(_debates);

  Future<void> load() async {
    final topics = await _dataSource.fetchTopics();
    final debates = await _dataSource.fetchDebates();

    _topics = topics;
    _debates = List<Debate>.from(debates)
      ..sort(
        (left, right) =>
            _engagementScore(right).compareTo(_engagementScore(left)),
      );
  }

  Future<Debate> createDebate(DebateDraft draft) async {
    final debate = await _dataSource.createDebate(draft);
    _upsert(debate);
    return debate;
  }

  Future<Debate> joinDebate({
    required String debateId,
    required DebateSide side,
  }) async {
    final debate = await _dataSource.joinDebate(debateId: debateId, side: side);
    _upsert(debate);
    return debate;
  }

  void _upsert(Debate debate) {
    final next = List<Debate>.from(_debates);
    final index = next.indexWhere((item) => item.id == debate.id);
    if (index == -1) {
      next.insert(0, debate);
    } else {
      next[index] = debate;
    }
    next.sort(
      (left, right) =>
          _engagementScore(right).compareTo(_engagementScore(left)),
    );
    _debates = next;
  }

  int _engagementScore(Debate debate) {
    final freshnessBonus = debate.createdAt.millisecondsSinceEpoch ~/ 10000000;
    return (debate.totalSupport * 3) + debate.watchingNow + freshnessBonus;
  }
}
