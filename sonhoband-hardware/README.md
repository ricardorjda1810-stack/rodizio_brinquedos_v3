# SonhoBand Hardware

Estrutura inicial do projeto de hardware do SonhoBand, uma caixa wearable infantil conectada ao ecossistema SonhoDoc/SonhoBand.

## Objetivo

Organizar o desenvolvimento mecanico inicial de uma caixa pequena, confortavel e ajustavel para uso infantil, com foco em prototipagem rapida, testes eletronicos, testes de conforto e evolucao do desenho ate uma futura versao em silicone macio.

## Conceito do produto

O SonhoBand e pensado como uma caixa wearable de baixo perfil para acomodar um pequeno conjunto eletronico e manter uma area inferior mais fina em contato com a pele, permitindo o posicionamento de um sensor termico. A fixacao inicial considera elastico ou cinta macia passando por hastes laterais.

Premissas do projeto:

- corpo arredondado para reduzir pontos de incomodo;
- fendas laterais para passagem de elastico;
- cavidade interna para componentes;
- area inferior fina dedicada ao contato do sensor termico;
- fabricacao inicial por impressao 3D flexivel em TPU;
- evolucao futura para silicone macio de cura por platina.

## Variantes OpenSCAD

### v0.1 dev

Arquivo: `openscad/sonhoband_case_v0_1_dev.scad`

Variante maior para prototipo eletronico inicial. Ela foi pensada para acomodar:

- ESP32 DevKit;
- MPU6050;
- TMP117;
- bateria LiPo 250 mAh;
- fios e folgas de montagem.

O modulo HC-05 foi removido do desenho porque o ESP32 ja possui Bluetooth/BLE integrado. A bateria recomendada para esta variante dev e LiPo 250 mAh.

Esta variante e apenas para teste eletronico e validacao de montagem. Ela pode ficar grande para uso confortavel em bebe.

### v0.2 mini

Arquivo: `openscad/sonhoband_case_v0_2_mini.scad`

Variante futura menor, voltada para o wearable real. Ela considera placas compactas como ESP32-C3 mini, XIAO ESP32C3 ou nRF52840 pequeno, com bateria LiPo de 100 a 150 mAh.

Esta variante mini e o alvo real de conforto para bebe, depois que a arquitetura eletronica estiver validada na variante dev.

## Estado atual

Os dois modelos principais foram gerados em STL definitivo e validados no OpenSCAD sem erro de renderizacao:

- `exports/stl/sonhoband_case_v0_1_dev.stl`
- `exports/stl/sonhoband_case_v0_2_mini.stl`

Tambem foram geradas imagens de preview:

- `exports/images/sonhoband_case_v0_1_dev.png`
- `exports/images/sonhoband_case_v0_2_mini.png`

Validacoes registradas:

- v0.1-dev renderizado no OpenSCAD como objeto 3D simples;
- v0.2-mini renderizado no OpenSCAD como objeto 3D simples;
- bounding box v0.1-dev: 60 x 38 x 15 mm;
- bounding box v0.2-mini: 40 x 28 x 10 mm;
- os arquivos STL foram criados e nao estao vazios;
- o HC-05 permanece fora do projeto, pois o ESP32 ja possui Bluetooth/BLE.

## Fluxo de desenvolvimento

1. Modelar a caixa parametricamente em OpenSCAD.
2. Exportar o modelo para STL.
3. Imprimir os primeiros prototipos em TPU.
4. Testar montagem eletronica, conforto, estabilidade, pressao da cinta e contato do sensor.
5. Ajustar medidas no modelo OpenSCAD.
6. Repetir os testes ate validar a geometria.
7. Evoluir para molde e fabricacao em silicone macio de cura por platina.

## Aviso importante

Este projeto e um prototipo experimental de hardware. Ele nao e um produto medico, nao substitui avaliacao clinica e nao deve ser usado para diagnostico, tratamento ou monitoramento medico sem validacao tecnica, regulatoria e profissional adequada.
