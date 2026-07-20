import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';

class ToyRecognitionCategory {
  final String id;
  final String name;
  final String? examples;
  final String? developmentAspect;

  const ToyRecognitionCategory({
    required this.id,
    required this.name,
    this.examples,
    this.developmentAspect,
  });

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'examples': examples,
        'developmentAspect': developmentAspect,
      };
}

class ToyRecognitionResult {
  final String suggestedName;
  final String categoryId;
  final double confidence;
  final List<String> alternativeCategoryIds;
  final String explanation;
  final bool needsReview;
  final String modelVersion;

  const ToyRecognitionResult({
    required this.suggestedName,
    required this.categoryId,
    required this.confidence,
    required this.alternativeCategoryIds,
    required this.explanation,
    required this.needsReview,
    required this.modelVersion,
  });

  factory ToyRecognitionResult.fromCallableData(
    Object? data, {
    required Set<String> allowedCategoryIds,
  }) {
    if (data is! Map) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.invalidResponse,
        'A resposta do reconhecimento não pôde ser lida.',
      );
    }

    String readString(String key) {
      final value = data[key];
      return value is String ? value.trim() : '';
    }

    final suggestedName = readString('suggestedName');
    final categoryId = readString('categoryId');
    final rawConfidence = data['confidence'];
    if (rawConfidence is! num ||
        !rawConfidence.isFinite ||
        rawConfidence < 0 ||
        rawConfidence > 1) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.invalidResponse,
        'A IA retornou uma confiança inválida.',
      );
    }
    final confidence = rawConfidence.toDouble();

    if (suggestedName.isEmpty || suggestedName.length > 80) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.invalidResponse,
        'A IA não retornou um nome válido para o brinquedo.',
      );
    }
    if (!allowedCategoryIds.contains(categoryId)) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.invalidResponse,
        'A IA retornou uma categoria que não existe no aplicativo.',
      );
    }

    final alternatives = <String>[];
    final rawAlternatives = data['alternativeCategoryIds'];
    if (rawAlternatives is Iterable) {
      for (final value in rawAlternatives) {
        final id = value is String ? value.trim() : '';
        if (id.isNotEmpty &&
            id != categoryId &&
            allowedCategoryIds.contains(id) &&
            !alternatives.contains(id)) {
          alternatives.add(id);
        }
      }
    }

    final rawNeedsReview = data['needsReview'];
    if (rawNeedsReview != null && rawNeedsReview is! bool) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.invalidResponse,
        'A IA retornou uma revisão inválida.',
      );
    }
    final explanation = readString('explanation');
    final rawModelVersion = readString('modelVersion');

    return ToyRecognitionResult(
      suggestedName: suggestedName,
      categoryId: categoryId,
      confidence: confidence,
      alternativeCategoryIds: alternatives.take(2).toList(growable: false),
      explanation: explanation.length <= 240
          ? explanation
          : explanation.substring(0, 240),
      needsReview: rawNeedsReview is bool
          ? rawNeedsReview || confidence < 0.75
          : confidence < 0.75,
      modelVersion: rawModelVersion.isEmpty
          ? 'unknown'
          : rawModelVersion.length <= 80
              ? rawModelVersion
              : rawModelVersion.substring(0, 80),
    );
  }
}

enum ToyRecognitionFailure {
  noPhoto,
  unsupportedImage,
  imageTooLarge,
  noToy,
  multipleToys,
  personDetected,
  unavailable,
  permissionDenied,
  invalidResponse,
  unknown,
}

class ToyRecognitionException implements Exception {
  final ToyRecognitionFailure failure;
  final String message;

  const ToyRecognitionException(this.failure, this.message);

  @override
  String toString() => message;
}

abstract interface class ToyRecognitionService {
  Future<ToyRecognitionResult> recognize({
    required String photoPath,
    required List<ToyRecognitionCategory> categories,
    required String locale,
  });
}

class FirebaseToyRecognitionService implements ToyRecognitionService {
  static const int maxImageBytes = 5 * 1024 * 1024;
  static const String region = 'southamerica-east1';

  const FirebaseToyRecognitionService();

