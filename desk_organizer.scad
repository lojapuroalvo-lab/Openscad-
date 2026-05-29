// =====================================================
//  Organizador de Mesa – Suporte para Canetas + Bandeja
//  Inspirado no design minimalista com ranhuras verticais
// =====================================================
$fn = 64;

// ── Dimensões gerais ────────────────────────────────
BL  = 230;     // comprimento total (mm)
BW  = 90;      // largura total (mm)
BH  = 14;      // altura da bandeja
BT  = 3;       // espessura das paredes/piso
BCR = 25;      // raio dos cantos arredondados

// Suporte de canetas (lado direito)
PHX = 150;     // X onde o suporte começa
PHH = 90;      // altura total do suporte

// Recorte circular (lado esquerdo da bandeja)
CCX = 42;      // centro X
CCY = 45;      // centro Y
CCR = 20;      // raio

// Ranhuras verticais
RSP = 4.5;     // espaçamento entre ranhuras
RW  = 1.2;     // largura de cada ranhura
RD  = 1.0;     // profundidade de protrusão

// ── Módulo auxiliar: forma oval/estádio ─────────────
module oblong(lx, ly, lz, r) {
    hull() {
        translate([r,    r,    0]) cylinder(r=r, h=lz);
        translate([lx-r, r,    0]) cylinder(r=r, h=lz);
        translate([r,    ly-r, 0]) cylinder(r=r, h=lz);
        translate([lx-r, ly-r, 0]) cylinder(r=r, h=lz);
    }
}

// ── Bandeja principal ────────────────────────────────
module bandeja() {
    difference() {
        // Corpo externo
        oblong(BL, BW, BH, BCR);
        // Cavidade interna
        translate([BT, BT, BT])
            oblong(BL-2*BT, BW-2*BT, BH, BCR-BT);
        // Recorte circular no piso
        translate([CCX, CCY, 0])
            cylinder(r=CCR, h=BH+1);
    }
}

// ── Suporte de canetas com ranhuras ─────────────────
module suporte_canetas() {
    PL = BL - PHX;   // comprimento do suporte no eixo X

    difference() {
        union() {
            // Corpo sólido do suporte
            translate([PHX, 0, 0])
                oblong(PL, BW, PHH, BCR);

            // Ranhuras na face esquerda (acima da bandeja)
            for (y = [BCR : RSP : BW - BCR - RW])
                translate([PHX - RD, y, BH])
                    cube([RD, RW, PHH - BH]);

            // Ranhuras na face frontal (y = 0)
            for (x = [PHX : RSP : BL - BCR - RW])
                translate([x, -RD, 0])
                    cube([RW, RD, PHH]);

            // Ranhuras na face traseira (y = BW)
            for (x = [PHX : RSP : BL - BCR - RW])
                translate([x, BW, 0])
                    cube([RW, RD, PHH]);
        }

        // Cavidade interna do suporte (aberto no topo)
        translate([PHX + BT, BT, BH])
            oblong(PL - 2*BT, BW - 2*BT, PHH - BH, BCR - BT);
    }
}

// ── Montagem final ───────────────────────────────────
color("wheat") {
    bandeja();
    suporte_canetas();
}
