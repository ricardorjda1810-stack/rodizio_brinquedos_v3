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
  late AppDatabase db;
  late ToyRepository toyRepository;
  late _FakeRecognitionService recognitionService;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
    recognitionService = _FakeRecognitionService();
    await toyRepository.ensureOfficialToyFormCategories();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await db.close();
  });

  testWidgets('resultado valido fecha o recorte e reconhece o caminho uma vez',
      (tester) async {
    final cropResult = Completer<String?>();
    var cropCalls = 0;

    await _pumpToyCreatePage(
      tester,
      toyRepository: toyRepository,
      recognitionService: recognitionService,
      cropper: ({required sourcePath}) {
        cropCalls++;
        expect(sourcePath, '/tmp/source.jpg');
        return cropResult.future;
      },
    );

    await _openCropPage(tester, recognitionService);
    await tester.tap(find.widgetWithText(FilledButton, 'Usar foto'));
    await tester.pump();

    expect(cropCalls, 1);
    expect(recognitionService.calls, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    cropResult.complete('/tmp/cropped.jpg');
    await tester.pumpAndSettle();

    expect(find.text('Ajustar foto'), findsNothing);
    expect(recognitionService.calls, 1);
    expect(recognitionService.photoPaths, <String>['/tmp/cropped.jpg']);

    await _disposeWidgetTree(tester);
  });

  testWidgets('resultado depois de mais de 60 segundos continua aceito',
      (tester) async {
    final cropResult = Completer<String?>();
    var cropCalls = 0;

    await _pumpToyCreatePage(
      tester,
      toyRepository: toyRepository,
      recognitionService: recognitionService,
      cropper: ({required sourcePath}) {
        cropCalls++;
        return cropResult.future;
      },
    );

    await _openCropPage(tester, recognitionService);
    await tester.tap(find.widgetWithText(FilledButton, 'Usar foto'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 61));

    expect(find.text('Ajustar foto'), findsOneWidget);
    expect(cropCalls, 1);
    expect(recognitionService.calls, 0);
    expect(tester.takeException(), isNull);

    cropResult.complete('/tmp/late-cropped.jpg');
    await tester.pumpAndSettle();

    expect(find.text('Ajustar foto'), findsNothing);
    expect(recognitionService.calls, 1);
    expect(recognitionService.photoPaths, <String>['/tmp/late-cropped.jpg']);

    await _disposeWidgetTree(tester);
  });

  testWidgets('cancelamento mantem pagina aberta e nao reconhece',
      (tester) async {
    var cropCalls = 0;

    await _pumpToyCreatePage(
      tester,
      toyRepository: toyRepository,
      recognitionService: recognitionService,
      cropper: ({required sourcePath}) async {
        cropCalls++;
        return null;
      },
    );

    await _openCropPage(tester, recognitionService);
    await tester.tap(find.widgetWithText(FilledButton, 'Usar foto'));
    await tester.pump();

    expect(find.text('Ajustar foto'), findsOneWidget);
    expect(find.text('Não foi possível usar a foto. Tente novamente.'),
        findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Usar foto'), findsOneWidget);
    expect(cropCalls, 1);
    expect(recognitionService.calls, 0);

    await _disposeWidgetTree(tester);
  });

  testWidgets('excecao libera nova tentativa e nao reconhece', (tester) async {
    var cropCalls = 0;

    await _pumpToyCreatePage(
      tester,
      toyRepository: toyRepository,
      recognitionService: recognitionService,
      cropper: ({required sourcePath}) async {
        cropCalls++;
        throw StateError('falha simulada');
      },
    );

    await _openCropPage(tester, recognitionService);
    await tester.tap(find.widgetWithText(FilledButton, 'Usar foto'));
    await tester.pump();

    expect(find.text('Ajustar foto'), findsOneWidget);
    expect(find.text('Erro ao processar a foto.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Usar foto'), findsOneWidget);
    expect(cropCalls, 1);
    expect(recognitionService.calls, 0);
    expect(tester.takeException(), isNull);

    await _disposeWidgetTree(tester);
  });

  testWidgets('toque duplo abre somente um cropper enquanto aguarda',
      (tester) async {
    final cropResult = Completer<String?>();
    var cropCalls = 0;

    await _pumpToyCreatePage(
      tester,
      toyRepository: toyRepository,
      recognitionService: recognitionService,
      cropper: ({required sourcePath}) {
        cropCalls++;
        return cropResult.future;
      },
    );

    await _openCropPage(tester, recognitionService);
    final usePhotoButton = find.byType(FilledButton);
    await tester.tap(usePhotoButton);
    await tester.tap(usePhotoButton);
    await tester.pump();

    expect(cropCalls, 1);
    expect(recognitionService.calls, 0);

    cropResult.complete(null);
    await tester.pump();

    await _disposeWidgetTree(tester);
  });

  testWidgets('descarte durante crop ignora conclusao tardia', (tester) async {
    final cropResult = Completer<String?>();
    var cropCalls = 0;

    await _pumpToyCreatePage(
      tester,
      toyRepository: toyRepository,
      recognitionService: recognitionService,
      cropper: ({required sourcePath}) {
        cropCalls++;
        return cropResult.future;
      },
    );

    await _openCropPage(tester, recognitionService);
    await tester.tap(find.widgetWithText(FilledButton, 'Usar foto'));
    await tester.pump();
    expect(cropCalls, 1);

    await _disposeWidgetTree(tester);
    cropResult.complete('/tmp/disposed-cropped.jpg');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(recognitionService.calls, 0);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpToyCreatePage(
  WidgetTester tester, {
  required ToyRepository toyRepository,
  required _FakeRecognitionService recognitionService,
  required PhotoCropper cropper,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ToyCreatePage(
        toyRepository: toyRepository,
        recognitionService: recognitionService,
        pickImage: (_) async {
          recognitionService.pickCalls++;
          return XFile('/tmp/source.jpg');
        },
        openPhotoCropPage: (
          context, {
          required sourcePath,
        }) {
          recognitionService.openCropPageCalls++;
          return PhotoCropPage.open(
            context,
            sourcePath: sourcePath,
            cropper: cropper,
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openCropPage(
  WidgetTester tester,
  _FakeRecognitionService recognitionService,
) async {
  final galleryButton = find.widgetWithText(OutlinedButton, 'Galeria');
  await tester.ensureVisible(galleryButton);
  final button = tester.widget<OutlinedButton>(galleryButton);
  expect(button.onPressed, isNotNull);
  button.onPressed!();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
  expect(recognitionService.pickCalls, 1);
  expect(recognitionService.openCropPageCalls, 1);
  expect(find.text('Ajustar foto'), findsOneWidget);
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

class _FakeRecognitionService implements ToyRecognitionService {
  int pickCalls = 0;
  int openCropPageCalls = 0;
  int calls = 0;
  final List<String> photoPaths = <String>[];

  @override
  Future<ToyRecognitionResult> recognize({
    required String photoPath,
    required List<ToyRecognitionCategory> categories,
    required String locale,
  }) async {
    calls++;
    photoPaths.add(photoPath);
    return const ToyRecognitionResult(
      suggestedName: 'Brinquedo de teste',
      categoryId: 'maos',
      confidence: 0.9,
      alternativeCategoryIds: <String>['imaginacao'],
      explanation: 'Resultado simulado.',
      needsReview: false,
      modelVersion: 'test',
    );
  }
}
