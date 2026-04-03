import 'package:debator/data/repositories/debate_repository.dart';
import 'package:debator/domain/models/debate_models.dart';
import 'package:flutter/foundation.dart';

class DebatorViewModel extends ChangeNotifier {
  DebatorViewModel({
    required DebateRepository repository,
  }) : _repository = repository;

  final DebateRepository _repository;

  bool _isLoading = true;
  bool _isCreating = false;
  bool _hasInitialized = false;
  String? _errorMessage;
  int _selectedTabIndex = 0;
  String? _selectedTopicId;
  String _searchQuery = '';
  final Set<String> _joiningDebateIds = <String>{};

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  int get selectedTabIndex => _selectedTabIndex;
  String? get selectedTopicId => _selectedTopicId;
  String get searchQuery => _searchQuery;

  List<DebateTopic> get topics => _repository.topics;
  List<Debate> get allDebates => _repository.debates;

  List<Debate> get featuredDebates => _repository.debates.take(3).toList();

  List<Debate> get filteredDebates {
    final query = _searchQuery.trim().toLowerCase();
    return _repository.debates.where((debate) {
      final matchesTopic =
          _selectedTopicId == null || debate.topicId == _selectedTopicId;
      final matchesQuery = query.isEmpty ||
          debate.title.toLowerCase().contains(query) ||
          debate.proposition.toLowerCase().contains(query) ||
          debate.overview.toLowerCase().contains(query);
      return matchesTopic && matchesQuery;
    }).toList();
  }

  DebateTopic? get selectedTopic {
    final selectedTopicId = _selectedTopicId;
    if (selectedTopicId == null) {
      return null;
    }
    return topicById(selectedTopicId);
  }

  int get openSeatCount =>
      _repository.debates.where((debate) => debate.needsOpponent).length;

  int get liveDebateCount =>
      _repository.debates.where((debate) => debate.status == DebateStatus.live).length;

  int get totalAudience =>
      _repository.debates.fold(0, (sum, debate) => sum + debate.watchingNow);

  List<Debate> get prototypeUserDebates => _repository.debates.where((debate) {
        return debate.participants.any((participant) => participant.handle == '@you');
      }).toList();

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    _hasInitialized = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.load();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to load the debate arena.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTab(int index) {
    if (_selectedTabIndex == index) {
      return;
    }
    _selectedTabIndex = index;
    notifyListeners();
  }

  void openTopic(String topicId) {
    _selectedTopicId = topicId;
    _selectedTabIndex = 1;
    notifyListeners();
  }

  void selectTopic(String? topicId) {
    if (_selectedTopicId == topicId) {
      return;
    }
    _selectedTopicId = topicId;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) {
      return;
    }
    _searchQuery = value;
    notifyListeners();
  }

  DebateTopic? topicById(String id) {
    for (final topic in _repository.topics) {
      if (topic.id == id) {
        return topic;
      }
    }
    return null;
  }

  Debate? debateById(String id) {
    for (final debate in _repository.debates) {
      if (debate.id == id) {
        return debate;
      }
    }
    return null;
  }

  bool isJoining(String debateId) => _joiningDebateIds.contains(debateId);

  Future<Debate> createDebate(DebateDraft draft) async {
    _isCreating = true;
    notifyListeners();
    try {
      final created = await _repository.createDebate(draft);
      _selectedTopicId = draft.topicId;
      _selectedTabIndex = 1;
      return created;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<Debate> joinDebate({
    required String debateId,
    required DebateSide side,
  }) async {
    _joiningDebateIds.add(debateId);
    notifyListeners();
    try {
      return await _repository.joinDebate(
        debateId: debateId,
        side: side,
      );
    } finally {
      _joiningDebateIds.remove(debateId);
      notifyListeners();
    }
  }
}
