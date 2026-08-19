import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/toy_recognition_service.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_crop_page.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_create_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ToyRepository toyRepository;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
    await toyRepository.ensureOfficialToyFormCategories();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await db.close();
  });

  for (final scenario in <_LocaleScenario>[
    const _LocaleScenario(
      locale: Locale('pt', 'BR'),
      newToy: 'Novo brinquedo',
      camera: 'Câmera',
      gallery: 'Galeria',
      toyName: 'Nome do brinquedo',
      primaryCategory: 'Categoria principal',
      save: 'Salvar',
      recognizing: 'Reconhecendo brinquedo...',
      suggestionApplied: 'Sugestão aplicada',
      analyzeAgain: 'Analisar novamente',
      useSuggestion: 'Usar sugestão',
      suggestedName: 'Blocos coloridos',
      explanation: 'Peças para empilhar.',
      categoryName: 'Mãos e Construção',
      selectCategory: 'Selecione uma categoria.',
      selectStorage:
          'Selecione uma caixa ou escolha "Sem caixa" para salvar o brinquedo.',
    ),
    const _LocaleScenario(
      locale: Locale('en', 'US'),
      newToy: 'New toy',
      camera: 'Camera',
      gallery: 'Gallery',
      toyName: 'Toy name',
      primaryCategory: 'Primary category',
      save: 'Save',
      recognizing: 'Recognizing toy...',
      suggestionApplied: 'Suggestion applied',
      analyzeAgain: 'Analyze again',
      useSuggestion: 'Use suggestion',
      suggestedName: 'Building blocks',
      explanation: 'Pieces for stacking.',
      categoryName: 'Hands and Building',
      selectCategory: 'Select a category.',
      selectStorage: 'Select a box or choose "No box" to save the toy.',
    ),
  ]) {
    final language = scenario.locale.languageCode;

    _testWidgets('renders the toy form in $language', (tester) async {
      await _pumpToyCreatePage(
        tester,
        toyRepository: toyRepository,
        locale: scenario.locale,
        recognitionService: _ImmediateRecognitionService(),
        size: const Size(430, 1600),
      );

      expect(find.text(scenario.newToy), findsNWidgets(2));
      expect(find.text(scenario.camera), findsOneWidget);
      expect(find.text(scenario.gallery), findsOneWidget);
      expect(find.text(scenario.toyName), findsOneWidget);
      expect(find.text(scenario.primaryCategory), findsOneWidget);
      expect(find.widgetWithText(FilledButton, scenario.save), findsOneWidget);
      expect(find.text(scenario.categoryName), findsOneWidget);

      if (language == 'en') {
        for (final portugueseText in <String>[
          'Novo brinquedo',
          'Câmera',
          'Galeria',
          'Nome do brinquedo',
          'Categoria principal',
          'Salvar',
          'Mãos e Construção',
          'Obrigatório.',
        ]) {
          expect(find.text(portugueseText), findsNothing);
        }
      }
    });

    _testWidgets('localizes photo cropping in $language', (tester) async {
      final isEn = language == 'en';
      await tester.pumpWidget(
        MaterialApp(
          locale: scenario.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: PhotoCropPage(
            sourcePath: '/tmp/source.jpg',
            cropper: ({required sourcePath}) async => null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(isEn ? 'Adjust photo' : 'Ajustar foto'), findsOneWidget);
      expect(find.text(isEn ? 'Use photo' : 'Usar foto'), findsOneWidget);
      expect(find.text(isEn ? 'Cancel' : 'Cancelar'), findsOneWidget);

      await tester.tap(
          find.widgetWithText(FilledButton, isEn ? 'Use photo' : 'Usar foto'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          isEn
              ? "Couldn't use the photo. Try again."
              : 'Não foi possível usar a foto. Tente novamente.',
        ),
        findsOneWidget,
      );

      if (isEn) {
        for (final portugueseText in <String>[
          'Ajustar foto',
          'Usar foto',
          'Cancelar',
          'Não foi possível usar a foto. Tente novamente.',
        ]) {
          expect(find.text(portugueseText), findsNothing);
        }
      }
    });

    _testWidgets(
      'localizes recognition loading, success, and application in $language',
      (tester) async {
        final recognitionCompleter = Completer<ToyRecognitionResult>();
        final service = _CompletingRecognitionService(recognitionCompleter);
        await _pumpToyCreatePage(
          tester,
          toyRepository: toyRepository,
          locale: scenario.locale,
          recognitionService: service,
        );

        await _tapGallery(tester, scenario.gallery);
        expect(find.text(scenario.recognizing), findsOneWidget);

        recognitionCompleter.complete(
          ToyRecognitionResult(
            suggestedName: scenario.suggestedName,
            categoryId: 'maos',
            confidence: 0.9,
            alternativeCategoryIds: const <String>['imaginacao'],
            explanation: scenario.explanation,
            needsReview: false,
            modelVersion: 'test',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(scenario.suggestedName), findsOneWidget);
        expect(find.textContaining(scenario.categoryName), findsWidgets);
        expect(
          find.widgetWithText(FilledButton, scenario.useSuggestion),
          findsOneWidget,
        );

        await tester.tap(
          find.widgetWithText(FilledButton, scenario.useSuggestion),
        );
        await tester.pumpAndSettle();

        expect(find.text(scenario.suggestionApplied), findsOneWidget);
        expect(find.text(scenario.analyzeAgain), findsOneWidget);
        expect(service.locales, <String>[language == 'en' ? 'en-US' : 'pt-BR']);
      },
    );

    _testWidgets('localizes required form validations in $language',
        (tester) async {
      await _pumpToyCreatePage(
        tester,
        toyRepository: toyRepository,
        locale: scenario.locale,
        recognitionService: _ImmediateRecognitionService(),
        size: const Size(430, 1200),
      );

      expect(
        find.text(
          language == 'en'
              ? 'Optional. You can edit the AI suggestion.'
              : 'Opcional. Você pode editar a sugestão da IA.',
        ),
        findsOneWidget,
      );

      await _pressFilledButton(tester, scenario.save);
      expect(find.text(scenario.selectCategory), findsOneWidget);

      await tester.ensureVisible(find.text(scenario.categoryName));
      await tester.tap(find.text(scenario.categoryName));
      await tester.pumpAndSettle();
      await _pressFilledButton(tester, scenario.save);
      expect(find.text(scenario.selectStorage), findsWidgets);
    });

    for (final failure in ToyRecognitionFailure.values) {
      _testWidgets('localizes ${failure.name} recognition failure in $language',
          (tester) async {
        await _pumpToyCreatePage(
          tester,
          toyRepository: toyRepository,
          locale: scenario.locale,
          recognitionService: _FailingRecognitionService(failure),
        );

        await _tapGallery(tester, scenario.gallery);
        await tester.pumpAndSettle();

        expect(
          find.text(_failureMessage(scenario.locale, failure)),
          findsOneWidget,
        );
        expect(
          find.text(
            language == 'en'
                ? "Couldn't suggest a toy"
                : 'Não foi possível sugerir',
          ),
          findsOneWidget,
        );
      });
    }
  }

  _testWidgets('renders the tablet toy form in en-US without fixed Portuguese',
      (tester) async {
    await _pumpToyCreatePage(
      tester,
      toyRepository: toyRepository,
      locale: const Locale('en', 'US'),
      recognitionService: _ImmediateRecognitionService(),
      size: const Size(1366, 1100),
    );

    for (final englishText in <String>[
      'New toy',
      'Toy photo',
      'Camera',
      'Gallery',
      'Preview',
      'Main information',
      'Organization',
      'Actions',
      'Hands and Building',
    ]) {
      expect(find.text(englishText), findsWidgets);
    }
    for (final portugueseText in <String>[
      'Novo brinquedo',
      'Foto do brinquedo',
      'Câmera',
      'Galeria',
      'Prévia',
      'Informações principais',
      'Organização',
      'Ações',
      'Mãos e Construção',
    ]) {
      expect(find.text(portugueseText), findsNothing);
    }
  });
}

Future<void> _pumpToyCreatePage(
  WidgetTester tester, {
  required ToyRepository toyRepository,
  required Locale locale,
  required ToyRecognitionService recognitionService,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ToyCreatePage(
        toyRepository: toyRepository,
        recognitionService: recognitionService,
        pickImage: (_) async => XFile('/tmp/source.jpg'),
        openPhotoCropPage: (
          context, {
          required sourcePath,
        }) async =>
            '/tmp/cropped.jpg',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _testWidgets(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}

Future<void> _tapGallery(WidgetTester tester, String label) async {
  final galleryButton = find.widgetWithText(OutlinedButton, label);
  await tester.ensureVisible(galleryButton);
  await tester.tap(galleryButton);
  await tester.pump();
}

Future<void> _pressFilledButton(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(FilledButton, label);
  final button = tester.widget<FilledButton>(finder);
  expect(button.onPressed, isNotNull);
  button.onPressed!();
  await tester.pump();
}

String _failureMessage(Locale locale, ToyRecognitionFailure failure) {
  final l10n = AppLocalizations(locale);
  return switch (failure) {
    ToyRecognitionFailure.noPhoto => l10n.recognitionNoPhoto,
    ToyRecognitionFailure.categoriesUnavailable =>
      l10n.recognitionCategoriesUnavailable,
    ToyRecognitionFailure.unsupportedImage => l10n.recognitionUnsupportedImage,
    ToyRecognitionFailure.imageTooLarge => l10n.recognitionImageTooLarge,
    ToyRecognitionFailure.noToy => l10n.recognitionNoToy,
    ToyRecognitionFailure.multipleToys => l10n.recognitionMultipleToys,
    ToyRecognitionFailure.personDetected => l10n.recognitionPersonDetected,
    ToyRecognitionFailure.unavailable => l10n.recognitionUnavailable,
    ToyRecognitionFailure.timeout => l10n.recognitionTimeout,
    ToyRecognitionFailure.permissionDenied => l10n.recognitionPermissionDenied,
    ToyRecognitionFailure.invalidResponse => l10n.recognitionInvalidResponse,
    ToyRecognitionFailure.unknown => l10n.recognitionUnknownFailure,
  };
}

class _LocaleScenario {
  final Locale locale;
  final String newToy;
  final String camera;
  final String gallery;
  final String toyName;
  final String primaryCategory;
  final String save;
  final String recognizing;
  final String suggestionApplied;
  final String analyzeAgain;
  final String useSuggestion;
  final String suggestedName;
  final String explanation;
  final String categoryName;
  final String selectCategory;
  final String selectStorage;

  const _LocaleScenario({
    required this.locale,
    required this.newToy,
    required this.camera,
    required this.gallery,
    required this.toyName,
    required this.primaryCategory,
    required this.save,
    required this.recognizing,
    required this.suggestionApplied,
    required this.analyzeAgain,
    required this.useSuggestion,
    required this.suggestedName,
    required this.explanation,
    required this.categoryName,
    required this.selectCategory,
    required this.selectStorage,
  });
}

class _ImmediateRecognitionService implements ToyRecognitionService {
  @override
  Future<ToyRecognitionResult> recognize({
    required String photoPath,
    required List<ToyRecognitionCategory> categories,
    required String locale,
  }) async {
    return const ToyRecognitionResult(
      suggestedName: 'Toy',
      categoryId: 'maos',
      confidence: 0.9,
      alternativeCategoryIds: <String>[],
      explanation: '',
      needsReview: false,
      modelVersion: 'test',
    );
  }
}

class _CompletingRecognitionService implements ToyRecognitionService {
  final Completer<ToyRecognitionResult> completer;
  final List<String> locales = <String>[];

  _CompletingRecognitionService(this.completer);

  @override
  Future<ToyRecognitionResult> recognize({
    required String photoPath,
    required List<ToyRecognitionCategory> categories,
    required String locale,
  }) {
    locales.add(locale);
    return completer.future;
  }
}

class _FailingRecognitionService implements ToyRecognitionService {
  final ToyRecognitionFailure failure;

  const _FailingRecognitionService(this.failure);

  @override
  Future<ToyRecognitionResult> recognize({
    required String photoPath,
    required List<ToyRecognitionCategory> categories,
    required String locale,
  }) async {
    throw ToyRecognitionException(failure);
  }
}
