function params = to_image_coor(scan, beacons, resolution)

scan_pos = [scan.position];
beacon_pos = [beacons.position];
pos = [scan_pos beacon_pos];

min_x = min(pos(1,:));
max_x = max(pos(1,:));
min_y = min(pos(2,:));
max_y = max(pos(2,:));

params = [1/resolution -min_x/(max_x-min_x); 1/resolution -min_y/(max_y-min_y)];

