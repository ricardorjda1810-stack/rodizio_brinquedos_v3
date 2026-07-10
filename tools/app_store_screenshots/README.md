# Usina de Screenshots da App Store

Pipeline local para transformar prints reais do simulador em screenshots de marketing prontos para o App Store Connect.

Esta ferramenta fica fora do runtime Flutter. Ela usa apenas Python, Pillow e PyYAML para compor imagens com texto, fundo, frame e layout consistente.

## Estrutura

```text
tools/app_store_screenshots/
  config/
    pt_br.yaml
    en_us.yaml
  input/
    pt-BR/
      iphone/
      ipad/
    en-US/
      iphone/
      ipad/
  output/
    final/
  compose.py
  generate.py
  showcase.py
  requirements.txt
```

## Como capturar prints reais do simulador

Use o app rodando no simulador e capture a tela com:

```bash
xcrun simctl io booted screenshot tools/app_store_screenshots/input/pt-BR/iphone/home.png
```

Ou, se quiser especificar um simulador:

```bash
xcrun simctl io <UDID> screenshot tools/app_store_screenshots/input/en-US/ipad/home.png
```

Nomes esperados pela configuração atual:

```text
input/pt-BR/iphone/home.png
input/pt-BR/iphone/rodada.png
input/pt-BR/iphone/planejamento.png
input/pt-BR/iphone/brinquedos.png
input/pt-BR/iphone/caixas.png
input/pt-BR/iphone/paywall.png

input/pt-BR/ipad/home.png
input/pt-BR/ipad/rodada.png
input/pt-BR/ipad/planejamento.png
input/pt-BR/ipad/brinquedos.png
input/pt-BR/ipad/caixas.png
input/pt-BR/ipad/paywall.png

input/en-US/iphone/home.png
input/en-US/iphone/rodada.png
input/en-US/iphone/planejamento.png
input/en-US/iphone/brinquedos.png
input/en-US/iphone/caixas.png
input/en-US/iphone/paywall.png

input/en-US/ipad/home.png
input/en-US/ipad/rodada.png
input/en-US/ipad/planejamento.png
input/en-US/ipad/brinquedos.png
input/en-US/ipad/caixas.png
input/en-US/ipad/paywall.png
```

Os arquivos PNG/JPG dentro de `input/` são ignorados pelo Git para evitar commitar prints pesados por acidente.

O gerador ainda aceita a estrutura antiga `input/iphone/` e `input/ipad/` como fallback, mas o caminho principal é sempre `input/<locale>/<device>/`.

## Instalação

```bash
cd tools/app_store_screenshots
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Gerar screenshots finais

iPhone:

```bash
python generate.py --locale pt-BR --device iphone --size 1320x2868
python generate.py --locale en-US --device iphone --size 1320x2868
```

iPad 13":

```bash
python generate.py --locale pt-BR --device ipad --size 2064x2752
python generate.py --locale en-US --device ipad --size 2064x2752
```

## Onde ficam os arquivos finais

```text
output/final/pt-BR/iphone/
output/final/en-US/iphone/
output/final/pt-BR/ipad/
output/final/en-US/ipad/
```

O gerador também cria showcases para revisão:

```text
output/showcase_pt-BR_iphone.png
output/showcase_en-US_iphone.png
output/showcase_pt-BR_ipad.png
output/showcase_en-US_ipad.png
```

`output/` é ignorado pelo Git.

## Trocar textos

Edite:

```text
config/pt_br.yaml
config/en_us.yaml
```

Cada item em `scenes` define:

```yaml
- id: home
  source: home.png
  title: "Organize toys without the clutter"
  subtitle: "Keep the household play routine easy to see."
```

`source` deve apontar para um arquivo existente dentro de `input/<locale>/<device>/`.

## Alterar cores e layout

As cores ficam no bloco `brand` dos YAMLs:

```yaml
brand:
  background: "#FFF7ED"
  headline: "#263832"
  subtitle: "#6B5A48"
  accent: "#FF6B17"
```

Os ajustes por dispositivo ficam em `devices`:

```yaml
devices:
  iphone:
    frame_width_ratio: 0.70
    frame_top_ratio: 0.34
```

Para mudanças estruturais maiores, edite `compose.py`.

## Gerar um showcase manual

```bash
python showcase.py --locale en-US --device iphone
```

Também é possível passar arquivos específicos:

```bash
python showcase.py \
  --screenshots output/final/en-US/iphone/01-home.png output/final/en-US/iphone/02-rodada.png \
  --output output/showcase_custom.png
```

## Etapa com IA

O repositório de referência usa uma etapa opcional de IA/Gemini depois do scaffold determinístico. Esta primeira versão do Rodízio de Brinquedos não exige Gemini MCP nem qualquer ferramenta de IA.

Um fluxo futuro pode usar os PNGs gerados em `output/final/` ou scaffolds intermediários como base para polimento visual, desde que:

- o texto não seja alterado;
- a tela real do app não seja inventada;
- dimensões finais continuem compatíveis com App Store Connect;
- não haja promessa exagerada, médica, terapêutica ou educacional garantida.

## Checklist antes de enviar ao App Store Connect

- Conferir dimensões finais com `sips -g pixelWidth -g pixelHeight <arquivo.png>`.
- Garantir que os textos estão no idioma correto.
- Garantir que não aparece a palavra "Premium" como promessa principal.
- Usar telas reais do app, sem mock de regra de negócio.
- Conferir que paywall mostra assinatura, restauração, Termos e Política.
- Exportar os arquivos de `output/final/<locale>/<device>/`.
