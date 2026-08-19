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
  String get search => isEn ? 'Search' : 'Buscar';
  String get searchShort => isEn ? 'Search' : 'Busca';
  String get clear => isEn ? 'Clear' : 'Limpar';
  String get clearFilters => isEn ? 'Clear filters' : 'Limpar filtros';
  String get clearSearch => isEn ? 'Clear search' : 'Limpar busca';
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
  String get renameBox => isEn ? 'Rename box' : 'Renomear caixa';
  String get boxName => isEn ? 'Box name' : 'Nome da caixa';
  String get boxNameRequired =>
      isEn ? 'Enter a box name.' : 'Informe o nome da caixa.';
  String get boxRenamed => isEn ? 'Box renamed.' : 'Caixa renomeada.';
  String renameBoxFailure(Object error) =>
      isEn ? 'Error renaming box: $error' : 'Erro ao renomear caixa: $error';
  String get backToHome => isEn ? 'Back to Home' : 'Voltar ao início';
  String get editLocation => isEn ? 'Edit location' : 'Editar local';
  String get changePhoto => isEn ? 'Change photo' : 'Trocar foto';
  String get addPhoto => isEn ? 'Add photo' : 'Adicionar foto';
  String get editInfo => isEn ? 'Edit information' : 'Editar informações';
  String get openInToys => isEn ? 'Open in Toys' : 'Abrir em Brinquedos';
  String get delete => isEn ? 'Delete' : 'Excluir';
  String get deleteUpper => isEn ? 'DELETE' : 'EXCLUIR';
  String get cancelUpper => isEn ? 'CANCEL' : 'CANCELAR';
  String get saveUpper => isEn ? 'SAVE' : 'SALVAR';
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
  String get boxUpper => isEn ? 'BOX' : 'CAIXA';
  String get category => isEn ? 'Category' : 'Categoria';
  String get categories => isEn ? 'Categories' : 'Categorias';
  String get locationsTitle => isEn ? 'Locations' : 'Locais';
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
  String get camera => isEn ? 'Camera' : 'Câmera';
  String get gallery => isEn ? 'Gallery' : 'Galeria';
  String get saving => isEn ? 'Saving...' : 'Salvando...';
  String get saveToy => isEn ? 'Save toy' : 'Salvar brinquedo';
  String get saveAndAddAnother =>
      isEn ? 'Save and add another' : 'Salvar e outro';
  String get toyCreateIntro => isEn
      ? 'Photo, category, and storage. The essentials in just a few steps.'
      : 'Foto, categoria e lugar de guardar. O essencial em poucos passos.';
  String get toyCreateHeaderSubtitle => isEn
      ? 'Add a toy to include it in the rotation.'
      : 'Cadastre um brinquedo para incluir no rodízio.';
  String get toyCreatePhotoSubtitle => isEn
      ? 'The photo appears first and helps recognize everything faster.'
      : 'A foto aparece primeiro e ajuda a reconhecer tudo mais rápido.';
  String get noPhotoAdded =>
      isEn ? 'No photo added' : 'Nenhuma foto adicionada';
  String get addPhotoFromCameraOrGallery => isEn
      ? 'Tap camera or gallery to add one.'
      : 'Toque em câmera ou galeria para incluir.';
  String get adjustPhoto => isEn ? 'Adjust photo' : 'Ajustar foto';
  String get cropPhotoInstruction => isEn
      ? 'Tap "Use photo" to open the editor and finish cropping.'
      : 'Toque em "Usar foto" para abrir o ajuste e concluir o recorte.';
  String get usePhoto => isEn ? 'Use photo' : 'Usar foto';
  String get photoUnavailable => isEn
      ? "Couldn't use the photo. Try again."
      : 'Não foi possível usar a foto. Tente novamente.';
  String get photoProcessingFailure =>
      isEn ? 'Error processing the photo.' : 'Erro ao processar a foto.';
  String get preview => isEn ? 'Preview' : 'Prévia';
  String get toyPreviewSubtitle => isEn
      ? 'How the toy will first appear in the catalog.'
      : 'Como o brinquedo começa a aparecer no catálogo.';
  String get generatedToyNamePreview =>
      isEn ? 'Automatically generated name' : 'Nome gerado automaticamente';
  String get categoryPending =>
      isEn ? 'Category pending' : 'Categoria pendente';
  String get locationPending => isEn ? 'Location pending' : 'Local pendente';
  String get missingCategoryAndLocation =>
      isEn ? 'Category and location missing' : 'Faltam categoria e local';
  String get missingCategory => isEn ? 'Category missing' : 'Falta categoria';
  String get missingLocation => isEn ? 'Location missing' : 'Falta local';
  String get readyToSave => isEn ? 'Ready to save' : 'Pronto para salvar';
  String get readyForRotation => isEn
      ? 'Everything is ready for the rotation.'
      : 'Tudo certo para entrar no rodízio.';
  String get completeRequiredFields => isEn
      ? 'Complete the required fields before saving.'
      : 'Complete os campos obrigatórios antes de salvar.';
  String get mainInformation =>
      isEn ? 'Main information' : 'Informações principais';
  String get toyNameOptionalSubtitle => isEn
      ? 'Enter a name or leave it blank for the app to generate one.'
      : 'Digite um nome ou deixe vazio para o app gerar.';
  String get toyNameExample =>
      isEn ? 'E.g. Building blocks' : 'Ex: Blocos de montar';
  String get toyNameOptionalHelper => isEn
      ? 'Optional. Leave blank to use the automatic box-based name.'
      : 'Opcional: vazio usa o nome automático por caixa.';
  String get toyNameRecognitionHelper => isEn
      ? 'Optional. You can edit the AI suggestion.'
      : 'Opcional. Você pode editar a sugestão da IA.';
  String get organization => isEn ? 'Organization' : 'Organização';
  String get primaryCategory =>
      isEn ? 'Primary category' : 'Categoria principal';
  String get categorySelectionSubtitle => isEn
      ? 'Choose the main stimulus to balance rotations.'
      : 'Escolha o estímulo principal para equilibrar as rodadas.';
  String get primaryCategoryInstruction => isEn
      ? 'Choose just one: the category that best represents the main stimulus.'
      : 'Escolha só uma: a que melhor representa o estímulo principal.';
  String get preparingOfficialCategories => isEn
      ? 'Preparing official categories...'
      : 'Preparando categorias oficiais...';
  String get required => isEn ? 'Required.' : 'Obrigatório.';
  String get categoryRequiredToSave => isEn
      ? 'A category is required to save.'
      : 'Categoria obrigatória para salvar.';
  String get categoryBalanceHelp => isEn
      ? 'The category balances rotations and keeps play varied.'
      : 'A categoria equilibra as rodadas e garante variedade nas brincadeiras.';
  String get storageSubtitle => isEn
      ? 'Choose where the toy is stored.'
      : 'Escolha onde o brinquedo fica guardado.';
  String get whereToStore => isEn ? 'Where to store it' : 'Onde guardar';
  String get storageInstruction => isEn
      ? 'You can store it in a box or mark it as an item without a box.'
      : 'Você pode deixar em uma caixa ou marcar como item sem caixa.';
  String get chooseBoxOrNoBox => isEn
      ? 'Choose a box or select "No box".'
      : 'Escolha uma caixa ou marque "Sem caixa".';
  String get selectABox => isEn ? 'Select a box' : 'Selecione uma caixa';
  String get newShort => isEn ? 'New' : 'Nova';
  String get newToyRotationNote => isEn
      ? 'Every new toy enters the rotation after it is saved.'
      : 'Todo brinquedo novo entra no rodízio após salvar.';
  String get actions => isEn ? 'Actions' : 'Ações';
  String get saveAnotherHelp => isEn
      ? 'Save and keep adding toys when organizing several at once.'
      : 'Salve e continue cadastrando quando estiver organizando muitos brinquedos.';
  String get selectCategoryValidation =>
      isEn ? 'Select a category.' : 'Selecione uma categoria.';
  String get selectStorageValidation => isEn
      ? 'Select a box or choose "No box" to save the toy.'
      : 'Selecione uma caixa ou escolha "Sem caixa" para salvar o brinquedo.';
  String get toySavedAddAnother =>
      isEn ? 'Toy saved! Add another one.' : 'Brinquedo salvo! Adicione outro.';
  String saveToyFailure(Object error) =>
      isEn ? 'Error saving toy: $error' : 'Erro ao salvar brinquedo: $error';
  String get recognizingToy =>
      isEn ? 'Recognizing toy...' : 'Reconhecendo brinquedo...';
  String get recognitionLoadingMessage => isEn
      ? 'The photo is analyzed without saving automatically.'
      : 'A foto é analisada sem salvar automaticamente.';
  String get recognitionSuggestionFailureTitle =>
      isEn ? "Couldn't suggest a toy" : 'Não foi possível sugerir';
  String get suggestionApplied =>
      isEn ? 'Suggestion applied' : 'Sugestão aplicada';
  String recognitionAppliedMessage(String name, String category) => isEn
      ? '$name · $category. Review the fields before saving.'
      : '$name · $category. Revise os campos antes de salvar.';
  String get analyzeAgain => isEn ? 'Analyze again' : 'Analisar novamente';
  String suggestedCategory(String category) => isEn
      ? 'Suggested category: $category.'
      : 'Categoria sugerida: $category.';
  String recognitionResultMessage(
    String category,
    int confidencePercent,
    String explanation,
  ) =>
      isEn
          ? '$category · $confidencePercent% confidence. $explanation'
          : '$category · confiança $confidencePercent%. $explanation';
  String get useSuggestion => isEn ? 'Use suggestion' : 'Usar sugestão';
  String get discard => isEn ? 'Discard' : 'Descartar';
  String get recognitionNoPhoto => isEn
      ? 'Add an available photo before starting recognition.'
      : 'Adicione uma foto disponível antes de iniciar o reconhecimento.';
  String get recognitionCategoriesUnavailable => isEn
      ? 'Categories are still being prepared. Try again.'
      : 'As categorias ainda estão sendo preparadas. Tente novamente.';
  String get recognitionUnsupportedImage => isEn
      ? 'Use a valid JPG, PNG, or WebP photo.'
      : 'Use uma foto JPG, PNG ou WebP válida.';
  String get recognitionImageTooLarge => isEn
      ? 'The photo is too large. Crop closer to the toy.'
      : 'A foto ficou muito grande. Recorte mais perto do brinquedo.';
  String get recognitionNoToy => isEn
      ? "We couldn't confidently find a toy in this photo."
      : 'Não encontramos um brinquedo com segurança nessa foto.';
  String get recognitionMultipleToys => isEn
      ? 'Recognition supports one toy at a time. Crop the photo closer.'
      : 'O reconhecimento funciona com um brinquedo por vez. Recorte a foto mais de perto.';
  String get recognitionPersonDetected => isEn
      ? 'To protect privacy, use a photo that shows only the toy.'
      : 'Para proteger a privacidade, use uma foto que mostre somente o brinquedo.';
  String get recognitionUnavailable => isEn
      ? 'Recognition is temporarily unavailable. Try again.'
      : 'O reconhecimento está temporariamente indisponível. Tente novamente.';
  String get recognitionTimeout => isEn
      ? 'Recognition took too long. Try again.'
      : 'O reconhecimento demorou demais. Tente novamente.';
  String get recognitionPermissionDenied => isEn
      ? 'Recognition is not authorized on this device yet.'
      : 'O reconhecimento ainda não está autorizado neste dispositivo.';
  String get recognitionInvalidResponse => isEn
      ? 'The recognition response could not be validated. Try again.'
      : 'A resposta do reconhecimento não pôde ser validada. Tente novamente.';
  String get recognitionUnknownFailure => isEn
      ? "We couldn't recognize the toy right now. Try again."
      : 'Não foi possível reconhecer o brinquedo agora. Tente novamente.';
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
  String get daysPlanned => isEn ? 'days planned' : 'dias planejados';
  String get daysReady => isEn ? 'days ready' : 'dias prontos';
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
  String get appVersionLoading => isEn ? 'Version —' : 'Versão —';
  String get appVersionUnavailable =>
      isEn ? 'Version unavailable' : 'Versão indisponível';
  String appVersionLabel(String version, String buildNumber) {
    final normalizedVersion = version.trim();
    if (normalizedVersion.isEmpty) return appVersionUnavailable;

    final prefix = isEn ? 'Version' : 'Versão';
    final normalizedBuildNumber = buildNumber.trim();
    if (normalizedBuildNumber.isEmpty) {
      return '$prefix $normalizedVersion';
    }

    return '$prefix $normalizedVersion ($normalizedBuildNumber)';
  }

  String get choosePlan => isEn ? 'Choose a plan' : 'Escolha um plano';
  String get annualPlan => isEn ? 'Annual plan' : 'Plano anual';
  String get monthlyPlan => isEn ? 'Monthly plan' : 'Plano mensal';
  String get continueWithSubscription =>
      isEn ? 'Continue with subscription' : 'Continuar com assinatura';
  String get subscriptionPlansUnavailable => isEn
      ? "We couldn't load the subscription plans. Check your connection and try again."
      : 'Não foi possível carregar os planos. Verifique sua conexão e tente novamente.';
  String get planUnavailable =>
      isEn ? 'Plan unavailable' : 'Plano indisponível';
  String get tryAgain => isEn ? 'Try again' : 'Tentar novamente';
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
        ? 'Free trial active — ${status.remainingDays} days remaining'
        : 'Teste grátis ativo — faltam ${status.remainingDays} dias';
  }

  String get roundReadyToStart =>
      isEn ? 'Ready to start' : 'Pronta para iniciar';
  String get roundWaitingForToys =>
      isEn ? 'Waiting for toys' : 'Aguardando brinquedos';
  String get registerToysForToday => isEn
      ? "Add your home's toys to build today's rotation."
      : 'Agora cadastre os brinquedos da sua casa para montar a rodada de hoje.';
  String get selectionReasonTitle =>
      isEn ? 'Why this selection?' : 'Por que esta seleção?';
  String get selectionReasonEmpty => isEn
      ? 'The suggestion appears as soon as toys are added.'
      : 'A sugestão aparece assim que houver brinquedos cadastrados.';
  String get selectionReasonMixed => isEn
      ? 'Mixes different categories and prioritizes less used toys.'
      : 'Mistura categorias diferentes e prioriza brinquedos menos usados.';
  String get selectionReasonAvailable => isEn
      ? 'Prioritizes available toys to keep play varied.'
      : 'Prioriza brinquedos disponíveis para manter a brincadeira variada.';
  String get roundChecklist =>
      isEn ? 'Rotation checklist' : 'Checklist da rodada';
  String markedToysCount(int count) {
    if (isEn) {
      return count == 1 ? '0 of 1 toy marked' : '0 of $count toys marked';
    }
    return count == 1
        ? '0 de 1 brinquedo marcado'
        : '0 de $count brinquedos marcados';
  }

  String get startRotation => isEn ? 'Start rotation' : 'Iniciar rodada';
  String get planningLoading =>
      isEn ? 'Loading planning...' : 'Carregando planejamento...';
  String get quickActions => isEn ? 'Quick actions' : 'Ações rápidas';
  String get boxesAndLocations =>
      isEn ? 'Boxes and locations' : 'Caixas e locais';
  String get upToDate => isEn ? 'Up to date' : 'Em dia';
  String get demoExamplesRemoved =>
      isEn ? 'Demo toys removed.' : 'Brinquedos de exemplo removidos.';
  String removeExamplesFailure(Object error) => isEn
      ? 'Failed to remove demo toys: $error'
      : 'Falha ao remover exemplos: $error';

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
    final boxMatch =
        RegExp(r'^Caixa\s+(\d+)(?:\s*[-–]\s*(.+))?$').firstMatch(original);
    if (boxMatch != null) {
      final number = int.tryParse(boxMatch.group(1) ?? '');
      final local = boxMatch.group(2)?.trim() ?? '';
      if (number != null) return boxLocationLabel(number, local);
    }
    return _enValueTranslations[original] ?? original;
  }

  String categoryName(String? text) => value(text);
  String categoryNameById(String categoryId, String? fallback) {
    final trimmedFallback = fallback?.trim() ?? '';
    if (!isEn) {
      if (trimmedFallback.isNotEmpty) return trimmedFallback;
      return _ptCategoryNamesById[categoryId.trim().toLowerCase()] ??
          trimmedFallback;
    }
    return _enCategoryNamesById[categoryId.trim().toLowerCase()] ??
        value(trimmedFallback);
  }

  String categoryExamplesById(String categoryId, String? fallback) {
    final trimmedFallback = fallback?.trim() ?? '';
    if (!isEn) return trimmedFallback;
    return _enCategoryExamplesById[categoryId.trim().toLowerCase()] ??
        trimmedFallback;
  }

  String categoryDevelopmentAspectById(
    String categoryId,
    String? fallback,
  ) {
    final trimmedFallback = fallback?.trim() ?? '';
    if (!isEn) return trimmedFallback;
    return _enCategoryDevelopmentAspectsById[categoryId.trim().toLowerCase()] ??
        trimmedFallback;
  }

  String toyDisplayName(String? text) {
    final original = text?.trim() ?? '';
    if (original.isEmpty) return unnamedToy;
    return original;
  }

  String toyDisplayNameForId({
    required String id,
    required String? name,
  }) {
    final original = name?.trim() ?? '';
    if (original.isEmpty) return unnamedToy;
    if (!isEn) return original;
    return _enDemoToyNamesById[id.trim()] ?? original;
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
    'Corpo e Respiração': 'Body and Breathing',
    'Corpo e Respiracao': 'Body and Breathing',
    'Sentidos e Exploração': 'Senses and Exploration',
    'Sentidos e Exploracao': 'Senses and Exploration',
    'Mãos e Construção': 'Hands and Building',
    'Maos e Construcao': 'Hands and Building',
    'Imaginação e Criatividade': 'Imagination and Creativity',
    'Imaginacao e Criatividade': 'Imagination and Creativity',
    'Comunicação e Histórias': 'Communication and Stories',
    'Comunicacao e Historias': 'Communication and Stories',
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

  static const Map<String, String> _ptCategoryNamesById = {
    'corpo': 'Corpo e Respiração',
    'movimento': 'Corpo e Respiração',
    'exploracao': 'Sentidos e Exploração',
    'exploração': 'Sentidos e Exploração',
    'coordenacao': 'Sentidos e Exploração',
    'maos': 'Mãos e Construção',
    'mãos': 'Mãos e Construção',
    'construcao': 'Mãos e Construção',
    'imaginacao': 'Imaginação e Criatividade',
    'imaginação': 'Imaginação e Criatividade',
    'faz_de_conta': 'Imaginação e Criatividade',
    'comunicacao': 'Comunicação e Histórias',
    'comunicação': 'Comunicação e Histórias',
    'livros': 'Comunicação e Histórias',
  };

  static const Map<String, String> _enCategoryNamesById = {
    'corpo': 'Body and Breathing',
    'movimento': 'Body and Breathing',
    'exploracao': 'Senses and Exploration',
    'exploração': 'Senses and Exploration',
    'coordenacao': 'Senses and Exploration',
    'maos': 'Hands and Building',
    'mãos': 'Hands and Building',
    'construcao': 'Hands and Building',
    'imaginacao': 'Imagination and Creativity',
    'imaginação': 'Imagination and Creativity',
    'faz_de_conta': 'Imagination and Creativity',
    'comunicacao': 'Communication and Stories',
    'comunicação': 'Communication and Stories',
    'livros': 'Communication and Stories',
  };

  static const Map<String, String> _enCategoryExamplesById = {
    'corpo': 'movement • balance • breathing • body pause',
    'movimento': 'movement • balance • breathing • body pause',
    'exploracao': 'textures • sounds • colors • water • sand • discovery',
    'exploração': 'textures • sounds • colors • water • sand • discovery',
    'coordenacao': 'textures • sounds • colors • water • sand • discovery',
    'maos': 'fitting • stacking • building • problem-solving',
    'mãos': 'fitting • stacking • building • problem-solving',
    'construcao': 'fitting • stacking • building • problem-solving',
    'imaginacao': 'pretend play • art • creation • expression',
    'imaginação': 'pretend play • art • creation • expression',
    'faz_de_conta': 'pretend play • art • creation • expression',
    'comunicacao': 'books • speaking • listening • storytelling • conversation',
    'comunicação': 'books • speaking • listening • storytelling • conversation',
    'livros': 'books • speaking • listening • storytelling • conversation',
  };

  static const Map<String, String> _enCategoryDevelopmentAspectsById = {
    'corpo': 'Movement, balance, breathing, and body pause',
    'movimento': 'Movement, balance, breathing, and body pause',
    'exploracao': 'Textures, sounds, colors, water, sand, and discovery',
    'exploração': 'Textures, sounds, colors, water, sand, and discovery',
    'coordenacao': 'Textures, sounds, colors, water, sand, and discovery',
    'maos': 'Fitting, stacking, building, and problem-solving',
    'mãos': 'Fitting, stacking, building, and problem-solving',
    'construcao': 'Fitting, stacking, building, and problem-solving',
    'imaginacao': 'Pretend play, art, creation, and expression',
    'imaginação': 'Pretend play, art, creation, and expression',
    'faz_de_conta': 'Pretend play, art, creation, and expression',
    'comunicacao': 'Books, speaking, listening, storytelling, and conversation',
    'comunicação': 'Books, speaking, listening, storytelling, and conversation',
    'livros': 'Books, speaking, listening, storytelling, and conversation',
  };

  static const Map<String, String> _enDemoToyNamesById = {
    'demo_toy_corpo_bola_macia': 'Soft ball',
    'demo_toy_maos_torre_empilhar': 'Stacking tower',
    'demo_toy_imaginacao_cozinha_brinquedo': 'Play kitchen',
    'demo_toy_comunicacao_livro_cartonado': 'Board book',
    'demo_toy_exploracao_lupa_infantil': "Kids' magnifier",
    'demo_toy_corpo_tunel_infantil_dobravel': 'Foldable play tunnel',
    'demo_toy_maos_encaixe_formas': 'Shape sorter',
    'demo_toy_imaginacao_comidinhas_madeira': 'Wooden play food',
    'demo_toy_comunicacao_cartoes_figuras': 'Picture cards',
    'demo_toy_exploracao_instrumentos_musicais_simples':
        'Simple musical instruments',
    'demo_toy_corpo_bambole_infantil': 'Kids hula hoop',
    'demo_toy_maos_quebra_cabeca_madeira': 'Wooden puzzle',
    'demo_toy_imaginacao_animais_fazenda': 'Farm animals',
    'demo_toy_comunicacao_telefone_brinquedo_simples': 'Toy phone',
    'demo_toy_exploracao_mesa_areia_agua': 'Sand and water table',
    'demo_toy_corpo_tapete_movimento': 'Movement mat',
    'demo_toy_maos_blocos_grandes': 'Large blocks',
    'demo_toy_imaginacao_bonecos_familia_simples': 'Simple family figures',
    'demo_toy_comunicacao_fantoches_historia': 'Story puppets',
    'demo_toy_exploracao_kit_jardinagem_infantil': 'Gardening set',
    'demo_toy_corpo_cones_coloridos': 'Colorful cones',
    'demo_toy_maos_cubos_montar_sem_marca': 'Building blocks',
    'demo_toy_imaginacao_carrinhos_madeira': 'Wooden cars',
    'demo_toy_comunicacao_jogo_memoria_imagens': 'Picture memory game',
    'demo_toy_exploracao_animais_insetos_exploracao':
        'Exploration animals and insects',
    'demo_toy_corpo_prancha_equilibrio_baixa': 'Low balance board',
    'demo_toy_maos_brinquedo_martelar': 'Hammering toy',
    'demo_toy_imaginacao_trem_madeira': 'Wooden train',
    'demo_toy_comunicacao_letras_grandes_madeira_espuma':
        'Large wood or foam letters',
    'demo_toy_exploracao_garrafas_sensoriais_seguras': 'Safe sensory bottles',
    'demo_toy_corpo_almofadas_percurso': 'Path cushions',
    'demo_toy_maos_parafusos_porcas_grandes': 'Large nuts and bolts',
    'demo_toy_imaginacao_casinha_bonecos': 'Dollhouse',
    'demo_toy_comunicacao_dados_historias': 'Story dice',
    'demo_toy_exploracao_tubos_observacao_transparentes':
        'Clear observation tubes',
    'demo_toy_corpo_argolas_arremesso': 'Toss rings',
    'demo_toy_maos_alinhavo_pecas_grandes': 'Large lacing pieces',
    'demo_toy_imaginacao_kit_medico_infantil': "Kids' doctor kit",
    'demo_toy_comunicacao_cartoes_emocoes': 'Emotion cards',
    'demo_toy_exploracao_pedras_formas_sensoriais_grandes':
        'Large sensory stones and shapes',
    'demo_toy_corpo_cavalinho_balanco_simples': 'Simple rocking horse',
    'demo_toy_maos_painel_fechos_busy_board': 'Latch activity board',
    'demo_toy_imaginacao_fantasias_simples': 'Simple costumes',
    'demo_toy_comunicacao_mini_quadro_branco': 'Mini whiteboard',
    'demo_toy_exploracao_circuito_bolinhas_grandes': 'Large ball run',
    'demo_toy_corpo_mini_cesta_bola': 'Mini basket with ball',
    'demo_toy_maos_copos_medidores_empilhar': 'Stacking measuring cups',
    'demo_toy_imaginacao_fantoches_animais': 'Animal puppets',
    'demo_toy_comunicacao_sequencia_historias_ilustradas':
        'Illustrated story sequence',
    'demo_toy_exploracao_brinquedo_causa_efeito': 'Cause-and-effect toy',
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
