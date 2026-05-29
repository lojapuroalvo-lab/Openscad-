// ================================================================
// Placa Decorativa - Dia da Enfermagem
// Compatível com OpenSCAD 2021+
// Impressão 3D em duas cores (branco + vermelho) ou monocromático
// ================================================================

$fn = 64;

// ── Parâmetros principais ────────────────────────────────────────
HS  = 60;   // escala do coração (aprox. metade da largura)
PT  = 5;    // espessura da placa
BD  = 15;   // profundidade da base
BW  = 95;   // largura da base
BH  = 22;   // altura da base

// ── Paleta de cores (preview) ────────────────────────────────────
BRANCO   = [0.97, 0.97, 0.97];
VERMELHO = [0.85, 0.08, 0.08];
PRETO    = [0.10, 0.10, 0.10];

// ================================================================
// FORMA DO CORAÇÃO (2D)
// ================================================================
module heart2d(s = 60) {
    r = s * 0.5;
    hull() {
        translate([-r * 0.50,  r * 0.10]) circle(r = r * 0.53);
        translate([ r * 0.50,  r * 0.10]) circle(r = r * 0.53);
        polygon([[0, -r * 0.95], [-r * 1.05, r * 0.10], [r * 1.05, r * 0.10]]);
    }
}

// ================================================================
// PLACA PRINCIPAL
// ================================================================
module placa_principal() {
    // Borda externa vermelha (atrás)
    color(VERMELHO)
    translate([0, 0, -1.5])
    linear_extrude(PT + 2)
    difference() {
        offset(r = 6.5) heart2d(HS);
        offset(r = 1.0) heart2d(HS);
    }

    // Corpo branco
    color(BRANCO)
    linear_extrude(PT)
    heart2d(HS);

    // Anel interno vermelho decorativo
    color(VERMELHO)
    translate([0, 0, PT - 1.0])
    linear_extrude(2.5)
    difference() {
        offset(r = -6.5)  heart2d(HS);
        offset(r = -10.5) heart2d(HS);
    }
}

// ================================================================
// ESTETOSCÓPIO (lado esquerdo)
// ================================================================
module estetoscopio() {
    ox = -HS * 0.72;
    oy =  HS * 0.10;

    color(VERMELHO) translate([ox, oy, PT]) {

        // Arco superior (headset)
        linear_extrude(4)
        difference() {
            circle(r = 13.5);
            circle(r = 9.5);
            translate([-25, -25]) square(50);   // mantém só metade superior
        }

        // Pontas das orelhas (esquerda e direita)
        for (lado = [-1, 1]) {
            translate([lado * 13, 0, 0]) {
                cylinder(h = 6, r1 = 3, r2 = 2, $fn = 24);
                translate([0, 0, 6]) sphere(r = 2.5, $fn = 24);
            }
        }

        // Tubo vertical descendo
        hull() {
            translate([0, -13, 0]) cylinder(h = 4, r = 2.2, $fn = 20);
            translate([0, -32, 0]) cylinder(h = 4, r = 2.2, $fn = 20);
        }

        // Curva inferior (tubo curvando para a direita)
        curva = [[0,-32], [4,-38], [9,-44], [16,-47]];
        for (i = [0 : len(curva) - 2]) {
            hull() {
                translate(curva[i])     cylinder(h = 4, r = 2.2, $fn = 20);
                translate(curva[i + 1]) cylinder(h = 4, r = 2.2, $fn = 20);
            }
        }

        // Diafragma (cabeça do estetoscópio)
        translate([16, -47, 0]) {
            cylinder(h = 5, r = 9, $fn = 40);
            color(BRANCO)
            translate([0, 0, 4.5])
            cylinder(h = 1.5, r = 7.5, $fn = 40);
        }
    }
}

// ================================================================
// TOUCA DE ENFERMEIRA (canto superior direito)
// ================================================================
module touca_enfermeira() {
    ox = HS * 0.52;
    oy = HS * 0.33;
    z  = PT;

