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

  test('presets oficiais somam os totais esperados', () {
    expect(AgePresetCatalog.presetFor(ChildAgeRange.months0To6).total, 4);
    expect(AgePresetCatalog.presetFor(ChildAgeRange.months6To12).total, 5);
    expect(AgePresetCatalog.presetFor(ChildAgeRange.years1To2).total, 6);
    expect(AgePresetCatalog.presetFor(ChildAgeRange.years2To3).total, 8);
    expect(AgePresetCatalog.presetFor(ChildAgeRange.years3To5).total, 9);
    expect(AgePresetCatalog.presetFor(ChildAgeRange.years5To7).total, 10);
  });
}
