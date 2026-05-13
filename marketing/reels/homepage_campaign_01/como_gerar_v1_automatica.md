# Como Gerar a V1 Automática do Reels

Este pacote monta automaticamente um vídeo MP4 vertical 9:16 usando os 8 assets visuais da campanha.

## 1. Coloque os assets na pasta correta

Pasta de entrada:

`marketing/reels/homepage_campaign_01/assets_input/`

Os arquivos obrigatórios devem ter exatamente estes nomes:

- `asset_01_muitos_brinquedos.png`
- `asset_02_crianca_sem_foco.png`
- `asset_03_pouco_engajamento.png`
- `asset_04_mae_organizando.png`
- `asset_05_ambiente_organizado.png`
- `asset_06_crianca_brincando_com_foco.png`
- `asset_07_mockup_app.png`
- `asset_08_tela_final_cta.png`

## 2. Áudios opcionais

Se quiser, coloque também:

- `narracao.mp3`
- `trilha.mp3`

Se esses arquivos não existirem, o vídeo será gerado sem áudio.

## 3. Instale o FFmpeg, se necessário

O script usa FFmpeg.

No macOS com Homebrew:

```bash
brew install ffmpeg
```

Para verificar:

```bash
ffmpeg -version
```

## 4. Rode o script

Na raiz do projeto, execute:

```bash
python3 marketing/reels/homepage_campaign_01/build_reels_v1.py
```

## 5. Encontre o MP4 final

O vídeo final será exportado em:

`marketing/reels/homepage_campaign_01/output/reels_rodizio_homepage_v1.mp4`

## 6. Acabamento opcional no CapCut

Depois de gerar a V1 automática, você pode importar o MP4 no CapCut apenas para acabamento:

- ajustar música;
- trocar fonte dos textos;
- inserir legenda animada;
- refinar cortes;
- adicionar tela final com link/bio;
- exportar a versão final.

## Observação

Se algum asset obrigatório estiver faltando, o script não gera o vídeo e mostra uma lista clara dos arquivos pendentes.
