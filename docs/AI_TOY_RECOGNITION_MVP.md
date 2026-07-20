# MVP: reconhecimento de brinquedos por foto

## Escopo

O fluxo analisa uma foto com um único brinquedo e sugere:

- um nome curto e genérico;
- uma das categorias oficiais cadastradas no aplicativo;
- confiança, explicação curta e até duas categorias alternativas.

A sugestão nunca é salva automaticamente. A pessoa precisa tocar em **Usar
sugestão** e ainda pode editar o nome ou trocar a categoria antes de salvar.
Quando a análise falha, o cadastro manual continua disponível.

## Arquitetura

1. O app seleciona e recorta a imagem, limita sua resolução e valida JPG, PNG
   ou WebP com no máximo 5 MiB.
2. O app chama a Cloud Function `recognizeToy`, protegida pelo Firebase App
   Check.
3. A função valida novamente a imagem e as categorias recebidas.
4. A função envia a foto ao modelo visual com uma saída JSON estrita.
5. O servidor só aceita categorias que já existam na taxonomia enviada pelo
   app e devolve a sugestão para confirmação humana.

A função não grava a foto em banco ou Storage. A requisição ao provedor de IA
usa `store: false`. Mesmo assim, a imagem deixa o dispositivo durante a análise;
essa finalidade deve constar da política de privacidade e das declarações da
loja antes de uma publicação.

## Regras de privacidade e qualidade

- Uma foto com pessoa visível é recusada e não deve ser descrita.
- Vários brinquedos sem um objeto principal claro são recusados.
- O modelo não deve inventar marca ou modelo.
- A categoria representa o estímulo principal da brincadeira.
- Toda resposta é validada no servidor e novamente no aplicativo.
- App Check reduz chamadas indevidas, mas não substitui limites de orçamento e
  monitoramento no Firebase e no provedor de IA.

## Preparação para teste

Pré-requisitos:

- projeto Firebase no plano compatível com Cloud Functions e chamadas externas;
- Firebase CLI autenticado no projeto correto;
- App Check configurado para o aplicativo iOS; configure também o Android
  quando esse alvo receber opções válidas no `firebase_options.dart`;
- uma chave da API da OpenAI com limite de gasto definido.

Instale e valide a função:

```bash
cd functions
npm ci
npm test
```

Cadastre a chave como segredo do Firebase, sem colocá-la no app ou no Git:

```bash
firebase functions:secrets:set OPENAI_API_KEY --project rodizio-de-brinquedos
```

Depois de revisar projeto, região, orçamento e App Check, publique somente a
função:

```bash
firebase deploy --only functions:recognizeToy --project rodizio-de-brinquedos
```

O modelo padrão está definido no servidor como `gpt-5-mini`. Ele pode ser
substituído pela variável de ambiente `OPENAI_VISION_MODEL`, sem alterar o app.

## Roteiro de aceite

1. Fotografar um brinquedo isolado e confirmar que nome e categoria aparecem
   como sugestão.
2. Descartar a sugestão e concluir o cadastro manualmente.
3. Aplicar a sugestão, editar o nome e trocar a categoria antes de salvar.
4. Testar foto sem brinquedo, com vários brinquedos e com uma pessoa visível.
5. Testar modo avião, tempo limite e App Check inválido.
6. Confirmar o layout no iPhone e no iPad.
7. Verificar nos logs que a função não registra Base64, foto ou texto pessoal.

## Fora do MVP

- reconhecer vários brinquedos em lote;
- identificar marca, modelo, faixa etária ou preço;
- salvar automaticamente;
- treinar um modelo próprio;
- armazenar fotos no servidor para reprocessamento.
