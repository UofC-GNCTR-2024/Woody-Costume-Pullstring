include <BOSL2/std.scad>

// https://github.com/BelfrySCAD/BOSL2/wiki/shapes3d.scad#functionmodule-torus

d_min = 12;
d_maj = 120;

affix_d_max = 4;
affix_ring_d_maj = 15;

$fn = 200;

torus(
    d_maj = d_maj,
    d_min = d_min
);

back(d_maj/2 + d_min * 0.3) difference() {
    torus(
        d_maj = affix_ring_d_maj,
        d_min = affix_d_max
    );

    cuboid([100, 100, 100], anchor=BACK);
}
