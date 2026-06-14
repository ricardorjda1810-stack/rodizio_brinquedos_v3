import 'dart:io';

class ToyAsset {
  final String fileName;
  final String kind;

  const ToyAsset(this.fileName, this.kind);
}

class Palette {
  final String soft;
  final String main;
  final String accent;
  final String deep;

  const Palette(this.soft, this.main, this.accent, this.deep);
}

const assets = <ToyAsset>[
  ToyAsset('demo_corpo_bola_macia_colorida.png', 'softBall'),
  ToyAsset('demo_maos_blocos_de_encaixe.png', 'blocks'),
  ToyAsset('demo_imaginacao_panelinha_de_faz_de_conta.png', 'pot'),
  ToyAsset('demo_comunicacao_livro_de_figuras.png', 'book'),
  ToyAsset('demo_exploracao_lupa_infantil.png', 'magnifier'),
  ToyAsset('demo_corpo_pinos_de_boliche_infantil.png', 'bowling'),
  ToyAsset('demo_maos_torre_de_empilhar.png', 'stackTower'),
  ToyAsset('demo_imaginacao_boneco_bebe_de_pano.png', 'doll'),
  ToyAsset('demo_comunicacao_cartoes_de_emocoes.png', 'emotionCards'),
  ToyAsset('demo_exploracao_garrafas_sensoriais.png', 'sensoryBottles'),
  ToyAsset('demo_corpo_mini_cones_de_movimento.png', 'cones'),
  ToyAsset('demo_maos_quebra_cabeca_de_formas.png', 'shapePuzzle'),
  ToyAsset('demo_imaginacao_carrinhos_coloridos.png', 'cars'),
  ToyAsset('demo_comunicacao_telefone_de_brinquedo.png', 'phone'),
  ToyAsset('demo_exploracao_instrumentos_musicais.png', 'instruments'),
  ToyAsset('demo_corpo_tapete_de_equilibrio.png', 'balanceMat'),
  ToyAsset('demo_maos_cubos_sensoriais.png', 'sensoryCubes'),
  ToyAsset('demo_imaginacao_fazendinha_de_madeira.png', 'farm'),
  ToyAsset('demo_comunicacao_fantoches_de_historias.png', 'storyPuppets'),
  ToyAsset('demo_exploracao_blocos_transparentes.png', 'transparentBlocks'),
  ToyAsset('demo_corpo_argolas_de_atividade.png', 'activityRings'),
  ToyAsset('demo_maos_potes_de_encaixar.png', 'nestingPots'),
  ToyAsset('demo_imaginacao_animais_de_brinquedo.png', 'toyAnimals'),
  ToyAsset('demo_comunicacao_alfabeto_ilustrado.png', 'alphabet'),
  ToyAsset('demo_exploracao_potes_de_descoberta.png', 'discoveryJars'),
  ToyAsset('demo_corpo_bambole_infantil.png', 'hoop'),
  ToyAsset('demo_maos_martelo_de_pinos.png', 'hammerPins'),
  ToyAsset('demo_imaginacao_casinha_de_bonecos.png', 'dollHouse'),
  ToyAsset('demo_comunicacao_cartoes_de_animais.png', 'animalCards'),
  ToyAsset('demo_exploracao_mesa_de_atividades.png', 'activityTable'),
  ToyAsset('demo_corpo_tunel_dobravel.png', 'tunnel'),
  ToyAsset('demo_maos_contas_grandes_de_montar.png', 'beads'),
  ToyAsset('demo_imaginacao_kit_medico_infantil.png', 'doctorKit'),
  ToyAsset('demo_comunicacao_sequencia_de_imagens.png', 'sequenceCards'),
  ToyAsset('demo_exploracao_chocalhos_variados.png', 'rattles'),
  ToyAsset('demo_corpo_carrinho_de_empurrar.png', 'pushCart'),
  ToyAsset('demo_maos_formas_geometricas.png', 'geoShapes'),
  ToyAsset('demo_imaginacao_mercadinho_de_brincar.png', 'market'),
  ToyAsset('demo_comunicacao_microfone_de_brinquedo.png', 'microphone'),
  ToyAsset('demo_exploracao_caixa_de_texturas.png', 'textureBox'),
  ToyAsset('demo_corpo_almofadas_de_percurso.png', 'cushions'),
  ToyAsset('demo_maos_painel_de_abrir_e_fechar.png', 'latchPanel'),
  ToyAsset('demo_imaginacao_fantoches_de_animais.png', 'animalPuppets'),
  ToyAsset('demo_comunicacao_livrinho_de_sons.png', 'soundBook'),
  ToyAsset('demo_exploracao_lanterna_infantil.png', 'flashlight'),
  ToyAsset('demo_corpo_bola_sensorial_com_textura.png', 'texturedBall'),
  ToyAsset('demo_maos_pecas_de_rosquear_grandes.png', 'screws'),
  ToyAsset('demo_imaginacao_fantasia_de_explorador.png', 'explorerCostume'),
  ToyAsset('demo_comunicacao_jogo_de_contar_historias.png', 'storyCards'),
  ToyAsset('demo_exploracao_blocos_magneticos_grandes.png', 'magneticBlocks'),
];

