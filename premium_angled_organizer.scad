// ╔══════════════════════════════════════════════════════════════╗
//  ORGANIZADOR DE MESA PREMIUM — Porta-Controle Inclinado
//  Design escandinavo moderno | FDM sem suportes | Base plana
//
//  COMO PERSONALIZAR:
//  → Altere os valores abaixo antes de renderizar (F6)
//  → total_length / total_width  : tamanho da base
//  → tilt_angle                  : inclinação do porta-controle
//  → cup_front_h / cup_back_h    : alturas frontal e traseira
//  → wall_t                      : espessura das paredes
// ╚══════════════════════════════════════════════════════════════╝

$fn = 64;

// ─────────────────────────────────────────────────────────────
//  PARÂMETROS GERAIS
// ─────────────────────────────────────────────────────────────
total_length = 260;
total_width  = 105;
base_h       = 18;
corner_r     = 13;
wall_t       = 2.4;
chamfer_s    = 1.0;      // chanfro suave das bordas superiores

// ─────────────────────────────────────────────────────────────
//  PORTA-CONTROLE INCLINADO
// ─────────────────────────────────────────────────────────────
tilt_angle   = 13;       // graus de inclinação para trás
cup_ext_l    = 85;       // comprimento externo (direção Y)
cup_ext_w    = 75;       // largura externa (direção X)
cup_front_h  = 70;       // altura da face frontal
cup_back_h   = 95;       // altura da face traseira
cup_corner_r = 18;       // raio dos cantos do copo (cápsula)

// posição do copo na base
cup_cx = cup_ext_w / 2 + wall_t;      // centro X
cup_cy = total_width / 2;              // centro Y (centralizado na largura)

// ─────────────────────────────────────────────────────────────
//  BANDEJA PRINCIPAL
// ─────────────────────────────────────────────────────────────
tray_x0      = cup_ext_w + wall_t * 3; // onde a bandeja começa
tray_len     = total_length - tray_x0 - wall_t;
tray_depth   = 12;                     // profundidade útil
tray_cr      = corner_r;              // raio dos cantos da bandeja

// ─────────────────────────────────────────────────────────────
//  SUPORTE DE CELULAR
// ─────────────────────────────────────────────────────────────
phone_w      = 15;
phone_d      = 8;
phone_angle  = 15;       // inclinação para trás em graus
phone_cx     = tray_x0 + tray_len * 0.35; // posição X (centro)

// ─────────────────────────────────────────────────────────────
//  PORTA-MOEDAS
// ─────────────────────────────────────────────────────────────
coin_d       = 55;
coin_depth   = 4;
coin_cx      = total_length - coin_d / 2 - wall_t - corner_r * 0.6;
coin_cy      = total_width / 2;

// ─────────────────────────────────────────────────────────────
//  TEXTURA CANELADA
// ─────────────────────────────────────────────────────────────
rib_w        = 3.0;      // largura da nervura
rib_gap      = 3.0;      // espaço entre nervuras
rib_depth    = 1.0;      // profundidade do sulco


// ╔══════════════════════════════════════════════════════════════╗
//  MÓDULO: perfil 2D em cápsula (hull de dois círculos)
// ╚══════════════════════════════════════════════════════════════╝
module capsule_profile_2d(len, wid, cr) {
    r = min(cr, wid / 2);
    hull() {
        translate([r,       r])       circle(r = r, $fn = 48);
        translate([len - r, r])       circle(r = r, $fn = 48);
        translate([r,       wid - r]) circle(r = r, $fn = 48);
        translate([len - r, wid - r]) circle(r = r, $fn = 48);
    }
}


