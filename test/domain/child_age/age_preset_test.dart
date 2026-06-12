import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';

void main() {
  test('ChildAgeRange possui os 6 labels corretos', () {
    expect(
      ChildAgeRange.values.map((range) => range.label),
      <String>[
        '0–6 meses',
        '6–12 meses',
        '1–2 anos',
        '2–3 anos',
        '3–5 anos',
        '5–7 anos',
      ],
    );
  });

  test('presets oficiais somam base e fim de semana esperados', () {
    expectPreset(
      ChildAgeRange.months0To6,
      baseTotal: 4,
      saturdayExtraCategoryId: 'exploracao',
      sundayExtraCategoryId: 'comunicacao',
    );
    expectPreset(
      ChildAgeRange.months6To12,
      baseTotal: 5,
      saturdayExtraCategoryId: 'corpo',
      sundayExtraCategoryId: 'exploracao',
    );
    expectPreset(
      ChildAgeRange.years1To2,
      baseTotal: 6,
      saturdayExtraCategoryId: 'corpo',
      sundayExtraCategoryId: 'imaginacao',
    );
    expectPreset(
      ChildAgeRange.years2To3,
      baseTotal: 8,
      saturdayExtraCategoryId: 'corpo',
      sundayExtraCategoryId: 'imaginacao',
    );
    expectPreset(
      ChildAgeRange.years3To5,
      baseTotal: 9,
      saturdayExtraCategoryId: 'corpo',
      sundayExtraCategoryId: 'comunicacao',
    );
    expectPreset(
      ChildAgeRange.years5To7,
      baseTotal: 10,
      saturdayExtraCategoryId: 'imaginacao',
      sundayExtraCategoryId: 'comunicacao',
    );
  });
}

void expectPreset(
  ChildAgeRange ageRange, {
  required int baseTotal,
  required String saturdayExtraCategoryId,
  required String sundayExtraCategoryId,
}) {
  final preset = AgePresetCatalog.presetFor(ageRange);
  final base = preset.quotasByCategoryId;
  final saturday = preset.quotasForWeekday(DateTime.saturday);
  final sunday = preset.quotasForWeekday(DateTime.sunday);

  expect(preset.total, baseTotal);
  expect(preset.totalForWeekday(DateTime.monday), baseTotal);
  expect(preset.totalForWeekday(DateTime.saturday), baseTotal + 1);
  expect(preset.totalForWeekday(DateTime.sunday), baseTotal + 1);

  for (final entry in base.entries) {
    final saturdayExpected =
        entry.key == saturdayExtraCategoryId ? entry.value + 1 : entry.value;
    final sundayExpected =
        entry.key == sundayExtraCategoryId ? entry.value + 1 : entry.value;

    expect(saturday[entry.key], saturdayExpected);
    expect(sunday[entry.key], sundayExpected);
  }
}
