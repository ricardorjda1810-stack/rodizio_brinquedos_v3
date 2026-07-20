import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/services/toy_recognition_service.dart';

void main() {
  const allowedCategoryIds = <String>{'maos', 'imaginacao', 'corpo'};

  group('ToyRecognitionResult.fromCallableData', () {
    test('normalizes a valid recognition result', () {
      final result = ToyRecognitionResult.fromCallableData(<String, Object?>{
        'suggestedName': '  Blocos coloridos  ',
        'categoryId': 'maos',
        'confidence': 0.94,
        'alternativeCategoryIds': <String>[
          'imaginacao',
          'inexistente',
          'imaginacao',
          'corpo',
        ],
        'explanation': 'Peças para montar e empilhar.',
        'needsReview': false,
        'modelVersion': 'vision-test',
      }, allowedCategoryIds: allowedCategoryIds);

      expect(result.suggestedName, 'Blocos coloridos');
      expect(result.categoryId, 'maos');
      expect(result.confidence, 0.94);
      expect(result.alternativeCategoryIds, <String>['imaginacao', 'corpo']);
      expect(result.needsReview, isFalse);
    });

    test('marks a low-confidence result for review by default', () {
      final result = ToyRecognitionResult.fromCallableData(<String, Object?>{
        'suggestedName': 'Carrinho',
        'categoryId': 'corpo',
        'confidence': 0.4,
      }, allowedCategoryIds: allowedCategoryIds);

      expect(result.needsReview, isTrue);
    });

    test('rejects a category outside the app taxonomy', () {
      expect(
        () => ToyRecognitionResult.fromCallableData(<String, Object?>{
          'suggestedName': 'Carrinho',
          'categoryId': 'veiculos',
          'confidence': 0.9,
        }, allowedCategoryIds: allowedCategoryIds),
        throwsA(
          isA<ToyRecognitionException>().having(
            (error) => error.failure,
            'failure',
            ToyRecognitionFailure.invalidResponse,
          ),
        ),
      );
    });

    test('rejects an empty suggested name', () {
      expect(
        () => ToyRecognitionResult.fromCallableData(<String, Object?>{
          'suggestedName': ' ',
          'categoryId': 'maos',
          'confidence': 0.9,
        }, allowedCategoryIds: allowedCategoryIds),
        throwsA(isA<ToyRecognitionException>()),
      );
    });

    test('rejects an invalid confidence instead of coercing it', () {
      expect(
        () => ToyRecognitionResult.fromCallableData(<String, Object?>{
          'suggestedName': 'Carrinho',
          'categoryId': 'corpo',
          'confidence': double.nan,
        }, allowedCategoryIds: allowedCategoryIds),
        throwsA(
          isA<ToyRecognitionException>().having(
            (error) => error.failure,
            'failure',
            ToyRecognitionFailure.invalidResponse,
          ),
        ),
      );
    });

    test('rejects an invalid needs-review type', () {
      expect(
        () => ToyRecognitionResult.fromCallableData(<String, Object?>{
          'suggestedName': 'Carrinho',
          'categoryId': 'corpo',
          'confidence': 0.9,
          'needsReview': 'false',
        }, allowedCategoryIds: allowedCategoryIds),
        throwsA(isA<ToyRecognitionException>()),
      );
    });
  });

  group('FirebaseToyRecognitionService local image validation', () {
    late Directory temporaryDirectory;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'toy-recognition-test-',
      );
    });

    tearDown(() async {
      await temporaryDirectory.delete(recursive: true);
    });

    test('rejects a truncated PNG signature before calling Firebase', () async {
      final photo = File('${temporaryDirectory.path}/invalid.png');
      await photo.writeAsBytes(<int>[0x89, 0x50, 0x4e, 0x47, 0, 0, 0, 0]);

      const service = FirebaseToyRecognitionService();
      await expectLater(
        service.recognize(
          photoPath: photo.path,
          categories: const <ToyRecognitionCategory>[
            ToyRecognitionCategory(id: 'corpo', name: 'Corpo'),
          ],
          locale: 'pt-BR',
        ),
        throwsA(
          isA<ToyRecognitionException>().having(
            (error) => error.failure,
            'failure',
            ToyRecognitionFailure.unsupportedImage,
          ),
        ),
      );
    });
  });
}