// ╔══════════════════════════════════════════════════════════════╗
//  MÓDULO: capsule_base — base completa da peça
// ╚══════════════════════════════════════════════════════════════╝
module capsule_base() {
    difference() {
        // Corpo principal com cantos suavizados
        hull() {
            for (xi = [corner_r, total_length - corner_r])
            for (yi = [corner_r, total_width - corner_r])
                translate([xi, yi, 0])
                cylinder(r = corner_r, h = base_h, $fn = 48);
        }

        // Chanfro perimetral no topo (borda suave 1 mm)
        translate([0, 0, base_h - chamfer_s])
        hull() {
            for (xi = [corner_r, total_length - corner_r])
            for (yi = [corner_r, total_width - corner_r])
                translate([xi, yi, 0])
                cylinder(r1 = corner_r, r2 = corner_r + chamfer_s,
                         h = chamfer_s + 0.1, $fn = 48);
        }
    }

    // Filete decorativo perimetral (linha rebaixada na lateral)
    difference() {
        translate([wall_t, wall_t, base_h * 0.4])
        hull() {
            for (xi = [corner_r - wall_t, total_length - corner_r - wall_t])
            for (yi = [corner_r - wall_t, total_width - corner_r - wall_t])
                translate([xi, yi, 0])
                cylinder(r = corner_r - wall_t, h = 1.2, $fn = 48);
        }
        translate([wall_t * 2, wall_t * 2, base_h * 0.4 - 0.1])
        hull() {
            for (xi = [corner_r - wall_t * 2, total_length - corner_r - wall_t * 2])
            for (yi = [corner_r - wall_t * 2, total_width - corner_r - wall_t * 2])
                translate([xi, yi, 0])
                cylinder(r = corner_r - wall_t * 2, h = 1.4, $fn = 48);
        }
    }
}


// ╔══════════════════════════════════════════════════════════════╗
//  MÓDULO: bandeja cápsula escavada
// ╚══════════════════════════════════════════════════════════════╝
module tray_cavity() {
    ir    = tray_cr - wall_t;
    inner_len = tray_len - wall_t * 2;
    inner_wid = total_width - wall_t * 2;

    translate([tray_x0 + wall_t, wall_t, base_h - tray_depth])
    hull() {
        // canto esquerdo superior/inferior
        for (yi = [ir, inner_wid - ir])
            translate([ir, yi, 0])
            cylinder(r = ir, h = tray_depth + 1, $fn = 48);
        // extremidade direita totalmente arredondada (semicírculo)
        translate([inner_len - inner_wid / 2, inner_wid / 2, 0])
        cylinder(r = inner_wid / 2 - wall_t * 0.5, h = tray_depth + 1, $fn = 60);
    }
}


// ╔══════════════════════════════════════════════════════════════╗
//  MÓDULO: angled_remote_holder — porta-controle inclinado
//
//  Estratégia sem suporte:
//  O compartimento é inclinado usando rotate(), mas só a parte
//  acima da base é visível. A inclinação é para trás (eixo Y),
//  criando altura frontal menor e traseira maior.
//  O interior é escavado pelo topo (sem overhang).
// ╚══════════════════════════════════════════════════════════════╝
module angled_remote_holder() {
    cw  = cup_ext_w;
    cl  = cup_ext_l;
    cr  = cup_corner_r;
    fh  = cup_front_h;
    bh  = cup_back_h;
    cx  = cup_cx;
    cy  = cup_cy;
    ta  = tilt_angle;

    // Altura máxima que o corpo inclinado ocupa na vertical
    max_h = bh + 5;

    // ── Perfil externo do copo (visto de cima: cápsula) ──────
    module cup_shell_2d(offset_val = 0) {
        r = max(1, cr + offset_val);
        lx = cw + offset_val * 2;
        ly = cl + offset_val * 2;
        hull() {
            translate([r,      r])      circle(r = r, $fn = 48);
            translate([lx - r, r])      circle(r = r, $fn = 48);
            translate([r,      ly - r]) circle(r = r, $fn = 48);
            translate([lx - r, ly - r]) circle(r = r, $fn = 48);
        }
    }

