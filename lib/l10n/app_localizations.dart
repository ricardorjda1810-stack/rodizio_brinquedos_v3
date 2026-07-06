import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:rodizio_brinquedos_v3/services/app_trial_service.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = <Locale>[
    Locale('pt', 'BR'),
    Locale('en', 'US'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    return localizations ?? const AppLocalizations(Locale('pt', 'BR'));
  }

  bool get isEn => locale.languageCode.toLowerCase() == 'en';

  String get dateLocale => isEn ? 'en_US' : 'pt_BR';

  String get appName => isEn ? 'Toy Rotation' : 'Rodízio de Brinquedos';
  String get appNameUpper => isEn ? 'TOY ROTATION' : 'RODÍZIO DE BRINQUEDOS';
  String get home => isEn ? 'Home' : 'Início';
  String get toys => isEn ? 'Toys' : 'Brinquedos';
  String get rotation => isEn ? 'Rotation' : 'Rodízio';
  String get boxes => isEn ? 'Boxes' : 'Caixas';
  String get settings => isEn ? 'Settings' : 'Configurações';
  String get settingsShort => isEn ? 'Settings' : 'Config.';
  String get planning => isEn ? 'Planning' : 'Planejamento';
  String get weeklyPlanning =>
      isEn ? 'Weekly planning' : 'Planejamento semanal';
  String get catalog => isEn ? 'Catalog' : 'Catálogo';
  String get searchToy => isEn ? 'Search toy' : 'Buscar brinquedo';
  String get toyName => isEn ? 'Toy name' : 'Nome do brinquedo';
  String get filters => isEn ? 'Filters' : 'Filtros';
  String get all => isEn ? 'All' : 'Todos';
  String get noBox => isEn ? 'No box' : 'Sem caixa';
  String get noLocation => isEn ? 'No location' : 'Sem local';
  String get noCategory => isEn ? 'No category' : 'Sem categoria';
  String get unnamedToy => isEn ? 'Unnamed toy' : 'Sem nome';
  String get toy => isEn ? 'Toy' : 'Brinquedo';
  String get stored => isEn ? 'Stored' : 'Guardado';
  String get inCollection => isEn ? 'in collection' : 'no acervo';
  String get fullCollection => isEn ? 'full collection' : 'acervo completo';
  String get today => isEn ? 'Today' : 'Hoje';
  String get timeToPlay => isEn ? 'Time to play' : 'Hora de brincar';
  String get todaysRotation => isEn ? "Today's rotation" : 'Rodada de hoje';
  String get toysForToday => isEn ? 'toys\nfor today' : 'brinquedos\npara hoje';
  String get buildRotation => isEn ? 'Build rotation' : 'Montar rodada';
  String get newToy => isEn ? 'New toy' : 'Novo brinquedo';
  String get homeOrganization =>
      isEn ? 'Home organization' : 'Organização da casa';
  String get location => isEn ? 'Location' : 'Local';
  String get locations => isEn ? 'locations' : 'locais';
  String get playSet => isEn ? 'Play set' : 'Brincadeira';
  String get itemsAvailable => isEn ? 'items available' : 'itens disponíveis';
  String get suggest => isEn ? 'Suggest' : 'Sugerir';
  String get suggestRound => isEn ? 'Suggest rotation' : 'Sugerir rodada';
  String get details => isEn ? 'Details' : 'Detalhes';
  String get build => isEn ? 'Build' : 'Montar';
  String get marked => isEn ? 'Marked' : 'Marcado';
  String get pending => isEn ? 'Pending' : 'Pendente';
  String get mark => isEn ? 'Mark' : 'Marcar';
  String get unmark => isEn ? 'Unmark' : 'Desmarcar';
  String get openToy => isEn ? 'Open toy' : 'Abrir brinquedo';
  String get viewToys => isEn ? 'View toys' : 'Ver brinquedos';
  String get moreOptions => isEn ? 'More options' : 'Mais opções';
  String get hideToys => isEn ? 'Hide toys' : 'Ocultar brinquedos';
  String get showToys => isEn ? 'View toys' : 'Ver brinquedos';
  String get createBox => isEn ? 'Create box' : 'Criar caixa';
  String get newBox => isEn ? 'New box' : 'Nova caixa';
  String get noBoxesTitle => isEn ? 'No boxes yet' : 'Nenhuma caixa cadastrada';
  String get noBoxesMessage => isEn
      ? 'Create the first box to organize toys at home with more ease.'
      : 'Crie a primeira caixa para organizar os brinquedos da casa com mais leveza.';
  String get boxesAtHome => isEn ? 'Home boxes' : 'Caixas da casa';
  String get boxesIntro => isEn
      ? 'See where each group is stored and open toys in a more organized way.'
      : 'Visualize onde cada grupo está guardado e abra os brinquedos de forma mais organizada.';
  String get boxActions => isEn ? 'Box actions' : 'Ações da caixa';
  String get editLocation => isEn ? 'Edit location' : 'Editar local';
  String get changePhoto => isEn ? 'Change photo' : 'Trocar foto';
  String get addPhoto => isEn ? 'Add photo' : 'Adicionar foto';
  String get editInfo => isEn ? 'Edit information' : 'Editar informações';
  String get openInToys => isEn ? 'Open in Toys' : 'Abrir em Brinquedos';
  String get delete => isEn ? 'Delete' : 'Excluir';
  String get viewLocations => isEn ? 'View locations' : 'Ver locais';
  String get myBoxes => isEn ? 'My boxes' : 'Minhas caixas';
  String get noToysInBox =>
      isEn ? 'No toys in this box.' : 'Nenhum brinquedo nesta caixa.';
  String get toyFromBox => isEn ? 'Toy in this box' : 'Brinquedo da caixa';
  String get unboxedToys => isEn
      ? 'Toys that need organization'
      : 'Brinquedos que precisam de organização';
  String get noLocationDefined =>
      isEn ? 'No location set' : 'Sem local definido';
  String get information => isEn ? 'Information' : 'Informações';
  String get name => isEn ? 'Name' : 'Nome';
  String get box => isEn ? 'Box' : 'Caixa';
  String get category => isEn ? 'Category' : 'Categoria';
  String get photo => isEn ? 'Photo' : 'Foto';
  String get toyPhoto => isEn ? 'Toy photo' : 'Foto do brinquedo';
  String get noPhoto => isEn ? 'No photo' : 'Sem foto';
  String get takePhoto => isEn ? 'Take photo' : 'Tirar foto';
  String get chooseFromGallery =>
      isEn ? 'Choose from gallery' : 'Escolher da galeria';
  String get removePhoto => isEn ? 'Remove photo' : 'Remover foto';
  String get photoActions => isEn ? 'Photo actions' : 'Ações da foto';
  String get toyActions => isEn ? 'Toy actions' : 'Ações do brinquedo';
  String get tapPhotoFullScreen => isEn
      ? 'Tap the photo to open it full screen.'
      : 'Toque na foto para abrir em destaque.';
  String get toyDetailIntro => isEn
      ? 'Photo, category, and location in one simple view.'
      : 'Foto, categoria e localização em uma visão simples.';
  String get edit => isEn ? 'Edit' : 'Editar';
  String get back => isEn ? 'Back' : 'Voltar';
  String get editName => isEn ? 'Edit name' : 'Editar nome';
  String get editCategory => isEn ? 'Edit category' : 'Editar categoria';
  String get editBox => isEn ? 'Edit box' : 'Editar caixa';
  String get deleteToy => isEn ? 'Delete toy' : 'Excluir brinquedo';
  String get save => isEn ? 'Save' : 'Salvar';
  String get cancel => isEn ? 'Cancel' : 'Cancelar';
  String get selectBox => isEn ? 'Select box' : 'Selecionar caixa';
  String get chooseCategory =>
      isEn ? 'Choose a category' : 'Escolha uma categoria';
  String get officialCategory =>
      isEn ? 'Official category' : 'Categoria oficial';
  String get noOfficialCategory => isEn
      ? 'No active official category.'
      : 'Nenhuma categoria oficial ativa.';
  String get boxLocation => isEn ? 'Box location' : 'Local da caixa';
  String get outsideBoxLocation =>
      isEn ? 'Location outside box' : 'Local fora da caixa';
  String get unboxedLocation =>
      isEn ? 'Location without box' : 'Local sem caixa';
  String get weeklySummary => isEn ? 'Weekly summary' : 'Resumo da semana';
  String get weeklyTotalsSubtitle => isEn
      ? "Totals include today's rotation and the next few days."
      : 'Totais consideram a rodada de hoje e os próximos dias.';
  String get toysThisWeek => isEn ? 'toys this week' : 'brinquedos na semana';
  String get averagePerDay => isEn ? 'average per day' : 'média por dia';
  String get boxesInUse => isEn ? 'boxes in use' : 'caixas em uso';
  String get categoryDistribution =>
      isEn ? 'Distribution by category' : 'Distribuição por categoria';
  String get editSchedule => isEn ? 'Edit schedule' : 'Editar programação';
  String get adjustCategories =>
      isEn ? 'Adjust categories' : 'Ajustar categorias';
  String get currentWeek => isEn ? 'Current week' : 'Semana atual';
  String get planned => isEn ? 'Planned' : 'Planejado';
  String get toPlan => isEn ? 'To plan' : 'A planejar';
  String get custom => isEn ? 'Custom' : 'Personalizado';
  String get standard => isEn ? 'Default' : 'Padrão';
  String get noPlannedToys =>
      isEn ? 'No planned toys' : 'Nenhum brinquedo planejado';
  String get notEnoughToys =>
      isEn ? 'Not enough toys' : 'Sem brinquedos suficientes';
  String get weekSchedule => isEn ? 'Week schedule' : 'Programação da semana';
  String get subscription => isEn ? 'Subscription' : 'Assinatura';
  String get restorePurchase => isEn ? 'Restore purchase' : 'Restaurar compra';
  String get restorePurchases =>
      isEn ? 'Restore purchases' : 'Restaurar compras';
  String get termsOfUse => isEn ? 'Terms of Use' : 'Termos de uso';
  String get privacyPolicy =>
      isEn ? 'Privacy Policy' : 'Política de privacidade';
  String get choosePlan => isEn ? 'Choose a plan' : 'Escolha um plano';
  String get annualPlan => isEn ? 'Annual plan' : 'Plano anual';
  String get monthlyPlan => isEn ? 'Monthly plan' : 'Plano mensal';
  String get continueWithSubscription =>
      isEn ? 'Continue with subscription' : 'Continuar com assinatura';
  String get trialEndedTitle =>
      isEn ? 'Your free trial has ended' : 'Seu teste grátis terminou';
  String get trialEndedSubtitle => isEn
      ? 'Choose a plan to continue organizing toys at home.'
      : 'Para continuar organizando os brinquedos da casa, escolha um plano.';
  String get subscriptionRequired =>
      isEn ? 'SUBSCRIPTION REQUIRED' : 'ASSINATURA NECESSÁRIA';
  String get notNow => isEn ? 'Not now' : 'Agora não';
  String get processing => isEn ? 'Processing...' : 'Processando...';
  String get startNow => isEn ? 'Start now' : 'Começar agora';
  String get mostPopular => isEn ? 'Most popular' : 'Mais popular';
  String get appFullAccess =>
      isEn ? 'Full app access' : 'App completo liberado';
  String get appFullAccessDescription => isEn
      ? 'Keep using Home, toys, boxes, rotation suggestions, and weekly planning after your trial.'
      : 'Mantenha Home, brinquedos, caixas, sugestão de rodada e planejamento semanal liberados após o teste.';
  String get selectAPlanSubtitle => isEn
      ? 'Subscribe to continue using Toy Rotation.'
      : 'Assine para continuar usando o Rodízio de Brinquedos.';

  String get fallbackAnnualPrice => isEn ? r'$19.99/year' : 'R\$ 99,90/ano';
  String get fallbackMonthlyPrice => isEn ? r'$2.99/month' : 'R\$ 14,90/mês';
  String get fallbackAnnualEquivalent =>
      isEn ? r'about $1.67/month' : 'equivalente a R\$ 8,32/mês';

  String trialHomeNotice(AppTrialStatus status) {
    if (!status.isTrialActive) return '';
    if (status.remainingDays <= 1) {
      return isEn
          ? 'Your free trial ends today'
          : 'Seu teste grátis termina hoje';
    }
    return isEn
        ? 'Free trial active - ${status.remainingDays} days left'
        : 'Teste grátis ativo - faltam ${status.remainingDays} dias';
  }

  String toysCount(int count) {
    if (isEn) return count == 1 ? '1 toy' : '$count toys';
    return count == 1 ? '1 brinquedo' : '$count brinquedos';
  }

  String compactToysCount(int count) {
    if (isEn) return count == 1 ? '1 toy' : '$count toys';
    return '$count brinq.';
  }

  String compactWeekdayLabel(int weekday, {required bool isToday}) {
    if (isToday) return isEn ? 'TODAY' : 'HOJE';
    if (isEn) {
      switch (weekday) {
        case DateTime.monday:
          return 'MON';
        case DateTime.tuesday:
          return 'TUE';
        case DateTime.wednesday:
          return 'WED';
        case DateTime.thursday:
          return 'THU';
        case DateTime.friday:
          return 'FRI';
        case DateTime.saturday:
          return 'SAT';
        case DateTime.sunday:
          return 'SUN';
      }
      return '';
    }
    switch (weekday) {
      case DateTime.monday:
        return 'SEG';
      case DateTime.tuesday:
        return 'TER';
      case DateTime.wednesday:
        return 'QUA';
      case DateTime.thursday:
        return 'QUI';
      case DateTime.friday:
        return 'SEX';
      case DateTime.saturday:
        return 'SÁB';
      case DateTime.sunday:
        return 'DOM';
    }
    return '';
  }

  String itemsCount(int count) {
    if (isEn) return count == 1 ? '1 item' : '$count items';
    return count == 1 ? '1 item' : '$count itens';
  }

  String toysAvailableCount(int count) {
    if (isEn) return count == 1 ? '1 item available' : '$count items available';
    return count == 1 ? '1 item disponível' : '$count itens disponíveis';
  }

  String toysMarkedCount(int collected, int total) {
    if (isEn) return '$collected of $total toys set aside';
    return '$collected de $total brinquedos separados';
  }

  String toysForWeekCount(int count) {
    if (isEn) {
      return count == 1 ? '1 toy this week' : '$count toys this week';
    }
    return count == 1 ? '1 brinquedo na semana' : '$count brinquedos na semana';
  }

  String plannedToyCount(int count) {
    if (isEn) return count == 1 ? '1 planned toy' : '$count planned toys';
    return count == 1
        ? '1 brinquedo programado'
        : '$count brinquedos programados';
  }

  String boxNumber(int number) => isEn ? 'Box $number' : 'Caixa $number';

  String value(String? text) {
    final original = text?.trim() ?? '';
    if (original.isEmpty || !isEn) return original;
    return _enValueTranslations[original] ?? original;
  }

  String categoryName(String? text) => value(text);
  String toyDisplayName(String? text) {
    final original = text?.trim() ?? '';
    if (original.isEmpty) return unnamedToy;
    return value(original);
  }

  String boxLocationLabel(int number, String? local) {
    final translatedLocal = value(local);
    if (translatedLocal.isEmpty) return boxNumber(number);
    return '${boxNumber(number)} - $translatedLocal';
  }

  String boxAndLocation({required String boxName, required String location}) {
    return isEn
        ? '$boxName - Location: $location'
        : '$boxName - Local: $location';
  }

  static const Map<String, String> _enValueTranslations = {
    'Corpo e Respiração': 'Body & Breathing',
    'Corpo e Respiracao': 'Body & Breathing',
    'Sentidos e Exploração': 'Senses & Exploration',
    'Sentidos e Exploracao': 'Senses & Exploration',
    'Mãos e Construção': 'Hands & Building',
    'Maos e Construcao': 'Hands & Building',
    'Imaginação e Criatividade': 'Imagination & Creativity',
    'Imaginacao e Criatividade': 'Imagination & Creativity',
    'Comunicação e Histórias': 'Communication & Stories',
    'Comunicacao e Historias': 'Communication & Stories',
    'Bola macia': 'Soft ball',
    'Lupa infantil': "Kids' magnifier",
    'Torre de empilhar': 'Stacking tower',
    'Cozinha de brinquedo': 'Play kitchen',
    'Livro cartonado': 'Board book',
    'Kit jardinagem infantil': 'Gardening set',
    'Túnel infantil dobrável': 'Foldable play tunnel',
    'Tunel infantil dobravel': 'Foldable play tunnel',
    'Instrumentos musicais simples': 'Simple musical instruments',
    'Encaixe de formas': 'Shape sorter',
    'Comidinhas de madeira': 'Wooden play food',
    'Cartões de figuras': 'Picture cards',
    'Cartoes de figuras': 'Picture cards',
    'Mesa de areia e água': 'Sand and water table',
    'Mesa de areia e agua': 'Sand and water table',
    'Quebra-cabeça de madeira': 'Wooden puzzle',
    'Quebra-cabeca de madeira': 'Wooden puzzle',
    'Animais de fazenda': 'Farm animals',
    'Casinha de bonecos': 'Dollhouse',
    'Kit médico infantil': "Kids' doctor kit",
    'Kit medico infantil': "Kids' doctor kit",
    'Telefone de brinquedo simples': 'Toy phone',
    'Carrinhos de madeira': 'Wooden cars',
    'Cubos de montar': 'Building blocks',
    'Sala': 'Living room',
    'Quarto': 'Bedroom',
    'Prateleira baixa': 'Low shelf',
    'Caixa de tecido': 'Fabric box',
    'Estante Montessori': 'Montessori shelf',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode.toLowerCase() == 'pt' ||
        locale.languageCode.toLowerCase() == 'en';
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    final normalized = locale.languageCode.toLowerCase() == 'en'
        ? const Locale('en', 'US')
        : const Locale('pt', 'BR');
    return SynchronousFuture<AppLocalizations>(AppLocalizations(normalized));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
