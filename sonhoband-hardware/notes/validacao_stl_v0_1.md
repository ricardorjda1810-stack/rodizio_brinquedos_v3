# Validacao STL v0.1

Checklist para inspecao dos STLs antes da impressao 3D em TPU.

## Arquivos

- [ ] `exports/stl/sonhoband_case_v0_1_dev.stl` existe.
- [ ] `exports/stl/sonhoband_case_v0_2_mini.stl` existe.
- [ ] Os dois arquivos STL nao estao vazios.
- [ ] Os dois arquivos abrem corretamente no slicer.
- [ ] Os previews PNG correspondentes foram conferidos.

## Renderizacao e geometria

- [ ] OpenSCAD renderiza `sonhoband_case_v0_1_dev.scad` sem erro.
- [ ] OpenSCAD renderiza `sonhoband_case_v0_2_mini.scad` sem erro.
- [ ] Bounding box v0.1-dev confere com 60 x 38 x 15 mm.
- [ ] Bounding box v0.2-mini confere com 40 x 28 x 10 mm.
- [ ] Escala do slicer esta em milimetros.
- [ ] Modelo nao foi importado rotacionado ou espelhado por engano.
- [ ] Cavidade interna esta aberta para montagem.
- [ ] Area inferior fina do sensor esta visivel e centralizada.
- [ ] Fendas laterais do elastico atravessam as hastes corretamente.
- [ ] Nao ha geometria solta, faces quebradas ou regioes claramente impossiveis de imprimir.

## Impressao em TPU

- [ ] Orientacao de impressao escolhida reduz suporte dentro da cavidade.
- [ ] Suportes, se usados, nao bloqueiam fendas nem area fina do sensor.
- [ ] Altura de camada adequada para preservar fendas e bordas arredondadas.
- [ ] Perimetros configurados para manter paredes resistentes.
- [ ] Infill escolhido considerando flexibilidade e resistencia.
- [ ] Retraction/velocidade ajustadas para TPU.
- [ ] Primeiro prototipo sera identificado como v0.1-dev ou v0.2-mini.

## Conferencia de projeto

- [ ] HC-05 permanece fora do projeto.
- [ ] v0.1-dev usa bateria recomendada LiPo 250 mAh.
- [ ] v0.2-mini considera bateria LiPo 100 a 150 mAh.
- [ ] v0.1-dev sera usado apenas para teste eletronico e montagem.
- [ ] v0.2-mini segue como alvo real de conforto para bebe.

## Apos impressao

- [ ] Medir comprimento, largura e altura com paquimetro.
- [ ] Conferir passagem do elastico.
- [ ] Conferir encaixe aproximado dos componentes.
- [ ] Conferir contato da area fina do sensor.
- [ ] Registrar fotos do prototipo em `exports/images/` ou em uma nota de teste.
- [ ] Anotar ajustes necessarios para a proxima revisao.

