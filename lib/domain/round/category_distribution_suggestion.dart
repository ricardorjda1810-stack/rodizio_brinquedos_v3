class CategoryDistributionSuggestion {
  final Map<String, int> distribution;
  final int total;

  const CategoryDistributionSuggestion({
    required this.distribution,
    required this.total,
  });
}

CategoryDistributionSuggestion buildDistribution(
  int total,
  Iterable<String> categories,
) {
  final categoryNames = categories
      .map((category) => category.trim())
      .where((category) => category.isNotEmpty)
      .toList(growable: false);

  final safeTotal = total < 0 ? 0 : total;
  if (categoryNames.isEmpty || safeTotal == 0) {
    return CategoryDistributionSuggestion(
      distribution: {for (final category in categoryNames) category: 0},
      total: safeTotal,
    );
  }

  final baseQuota = safeTotal ~/ categoryNames.length;
  var remaining = safeTotal % categoryNames.length;

  final distribution = <String, int>{};
  for (final category in categoryNames) {
    final extra = remaining > 0 ? 1 : 0;
    distribution[category] = baseQuota + extra;
    if (remaining > 0) remaining--;
  }

  return CategoryDistributionSuggestion(
    distribution: distribution,
    total: safeTotal,
  );
}
