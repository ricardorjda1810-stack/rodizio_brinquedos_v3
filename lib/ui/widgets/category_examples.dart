String _norm(String s) {
  var out = s.toLowerCase().trim();

  // remove acentos (manual, sem deps)
  out = out
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ì', 'i')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ò', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ç', 'c');

  // normaliza pontuação/hífen e espaços
  out = out.replaceAll('-', ' ');
  out = out.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();

  return out;
}

List<String> examplesForCategoryName(String categoryName) {
  final n = _norm(categoryName);

  // Calibrado para ToyRepository.defaultCategories.
  // Usa contains para continuar robusto em renomeações leves.

  if (n.contains('veic') || n.contains('carro') || n.contains('carr')) {
    return const ['carrinho', 'caminhao', 'trenzinho', 'onibus'];
  }

  if (n.contains('bonec') || n.contains('peluc') || n.contains('person')) {
    return const ['boneca', 'ursinho', 'personagem', 'fantoche'];
  }

  if (n.contains('mont') ||
      n.contains('lego') ||
      n.contains('bloco') ||
      n.contains('encaix')) {
    return const ['blocos', 'lego', 'encaixe', 'engrenagens'];
  }

  if (n.contains('livro') || n.contains('leitur') || n.contains('hist')) {
    return const ['historias', 'figuras', 'sons', 'toque'];
  }

  if (n.contains('jogo') ||
      n.contains('cart') ||
      n.contains('domino') ||
      n.contains('memoria')) {
    return const ['memoria', 'domino', 'cartas', 'trilhas'];
  }

  if (n.contains('faz') ||
      n.contains('conta') ||
      n.contains('casinh') ||
      n.contains('cozinh')) {
    return const ['cozinha', 'medico', 'mercado', 'ferramentas'];
  }

  if (n.contains('arte') || n.contains('desenh') || n.contains('pint')) {
    return const ['giz', 'tinta', 'colagem', 'massinha'];
  }

  if (n.contains('music') || n.contains('som') || n.contains('instrument')) {
    return const ['tambor', 'chocalho', 'teclado', 'violao'];
  }

  if (n.contains('banh') || n.contains('agua')) {
    return const ['patinho', 'barquinho', 'copinhos', 'esguicho'];
  }

  if (n.contains('outro') || n.contains('divers') || n.contains('geral')) {
    return const ['quebra-cabeca', 'lupa', 'ima', 'surpresa'];
  }

  return const <String>[];
}
