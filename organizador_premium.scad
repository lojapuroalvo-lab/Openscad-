// =====================================================================
//  ORGANIZADOR DE MESA PREMIUM – MINIMALISTA
//  Otimizado para impressão 3D FDM – sem suportes
// =====================================================================
//
//  AJUSTES RÁPIDOS:
//    total_length  : comprimento total → reduzir para 240 para caber
//                    em mesa de 250 mm (imprima na diagonal)
//    enable_ribs   : true / false → ativa ou desativa textura canelada
//    phone_slot_depth : aumentar se o celular for muito grosso
//    tray_floor_z  : espessura do fundo; nunca deixar menor que coin_depth + 2
//
// =====================================================================

$fn = 64;

// ════════════════════════════════════════════
//   PARÂMETROS – edite aqui
// ════════════════════════════════════════════

// Geral
total_length         = 270;   // comprimento total (mm)
total_width          = 105;   // largura total (mm)
tray_height          = 18;    // altura externa da bandeja
wall                 = 2.4;   // espessura das paredes
corner_radius        = 18;    // raio externo dos cantos
inner_corner_radius  = 13;    // raio interno da bandeja
tray_floor_z         = 6;     // espessura do fundo (≥ coin_depth + 2)

// Porta-controle / porta-canetas (lado esquerdo)
holder_length        = 82;    // comprimento externo
holder_width         = 78;    // largura externa
holder_front_height  = 70;    // altura frontal
holder_back_height   = 95;    // altura traseira → cria inclinação ~15°
holder_corner_r      = 12;    // raio dos cantos do porta-controle

// Suporte frontal para celular
phone_slot_length    = 90;    // abertura útil para o celular (largura)
phone_slot_depth     = 11;    // profundidade do canal (frente→trás)
phone_slot_height    = 14;    // altura do encosto traseiro
phone_slot_width     = 14;    // largura do canal (≈ espessura do celular)

// Rebaixo circular – moedas / anéis (lado direito)
coin_diameter        = 58;    // diâmetro externo do rebaixo
coin_inner_diameter  = 50;    // diâmetro interno útil
coin_depth           = 4;     // profundidade (não exceder tray_floor_z − 2)

// Textura canelada
enable_ribs          = true;  // false = sem textura
rib_width            = 1.2;
rib_spacing          = 3.0;
rib_depth            = 0.8;

// ════════════════════════════════════════════
//   1. rounded_box
// ════════════════════════════════════════════
module rounded_box(length, width, height, radius) {
    hull() {
        translate([radius,        radius,       0]) cylinder(r=radius, h=height);
        translate([length-radius, radius,       0]) cylinder(r=radius, h=height);
        translate([radius,        width-radius, 0]) cylinder(r=radius, h=height);
        translate([length-radius, width-radius, 0]) cylinder(r=radius, h=height);
    }
}

// ════════════════════════════════════════════
//   2. capsule_2d
// ════════════════════════════════════════════
module capsule_2d(length, width) {
    r = width / 2;
    hull() {
        translate([r,        r]) circle(r=r);
        translate([length-r, r]) circle(r=r);
    }
}

// ════════════════════════════════════════════
//   3. capsule_prism
// ════════════════════════════════════════════
module capsule_prism(length, width, height) {
    linear_extrude(height=height) capsule_2d(length, width);
}

// ════════════════════════════════════════════
//   4. main_tray
// ════════════════════════════════════════════
module main_tray() {
    difference() {
        rounded_box(total_length, total_width, tray_height, corner_radius);
        tray_inner_cutout();
        coin_recess();
    }
}

// ════════════════════════════════════════════
//   5. tray_inner_cutout
// ════════════════════════════════════════════
module tray_inner_cutout() {
    translate([wall, wall, tray_floor_z])
        rounded_box(
            total_length - 2*wall,
            total_width  - 2*wall,
            tray_height,
            inner_corner_radius
        );
}

// ════════════════════════════════════════════
//   7. remote_holder_inner_cutout
//   (declarado antes de angled_remote_holder)
// ════════════════════════════════════════════
module remote_holder_inner_cutout() {
    hl  = holder_length;
    hw  = holder_width;
    hfh = holder_front_height;
    hbh = holder_back_height;
    cr  = holder_corner_r;
    icr = cr - wall;           // raio interno dos cantos

    // A cavidade segue a mesma forma inclinada do corpo externo
    // mas ligeiramente menor (espessura = wall) e mais alta
    // (hfh+2, hbh+2) para garantir abertura no topo sem tampa
    hull() {
        translate([cr,    cr,    wall  ]) cylinder(r=icr, h=1);
        translate([hl-cr, cr,    wall  ]) cylinder(r=icr, h=1);
        translate([cr,    hw-cr, wall  ]) cylinder(r=icr, h=1);
        translate([hl-cr, hw-cr, wall  ]) cylinder(r=icr, h=1);
        translate([cr,    cr,    hfh+2 ]) cylinder(r=icr, h=1);
        translate([hl-cr, cr,    hfh+2 ]) cylinder(r=icr, h=1);
        translate([cr,    hw-cr, hbh+2 ]) cylinder(r=icr, h=1);
        translate([hl-cr, hw-cr, hbh+2 ]) cylinder(r=icr, h=1);
    }
}

// ════════════════════════════════════════════
//   6. angled_remote_holder
// ════════════════════════════════════════════
module angled_remote_holder() {
    hl  = holder_length;
    hw  = holder_width;
    hfh = holder_front_height;
    hbh = holder_back_height;
    cr  = holder_corner_r;

