%generate figures

path = 'H:\gcielniak\Google Drive (work)\beacon_logs\Bestways Feb 2016\';

file_names = dir([path,'wifi_bt_log_*.txt']);

file_name = file_names(2).name;

%map = imresize(imread([path, 'Bestways_map.png']),0.5);
scale = size(map,2)/95.56;

beacons = read_beacon_settings([path, 'beacon_settings.txt']);

data = read_log([path, file_name]);

figure;
axis equal;
axis([0 80 0 100]);

hold on;
for j=1:length(beacons)
    circle(beacons(j).position(1), beacons(j).position(2), .5, [.5 .5 .5], 1);
end

fprintf('%s\n',file_name);

assoc = [];

for i = 1:length(data)
    detected = 0;
    for j=1:length(beacons)
       if strcmp(data(i).uuid,beacons(j).uuid) || strcmp(data(i).address,beacons(j).address)
           data(i).distance = sqrt((beacons(j).position(1)-data(i).position(1))^2 + (beacons(j).position(2)-data(i).position(2))^2);
            assoc(i).uuid = data(i).uuid;
            assoc(i).name = data(i).name;
            assoc(i).address = data(i).address;
            norm_reading = min((105 + data(i).value),30)/30;
            alpha = (norm_reading*0.8)^5;
%            radius = ((1-norm_reading)*7)^2;
            r2 = -8^(-14)*data(i).value^7;
            abs(radius - r2)
            %
            circle(beacons(j).position(1), beacons(j).position(2), r2, [1 0 0], alpha);
            detected = 1;
            break;
        end
    end
    if detected == 0
        assoc(i).uuid = '';
        assoc(i).name = '';
        assoc(i).address = '';
        data(i).distance = Inf;
        
        fprintf('NA: %s %s %s %.1f\n',data(i).name,data(i).address,data(i).uuid,data(i).value);
    end
    plot(data(i).position(1),data(i).position(2),'k.');
    pause(0.01);
end
hold off;

if 0
%%
[un, ia] = unique({assoc.name});
un = {assoc(ia).name};
ua = {assoc(ia).address};
uu = [un;ua]';

for i = 1:length(uu)
    fprintf('%s %s\n',uu{i,1},uu{i,2});
end
end