  @override
  Future<ToyRecognitionResult> recognize({
    required String photoPath,
    required List<ToyRecognitionCategory> categories,
    required String locale,
  }) async {
    final normalizedPath = photoPath.trim();
    if (normalizedPath.isEmpty) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.noPhoto,
        'Adicione uma foto antes de iniciar o reconhecimento.',
      );
    }
    if (categories.isEmpty) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.unavailable,
        'As categorias ainda estão sendo preparadas. Tente novamente.',
      );
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.noPhoto,
        'A foto selecionada não está mais disponível.',
      );
    }

    final fileLength = await file.length();
    if (fileLength <= 0) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.noPhoto,
        'A foto selecionada está vazia.',
      );
    }
    if (fileLength > maxImageBytes) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.imageTooLarge,
        'A foto ficou muito grande. Recorte mais perto do brinquedo.',
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.noPhoto,
        'A foto selecionada está vazia.',
      );
    }
    if (bytes.length > maxImageBytes) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.imageTooLarge,
        'A foto ficou muito grande. Recorte mais perto do brinquedo.',
      );
    }

    final mimeType = _detectMimeType(bytes);
    if (mimeType == null) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.unsupportedImage,
        'Use uma foto JPG, PNG ou WebP.',
      );
    }

    final allowedIds = categories.map((category) => category.id).toSet();
    try {
      final callable =
          FirebaseFunctions.instanceFor(region: region).httpsCallable(
        'recognizeToy',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 45)),
      );
      final response = await callable.call<Object?>(<String, Object?>{
        'imageBase64': base64Encode(bytes),
        'mimeType': mimeType,
        'locale': locale,
        'categories': categories.map((category) => category.toJson()).toList(),
      });

      return ToyRecognitionResult.fromCallableData(
        response.data,
        allowedCategoryIds: allowedIds,
      );
    } on FirebaseFunctionsException catch (error) {
      throw _mapFunctionsException(error);
    } on ToyRecognitionException {
      rethrow;
    } catch (_) {
      throw const ToyRecognitionException(
        ToyRecognitionFailure.unknown,
        'Não foi possível reconhecer o brinquedo agora. Tente novamente.',
      );
    }
  }

  static String? _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
        ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }

  static ToyRecognitionException _mapFunctionsException(
    FirebaseFunctionsException error,
  ) {
    final details = error.details;
    final reason = details is Map ? details['reason']?.toString() : null;
    switch (reason) {
      case 'person_detected':
        return const ToyRecognitionException(
          ToyRecognitionFailure.personDetected,
          'Para proteger a privacidade, use uma foto que mostre somente o brinquedo.',
        );
      case 'multiple_toys':
        return const ToyRecognitionException(
          ToyRecognitionFailure.multipleToys,
          'O MVP reconhece um brinquedo por vez. Recorte a foto mais de perto.',
        );
      case 'no_toy':
        return const ToyRecognitionException(
          ToyRecognitionFailure.noToy,
          'Não encontramos um brinquedo com segurança nessa foto.',
        );
      case 'image_too_large':
        return const ToyRecognitionException(
          ToyRecognitionFailure.imageTooLarge,
          'A foto ficou muito grande. Recorte mais perto do brinquedo.',
        );
      case 'invalid_image':
        return const ToyRecognitionException(
          ToyRecognitionFailure.unsupportedImage,
          'Use uma foto JPG, PNG ou WebP válida.',
        );
      case 'invalid_categories':
        return const ToyRecognitionException(
          ToyRecognitionFailure.invalidResponse,
          'As categorias oficiais não puderam ser validadas.',
        );
    }

    if (error.code == 'permission-denied' || error.code == 'unauthenticated') {
      return const ToyRecognitionException(
        ToyRecognitionFailure.permissionDenied,
        'O reconhecimento ainda não está autorizado neste dispositivo.',
      );
    }
    if (error.code == 'deadline-exceeded' ||
        error.code == 'unavailable' ||
        error.code == 'resource-exhausted') {
      return const ToyRecognitionException(
        ToyRecognitionFailure.unavailable,
        'O reconhecimento está temporariamente indisponível. Tente novamente.',
      );
    }

    return const ToyRecognitionException(
      ToyRecognitionFailure.unknown,
      'Não foi possível reconhecer o brinquedo agora.',
    );
  }
}
