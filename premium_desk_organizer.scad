// ============================================================
//  ORGANIZADOR DE MESA PREMIUM — FDM 3D Print Ready
//  Design escandinavo moderno, sem suportes, base plana.
//
//  COMO ALTERAR:
//  Edite os parâmetros abaixo antes de renderizar.
//  total_length / total_width  → tamanho geral
//  cup_height                  → altura do porta-controle
//  cup_inner_d                 → abertura interna do copo
//  wall_t                      → espessura das paredes
//  corner_r                    → arredondamento geral
// ============================================================

$fn = 60;

// ─── Dimensões Gerais ────────────────────────────────────────
total_length  = 250;
total_width   = 100;
base_h        = 18;
corner_r      = 14;
wall_t        = 2.4;
chamfer       = 1.0;   // chanfro das bordas superiores

// ─── Porta-controle orgânico ─────────────────────────────────
cup_height    = 90;
cup_inner_d   = 65;
cup_depth     = 80;    // profundidade frontal-traseira (formato cápsula)
cup_width     = cup_inner_d + wall_t * 2;
cup_x         = cup_width / 2 + wall_t;   // posição X do centro
cup_y         = total_width / 2;

// ─── Textura canelada ────────────────────────────────────────
rib_w         = 3.0;   // largura da ranhura
rib_gap       = 3.0;   // espaçamento entre ranhuras
rib_depth_val = 0.9;   // profundidade do sulco

// ─── Bandeja cápsula ─────────────────────────────────────────
tray_x_start  = cup_width + wall_t * 3;
tray_length   = total_length - tray_x_start - wall_t;
tray_depth    = 12;    // profundidade útil

// ─── Suporte de celular ──────────────────────────────────────
phone_w       = 14;
phone_d       = 8;
phone_angle   = 15;    // graus de inclinação

// ─── Porta-moedas ────────────────────────────────────────────
coin_d        = 50;
coin_depth    = 4;
coin_x        = total_length - coin_d / 2 - wall_t - corner_r / 2;
coin_y        = total_width / 2;

// ─── Divisória ───────────────────────────────────────────────
div_t         = 1.8;
div_h         = tray_depth - 1;
div_clearance = 0.25;  // folga para encaixe por pressão


// ============================================================
//  rounded_box — caixa sólida com cantos arredondados 3D
// ============================================================
module rounded_box(lx, ly, lz, r) {
    r2 = min(r, min(lx, ly) / 2 - 0.1);
    hull() {
        for (xi = [r2, lx - r2])
        for (yi = [r2, ly - r2])
            translate([xi, yi, 0])
            cylinder(r = r2, h = lz, $fn = 48);
    }
}


// ============================================================
//  capsule_2d — perfil 2D de cápsula (usado com linear_extrude)
// ============================================================
module capsule_2d(len, wid) {
    r = wid / 2;
    hull() {
        translate([r, r])         circle(r = r, $fn = 48);
        translate([len - r, r])   circle(r = r, $fn = 48);
    }
}


// ============================================================
//  decorative_ribs — filetes canelados verticais em superfície
//  Aplica sulcos em torno de um perfil extrudado.
//  Usa diferença com cilindros finos posicionados na borda.
// ============================================================
module decorative_ribs_cup(cx, cy, r_outer, h_start, h_end) {
    pitch = rib_w + rib_gap;
    circ  = 2 * PI * r_outer;
    count = floor(circ / pitch);
    step  = 360 / count;
    rh    = h_end - h_start;

    translate([cx, cy, h_start])
    for (i = [0 : count - 1]) {
        rotate([0, 0, i * step])
        translate([r_outer, 0, 0])
        scale([rib_depth_val, rib_w / 2, 1])
        cylinder(r = 1, h = rh, $fn = 8);
    }
}

module decorative_ribs_tray(x0, y0, length, height) {
    pitch = rib_w + rib_gap;
    count = floor(length / pitch);

    // lateral frontal
    translate([x0, y0, 0])
    for (i = [0 : count - 1]) {
        translate([i * pitch + pitch / 2, 0, 0])
        scale([rib_w / 2, rib_depth_val, 1])
        cylinder(r = 1, h = height, $fn = 8);
    }

    // lateral traseira
    translate([x0, y0 + total_width - wall_t, 0])
    for (i = [0 : count - 1]) {
        translate([i * pitch + pitch / 2, 0, 0])
        scale([rib_w / 2, rib_depth_val, 1])
        cylinder(r = 1, h = height, $fn = 8);
    }
}