Future<void> main() async {
  final sips = await Process.run('which', ['sips']);
  if (sips.exitCode != 0) {
    stderr.writeln('sips was not found. This generator runs on macOS.');
    exit(1);
  }

  final outputDir = Directory('assets/demo/toys');
  outputDir.createSync(recursive: true);

  final tempDir = Directory.systemTemp.createTempSync('demo_toy_assets_');
  try {
    for (final asset in assets) {
      final svgFile = File('${tempDir.path}/${asset.fileName}.svg');
      final pngFile = File('${outputDir.path}/${asset.fileName}');
      svgFile.writeAsStringSync(_svgFor(asset));

      final result = await Process.run(
        'sips',
        ['-s', 'format', 'png', svgFile.path, '--out', pngFile.path],
      );
      if (result.exitCode != 0) {
        stderr
          ..writeln('Failed to create ${asset.fileName}')
          ..writeln(result.stderr);
        exit(result.exitCode);
      }
    }
  } finally {
    tempDir.deleteSync(recursive: true);
  }

  stdout.writeln('Generated ${assets.length} demo toy PNGs.');
}

String _svgFor(ToyAsset asset) {
  final palette = _paletteFor(asset.fileName);
  final toy = _toyShape(asset.kind, palette);

  return '''
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="42" fill="#FFFCF7"/>
  <circle cx="100" cy="94" r="46" fill="${palette.soft}" opacity="0.52"/>
  <circle cx="414" cy="120" r="30" fill="${palette.accent}" opacity="0.24"/>
  <circle cx="410" cy="398" r="54" fill="${palette.soft}" opacity="0.38"/>
  <ellipse cx="256" cy="398" rx="142" ry="28" fill="#D7D2C6" opacity="0.38"/>
  <g stroke="#5F625B" stroke-width="10" stroke-linecap="round" stroke-linejoin="round">
    $toy
  </g>
</svg>
''';
}

Palette _paletteFor(String fileName) {
  if (fileName.contains('corpo')) {
    return const Palette('#F7D3C4', '#F2A58E', '#88B8AE', '#D77761');
  }
  if (fileName.contains('maos')) {
    return const Palette('#F2E6BE', '#E8C86D', '#9FC59A', '#B88E44');
  }
  if (fileName.contains('imaginacao')) {
    return const Palette('#E7D7EF', '#C9A3D9', '#F2A3A0', '#8D6A99');
  }
  if (fileName.contains('comunicacao')) {
    return const Palette('#CFE6F7', '#8EC7E8', '#F0C76C', '#5E94B2');
  }
  return const Palette('#D6EEDC', '#8CCFA0', '#7FB8C4', '#5C9A72');
}

