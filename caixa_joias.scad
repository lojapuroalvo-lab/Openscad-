// Caixa Organizadora de Joias
// Dimensões: 150mm x 120mm x 100mm

// === PARÂMETROS ===
comp  = 150;   // comprimento (X)
larg  = 120;   // largura (Y)
alt   = 100;   // altura total (Z)
esp   = 3;     // espessura das paredes
r_ext = 4;     // raio do arredondamento externo
tampa_alt = 35; // altura da tampa

// Altura do corpo (sem a tampa)
corpo_alt = alt - tampa_alt;

// === MÓDULOS ===

// Caixa arredondada
module caixa_arredondada(cx, cy, cz, r, espessura) {
    difference() {
        // Externo
        hull() {
            for (x = [r, cx - r])
                for (y = [r, cy - r])
                    translate([x, y, 0])
                        cylinder(r=r, h=cz, $fn=40);
        }
        // Interno (cavidade)
        translate([espessura, espessura, espessura])
            hull() {
                ri = max(r - espessura, 1);
                cx2 = cx - 2*espessura;
                cy2 = cy - 2*espessura;
                for (x = [ri, cx2 - ri])
                    for (y = [ri, cy2 - ri])
                        translate([x, y, 0])
                            cylinder(r=ri, h=cz, $fn=40);
            }
    }
}

// === CORPO DA CAIXA ===
module corpo() {
    caixa_arredondada(comp, larg, corpo_alt, r_ext, esp);

    // Divisórias internas
    // Divisória longitudinal (divide em 2 fileiras)
    translate([esp, larg/2 - esp/2, esp])
        cube([comp - 2*esp, esp, corpo_alt - esp - 1]);

    // Divisória transversal fileira 1
    translate([comp/2 - esp/2, esp, esp])
        cube([esp, larg/2 - esp, corpo_alt - esp - 1]);

    // Divisória transversal fileira 2
    translate([comp/2 - esp/2, larg/2, esp])
        cube([esp, larg/2 - esp, corpo_alt - esp - 1]);
}

// === TAMPA ===
module tampa() {
    difference() {
        // Corpo da tampa
        caixa_arredondada(comp, larg, tampa_alt, r_ext, esp);

        // Encaixe (rebaixo para sentar no corpo)
        folga = 0.4;
        translate([esp + folga, esp + folga, esp])
            hull() {
                ri = max(r_ext - esp - folga, 1);
                cx2 = comp - 2*(esp + folga);
                cy2 = larg - 2*(esp + folga);
                for (x = [ri, cx2 - ri])
                    for (y = [ri, cy2 - ri])
                        translate([x, y, 0])
                            cylinder(r=ri, h=tampa_alt, $fn=40);
            }
    }

    // Puxador central na tampa
    translate([comp/2, larg/2, tampa_alt])
        cylinder(d=20, h=8, $fn=40);
    translate([comp/2, larg/2, tampa_alt + 8])
        sphere(d=14, $fn=40);
}

// === RENDERIZAÇÃO ===
// Corpo posicionado na origem
color("SandyBrown", 0.9)
    corpo();

// Tampa deslocada ao lado para visualização
color("Peru", 0.85)
    translate([comp + 20, 0, 0])
        tampa();