// ============================================================
//  organic_remote_holder — porta-controle formato gota/cápsula
//  Frente: reta  |  Traseira: curva convexa
// ============================================================
module organic_remote_holder() {
    // Perfil orgânico: hull entre retângulo frontal e semicírculo traseiro
    // Visto de cima: frente reta, traseira com arco
    half_w  = cup_width / 2;
    front_d = cup_depth * 0.38;  // quanto da profundidade é reta
    back_r  = cup_depth * 0.72;  // raio do arco traseiro

    module cup_footprint_2d() {
        hull() {
            // borda frontal reta
            translate([0, -half_w + corner_r / 2]) circle(r = corner_r / 2, $fn = 32);
            translate([0,  half_w - corner_r / 2]) circle(r = corner_r / 2, $fn = 32);
            // parte traseira convexa
            translate([front_d + back_r - cup_depth * 0.08, 0])
                circle(r = back_r * 0.88, $fn = 60);
        }
    }

    difference() {
        union() {
            // Corpo externo
            translate([cup_x - cup_width / 2 + 0.1, cup_y, 0])
            rotate([0, 0, -90])
            linear_extrude(height = cup_height)
                cup_footprint_2d();

            // Filete decorativo na base (anel de transição)
            translate([cup_x - cup_width / 2 + 0.1, cup_y, base_h - 1])
            rotate([0, 0, -90])
            linear_extrude(height = 2)
            offset(delta = 1.2)
                cup_footprint_2d();
        }

        // Furo interno — mesma forma, menor
        translate([cup_x - cup_width / 2 + 0.1 + wall_t * 0.8, cup_y, wall_t + base_h])
        rotate([0, 0, -90])
        linear_extrude(height = cup_height)
        offset(delta = -wall_t)
            cup_footprint_2d();

        // Raspar parte que fica dentro da base
        translate([-1, -1, -0.1])
        cube([total_length + 2, total_width + 2, base_h]);

        // Chanfro borda superior do copo
        translate([cup_x - cup_width / 2 + 0.1, cup_y, cup_height - chamfer])
        rotate([0, 0, -90])
        linear_extrude(height = chamfer + 0.1)
        offset(delta = chamfer * 0.8)
            cup_footprint_2d();
    }
}


// ============================================================
//  capsule_tray — bandeja em formato cápsula orgânica
// ============================================================
module capsule_tray() {
    tw = total_width;
    tl = tray_length;
    tx = tray_x_start;

    module tray_outer() {
        translate([tx, corner_r, 0])
        hull() {
            // extremidade esquerda (junto ao copo)
            cylinder(r = corner_r, h = base_h, $fn = 48);
            translate([0, tw - corner_r * 2, 0])
            cylinder(r = corner_r, h = base_h, $fn = 48);
            // extremidade direita arredondada
            translate([tl - corner_r, tw / 2 - corner_r, 0])
            cylinder(r = corner_r, h = base_h, $fn = 48);
            translate([tl - corner_r, tw / 2 - corner_r, 0])
            cylinder(r = corner_r, h = base_h, $fn = 48);
            translate([tl, tw / 2 - corner_r * 0.1, 0])
            cylinder(r = corner_r * 0.8, h = base_h, $fn = 48);
        }
    }

    module tray_inner() {
        ir = corner_r - wall_t;
        translate([tx + wall_t, corner_r + wall_t, base_h - tray_depth])
        hull() {
            cylinder(r = ir, h = tray_depth + 1, $fn = 48);
            translate([0, tw - (corner_r + wall_t) * 2, 0])
            cylinder(r = ir, h = tray_depth + 1, $fn = 48);
            translate([tl - corner_r - wall_t * 2, tw / 2 - corner_r - wall_t / 2, 0])
            cylinder(r = ir * 0.8, h = tray_depth + 1, $fn = 48);
            translate([tl - wall_t * 2, tw / 2 - corner_r * 0.1, 0])
            cylinder(r = ir * 0.6, h = tray_depth + 1, $fn = 48);
        }
    }

    difference() {
        tray_outer();
        tray_inner();
        // chanfro borda superior bandeja
        translate([tx - 0.1, -0.1, base_h - chamfer])
        cube([tl + corner_r + 1, tw + 1, chamfer + 0.1]);
    }
}


// ============================================================
//  phone_stand — slot inclinado para celular (frente central)
// ============================================================
module phone_stand() {
    tx     = tray_x_start;
    tl     = tray_length;
    cx     = tx + tl * 0.38;
    slot_h = base_h + phone_d / tan((90 - phone_angle) * PI / 180);

    // Bloco cortado da parede frontal em ângulo
    translate([cx - phone_w / 2, -0.1, 0])
    rotate([phone_angle, 0, 0])
    cube([phone_w, phone_d + 1, slot_h]);

