// ============================================================
// ORGANIZADOR DE MESA PREMIUM
// Design Escandinavo Moderno - Impressão 3D
// Sem suportes - Base plana - PLA optimizado
// ============================================================

// --- PARÂMETROS GLOBAIS ---
total_length    = 260;
total_width     = 105;
base_height     = 18;
wall            = 2.4;
floor_t         = 2.0;
corner_r        = 8;
$fn             = 64;

// --- PORTA-CONTROLE ---
rc_ext_l        = 85;
rc_ext_w        = 75;
rc_front_h      = 70;
rc_rear_h       = 95;
rc_tilt         = 13;   // graus de inclinação para trás

// --- BANDEJA PRINCIPAL ---
tray_depth      = 12;
tray_inner_r    = (total_width - 2*wall) / 2;

// --- SUPORTE CELULAR ---
phone_w         = 15;
phone_d         = 8;
phone_tilt      = 15;

// --- PORTA-MOEDAS ---
coin_dia        = 55;
coin_depth      = 4;

// --- TEXTURA ---
rib_w           = 3;
rib_gap         = 3;
rib_depth       = 1;
rib_h_rc        = rc_front_h;

// ============================================================
// UTILITÁRIOS
// ============================================================

module rounded_box(lx, ly, lz, r) {
    hull() {
        for (dx = [-lx/2+r, lx/2-r])
        for (dy = [-ly/2+r, ly/2-r])
            translate([dx, dy, 0])
                cylinder(r=r, h=lz);
    }
}

module capsule_2d(lx, ly) {
    r = ly / 2;
    hull() {
        translate([-lx/2 + r, 0]) circle(r=r);
        translate([ lx/2 - r, 0]) circle(r=r);
    }
}

// Cápsula 3D extrudada
module capsule_box(lx, ly, lz, r_top=4) {
    hull() {
        translate([0, 0, r_top])
            minkowski() {
                linear_extrude(lz - r_top)
                    capsule_2d(lx - 2*r_top, ly - 2*r_top);
                sphere(r=r_top);
            }
        linear_extrude(0.01)
            capsule_2d(lx, ly);
    }
}

// ============================================================
// MÓDULO: BASE / BANDEJA PRINCIPAL
// ============================================================
module capsule_base() {
    // posição: origin = canto traseiro-esquerdo do produto
    // produto vai de x=0..260, y=0..105, z=0..base_height

    cx = total_length / 2;
    cy = total_width / 2;

    difference() {
        // corpo externo
        translate([cx, cy, 0])
            rounded_box(total_length, total_width, base_height, corner_r);

        // escavação interna da bandeja (deixa parede lateral e fundo)
        translate([cx, cy, floor_t])
            rounded_box(
                total_length - 2*wall,
                total_width  - 2*wall,
                base_height,
                corner_r - wall
            );

        // slot suporte celular (centro da bandeja, parede frontal)
        phone_stand_cut();

        // porta-moedas (extremidade direita)
        coin_cut();
    }
}

// ============================================================
// MÓDULO: PORTA-CONTROLE INCLINADO
// ============================================================
module angled_remote_holder() {
    // Posiciona no canto esquerdo da bandeja
    // Centro em x=rc_ext_l/2 + wall, y=total_width/2
    cx = rc_ext_l/2 + wall;
    cy = total_width / 2;
    bz = base_height;  // sobe do topo da base

    translate([cx, cy, bz]) {
        difference() {
            // Corpo externo inclinado — hull entre perfil frontal (baixo) e traseiro (alto)
            _rc_body_solid();

            // Escavação interna
            translate([0, 0, floor_t])
                _rc_body_inner();

            // Abertura no topo
            translate([0, 0, rc_front_h - 0.01])
                _rc_top_opening();
        }

        // Nervuras decorativas nas paredes externas
        decorative_ribs_rc(cx, cy);
    }
}

module _rc_body_solid() {
    // Cápsula oval inclinada para trás
    // inclinação: ângulo rc_tilt graus no eixo Y (topo vai para trás)
    a = rc_tilt;
    dh = rc_rear_h - rc_front_h; // diferença de altura f→t

    hull() {
        // Anel inferior (elipse via scale)
        scale([1, rc_ext_w/rc_ext_l, 1])
            cylinder(d=rc_ext_l, h=1);

        // Anel superior traseiro inclinado
        translate([0, -sin(a)*(rc_front_h), rc_front_h])
            scale([1, rc_ext_w/rc_ext_l, 1])
                cylinder(d=rc_ext_l, h=1);
    }
}

module _rc_body_inner() {
    a = rc_tilt;
    inner_l = rc_ext_l - 2*wall;
    inner_w = rc_ext_w - 2*wall;

