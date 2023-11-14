include <BOSL2/std.scad>


reel_d = 32 + 1;
reel_h = 10 + 0.5; // really probably about 10

reel_holder_t = 3; // rounded walls
reel_holder_top_t = 2; // flat top

reel_opening_d = 10; // "id"
reel_torus_d_min = 5;

reel_ball_d = 7.5; // diameter of the ball that has to fit through everything

speaker_depth = 16.5;
speaker_w = 31;
speaker_l = 70;
speaker_screw_d = 2.6; // M3 thread-forming
speaker_screw_sep_w = 24;
speaker_screw_sep_l = 64;
speaker_lip_t = 2.5; // lip around screw holes
speaker_screw_l = 5; // length of screw going into plastic (= screw length - speaker thickness)
// Speaker noise part, rounded rect: 38x27

amp_screw_sep = 10;
amp_screw_d = 2.8; // use M3 thread-forming maybe

// board_unit (audio plus speaker) size: 45x70mm x 20mm tall (or 15mm after a small modification)

box_int_w = 70; // [in x] speaker length
box_int_l = 60; // [in z] speaker depth + board_unit
box_int_h = 31; // [in y] speaker width

box_t = 2; // box thickness
box_bot_t = 1.5; // USB-C cable passes through

usbc_pos_x = -12; // center of USB port
usbc_w = 3.5;
usbc_l = 9;
usbc_pcb_t = 1.6+0.3 + 1.2;
// reel goes opposite USB port
// USB port points out the bottom

dist_reel_center_to_bottom = 18;

mounting_ring_d_opening = 5;
mounting_ring_d_min = 4;

rp_pin_pitch = 2.54;
rp_pin_w = 1; // real: 0.64
rp_pin_edge_to_back_pins = 21.6 + 0.2;
rp_back_pin_count = 7;
rp_side_pin_count = 9;
rp_side_pin_sep = 2.54 * 6;


$fn = 80;

make_enclosure(); // main
// make_enclosure_inspection(); // convenient view for debugging

module make_enclosure_inspection() {
    difference() {
        make_enclosure();

        cuboid(
            1000,
            anchor = FRONT
        );
    }
}

module make_enclosure() {
    difference() {
        union() {
            down(box_bot_t) cuboid(
                [box_int_w + 2*box_t, box_int_h + 2*box_t, box_int_l + box_bot_t],
                anchor = BOTTOM,
                rounding = 2.9
            );

            // add mounting rings
            for (x = [1,-1]) for (z = [10, 50]) {
                translate([(box_int_w/2 + box_t)*x, box_int_h/2, z])
                xrot(90) torus(
                    id = mounting_ring_d_opening,
                    d_min = mounting_ring_d_min,
                );
            }
            
        }

        // remove inside of box
        cuboid(
            [box_int_w, box_int_h, box_int_l+0.001],
            anchor = BOTTOM
        );

        // remove USB-C port out bottom
        translate([usbc_pos_x, box_int_h/2 - usbc_pcb_t, -box_bot_t-1])
        cuboid(
            [usbc_l, usbc_w, 10],
            anchor = BOTTOM + BACK,
            rounding = usbc_w/2-0.01, except=[TOP,BOTTOM]
        );

        // remove hole for cord
        up(dist_reel_center_to_bottom)
        xcyl(d = reel_opening_d+1, h = 200, anchor = LEFT);

        // remove reel entry from outside
        fwd(box_int_h/2 + box_t) left(15) up(dist_reel_center_to_bottom)
        ycyl(d=reel_d, h=reel_h, anchor=FRONT);

        // remove pins to secure RP2040-Zero board
        // remove back pins (perpendicular to USB cord)
        right(usbc_pos_x) {
            up(rp_pin_edge_to_back_pins) xcopies(n=rp_back_pin_count, spacing=rp_pin_pitch) {
                cuboid(
                    [rp_pin_w, 100, rp_pin_w],
                    anchor=FRONT
                );
            }
        }
        
        // remove side pins (parallel to USB cord)
        for (x = [1, -1]) {
            right(usbc_pos_x + x*rp_side_pin_sep/2) {
                up(rp_pin_edge_to_back_pins - ((rp_side_pin_count-1)*rp_pin_pitch)/2) zcopies(spacing=rp_pin_pitch, n=rp_side_pin_count) {
                    cuboid(
                        [rp_pin_w, 100, rp_pin_w],
                        anchor=FRONT
                    );
                }
            }
        }
    }

    // add corner pieces to screw in the speaker
    for (x = [1,-1]) for (y = [1, -1]) {
        difference() {
            hull() {
                // top, closest to speaker
                translate([speaker_screw_sep_l/2*x, speaker_screw_sep_w/2*y, box_int_l - speaker_lip_t])
                zcyl(d = 7, h=3, anchor=TOP);

                // create a taper for nice printing
                translate([box_int_w/2*x, box_int_h/2*y, box_int_l - 20])
                zcyl(d = 1, h=1, anchor=TOP, $fn=8);
            }

            // remove hole
            translate([speaker_screw_sep_l/2*x, speaker_screw_sep_w/2*y, box_int_l - speaker_lip_t])
            zcyl(d = speaker_screw_d, h = speaker_screw_l, anchor = TOP);
        }
    }

    // add torus for reel/cord
    for (incl_box_t = [0.5]) // can include '0' and/or '1' as well
    right(box_int_w/2 + box_t*incl_box_t) up(dist_reel_center_to_bottom) yrot(90)
    yscale(reel_ball_d/reel_opening_d)
    torus(
        id = reel_opening_d,
        d_min = reel_torus_d_min,
    );

    // add reel holder
    fwd(box_int_h/2) left(15) up(dist_reel_center_to_bottom) difference() {
        union() {
            hull() {
                ycyl(
                    d=reel_d + 2*reel_holder_t, h=reel_h+reel_holder_top_t,
                    anchor=FRONT,
                    rounding = 2
                );
                // down(dist_reel_center_to_bottom) ycyl(d=0.1, h=reel_h, anchor=FRONT, $fn=8); // would be good if it was in the air, for printing purposes
            }

            // add part for ball to slip through
            right(reel_d/2+reel_holder_t) back(reel_h/2) {
                //sphere(d = reel_ball_d+2*2, $fn=40);
                //yrot(90) torus(d_min=3.5, id=reel_ball_d-0.1); // unprintable
                xcyl(d=reel_ball_d+2*3, h=3, rounding2=2);
            }
        }

        // constrain to within the box (but ensure interection with the box)
        fwd(box_t/2) cuboid(
            [100, 100, 100],
            anchor=BACK
        );

        // remove slit out
        cuboid(
            [100, reel_h - reel_holder_top_t, 3],
            anchor = FRONT+LEFT,
        );

        // remove reel
        ycyl(d=reel_d, h=reel_h, anchor=FRONT);

        // remove gap for reel ball
        back(reel_h/2) xcyl(d=reel_ball_d, h=100, anchor=LEFT);

    }
}

