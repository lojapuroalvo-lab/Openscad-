// ============================================================
//  ORGANIZADOR DE MESA MINIMALISTA - FDM 3D Print Ready
//  Para alterar medidas, edite os parâmetros abaixo.
//  Principais: total_length, total_width, tray_height,
//              cup_height, cup_od, cup_id, corner_r
// ============================================================

$fn = 56;

// --- Parâmetros Principais ---
total_length  = 220;   // comprimento total da base
total_width   = 85;    // largura total da base
tray_height   = 18;    // altura da base/bandeja
corner_r      = 12;    // raio dos cantos arredondados

// --- Copo porta-controle ---
cup_height    = 85;    // altura total do copo
cup_od        = 75;    // diâmetro externo
cup_id        = 60;    // diâmetro interno
cup_wall      = (cup_od - cup_id) / 2; // ~7.5 mm

// --- Bandeja ---
tray_inner_depth = 11; // profundidade útil da bandeja
tray_wall        = 2.4;

// --- Textura canelada ---
rib_count     = 24;    // número de caneluras no copo
rib_depth     = 0.8;   // profundidade de cada canelura
rib_width     = 1.2;   // largura do sulco
tray_rib_count = 18;   // caneluras na lateral da bandeja

// --- Suporte de celular ---
phone_slot_w  = 13;    // largura da canaleta
phone_slot_d  = 6.5;   // profundidade
phone_slot_h  = tray_height + 1;

// --- Área de moedas ---
coin_r        = 18;    // raio da área circular de moedas
coin_depth    = 2.5;   // rebaixo

// --- Divisória interna da bandeja ---
divider_t     = 1.8;   // espessura

// --- Posicionamento ---
cup_cx = cup_od / 2 + tray_wall;           // centro X do copo
tray_x_start = cup_od + tray_wall * 2;     // onde a bandeja começa em X
tray_length  = total_length - tray_x_start; // comprimento da bandeja

// ============================================================
//  MÓDULO: caixa com cantos arredondados (extrusão Minkowski)
// ============================================================
module rounded_box(length, width, height, radius) {
    r = min(radius, min(length, width) / 2 - 0.1);
    minkowski() {
        cube([length - r*2, width - r*2, height * 0.01], center = false);
        union() {
            cylinder(r = r, h = height - 1, $fn = 48);
        }
    }
}

// ============================================================
//  MÓDULO: textura canelada vertical (sulcos em torno de cil.)
// ============================================================
module ribbed_texture_cup(radius, height, count, depth, width) {
    angle_step = 360 / count;
    for (i = [0 : count - 1]) {
        rotate([0, 0, i * angle_step])
        translate([radius - depth / 2, 0, 0])
        scale([depth, width, 1])
        cylinder(r = 0.5, h = height, $fn = 8);
    }
}

module ribbed_texture_tray(length, height, count, depth, width) {
    step = length / count;
    for (i = [0 : count - 1]) {
        translate([i * step + step / 2, -depth / 2, 0])
        scale([width, depth, 1])
        cylinder(r = 0.5, h = height, $fn = 8);
    }
}

// ============================================================
//  MÓDULO: base/bandeja direita
// ============================================================
module tray_base() {
    // --- Bloco base completo com cantos arredondados ---
    translate([corner_r, corner_r, 0])
    minkowski() {
        cube([total_length - corner_r*2, total_width - corner_r*2, tray_height * 0.5]);
        cylinder(r = corner_r, h = tray_height * 0.5, $fn = 48);
    }

    // --- Parede traseira da bandeja (reforço) ---
    bx = tray_x_start;
    translate([bx, 0, 0])
    cube([tray_wall, total_width, tray_height + 4]);
}

// ============================================================
//  MÓDULO: interior escavado da bandeja
// ============================================================
module tray_interior() {
    bx = tray_x_start + tray_wall;
    inner_l = tray_length - tray_wall * 2 - 2;
    inner_w = total_width - tray_wall * 2 - 2;
    inner_h = tray_inner_depth;

    translate([bx + 1, tray_wall + 1, tray_height - inner_h + 0.01])
    hull() {
        r2 = 6;
        pts = [[r2, r2], [inner_l - r2, r2],
               [inner_l - r2, inner_w - r2], [r2, inner_w - r2]];
        for (p = pts)
            translate([p[0], p[1], 0])
            cylinder(r = r2, h = inner_h + 1, $fn = 32);
    }
}

