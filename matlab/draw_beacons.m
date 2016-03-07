function draw_beacons(beacons)

for j=1:length(beacons)
    circle(beacons(j).position(1), beacons(j).position(2), .5, [.5 .5 .5], 1);
end