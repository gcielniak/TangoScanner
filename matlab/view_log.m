%generate figures

path = 'H:\gcielniak\Google Drive (work)\beacon_logs\Bestways Feb 2016\';

file_names = dir([path,'wifi_bt_log_*.txt']);

file_name = file_names(2).name;

map = imresize(imread([path, 'Bestways_map.png']),0.5);
scale = size(map,2)/95.56;

beacons = read_beacon_settings([path, 'beacon_settings.txt']);

data = read_log([path, file_name]);
scan = get_scan(data, 2);
pos = [data(:).position];
fprintf('%s\n',file_name);

assoc = [];

for i = 1:length(scan)
    clf;
    axis equal;
    axis([0 80 0 100]);
    hold on;
    draw_beacons(beacons);

    plot(pos(1,1:i),pos(2,1:i),'k.');
    for j = 1:length(scan{i})
        for k = 1:length(beacons)
           if strcmp(scan{i}{j}.uuid,beacons(k).uuid) || strcmp(scan{i}{j}.address,beacons(k).address)
                norm_reading = min((105 + scan{i}{j}.value),30)/30;
                alpha = (norm_reading*0.8)^2;
                radius = ((1-norm_reading)*7)^2;
                circle(beacons(k).position(1), beacons(k).position(2), radius, [1 0 0], alpha);
                break;
            end
        end
    end
    hold off;
    pause(0.01);
end
hold off;