    // Boca de entrada arredondada (facilitar encaixe do celular)
    translate([cx - phone_w / 2 - 0.5, -0.1, base_h - 1])
    cube([phone_w + 1, wall_t + 1, 2]);
}


// ============================================================
//  coin_tray — rebaixo circular para moedas
// ============================================================
module coin_tray() {
    translate([coin_x, coin_y, base_h - coin_depth + 0.01])
    cylinder(d = coin_d, h = coin_depth + 1, $fn = 60);
}


// ============================================================
//  divider — divisória encaixável por pressão
//  Imprime separada; encaixa nos slots internos da bandeja.
// ============================================================
module divider() {
    tw    = total_width - wall_t * 2 - div_clearance * 2 - corner_r * 0.4;
    tx    = tray_x_start;
    tl    = tray_length;
    dx    = tx + tl * 0.45;
    slot_groove = 1.6;  // largura do encaixe inferior

    // Corpo da divisória
    translate([dx, wall_t + corner_r * 0.2 + div_clearance, base_h - div_h])
    difference() {
        // Parede principal com topo suavizado
        hull() {
            cube([div_t, tw, div_h * 0.85]);
            translate([0, 2, div_h * 0.85])
            cube([div_t, tw - 4, div_h * 0.15]);
        }

        // Alivio central decorativo (janela oval)
        translate([div_t / 2, tw / 2, div_h * 0.3])
        rotate([90, 0, 90])
        scale([1, 1.6, 1])
        cylinder(d = tw * 0.35, h = div_t + 0.1, center = true, $fn = 48);
    }

    // Pé de encaixe inferior (encaixa no piso da bandeja)
    translate([dx - slot_groove / 2, wall_t + corner_r * 0.2 + div_clearance, base_h - div_h - 1.5])
    cube([div_t + slot_groove, tw, 1.6]);
}


// ============================================================
//  base_plate — base plana unificada com chanfros
// ============================================================
module base_plate() {
    difference() {
        rounded_box(total_length, total_width, base_h, corner_r);
        // chanfro superior da base
        translate([-0.1, -0.1, base_h - chamfer])
        cube([total_length + 0.2, total_width + 0.2, chamfer + 0.1]);
    }

    // Filete perimetral decorativo na base
    difference() {
        translate([wall_t, wall_t, base_h - chamfer - 0.8])
        rounded_box(total_length - wall_t * 2, total_width - wall_t * 2,
                    chamfer + 1, corner_r - wall_t);
        translate([wall_t * 2, wall_t * 2, base_h - chamfer - 1])
        rounded_box(total_length - wall_t * 4, total_width - wall_t * 4,
                    chamfer + 2, corner_r - wall_t * 2);
    }
}


// ============================================================
//  main — produto final completo
// ============================================================
module main() {
    difference() {
        union() {
            base_plate();
            capsule_tray();
            organic_remote_holder();
        }

        // Subtrações
        coin_tray();
        phone_stand();

        // Rebaixo leve no fundo do porta-controle (anti-vácuo)
        translate([cup_x, cup_y, -0.1])
        cylinder(d = cup_inner_d * 0.4, h = wall_t + 0.2, $fn = 32);
    }

    // Textura canelada no copo (diferença aplicada sobre o copo pronto)
    difference() {
        decorative_ribs_cup(cup_x, cup_y, cup_width / 2 + 0.3,
                            base_h + 2, cup_height - 2);
        // garantir que ribs não entram no interior
        translate([cup_x, cup_y, -0.1])
        cylinder(d = cup_inner_d - 2, h = cup_height + 1, $fn = 60);
        // garantir que ribs não ultrapassam o topo
        translate([-1, -1, cup_height - 1.5])
        cube([total_length + 2, total_width + 2, 3]);
    }

    // Textura canelada na bandeja (lateral frontal e traseira)
    difference() {
        decorative_ribs_tray(tray_x_start, 0, tray_length * 0.7, base_h - 1);
        // não penetrar na parede
        translate([tray_x_start - 1, -0.1, -0.1])
        cube([tray_length + 2, wall_t + rib_depth_val - 0.1, base_h + 1]);
        translate([tray_x_start - 1, total_width - wall_t - rib_depth_val + 0.1, -0.1])
        cube([tray_length + 2, wall_t + rib_depth_val + 1, base_h + 1]);
    }
}


// ============================================================
//  CHAMADA PRINCIPAL
//  Descomente divider() abaixo para imprimir a divisória
//  separada (posiciona ao lado do organizador).
// ============================================================
main();

// Divisória — imprimir separado:
// translate([0, total_width + 10, 0]) divider();
