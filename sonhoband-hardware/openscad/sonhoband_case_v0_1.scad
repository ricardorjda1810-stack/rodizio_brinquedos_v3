/*
  SonhoBand case v0.1
  Modelo parametrico inicial em OpenSCAD.

  Unidades: milimetros.
  Orientacao:
  - X = comprimento do corpo
  - Y = largura do corpo
  - Z = altura do corpo
*/

$fn = 64;

// -----------------------------
// Parametros principais
// -----------------------------

body_length = 35;
body_width = 25;
body_height = 9;

wall = 2;
corner_radius = 5;

// Area inferior fina para contato do sensor termico.
sensor_diameter = 10;
sensor_floor_thickness = 0.8;

// Hastes laterais e passagem do elastico.
lug_length = 8;
lug_width = 18;
lug_overlap = 2;
lug_corner_radius = 4;

elastic_slot_width = 10;
elastic_slot_height = 3;
elastic_slot_z = body_height / 2;

// Folgas e raios internos.
cavity_clearance = 0.3;
cavity_corner_radius = max(corner_radius - wall, 1);

// -----------------------------
// Modelo final
// -----------------------------

sonhoband_case();

// -----------------------------
// Modulos principais
// -----------------------------

module sonhoband_case() {
    difference() {
        union() {
            main_body();
            side_lugs();
        }

        internal_cavity();
        sensor_thin_area();
        elastic_slots();
    }
}

module main_body() {
    rounded_box_xy(
        [body_length, body_width, body_height],
        corner_radius
    );
}

module side_lugs() {
    for (side = [-1, 1]) {
        translate([
            side * (body_length / 2 + lug_length / 2 - lug_overlap),
            0,
            0
        ]) {
            rounded_box_xy(
                [lug_length, lug_width, body_height],
                lug_corner_radius
            );
        }
    }
}

module internal_cavity() {
    // Cavidade aberta pela parte superior, deixando parede e fundo geral.
    translate([0, 0, wall]) {
        rounded_box_xy(
            [
                body_length - 2 * wall - cavity_clearance,
                body_width - 2 * wall - cavity_clearance,
                body_height + 1
            ],
            cavity_corner_radius
        );
    }
}

module sensor_thin_area() {
    // Rebaixo interno circular que deixa apenas 0,8 mm de material no fundo.
    translate([0, 0, sensor_floor_thickness]) {
        cylinder(
            h = body_height + 2,
            d = sensor_diameter,
            center = false
        );
    }
}

module elastic_slots() {
    for (side = [-1, 1]) {
        translate([
            side * (body_length / 2 + lug_length / 2 - lug_overlap),
            0,
            elastic_slot_z
        ]) {
            elastic_slot_cut(lug_length + 3);
        }
    }
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

