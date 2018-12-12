path_height = 0.1;
path_width = 0.1;

arm_width = 6;
arm_length = 70;
thickness = 3;

draft = false;
//draft = true;

//do_rotate = false;
do_rotate = true;

//high_res = false;
high_res = true;


function path_width() = draft ? 2 : path_width ;
function path_height() = draft ? 2 : path_height ;

module extrusion(length) {
    cube([path_width(), length, path_height()], center=false);
}

module arm() {
    translate([-path_width()/2,0,0]) {
        // Floating arm base
        rhombus_s = arm_length/5;
        translate([0,rhombus_s,0]) {
            extrusion(arm_length-rhombus_s);
        };

        // Center Star
        translate([0,rhombus_s,0]) {
            rotate([0,0,60]) {
                extrusion(rhombus_s);
            }
            // Star echo
            translate([0, arm_width*2-2, 0])
                rotate([0,0,60]) {
                    extrusion(2*rhombus_s/3);
                }
        };

        // Tree bit
        for(i=[1:3]) {
            d = arm_length - 12*i + 2;
            translate([0,d,0]) {
                rotate([0,0,60]) {
                    extrusion(5*i + 2);
                };
            };
        }
    };
};

module profile() {
    chamfer_size = 1;
    // Tapered
    cylinder(h=chamfer_size, d1=arm_width-2*chamfer_size, d2=arm_width, center=false, $fn=high_res?32:14);
    // The middle
    translate([0,0,chamfer_size])
        cylinder(h=thickness-2*chamfer_size, d=arm_width, center=false, $fn=high_res?32:14);
    // Tapered again
    translate([0,0,thickness-chamfer_size])
        cylinder(h=chamfer_size, d1=arm_width, d2=arm_width-2*chamfer_size, center=false, $fn=high_res?32:14);
};

union() {
    for(i=do_rotate?[0:60:359]:[0]) {
        minkowski() {
            rotate([0,0,i]) {
                union() {
                    arm();
                    mirror(v=[1,0,0]) arm();
                }
            }
            if(!draft) {
                profile();
            }
        }
    }
}

//profile();
