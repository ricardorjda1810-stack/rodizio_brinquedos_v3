/*
  SonhoBand case v0.1 dev
  Variante maior para prototipo eletronico inicial.

  Objetivo:
  - Acomodar ESP32 DevKit, MPU6050, TMP117, LiPo 250 mAh e fios.
  - Priorizar montagem simples e espaco interno.
  - Nao incluir HC-05, pois o ESP32 ja possui Bluetooth/BLE.

  Unidades: milimetros.
  Orientacao:
  - X = comprimento
  - Y = largura
  - Z = altura
*/

$fn = 64;

// -----------------------------
// Parametros principais
// -----------------------------

external_length = 60;
external_width = 38;
external_height = 15;

cavity_length = 54;
cavity_width = 30;
cavity_height = 10;

wall = 2;
corner_radius = 7;

// A cavidade abre pela parte superior. O fundo fica mais espesso nesta
// variante para respeitar a altura util aproximada de 10 mm.
cavity_floor_thickness = external_height - cavity_height;
cavity_corner_radius = max(corner_radius - wall, 1);

// Area inferior fina para contato do sensor termico.
sensor_diameter = 10;
sensor_floor_thickness = 0.8;

// Hastes laterais integradas ao envelope externo.
lug_length = 12;
lug_width = cavity_width + 2 * wall;
lug_projection = 6;
lug_corner_radius = 5;

// Fendas para elastico de 12 mm.
elastic_slot_width = 12;
elastic_slot_height = 3.5;
elastic_slot_z = external_height / 2;

// Referencias aproximadas dos componentes previstos.
// Estes valores sao apenas guias de projeto, nao sao subtraidos do modelo.
esp32_devkit_size = [52, 28, 6];
mpu6050_size = [20, 15, 3];
tmp117_size = [10, 10, 2];
lipo_250mah_size = [35, 20, 5];

// -----------------------------
// Modelo final
// -----------------------------

sonhoband_case_dev();

// Para visualizar referencias internas no preview, descomente:
// component_reference_layout();

// -----------------------------
// Modulos principais
// -----------------------------

module sonhoband_case_dev() {
    difference() {
        union() {
            central_body();
            side_lugs();
        }

        internal_cavity();
        sensor_thin_area();
        elastic_slots();
    }
}

module central_body() {
    rounded_box_xy(
        [external_length - 2 * lug_projection, external_width, external_height],
        corner_radius
    );
}

module side_lugs() {
    for (side = [-1, 1]) {
        translate([
            side * (external_length / 2 - lug_length / 2),
            0,
            0
        ]) {
            rounded_box_xy(
                [lug_length, lug_width, external_height],
                lug_corner_radius
            );
        }
    }
}

module internal_cavity() {
    // Cavidade aberta pela parte superior, aproximando 54 x 30 x 10 mm.
    translate([0, 0, cavity_floor_thickness]) {
        rounded_box_xy(
            [cavity_length, cavity_width, cavity_height + 1],
            cavity_corner_radius
        );
    }
}

module sensor_thin_area() {
    // Rebaixo circular interno que deixa apenas 0,8 mm de material no fundo.
    translate([0, 0, sensor_floor_thickness]) {
        cylinder(
            h = external_height + 2,
            d = sensor_diameter,
            center = false
        );
    }
}

module elastic_slots() {
    for (side = [-1, 1]) {
        translate([
            side * (external_length / 2 - lug_length / 2),
            0,
            elastic_slot_z
        ]) {
            elastic_slot_cut(lug_length + 4);
        }
    }
}

module component_reference_layout() {
    // Guias visuais opcionais para verificar a ideia de arranjo interno.
    color([0.1, 0.3, 1.0, 0.25])
        translate([0, 0, cavity_floor_thickness + esp32_devkit_size[2] / 2])
            cube(esp32_devkit_size, center = true);

    color([1.0, 0.6, 0.1, 0.25])
        translate([-14, -7, cavity_floor_thickness + 7])
            cube(mpu6050_size, center = true);

    color([0.0, 0.8, 0.5, 0.25])
        translate([12, -8, cavity_floor_thickness + 6])
            cube(tmp117_size, center = true);

    color([0.9, 0.1, 0.1, 0.25])
        translate([6, 7, cavity_floor_thickness + 7])
            cube(lipo_250mah_size, center = true);
}

// -----------------------------
// Modulos utilitarios
// -----------------------------

module rounded_box_xy(size, radius) {
    // Caixa com cantos arredondados no plano XY e laterais verticais.
    safe_radius = min(radius, min(size[0], size[1]) / 2);

    hull() {
        for (x = [-size[0] / 2 + safe_radius, size[0] / 2 - safe_radius]) {
            for (y = [-size[1] / 2 + safe_radius, size[1] / 2 - safe_radius]) {
                translate([x, y, 0]) {
                    cylinder(
                        h = size[2],
                        r = safe_radius,
                        center = false
                    );
                }
            }
        }
    }
}

module elastic_slot_cut(length) {
    // Fenda em formato capsula, atravessando cada haste lateral no eixo X.
    slot_radius = elastic_slot_height / 2;

    hull() {
        for (y = [
            -elastic_slot_width / 2 + slot_radius,
            elastic_slot_width / 2 - slot_radius
        ]) {
            translate([0, y, 0]) {
                rotate([0, 90, 0]) {
                    cylinder(
                        h = length,
                        r = slot_radius,
                        center = true
                    );
                }
            }
        }
    }
}
