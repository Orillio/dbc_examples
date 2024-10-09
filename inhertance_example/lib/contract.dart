abstract class Contract {
  Map<String, bool> _invariantAsserts = {};
  Map<String, bool> get invariantAsserts => _invariantAsserts;

  void _checkAsserts(Map<String, bool> asserts) {
    for (final item in asserts.entries) {
      assert(item.value, item.key);
    }
  }

  void _checkInvariant() {
    if (invariantAsserts.isEmpty) return;
    _checkAsserts(invariantAsserts);
  }

  void ensure(Map<String, bool> asserts) {
    _checkInvariant();
    _checkAsserts(asserts);
  }

  void require(Map<String, bool> asserts) {
    _checkInvariant();
    _checkAsserts(asserts);
  }
}
