import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'dart:convert';
import 'dart:io';

class DevSeed {
  static Future<void> ensureSampleData({
    required ToyRepository toyRepository,
    bool onlyDebug = true,
  }) async {
    if (onlyDebug && !kDebugMode) return;

    final db = toyRepository.db;
    if (db == null) return;

    final photoSourcePath = await _ensureSimplePhoto(
      'seed_photo.png',
      _simplePngBase64,
    );
    final boxPhotoSourcePath = await _ensureSimplePhoto(
      'seed_box_photo.png',
      _simplePngBase64,
    );

    final existingBoxes = await (db.select(db.boxes)
          ..orderBy([(b) => OrderingTerm.asc(b.number)]))
        .get();

    for (final box in existingBoxes) {
      if ((box.photoPath ?? '').trim().isNotEmpty) continue;
      await (db.update(db.boxes)..where((b) => b.id.equals(box.id))).write(
        BoxesCompanion(photoPath: Value(boxPhotoSourcePath)),
      );
    }

    final boxesWithPhoto = await (db.select(db.boxes)
          ..orderBy([(b) => OrderingTerm.asc(b.number)]))
        .get();

    if (boxesWithPhoto.isEmpty) return;

    const categoryIds = <String>[
      'veiculos',
      'bonecos',
      'montagem',
      'livros',
      'jogos',
      'faz_de_conta',
      'artes',
      'musica',
      'banho',
      'outros',
    ];

    const locations = <String>[
      'Sala',
      'Quarto',
      'Brinquedoteca',
      'Varanda',
      'Corredor',
      'Banheiro',
      'Cozinha',
      'Area de servico',
    ];

    const names = <String>[
      'Carrinho Turbo',
      'Caminhao de Bombeiro',
      'Helicoptero Azul',
      'Trem Expresso',
      'Aviao Vermelho',
      'Boneca Luna',
      'Boneco Explorador',
      'Super Heroi Max',
      'Familia Pinguim',
      'Dinossauro Rex',
      'Blocos Coloridos',
      'Quebra Cabeca Zoo',
      'Torre de Encaixe',
      'Kit Monta Robo',
      'Pecas Magneticas',
      'Livro dos Animais',
      'Livro das Cores',
      'Livro de Aventuras',
      'Livro de Numeros',
      'Livro de Historias',
      'Memoria dos Bichos',
      'Dominio Infantil',
      'Ludo Kids',
      'Jogo da Velha',
      'Cartas Ilustradas',
      'Fantasia de Pirata',
      'Fantasia de Medica',
      'Cozinha de Brincar',
      'Telefone de Brinquedo',
      'Maleta de Ferramentas',
      'Kit Pintura',
      'Massinha Colorida',
      'Giz de Cera',
      'Tambor Infantil',
      'Teclado Musical',
      'Chocalho Estrela',
      'Patinho de Banho',
      'Barquinho Espuma',
      'Bola Sensorial',
      'Pelucia Ursinho',
    ];

    final existingToys = await toyRepository.getAllToysOnce();
    final currentCount = existingToys.length;

    final targetCount = currentCount < names.length ? names.length : names.length * 2;
    if (currentCount >= targetCount) return;

    for (var i = currentCount; i < targetCount; i++) {
      final name = names[i % names.length];
      final categoryId = categoryIds[i % categoryIds.length];
      final hasBox = i % 6 != 0;
      final boxId = hasBox ? boxesWithPhoto[i % boxesWithPhoto.length].id : null;
      final locationText = i % 9 == 0 ? null : locations[i % locations.length];

      await toyRepository.addToyWithGeneratedName(
        categoryId: categoryId,
        name: name,
        boxId: boxId,
        locationText: locationText,
        photoSourcePath: photoSourcePath,
      );
    }
  }

  static Future<String> _ensureSimplePhoto(
    String fileName,
    String base64Data,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, fileName);
    final file = File(path);
    if (!await file.exists()) {
      await file.writeAsBytes(base64Decode(base64Data), flush: true);
    }
    return file.path;
  }

  static const String _simplePngBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9pWHr2wAAAAASUVORK5CYII=';
}