String _toyShape(String kind, Palette p) {
  switch (kind) {
    case 'softBall':
      return '''
<circle cx="256" cy="254" r="96" fill="${p.main}"/>
<path d="M174 226c44 18 102 19 164-6" fill="none"/>
<path d="M224 163c25 58 28 122 8 184" fill="none"/>
<circle cx="292" cy="218" r="18" fill="${p.accent}" stroke="none"/>
<circle cx="230" cy="290" r="14" fill="#FFF5D8" stroke="none"/>
''';
    case 'bowling':
      return '''
<path d="M196 143c-20 70-16 146 4 210h48c20-64 24-140 4-210z" fill="#FFF5D8"/>
<path d="M202 202h44M199 272h50" fill="none"/>
<path d="M264 151c-18 64-14 136 4 194h44c18-58 22-130 4-194z" fill="${p.soft}"/>
<circle cx="174" cy="344" r="42" fill="${p.main}"/>
<circle cx="160" cy="332" r="8" fill="#FFFDF7" stroke="none"/>
<circle cx="184" cy="326" r="8" fill="#FFFDF7" stroke="none"/>
''';
    case 'cones':
      return '''
<polygon points="158,338 204,176 250,338" fill="${p.main}"/>
<polygon points="270,338 316,176 362,338" fill="${p.accent}"/>
<path d="M184 248h40M296 248h40" fill="none" stroke="#FFF5D8"/>
<rect x="138" y="338" width="132" height="34" rx="16" fill="${p.soft}"/>
<rect x="250" y="338" width="132" height="34" rx="16" fill="${p.soft}"/>
''';
    case 'balanceMat':
      return '''
<rect x="134" y="210" width="244" height="128" rx="34" fill="${p.soft}"/>
<path d="M158 254h196M158 294h196" fill="none" opacity="0.45"/>
<ellipse cx="216" cy="262" rx="25" ry="38" fill="${p.main}"/>
<ellipse cx="304" cy="284" rx="25" ry="38" fill="${p.accent}"/>
''';
    case 'activityRings':
      return '''
<circle cx="196" cy="244" r="54" fill="none" stroke="${p.main}" stroke-width="18"/>
<circle cx="266" cy="214" r="54" fill="none" stroke="${p.accent}" stroke-width="18"/>
<circle cx="316" cy="282" r="54" fill="none" stroke="#F2D98F" stroke-width="18"/>
<rect x="170" y="338" width="172" height="24" rx="12" fill="${p.soft}"/>
''';
    case 'hoop':
      return '''
<circle cx="256" cy="250" r="104" fill="none" stroke="${p.main}" stroke-width="24"/>
<circle cx="256" cy="250" r="62" fill="#FFFCF7" stroke="${p.accent}" stroke-width="12"/>
<path d="M256 354v42M210 396h92" fill="none"/>
''';
    case 'tunnel':
      return '''
<path d="M134 340V238c0-60 48-108 108-108h28c60 0 108 48 108 108v102" fill="${p.soft}"/>
<path d="M190 340v-90c0-36 30-66 66-66s66 30 66 66v90" fill="#FFFCF7"/>
<path d="M160 230h192M158 284h196" fill="none" opacity="0.45"/>
''';
    case 'pushCart':
      return '''
<path d="M170 242h144l24 92H194z" fill="${p.main}"/>
<path d="M314 244l44-54" fill="none"/>
<circle cx="210" cy="354" r="28" fill="${p.accent}"/>
<circle cx="318" cy="354" r="28" fill="${p.accent}"/>
<rect x="196" y="186" width="84" height="54" rx="14" fill="${p.soft}"/>
''';
    case 'cushions':
      return '''
<rect x="130" y="278" width="130" height="76" rx="22" fill="${p.main}"/>
<rect x="222" y="244" width="132" height="86" rx="24" fill="${p.accent}"/>
<rect x="172" y="196" width="138" height="82" rx="26" fill="${p.soft}"/>
<path d="M164 316h64M256 286h62M206 236h68" fill="none" opacity="0.35"/>
''';
    case 'texturedBall':
      return '''
<circle cx="256" cy="260" r="96" fill="${p.main}"/>
<circle cx="212" cy="222" r="13" fill="${p.soft}" stroke="none"/>
<circle cx="278" cy="210" r="12" fill="${p.accent}" stroke="none"/>
<circle cx="312" cy="276" r="14" fill="#FFF5D8" stroke="none"/>
<circle cx="236" cy="310" r="12" fill="${p.accent}" stroke="none"/>
<path d="M176 260c44 22 100 27 160 0" fill="none"/>
''';
    case 'blocks':
      return '''
<rect x="150" y="274" width="86" height="86" rx="14" fill="${p.main}"/>
<rect x="238" y="220" width="86" height="86" rx="14" fill="${p.accent}"/>
<rect x="184" y="166" width="86" height="86" rx="14" fill="${p.soft}"/>
<circle cx="193" cy="316" r="12" fill="#FFFCF7" stroke="none"/>
<circle cx="281" cy="262" r="12" fill="#FFFCF7" stroke="none"/>
''';
    case 'stackTower':
      return '''
<rect x="188" y="322" width="136" height="42" rx="16" fill="${p.main}"/>
<rect x="204" y="274" width="104" height="42" rx="16" fill="${p.accent}"/>
<rect x="220" y="226" width="72" height="42" rx="16" fill="${p.soft}"/>
<circle cx="256" cy="190" r="32" fill="${p.main}"/>
<path d="M256 156v-34" fill="none"/>
''';
    case 'shapePuzzle':
      return '''
<rect x="134" y="174" width="244" height="178" rx="28" fill="${p.soft}"/>
<circle cx="204" cy="252" r="30" fill="#FFFCF7"/>
<rect x="278" y="222" width="58" height="58" rx="12" fill="#FFFCF7"/>
<polygon points="240,314 272,276 304,314" fill="#FFFCF7"/>
<circle cx="204" cy="252" r="20" fill="${p.main}" stroke="none"/>
<rect x="284" y="228" width="46" height="46" rx="10" fill="${p.accent}" stroke="none"/>
''';
    case 'sensoryCubes':
      return '''
<rect x="150" y="210" width="90" height="90" rx="16" fill="${p.main}"/>
<rect x="258" y="188" width="90" height="90" rx="16" fill="${p.soft}"/>
<rect x="212" y="292" width="90" height="90" rx="16" fill="${p.accent}"/>
<path d="M170 238h50M170 266h50M278 226l50 18M278 256l50-18" fill="none" opacity="0.45"/>
<circle cx="256" cy="336" r="18" fill="#FFFCF7" stroke="none"/>
''';
    case 'nestingPots':
      return '''
<path d="M154 300h90l-16 62h-58z" fill="${p.main}"/>
<path d="M216 260h100l-18 78h-64z" fill="${p.accent}"/>
<path d="M286 218h112l-20 92h-72z" fill="${p.soft}"/>
<path d="M150 300h98M212 260h108M282 218h120" fill="none"/>
''';
    case 'hammerPins':
      return '''
<rect x="150" y="286" width="208" height="60" rx="20" fill="${p.soft}"/>
<circle cx="202" cy="286" r="18" fill="${p.main}"/>
<circle cx="256" cy="286" r="18" fill="${p.accent}"/>
<circle cx="310" cy="286" r="18" fill="${p.main}"/>
<rect x="282" y="150" width="96" height="38" rx="14" fill="${p.accent}" transform="rotate(24 330 169)"/>
<path d="M286 196l-86 88" fill="none" stroke="${p.deep}"/>
''';
    case 'beads':
      return '''
<path d="M142 292c54-92 174-92 228 0" fill="none"/>
<circle cx="166" cy="278" r="25" fill="${p.main}"/>
<circle cx="220" cy="232" r="25" fill="${p.accent}"/>
<circle cx="286" cy="232" r="25" fill="${p.soft}"/>
<circle cx="342" cy="278" r="25" fill="${p.main}"/>
<rect x="154" y="330" width="204" height="28" rx="14" fill="${p.soft}"/>
''';
    case 'geoShapes':
      return '''
<circle cx="188" cy="230" r="44" fill="${p.main}"/>
<rect x="264" y="186" width="82" height="82" rx="16" fill="${p.accent}"/>
<polygon points="256,318 310,238 364,318" fill="${p.soft}"/>
<path d="M166 348h202" fill="none"/>
''';
    case 'latchPanel':
      return '''
<rect x="136" y="174" width="240" height="188" rx="26" fill="${p.soft}"/>
<rect x="164" y="206" width="72" height="116" rx="14" fill="${p.main}"/>
<rect x="276" y="206" width="72" height="116" rx="14" fill="${p.accent}"/>
<path d="M198 232v58M198 262h42M314 224c24 20 24 54 0 74" fill="none"/>
<circle cx="222" cy="278" r="8" fill="#FFFCF7" stroke="none"/>
''';
    case 'screws':
      return '''
<circle cx="194" cy="240" r="50" fill="${p.main}"/>
<circle cx="318" cy="240" r="50" fill="${p.accent}"/>
<path d="M162 240h64M194 208v64M286 240h64M318 208v64" fill="none" stroke="#FFFCF7"/>
<rect x="156" y="322" width="200" height="38" rx="18" fill="${p.soft}"/>
''';
    case 'pot':
      return '''
<path d="M176 238h160l-18 106H194z" fill="${p.main}"/>
<path d="M174 238c12-36 152-36 164 0" fill="${p.soft}"/>
<path d="M176 268h-36c-22 0-22 44 0 44h44M336 268h36c22 0 22 44 0 44h-44" fill="none"/>
<path d="M246 206c-8-30 38-30 30 0" fill="none"/>
''';
    case 'doll':
      return '''
<circle cx="256" cy="170" r="44" fill="#F7D8C9"/>
<path d="M204 242c28-44 76-44 104 0l30 108H174z" fill="${p.main}"/>
<circle cx="238" cy="164" r="6" fill="#5F625B" stroke="none"/>
<circle cx="274" cy="164" r="6" fill="#5F625B" stroke="none"/>
<path d="M238 192c12 10 24 10 36 0M204 278l-50 38M308 278l50 38" fill="none"/>
''';
    case 'cars':
      return '''
<path d="M136 282h120l28 44H118z" fill="${p.main}"/>
<path d="M264 230h108l28 52H244z" fill="${p.accent}"/>
<circle cx="162" cy="336" r="24" fill="#FFFCF7"/>
<circle cx="244" cy="336" r="24" fill="#FFFCF7"/>
<circle cx="286" cy="292" r="22" fill="#FFFCF7"/>
<circle cx="370" cy="292" r="22" fill="#FFFCF7"/>
''';
    case 'farm':
      return '''
<path d="M158 234l98-76 98 76v118H158z" fill="${p.main}"/>
<path d="M206 352v-78h100v78M158 234h196" fill="none"/>
<path d="M132 352h248M138 306h54M320 306h54" fill="none" stroke="${p.deep}"/>
<circle cx="256" cy="226" r="22" fill="${p.soft}"/>
''';
    case 'toyAnimals':
      return '''
<ellipse cx="206" cy="286" rx="66" ry="42" fill="${p.main}"/>
<circle cx="156" cy="248" r="34" fill="${p.main}"/>
<path d="M134 228l-20-26M178 228l20-26M172 326v32M232 326v32" fill="none"/>
<ellipse cx="316" cy="286" rx="50" ry="38" fill="${p.accent}"/>
<circle cx="358" cy="252" r="28" fill="${p.accent}"/>
<path d="M294 320v34M336 320v34" fill="none"/>
''';
    case 'dollHouse':
      return '''
<path d="M154 246l102-86 102 86v116H154z" fill="${p.soft}"/>
<rect x="196" y="272" width="52" height="90" rx="10" fill="${p.main}"/>
<rect x="274" y="270" width="50" height="46" rx="10" fill="${p.accent}"/>
<path d="M154 246h204M256 160v202" fill="none"/>
''';
    case 'doctorKit':
      return '''
<rect x="148" y="224" width="216" height="128" rx="24" fill="${p.main}"/>
<path d="M214 224v-34h84v34" fill="none"/>
<path d="M256 248v80M216 288h80" fill="none" stroke="#FFFCF7" stroke-width="16"/>
<circle cx="356" cy="184" r="26" fill="${p.soft}"/>
''';
    case 'market':
      return '''
<rect x="150" y="240" width="212" height="112" rx="14" fill="${p.soft}"/>
<path d="M140 238l28-62h176l28 62z" fill="${p.main}"/>
<path d="M184 176v62M230 176v62M276 176v62M322 176v62" fill="none" opacity="0.45"/>
<circle cx="210" cy="294" r="18" fill="${p.accent}"/>
<circle cx="256" cy="294" r="18" fill="${p.main}"/>
<circle cx="302" cy="294" r="18" fill="${p.accent}"/>
''';
    case 'animalPuppets':
      return '''
<path d="M202 314v62M310 314v62" fill="none"/>
<circle cx="202" cy="236" r="56" fill="${p.main}"/>
<circle cx="310" cy="236" r="56" fill="${p.accent}"/>
<path d="M166 198l-20-30M238 198l20-30M274 194l-24-24M346 194l24-24" fill="none"/>
<circle cx="184" cy="228" r="7" fill="#5F625B" stroke="none"/>
<circle cx="220" cy="228" r="7" fill="#5F625B" stroke="none"/>
<path d="M184 258c12 10 24 10 36 0M292 258c12 10 24 10 36 0" fill="none"/>
''';
    case 'explorerCostume':
      return '''
<path d="M172 224c48-54 120-54 168 0z" fill="${p.main}"/>
<rect x="144" y="218" width="224" height="34" rx="17" fill="${p.accent}"/>
<path d="M210 276h92l42 78H168z" fill="${p.soft}"/>
<path d="M256 276v78M212 314h88" fill="none"/>
<circle cx="340" cy="310" r="22" fill="${p.main}"/>
''';
    case 'book':
      return '''
<path d="M136 184c42-22 84-18 120 10v164c-38-30-78-34-120-10z" fill="${p.soft}"/>
<path d="M256 194c36-28 78-32 120-10v164c-42-24-82-20-120 10z" fill="${p.main}"/>
<path d="M256 194v164M166 232h58M166 270h58M290 234h56M290 272h56" fill="none"/>
<circle cx="316" cy="316" r="22" fill="${p.accent}"/>
''';
    case 'emotionCards':
      return '''
<rect x="126" y="206" width="92" height="132" rx="18" fill="${p.soft}" transform="rotate(-8 172 272)"/>
<rect x="210" y="188" width="92" height="132" rx="18" fill="${p.main}"/>
<rect x="294" y="206" width="92" height="132" rx="18" fill="${p.accent}" transform="rotate(8 340 272)"/>
<path d="M154 268c12 12 26 12 38 0M236 258c12-12 26-12 38 0M320 274c12 10 26 10 38 0" fill="none"/>
<circle cx="158" cy="242" r="5" fill="#5F625B" stroke="none"/>
<circle cx="192" cy="242" r="5" fill="#5F625B" stroke="none"/>
''';
    case 'phone':
      return '''
<rect x="190" y="152" width="132" height="220" rx="30" fill="${p.main}"/>
<rect x="212" y="198" width="88" height="86" rx="16" fill="${p.soft}"/>
<circle cx="256" cy="326" r="18" fill="${p.accent}"/>
<path d="M222 180h68M230 302h52" fill="none"/>
''';
    case 'storyPuppets':
      return '''
<rect x="138" y="182" width="236" height="174" rx="22" fill="${p.soft}"/>
<path d="M138 224c38 26 74 26 112 0v132H138zM374 224c-38 26-74 26-112 0v132h112z" fill="${p.main}"/>
<circle cx="218" cy="282" r="28" fill="${p.accent}"/>
<circle cx="298" cy="282" r="28" fill="${p.accent}"/>
<path d="M218 310v42M298 310v42" fill="none"/>
''';
    case 'alphabet':
      return '''
<rect x="142" y="228" width="80" height="80" rx="14" fill="${p.main}"/>
<rect x="216" y="174" width="80" height="80" rx="14" fill="${p.soft}"/>
<rect x="290" y="246" width="80" height="80" rx="14" fill="${p.accent}"/>
<text x="182" y="282" text-anchor="middle" font-family="Arial" font-size="44" font-weight="700" fill="#5F625B" stroke="none">A</text>
<text x="256" y="228" text-anchor="middle" font-family="Arial" font-size="44" font-weight="700" fill="#5F625B" stroke="none">B</text>
<text x="330" y="300" text-anchor="middle" font-family="Arial" font-size="44" font-weight="700" fill="#5F625B" stroke="none">C</text>
''';
    case 'animalCards':
      return '''
<rect x="144" y="196" width="96" height="138" rx="18" fill="${p.soft}" transform="rotate(-6 192 265)"/>
<rect x="272" y="196" width="96" height="138" rx="18" fill="${p.main}" transform="rotate(6 320 265)"/>
<circle cx="192" cy="252" r="30" fill="#FFFCF7"/>
<circle cx="320" cy="252" r="30" fill="#FFFCF7"/>
<path d="M170 228l-16-20M214 228l16-20M300 230l-18-18M340 230l18-18" fill="none"/>
<path d="M176 286h32M304 286h32" fill="none"/>
''';
    case 'sequenceCards':
      return '''
<rect x="118" y="214" width="82" height="118" rx="16" fill="${p.soft}"/>
<rect x="216" y="196" width="82" height="118" rx="16" fill="${p.main}"/>
<rect x="314" y="214" width="82" height="118" rx="16" fill="${p.accent}"/>
<circle cx="159" cy="258" r="18" fill="#F4D56F" stroke="none"/>
<path d="M242 274l16-34 16 34zM340 278h32M356 248v60" fill="none"/>
<path d="M204 274h10M302 274h10" fill="none"/>
''';
    case 'microphone':
      return '''
<rect x="218" y="150" width="76" height="128" rx="38" fill="${p.main}"/>
<path d="M180 236c0 58 152 58 152 0M256 306v58M208 364h96" fill="none"/>
<path d="M230 188h52M230 224h52" fill="none" stroke="#FFFCF7"/>
''';
    case 'soundBook':
      return '''
<path d="M142 194c38-20 76-16 114 10v150c-38-26-76-30-114-10z" fill="${p.soft}"/>
<path d="M256 204c38-26 76-30 114-10v150c-38-20-76-16-114 10z" fill="${p.main}"/>
<path d="M256 204v150M306 244v56c0 18-32 18-32 0s32-18 32 0M332 230v50c0 18-30 18-30 0s30-16 30 0" fill="none"/>
''';
    case 'storyCards':
      return '''
<rect x="146" y="212" width="86" height="122" rx="16" fill="${p.soft}" transform="rotate(-9 189 273)"/>
<rect x="214" y="186" width="86" height="122" rx="16" fill="${p.main}"/>
<rect x="282" y="212" width="86" height="122" rx="16" fill="${p.accent}" transform="rotate(9 325 273)"/>
<path d="M174 270c18-28 46-28 58 0M246 246h22M246 278h36M306 268l18-28 18 28" fill="none"/>
''';
    case 'magnifier':
      return '''
<circle cx="226" cy="224" r="76" fill="${p.soft}" opacity="0.78"/>
<circle cx="226" cy="224" r="76" fill="none"/>
<path d="M282 280l82 82" fill="none" stroke="${p.deep}" stroke-width="22"/>
<circle cx="204" cy="206" r="18" fill="#FFFCF7" stroke="none" opacity="0.82"/>
<path d="M194 288c44 18 88 8 118-30" fill="none" opacity="0.35"/>
''';
    case 'sensoryBottles':
      return '''
<rect x="152" y="174" width="70" height="178" rx="30" fill="${p.soft}"/>
<rect x="236" y="154" width="70" height="198" rx="30" fill="${p.main}"/>
<rect x="320" y="184" width="70" height="168" rx="30" fill="${p.accent}"/>
<path d="M164 222h46M248 236h46M332 250h46" fill="none" stroke="#FFFCF7"/>
<circle cx="186" cy="276" r="9" fill="#FFFCF7" stroke="none"/>
<circle cx="272" cy="294" r="9" fill="#FFFCF7" stroke="none"/>
<circle cx="356" cy="288" r="9" fill="#FFFCF7" stroke="none"/>
''';
    case 'instruments':
      return '''
<rect x="160" y="234" width="118" height="98" rx="22" fill="${p.main}"/>
<ellipse cx="219" cy="234" rx="59" ry="24" fill="${p.soft}"/>
<path d="M170 274h98M190 332v32M248 332v32" fill="none"/>
<circle cx="330" cy="224" r="34" fill="${p.accent}"/>
<path d="M330 258v88M298 322l64-64" fill="none"/>
''';
    case 'transparentBlocks':
      return '''
<rect x="150" y="244" width="96" height="96" rx="16" fill="${p.main}" opacity="0.62"/>
<rect x="220" y="178" width="96" height="96" rx="16" fill="${p.accent}" opacity="0.58"/>
<rect x="286" y="260" width="96" height="96" rx="16" fill="${p.soft}" opacity="0.72"/>
<path d="M170 264h56v56M240 198h56v56M306 280h56v56" fill="none" opacity="0.45"/>
''';
    case 'discoveryJars':
      return '''
<path d="M162 188h76v28c0 16-8 24-8 44v80c0 16-14 28-30 28s-30-12-30-28v-80c0-20-8-28-8-44z" fill="${p.soft}"/>
<path d="M274 188h76v28c0 16-8 24-8 44v80c0 16-14 28-30 28s-30-12-30-28v-80c0-20-8-28-8-44z" fill="${p.main}"/>
<circle cx="200" cy="292" r="14" fill="${p.accent}"/>
<path d="M298 298l18-30 18 30z" fill="${p.accent}"/>
''';
    case 'activityTable':
      return '''
<rect x="150" y="202" width="212" height="118" rx="24" fill="${p.soft}"/>
<path d="M184 320v54M328 320v54M176 238h160" fill="none"/>
<circle cx="206" cy="270" r="24" fill="${p.main}"/>
<rect x="248" y="246" width="48" height="48" rx="12" fill="${p.accent}"/>
<path d="M320 246c24 26 24 50 0 76" fill="none"/>
''';
    case 'rattles':
      return '''
<circle cx="204" cy="214" r="46" fill="${p.main}"/>
<circle cx="318" cy="214" r="46" fill="${p.accent}"/>
<path d="M232 246l58 84M290 246l-58 84" fill="none"/>
<rect x="196" y="326" width="72" height="30" rx="15" fill="${p.soft}" transform="rotate(35 232 341)"/>
<rect x="244" y="326" width="72" height="30" rx="15" fill="${p.soft}" transform="rotate(-35 280 341)"/>
''';
    case 'textureBox':
      return '''
<path d="M148 246h216v98H148z" fill="${p.soft}"/>
<path d="M148 246l46-54h216l-46 54z" fill="${p.main}"/>
<path d="M364 246l46-54v98l-46 54z" fill="${p.accent}"/>
<path d="M188 286h44M260 286h44M188 318h116" fill="none" opacity="0.45"/>
''';
    case 'flashlight':
      return '''
<path d="M164 250l108-58 52 96-108 58z" fill="${p.main}"/>
<path d="M318 190l72-38 38 72-72 38z" fill="${p.soft}"/>
<path d="M120 274l-54-28M128 314l-66 12M154 350l-44 48" fill="none" stroke="${p.accent}" opacity="0.65"/>
<circle cx="256" cy="270" r="14" fill="#FFFCF7" stroke="none"/>
''';
    case 'magneticBlocks':
      return '''
<rect x="148" y="242" width="96" height="96" rx="14" fill="${p.main}"/>
<rect x="268" y="194" width="96" height="96" rx="14" fill="${p.accent}"/>
<path d="M178 290c0-28 36-28 36 0v22M298 242c0-28 36-28 36 0v22" fill="none" stroke="#FFFCF7"/>
<circle cx="244" cy="242" r="20" fill="${p.soft}"/>
<circle cx="268" cy="290" r="20" fill="${p.soft}"/>
''';
  }

  throw ArgumentError('Unknown asset kind: $kind');
}
