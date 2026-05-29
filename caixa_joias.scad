// Bandeja Canelada - Organizadora de Joias
// Estilo: caneluras verticais, forma oval, borda ondulada

// === PARÂMETROS ===
comp    = 150;  // comprimento total
larg    = 120;  // largura total
alt     = 70;   // altura da bandeja (ajuste conforme desejado)
base_h  = 3;    // espessura da base
flute_r = 6;    // raio de cada canelura
wall    = 3;    // espessura da parede interna
$fn     = 40;

// === GEOMETRIA ===
R      = larg / 2;               // raio das extremidades = 60
str    = comp - larg;            // trecho reto lateral = 30
R_cav  = R - flute_r - wall;    // raio da cavidade interna = 51

// Número de caneluras distribuídas
n_semi = max(6, round(PI * R / (flute_r * 2)));       // por semicírculo (~16)
n_str  = max(0, round(str / (flute_r * 2) - 0.5));   // no trecho reto (~2)

// === MÓDULOS ===

// Uma canelura: cilindro + esfera no topo (borda ondulada)
module uma_canelura(h) {
    cylinder(r=flute_r, h=h, $fn=24);
    translate([0, 0, h]) sphere(r=flute_r, $fn=24);
}

// Posiciona todas as caneluras ao redor do contorno
module posicionar_caneluras(h) {
    // Semicírculo esquerdo — centro em [R, R]
    for(i = [0 : n_semi]) {
        a = 90 + i * 180 / n_semi;
        translate([R + R*cos(a), R + R*sin(a), 0])
            uma_canelura(h);
    }
    // Semicírculo direito — centro em [comp-R, R]
    for(i = [0 : n_semi]) {
        a = -90 + i * 180 / n_semi;
        translate([comp-R + R*cos(a), R + R*sin(a), 0])
            uma_canelura(h);
    }
    // Trechos retos (frente e fundo)
    if (n_str > 0 && str > 0) {
        for(i = [0 : n_str - 1]) {
            x = R + (i + 0.5) * str / n_str;
            translate([x, 0,    0]) uma_canelura(h);
            translate([x, larg, 0]) uma_canelura(h);
        }
    }
}

// Cavidade interna lisa (oval)
module cavidade_interna() {
    translate([0, 0, base_h])
        hull() {
            translate([R, R, 0])
                cylinder(r=R_cav, h=alt + flute_r + 1, $fn=80);
            translate([comp-R, R, 0])
                cylinder(r=R_cav, h=alt + flute_r + 1, $fn=80);
        }
}

// Base sólida (preenchimento entre as caneluras)
module base_solida() {
    hull() posicionar_caneluras(base_h);
}

// Bandeja completa
module bandeja() {
    difference() {
        union() {
            base_solida();
            posicionar_caneluras(alt);
        }
        cavidade_interna();
    }
}

// === RENDERIZAÇÃO ===
color("RosyBrown", 0.95)
    bandeja();