    // Corpo da touca (branco)
    color(BRANCO)
    translate([ox, oy, z])
    linear_extrude(4)
    polygon([
        [-16,  0], [16,  0],
        [ 13, 15], [-13, 15]
    ]);

    // Faixa vermelha horizontal
    color(VERMELHO)
    translate([ox - 16, oy + 3, z])
    linear_extrude(4.5)
    square([32, 5]);

    // Aba inferior vermelha
    color(VERMELHO)
    translate([ox, oy, z + 4])
    linear_extrude(2)
    polygon([[-19, 0], [19, 0], [18, 5], [-18, 5]]);

    // Cruz vermelha
    color(VERMELHO)
    translate([ox, oy + 8, z + 4])
    linear_extrude(3) {
        square([5, 14], center = true);
        square([14, 5], center = true);
    }
}

// ================================================================
// LINHA DE ECG / ELETROCARDIOGRAMA
// ================================================================
module linha_ecg() {
    color(VERMELHO)
    translate([0, -HS * 0.28, PT])
    linear_extrude(2.5)
    polygon([
        [-34, -1.5],
        [-22, -1.5],
        [-18,  5.5],
        [-14, -9.5],
        [-10,  7.0],
        [ -6, -1.5],
        [ 34, -1.5],
        [ 34,  1.5],
        [ -6,  1.5],
        [-10,  8.0],
        [-14, -8.5],
        [-18,  6.5],
        [-22,  1.5],
        [-34,  1.5]
    ]);
}

// Coraçãozinho ao lado da linha de ECG
module mini_coracao_ecg() {
    color(VERMELHO)
    translate([17, -HS * 0.28, PT])
    linear_extrude(2.5)
    scale([8.5 / HS, 8.5 / HS])
    heart2d(HS);
}

// ================================================================
// TEXTOS
// ================================================================
module textos() {
    z = PT + 0.8;

    // Nome - linha 1
    color(PRETO)
    translate([0, HS * 0.15, z])
    linear_extrude(2)
    text("Rosimeire", size = 9.5,
         halign = "center", valign = "center",
         font = "Liberation Sans:style=Bold Italic");

    // Nome - linha 2
    color(PRETO)
    translate([0, HS * 0.15 - 13, z])
    linear_extrude(2)
    text("Andrade", size = 9.5,
         halign = "center", valign = "center",
         font = "Liberation Sans:style=Bold Italic");

    // Evento
    color(PRETO)
    translate([0, -HS * 0.53, z])
    linear_extrude(2)
    text("Dia da Enfermagem", size = 5,
         halign = "center", valign = "center",
         font = "Liberation Sans");

    // Data
    color(PRETO)
    translate([0, -HS * 0.53 - 8, z])
    linear_extrude(2)
    text("12/05/2026", size = 5,
         halign = "center", valign = "center",
         font = "Liberation Sans");

    // Coraçõezinhos decorativos ao lado do texto do evento
    for (pos = [[-50, -HS * 0.53], [46, -HS * 0.53]]) {
        color(VERMELHO)
        translate([pos[0], pos[1], z])
        linear_extrude(2)
        scale([4.5 / HS, 4.5 / HS])
        heart2d(HS);
    }
}

// ================================================================
// BASE / SUPORTE
// ================================================================
module base() {
    slot_w   = PT + 3.0;
    bottom_y = -HS * 0.60;

    color(BRANCO)
    difference() {
        // Corpo retangular da base
        translate([-BW / 2, bottom_y - BH, 0])
            cube([BW, BH, BD]);

        // Encaixe vertical para a placa
        translate([-slot_w / 2, bottom_y - BH + 5, BD * 0.35])
            cube([slot_w, BH, BD]);
    }
}

// ================================================================
// MONTAGEM FINAL
// ================================================================
base();
placa_principal();
estetoscopio();
touca_enfermeira();
linha_ecg();
mini_coracao_ecg();
textos();
