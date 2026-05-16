import '../../core/crisis_detection/baseline_profile.dart';

class BaselineProfileRepository {
  BaselineProfile? _current;

  void save(BaselineProfile profile) {
    _current = profile;
  }

  BaselineProfile? getCurrent() {
    return _current;
  }

  void clear() {
    _current = null;
  }
}
