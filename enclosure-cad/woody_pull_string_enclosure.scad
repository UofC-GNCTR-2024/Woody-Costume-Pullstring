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
rp_actual_t = 1.6+0.3;
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


rp_top_block_screw_sep = 10;
rp_top_block_screw_d = 3.2;
rp_top_block_nut_w = 5.5;
rp_top_block_nut_t = 3;
rp_width = 18 + 0.5;
rp_height = 23 + 0.5; // z-axis
rp_top_block_overlap = 2;
rp_top_block_dist_pcb_top_to_screw_center = 5;

spring_d = 10+1.5;
spring_tube_len = 12;
spring_len = 30;

limit_switch_screw_sep = 10;
limit_switch_screw_d = 1.8;
limit_switch_screw_head_d = 4;

flexy_sheet_t = 1;

$fn = 80;
// make_enclosure(); // main
// make_enclosure_inspection(RIGHT); // convenient view for debugging


// right(50) make_flexy_sheet();
// up(10) make_rp_top_block();

// make_flexy_sheet();
make_rp_top_block();

// draw fake speaker
if (0)
% up(box_int_l) cuboid(
    [speaker_l, speaker_w, 18],
    anchor=TOP
);


module make_enclosure_inspection(side_to_keep) {
    difference() {
        make_enclosure();

        cuboid(
            1000,
            anchor = side_to_keep
        );
    }
}

module make_rp_top_block() {
    difference() {
        union() {
            down(rp_top_block_overlap) // overlap with RP; z=0 is at the top of the PCB
            cuboid(
                [rp_width+2*3, 8, 12],
                anchor=BOTTOM+BACK
            );
        }

        // remove the RP board itself
        fwd(usbc_pcb_t - rp_actual_t)
        cuboid(
            [rp_width, rp_actual_t, 100],
            anchor=BACK+TOP
        );

        // remove screw holes and nuts
        up(rp_top_block_dist_pcb_top_to_screw_center)
        for (x = [1,-1]) {
            right(x*rp_top_block_screw_sep/2) {
                ycyl(d=rp_top_block_screw_d, h=100);

                fwd(5.5)
                ycyl(r=rp_top_block_nut_w/sqrt(3), h=100, anchor=BACK, $fn=6);
            }
        }
    }
}

module make_flexy_sheet() {
    difference() {
        right(box_int_w/2 - 25)
        cuboid(
            [flexy_sheet_t, box_int_h - 10, box_int_l - 25],
            anchor=BOTTOM+RIGHT,
            rounding=3, except=[BOTTOM, LEFT, RIGHT]
        );

        // remove hole in it
        // remove hole for cord (edge and in flexy sheet)
        up(dist_reel_center_to_bottom)
        xcyl(d = reel_opening_d+0.5, h = 200, anchor = LEFT);
    }
}

module make_enclosure() {
    difference() {
        union() {
            // create box shell
            difference() {
                down(box_bot_t) cuboid(
                    [box_int_w + 2*box_t, box_int_h + 2*box_t, box_int_l + box_bot_t],
                    anchor = BOTTOM,
                    rounding = 2.9
                );

                // remove inside of box
                cuboid(
                    [box_int_w, box_int_h, box_int_l+0.01],
                    anchor = BOTTOM
                );
            }

            // add mounting rings
            for (x = [1,-1]) for (z = [10, 50]) {
                translate([(box_int_w/2 + box_t)*x, box_int_h/2, z])
                xrot(90) torus(
                    id = mounting_ring_d_opening,
                    d_min = mounting_ring_d_min,
                );
            }

            // add bit around USB-C port
            translate([usbc_pos_x, box_int_h/2 - usbc_pcb_t - usbc_w/2, 0])
            cuboid(
                [usbc_l+3, usbc_w/2+3, 5],
                anchor = BOTTOM+BACK,
                // rounding = usbc_w/2-0.01, except=[TOP,BOTTOM]
            );

            // add tube to hold spring (straight, so unused)
            // right(box_int_w/2) up(dist_reel_center_to_bottom)
            // difference() {
            //     xcyl(d=spring_d + 2*3, h=spring_tube_len, anchor=RIGHT);
            //     xcyl(d=spring_d, h=100);
            // }

            // add tube to hold spring (curves to back)
            // right(box_int_w/2) up(dist_reel_center_to_bottom)
            // back(20) path_extrude2d(arc(d=40, angle=[220,270]), caps=false)
            // difference() {
            //     circle(d=spring_d+2*3);
            //     circle(d=spring_d);
            // }

            // add a flexy sheet to trigger the switch
            // right(box_int_w/2 - 25)
            // cuboid(
            //     [1, box_int_h - 10, box_int_l - 20],
            //     anchor=BOTTOM+RIGHT
            // );
            // TODO: flare out at bottom

            // add a mount for a flexy sheet
            right(box_int_w/2 - 25)
            cuboid(
                [flexy_sheet_t + 2*3, box_int_h - 6, 8],
                anchor=BOTTOM,
                rounding=2, except=BOTTOM
            );

            // add a spot to mount limit switch (floating)
            // right(box_int_w/2)
            // up(30)
            // cuboid(
            //     [20, 10, 20],
            //     anchor=RIGHT+FRONT
            // );

            // add a spot to mount limit switch (grounded)
            right(box_int_w/2)
            cuboid(
                [20, 10, 30 + 10],
                anchor=RIGHT+FRONT+BOTTOM
            );

        }

        // remove where the flexy sheet slips in
        right(box_int_w/2 - 25)
        cuboid(
            [flexy_sheet_t + 0.25, box_int_h - 10, 8],
            anchor=BOTTOM,
        );
        

        // remove mounting holes and screwdriver hole on limit switch
        right(box_int_w/2 - 15)
        for (z=[1,-1]) up(30 + z * limit_switch_screw_sep/2) {
            ycyl(d=limit_switch_screw_d, h=box_int_h/2, anchor=FRONT);

            ycyl(d=limit_switch_screw_head_d, h=100, anchor=BACK);
        }

        // remove screws for rp_top_block_screw_sep
        right(usbc_pos_x)
        up(rp_height + rp_top_block_dist_pcb_top_to_screw_center)
        for (x = [1,-1]) right(x * rp_top_block_screw_sep/2)
        ycyl(d=rp_top_block_screw_d, h=100, anchor=FRONT);

        // remove USB-C port out bottom
        translate([usbc_pos_x, box_int_h/2 - usbc_pcb_t, -box_bot_t-1])
        cuboid(
            [usbc_l, usbc_w, 10],
            anchor = BOTTOM + BACK,
            rounding = usbc_w/2-0.01, except=[TOP,BOTTOM]
        );

        // remove hole for cord (edge and in flexy sheet)
        up(dist_reel_center_to_bottom)
        xcyl(d = reel_opening_d+0.5, h = 200, anchor = LEFT);

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

}

