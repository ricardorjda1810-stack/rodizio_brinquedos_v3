# Medidas v0.1

Documento inicial de referencia para as caixas wearable infantis SonhoBand.

## Decisao eletronica

- O modulo HC-05 foi removido do desenho porque o ESP32 ja possui Bluetooth/BLE integrado.
- A variante dev usa ESP32 DevKit para facilitar testes eletronicos.
- A variante mini deve migrar para placa compacta, como ESP32-C3 mini, XIAO ESP32C3 ou nRF52840 pequeno.

## Variante v0.1 dev

Arquivo OpenSCAD: `openscad/sonhoband_case_v0_1_dev.scad`

Uso previsto:

- teste eletronico inicial;
- montagem simples;
- espaco interno suficiente para placa, sensores, bateria e fios;
- nao e o alvo final de conforto para bebe.

Componentes previstos:

- ESP32 DevKit;
- MPU6050;
- TMP117;
- bateria LiPo 250 mAh;
- fios internos;
- sem HC-05.

Medidas:

- Dimensoes externas iniciais: 60 mm x 38 mm x 15 mm
- Bounding box do STL validado: 60 mm x 38 mm x 15 mm
- Cavidade interna aproximada: 54 mm x 30 mm x 10 mm
- Parede geral: 2 mm
- Area fina do sensor termico: 10 mm de diametro
- Espessura da area fina do sensor: 0,8 mm
- Fenda para elastico: 12 mm de largura
- Bateria recomendada: LiPo 250 mAh
- Material inicial sugerido: TPU

Observacao: a variante dev pode ficar grande para uso confortavel em bebe. Ela deve ser usada principalmente para validar a eletronica e o arranjo interno.

## Variante v0.2 mini

Arquivo OpenSCAD: `openscad/sonhoband_case_v0_2_mini.scad`

Uso previsto:

- alvo real de conforto para bebe;
- wearable menor e mais leve;
- base para futura versao em silicone macio.

Componentes previstos:

- ESP32-C3 mini, XIAO ESP32C3 ou nRF52840 pequeno;
- sensor termico TMP117 ou equivalente;
- sensor de movimento compacto;
- bateria LiPo 100 a 150 mAh;
- fios curtos ou placa integrada.

Medidas:

- Dimensoes externas iniciais: 40 mm x 28 mm x 10 mm
- Bounding box do STL validado: 40 mm x 28 mm x 10 mm
- Cavidade interna aproximada: 34 mm x 22 mm x 6 mm
- Parede geral: 2 mm
- Area fina do sensor termico: 10 mm de diametro
- Espessura da area fina do sensor: 0,8 mm
- Fenda para elastico: 10 mm de largura
- Bateria prevista: LiPo 100 a 150 mAh
- Material inicial sugerido: TPU
- Material futuro: silicone macio de cura por platina

## Observacoes gerais

- As medidas sao iniciais e devem ser validadas com prototipos fisicos.
- O conforto infantil deve orientar os proximos ajustes de raio, espessura e pressao da cinta.
- A area fina do sensor deve manter contato consistente com a pele sem gerar marca, dor ou incomodo.
- A versao mini e o desenho mais importante para conforto real; a dev existe para acelerar a validacao eletronica.