    // ── Geometria inclinada principal ─────────────────────────
    // A inclinação é aplicada sobre o eixo Y, com pivô na base frontal
    translate([cx - cw / 2, cy - cl / 2, base_h]) {
        difference() {
            // Corpo externo: extrusão vertical (antes da inclinação)
            // Usamos uma cunha: interpolação de altura frente→trás
            // sem rotate para evitar overhang — geramos ponto a ponto.
            // Técnica: hull de fatias em alturas crescentes.
            hull() {
                // Face inferior (base)
                linear_extrude(height = 0.1)
                    cup_shell_2d(0);
                // Face superior frontal (menor)
                translate([0, 0, fh - base_h])
                linear_extrude(height = 0.1)
                    cup_shell_2d(0);
                // Face superior traseira (maior) — recuada pelo ângulo
                translate([0, cl * sin(ta) * 0.5,  bh - base_h])
                linear_extrude(height = 0.1)
                    cup_shell_2d(0);
            }

            // ── Interior oco ─────────────────────────────────
            // Removido pelo topo; base com fundo mínimo (wall_t)
            translate([wall_t, wall_t, wall_t])
            hull() {
                linear_extrude(height = 0.1)
                    cup_shell_2d(-wall_t);
                translate([0, 0, fh - base_h - wall_t])
                linear_extrude(height = 0.1)
                    cup_shell_2d(-wall_t);
                translate([0, (cl - wall_t * 2) * sin(ta) * 0.5, bh - base_h - wall_t * 0.5])
                linear_extrude(height = 0.1)
                    cup_shell_2d(-wall_t);
            }

            // ── Arredondamento do topo frontal ───────────────
            // Chanfro côncavo para suavizar a borda de entrada
            translate([-0.5, -0.5, fh - base_h - 3])
            rotate([-30, 0, 0])
            cube([cw + 1, 4, 5]);

            // ── Cortar tudo abaixo da base da bandeja ────────
            translate([-1, -1, -(base_h + 1)])
            cube([cw + 2, cl + 2, base_h + 1]);
        }

        // ── Anel decorativo de transição base → copo ─────────
        translate([0, 0, -0.5])
        difference() {
            linear_extrude(height = 2.5)
                cup_shell_2d(1.5);
            translate([0, 0, -0.1])
            linear_extrude(height = 3.1)
                cup_shell_2d(0);
        }
    }
}


// ╔══════════════════════════════════════════════════════════════╗
//  MÓDULO: decorative_ribs — textura canelada vertical
// ╚══════════════════════════════════════════════════════════════╝

// Nervuras ao redor de um perfil retangular (lateral de bandeja)
module decorative_ribs_wall(x0, y0, length, height, front_or_back) {
    pitch = rib_w + rib_gap;
    n     = floor(length / pitch);
    extra = (length - n * pitch) / 2;

    translate([x0 + extra, y0, 0])
    for (i = [0 : n - 1]) {
        translate([i * pitch + rib_w / 2, 0, 0])
        scale([rib_w / 2, rib_depth, 1])
        cylinder(r = 1, h = height, $fn = 8);
    }
}

// Nervuras ao redor do copo (radiais)
module decorative_ribs_cup() {
    cx  = cup_cx;
    cy  = cup_cy;
    r   = max(cup_ext_w, cup_ext_l) / 2 + 0.5;
    h0  = base_h + 2;
    h1  = cup_front_h - 4;

    pitch = rib_w + rib_gap;
    circ  = 2 * PI * r;
    n     = floor(circ / pitch);
    step  = 360 / n;

    translate([cx, cy, h0])
    for (i = [0 : n - 1]) {
        rotate([0, 0, i * step])
        translate([cup_ext_w / 2 + 0.2, 0, 0])
        scale([rib_depth, rib_w / 2, 1])
        cylinder(r = 1, h = h1 - h0, $fn = 8);
    }
}


