enum ChildAgeRange {
  months0To6('months0To6', '0–6 meses'),
  months6To12('months6To12', '6–12 meses'),
  years1To2('years1To2', '1–2 anos'),
  years2To3('years2To3', '2–3 anos'),
  years3To5('years3To5', '3–5 anos'),
  years5To7('years5To7', '5–7 anos');

  final String storageValue;
  final String label;

  const ChildAgeRange(this.storageValue, this.label);

  static ChildAgeRange? fromStorageValue(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    for (final range in ChildAgeRange.values) {
      if (range.storageValue == normalized) return range;
    }
    return null;
  }
}