    // Centraliza o porta-controle na largura da bandeja
    y0 = (total_width - hw) / 2;

    translate([0, y0, 0])
    difference() {
        // ── Corpo externo inclinado ──────────────────────────
        // 8 cilindros nos cantos: 4 inferiores + 4 superiores
        // Frente (y~cr) termina em hfh; trás (y~hw-cr) termina em hbh
        hull() {
            translate([cr,    cr,    0  ]) cylinder(r=cr, h=1);
            translate([hl-cr, cr,    0  ]) cylinder(r=cr, h=1);
            translate([cr,    hw-cr, 0  ]) cylinder(r=cr, h=1);
            translate([hl-cr, hw-cr, 0  ]) cylinder(r=cr, h=1);
            translate([cr,    cr,    hfh]) cylinder(r=cr, h=1);
            translate([hl-cr, cr,    hfh]) cylinder(r=cr, h=1);
            translate([cr,    hw-cr, hbh]) cylinder(r=cr, h=1);
            translate([hl-cr, hw-cr, hbh]) cylinder(r=cr, h=1);
        }
        // ── Cavidade interna inclinada (boca aberta no topo) ──
        remote_holder_inner_cutout();
    }
}

// ════════════════════════════════════════════
//   8. vertical_ribs_on_front
// ════════════════════════════════════════════
module vertical_ribs_on_front() {
    if (enable_ribs) {
        // Nervuras na face frontal da bandeja (y = 0, exterior)
        // Começa após o porta-controle, termina antes da curva final
        x_start = holder_length + rib_spacing * 2;
        x_end   = total_length - corner_radius * 1.3;

        for (x = [x_start : rib_spacing : x_end])
            translate([x, -rib_depth, 0])
                cube([rib_width, rib_depth, tray_height]);
    }
}

// ════════════════════════════════════════════
//   9. vertical_ribs_on_holder
// ════════════════════════════════════════════
module vertical_ribs_on_holder() {
    if (enable_ribs) {
        hl  = holder_length;
        hw  = holder_width;
        hfh = holder_front_height;
        hbh = holder_back_height;
        cr  = holder_corner_r;
        y0  = (total_width - hw) / 2;

        // ── Face frontal do porta-controle (y = y0) ───────────
        for (x = [cr + rib_spacing : rib_spacing : hl - cr - rib_width])
            translate([x, y0 - rib_depth, 0])
                cube([rib_width, rib_depth, hfh]);

        // ── Face traseira do porta-controle (y = y0 + hw) ─────
        for (x = [cr + rib_spacing : rib_spacing : hl - cr - rib_width])
            translate([x, y0 + hw, 0])
                cube([rib_width, rib_depth, hbh]);

        // ── Face esquerda / lateral (x = 0, acima da bandeja) ─
        for (y = [y0 + cr + rib_spacing : rib_spacing : y0 + hw - cr - rib_width])
            translate([-rib_depth, y, tray_height])
                cube([rib_depth, rib_width, hbh - tray_height]);
    }
}

// ════════════════════════════════════════════
//   10. phone_slot
// ════════════════════════════════════════════
module phone_slot() {
    // Suporte para celular em landscape (horizontal)
    // O celular encosta na parede frontal interna da bandeja (y = wall)
    // e descansa sobre o encosto traseiro abaixo.
    //
    // Para celular maior: aumente phone_slot_length e phone_slot_depth

    x_ctr  = total_length / 2;
    x0     = x_ctr - phone_slot_length / 2;

    // Encosto traseiro – barra que segura o celular
    translate([x0, wall + phone_slot_depth, tray_floor_z])
        cube([phone_slot_length, wall, phone_slot_height]);

    // Batente lateral esquerdo
    translate([x0 - wall, wall, tray_floor_z])
        cube([wall, phone_slot_depth + wall * 2, phone_slot_height - 4]);

    // Batente lateral direito
    translate([x0 + phone_slot_length, wall, tray_floor_z])
        cube([wall, phone_slot_depth + wall * 2, phone_slot_height - 4]);
}

// ════════════════════════════════════════════
//   11. coin_recess
// ════════════════════════════════════════════
module coin_recess() {
    // Rebaixo circular no piso da bandeja (lado direito)
    // Usado para moedas, anéis, clipes, etc.
    // Corta de (tray_floor_z − coin_depth) até tray_floor_z
    // → deixa fundo com (tray_floor_z − coin_depth) mm de espessura

    x_pos = total_length - corner_radius - coin_diameter/2 - 6;
    y_pos = total_width / 2;
    z_cut = tray_floor_z - coin_depth;   // início do corte (z = 2 com config padrão)

    translate([x_pos, y_pos, z_cut])
        cylinder(r=coin_inner_diameter/2, h=coin_depth + 1);
}

// ════════════════════════════════════════════
//   12. bevel_details
// ════════════════════════════════════════════
module bevel_details() {
    // Os cantos arredondados do rounded_box já garantem
    // o acabamento premium. Módulo reservado para ajustes futuros
    // (ex: minibisél nas arestas superiores internas).
}

// ════════════════════════════════════════════
//   13. final_product
// ════════════════════════════════════════════
module final_product() {
    union() {
        main_tray();                  // bandeja base
        angled_remote_holder();       // porta-controle inclinado
        vertical_ribs_on_front();     // nervuras na face frontal da bandeja
        vertical_ribs_on_holder();    // nervuras no porta-controle
        phone_slot();                 // suporte para celular
    }
}

// ════════════════════════════════════════════
//   RENDERIZAR
// ════════════════════════════════════════════
color("wheat") final_product();