// ╔══════════════════════════════════════════════════════════════╗
//  MÓDULO: phone_stand — slot inclinado para celular
// ╚══════════════════════════════════════════════════════════════╝
module phone_stand() {
    px = phone_cx - phone_w / 2;
    py = -0.1;
    pz = base_h - phone_d;

    // Bloco principal cortado com inclinação
    translate([px, py, 0])
    rotate([phone_angle, 0, 0])
    translate([0, 0, pz])
    cube([phone_w, phone_d + wall_t + 1, base_h + phone_d]);

    // Alargamento da boca de entrada
    translate([px - 0.8, py, base_h - 1.5])
    cube([phone_w + 1.6, wall_t + 0.1, 2]);
}


// ╔══════════════════════════════════════════════════════════════╗
//  MÓDULO: coin_tray — rebaixo circular para moedas/alianças
// ╚══════════════════════════════════════════════════════════════╝
module coin_tray() {
    translate([coin_cx, coin_cy, base_h - coin_depth + 0.01])
    cylinder(d = coin_d, h = coin_depth + 0.5, $fn = 64);

    // Borda interna suave (filete de 1 mm na borda do rebaixo)
    translate([coin_cx, coin_cy, base_h - coin_depth + 0.01])
    difference() {
        cylinder(d = coin_d + 2, h = 1.5, $fn = 64);
        translate([0, 0, -0.1])
        cylinder(d = coin_d - 2, h = 2, $fn = 64);
    }
}


// ╔══════════════════════════════════════════════════════════════╗
//  MÓDULO: main — produto final montado
// ╚══════════════════════════════════════════════════════════════╝
module main() {
    difference() {
        union() {
            capsule_base();
            angled_remote_holder();
        }

        // Escavar bandeja
        tray_cavity();

        // Cortar slot do celular
        phone_stand();

        // Rebaixo das moedas
        coin_tray();

        // Furo antivácuo no fundo do copo (facilita remover objetos)
        translate([cup_cx, cup_cy, -0.1])
        cylinder(d = (cup_ext_w - wall_t * 2) * 0.45, h = wall_t + 0.2, $fn = 40);
    }

    // ── Textura canelada na lateral da bandeja ─────────────
    difference() {
        union() {
            // Lateral frontal da bandeja
            decorative_ribs_wall(tray_x0, 0,
                                 tray_len * 0.62, base_h - 0.5, true);
            // Lateral traseira da bandeja
            decorative_ribs_wall(tray_x0, total_width - rib_depth,
                                 tray_len * 0.62, base_h - 0.5, false);
        }
        // Recortar o que ultrapassar a face da parede
        translate([tray_x0 - 1, -0.1, -0.1])
        cube([tray_len + 2, wall_t + 0.05, base_h + 1]);
        translate([tray_x0 - 1, total_width - wall_t + 0.05, -0.1])
        cube([tray_len + 2, wall_t + 1, base_h + 1]);
    }

    // ── Textura canelada no copo ───────────────────────────
    difference() {
        decorative_ribs_cup();
        // Não penetrar o interior do copo
        translate([cup_cx - cup_ext_w / 2 + wall_t,
                   cup_cy - cup_ext_l / 2 + wall_t, base_h - 0.1])
        hull() {
            for (xi = [cup_corner_r - wall_t, cup_ext_w - cup_corner_r - wall_t])
            for (yi = [cup_corner_r - wall_t, cup_ext_l - cup_corner_r - wall_t])
                translate([xi, yi, 0])
                cylinder(r = cup_corner_r - wall_t, h = cup_front_h, $fn = 48);
        }
        // Não ultrapassar o topo do copo
        translate([-1, -1, cup_front_h - 1])
        cube([total_length + 2, total_width + 2, 4]);
    }
}


// ╔══════════════════════════════════════════════════════════════╗
//  CHAMADA PRINCIPAL — pressione F6 para renderizar
// ╚══════════════════════════════════════════════════════════════╝
main();