// ============================================================
//  MÓDULO: divisória interna da bandeja
// ============================================================
module tray_divider() {
    bx   = tray_x_start + tray_wall + 1;
    div_x = bx + (tray_length - tray_wall * 2 - 2) * 0.45;
    div_h = tray_inner_depth - 1;
    div_w = total_width - tray_wall * 2 - 4;

    translate([div_x, tray_wall + 2, tray_height - tray_inner_depth + 0.5])
    hull() {
        cube([divider_t, div_w, div_h * 0.6]);
        translate([0, 4, div_h * 0.6])
        cube([divider_t, div_w - 8, 0.1]);
    }
}

// ============================================================
//  MÓDULO: área circular para moedas/anel
// ============================================================
module coin_area() {
    bx     = tray_x_start + tray_wall + 1;
    inner_w = total_width - tray_wall * 2 - 2;
    cx     = bx + (tray_length - tray_wall * 2 - 2) * 0.75;
    cy     = tray_wall + 1 + inner_w / 2;
    cz     = tray_height - coin_depth + 0.01;

    translate([cx, cy, cz])
    cylinder(r = coin_r, h = coin_depth + 1, $fn = 48);
}

// ============================================================
//  MÓDULO: copo porta-controle/canetas
// ============================================================
module remote_cup() {
    cx = cup_cx;
    cy = total_width / 2;

    difference() {
        // Corpo externo
        translate([cx, cy, 0])
        cylinder(d = cup_od, h = cup_height, $fn = 56);

        // Furo interno
        translate([cx, cy, tray_wall + 1])
        cylinder(d = cup_id, h = cup_height, $fn = 56);

        // Cortar base para encaixar na bandeja
        translate([0, 0, -0.1])
        cube([tray_x_start + 0.1, total_width, tray_height]);
    }
}

// ============================================================
//  MÓDULO: textura ripada no copo
// ============================================================
module cup_ribs() {
    cx = cup_cx;
    cy = total_width / 2;
    r  = cup_od / 2;

    translate([cx, cy, tray_height])
    difference() {
        cylinder(r = r + rib_depth * 0.5, h = cup_height - tray_height, $fn = 56);
        cylinder(r = r - rib_depth * 0.5, h = cup_height - tray_height + 1, $fn = 56);
        ribbed_texture_cup(r, cup_height - tray_height, rib_count, rib_depth * 6, rib_width * 2);
    }
}

// ============================================================
//  MÓDULO: textura ripada na lateral externa da bandeja
// ============================================================
module tray_ribs() {
    side_h = tray_height;
    bx     = tray_x_start;
    len    = tray_length;

    // Lateral frontal
    translate([bx, 0, 0])
    difference() {
        cube([len, tray_wall, side_h]);
        translate([0, tray_wall, 0])
        ribbed_texture_tray(len, side_h, tray_rib_count, rib_depth * 5, rib_width * 1.5);
    }

    // Lateral traseira
    translate([bx, total_width - tray_wall, 0])
    difference() {
        cube([len, tray_wall, side_h]);
        ribbed_texture_tray(len, side_h, tray_rib_count, rib_depth * 5, rib_width * 1.5);
    }
}

// ============================================================
//  MÓDULO: suporte frontal de celular
// ============================================================
module phone_slot() {
    slot_y = total_width / 2 - phone_slot_w / 2;
    slot_x = tray_x_start + (tray_length) * 0.3;

    // Corta a parede frontal da base para criar a canaleta
    translate([slot_x - phone_slot_w / 2, -0.1, tray_height - phone_slot_d])
    cube([phone_slot_w, tray_wall + 1, phone_slot_d + 1]);

    // Chanfro suave na entrada
    translate([slot_x - phone_slot_w / 2 - 1, -0.1, tray_height - phone_slot_d - 2])
    rotate([-45, 0, 0])
    cube([phone_slot_w + 2, 2, 3]);
}

// ============================================================
//  MÓDULO: produto final
// ============================================================
module final_product() {
    difference() {
        union() {
            // Base com bandeja
            tray_base();

            // Copo
            remote_cup();

            // Divisória
            tray_divider();
        }

        // Escavar interior da bandeja
        tray_interior();

        // Escavar área de moedas
        coin_area();

        // Slot do celular
        phone_slot();
    }

    // Textura ripada (subtractiva no copo)
    difference() {
        cup_ribs();
        // Garantir que não ultrapasse o interior do copo
        translate([cup_cx, total_width / 2, -0.1])
        cylinder(d = cup_id - 1, h = cup_height + 1, $fn = 56);
    }
}

// ============================================================
//  CHAMADA PRINCIPAL
// ============================================================
final_product();