    hull() {
        scale([1, inner_w/inner_l, 1])
            cylinder(d=inner_l, h=1);
        translate([0, -sin(a)*(rc_front_h - floor_t), rc_front_h - floor_t])
            scale([1, inner_w/inner_l, 1])
                cylinder(d=inner_l, h=1);
    }
}

module _rc_top_opening() {
    // Abertura elíptica no topo com borda arredondada (chanfro 1mm)
    inner_l = rc_ext_l - 2*wall - 2;
    inner_w = rc_ext_w - 2*wall - 2;
    scale([1, inner_w/inner_l, 1])
        cylinder(d=inner_l, h=50);
}

// ============================================================
// MÓDULO: SUPORTE DE CELULAR (corte na base)
// ============================================================
module phone_stand_cut() {
    // Slot na parede frontal da bandeja, no centro x
    cx = total_length / 2;
    cy = wall / 2;

    translate([cx, cy, floor_t + 2])
        rotate([-phone_tilt, 0, 0])
            // slot: largura 15mm, profundidade 8mm, altura suficiente
            translate([-phone_w/2, -0.5, 0])
                cube([phone_w, phone_d + 1, base_height]);
}

module phone_stand() {
    // Módulo visual do slot — o corte é feito em capsule_base
    // Aqui apenas documentamos; o cut está em phone_stand_cut()
}

// ============================================================
// MÓDULO: PORTA-MOEDAS (corte na base)
// ============================================================
module coin_cut() {
    // Rebaixo circular na extremidade direita da bandeja
    cx = total_length - coin_dia/2 - wall - 4;
    cy = total_width / 2;

    translate([cx, cy, floor_t])
        cylinder(d=coin_dia, h=coin_depth + 0.1);
}

module coin_tray() {
    // Documentação — corte já realizado em capsule_base()
}

// ============================================================
// MÓDULO: NERVURAS DECORATIVAS (porta-controle)
// ============================================================
module decorative_ribs_rc(base_cx, base_cy) {
    // Nervuras verticais ao redor da cápsula oval do porta-controle
    // Aplicadas como sólidos finos na superfície externa

    n_ribs = floor(rc_ext_l / (rib_w + rib_gap));
    start_x = -(n_ribs * (rib_w + rib_gap)) / 2 + rib_w/2;

    for (i = [0 : n_ribs - 1]) {
        x = start_x + i * (rib_w + rib_gap);
        // Verifica se o ponto está dentro da elipse
        rx = rc_ext_l / 2;
        ry = rc_ext_w / 2;
        // normaliza para elipse
        if ((x*x)/(rx*rx) < 0.92) {
            // Posição y na superfície da elipse (frente)
            y_surf = -ry * sqrt(max(0, 1 - (x*x)/(rx*rx)));
            translate([x, y_surf - rib_depth + 0.2, 0])
                cube([rib_w, rib_depth, rib_h_rc], center=false);
        }
    }

    // Nervuras na parte de trás também
    for (i = [0 : n_ribs - 1]) {
        x = start_x + i * (rib_w + rib_gap);
        rx = rc_ext_l / 2;
        ry = rc_ext_w / 2;
        if ((x*x)/(rx*rx) < 0.92) {
            y_surf = ry * sqrt(max(0, 1 - (x*x)/(rx*rx)));
            translate([x, y_surf - 0.2, 0])
                cube([rib_w, rib_depth, rib_h_rc], center=false);
        }
    }
}

// ============================================================
// MÓDULO: NERVURAS LATERAIS DA BANDEJA
// ============================================================
module decorative_ribs_tray() {
    // Nervuras na parede frontal (y=0) da bandeja
    start_x_ribs = rc_ext_l + wall * 2 + rib_gap;
    end_x_ribs   = total_length - coin_dia - wall - 4;
    n = floor((end_x_ribs - start_x_ribs) / (rib_w + rib_gap));

    for (i = [0 : n - 1]) {
        x = start_x_ribs + i * (rib_w + rib_gap);
        // Parede frontal externa
        translate([x, 0, 0])
            cube([rib_w, rib_depth, base_height]);
        // Parede traseira externa
        translate([x, total_width - rib_depth, 0])
            cube([rib_w, rib_depth, base_height]);
    }
}

// ============================================================
// MÓDULO PRINCIPAL
// ============================================================
module main() {
    // --- Base + bandeja ---
    color("WhiteSmoke")
        capsule_base();

    // --- Porta-controle inclinado ---
    color("WhiteSmoke")
        angled_remote_holder();

    // --- Nervuras laterais da bandeja ---
    color("Silver")
        decorative_ribs_tray();
}

main();
