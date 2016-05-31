%generate figures

path = 'H:\gcielniak\Google Drive (work)\beacon_logs\Bestways Feb 2016\';
%path = '/Users/gcielniak/Google Drive (work)/beacon_logs/Bestways Feb 2016/';


file_names = dir([path,'wifi_bt_log_*.txt']);

file_name = file_names(3).name;

map = imresize(imread([path, 'Bestways_map.png']),0.5);
scale = size(map,2)/95.56;

beacons = read_beacon_settings([path, 'beacon_settings.txt']);

data = read_log([path, file_name]);
fprintf('%s\n',file_name);

for t = 2%1:3
    for alpha = 0.5%0.1:0.1:1
scan = get_scan(data, t, alpha);
pos = [data(:).position];
pos = pos(1:2,:);

out_pos = [];
vis = 1;

for i = 1:length(scan)
    if vis
    clf;
    axis equal;
    axis([0 80 0 100]);
    hold on;
    draw_beacons(beacons);
    end
    detected = 0;

    plot(pos(1,1:i),pos(2,1:i),'k.');
    for j = 1:length(scan{i})
        scan{i}{j}.beacon_id = 0;
        for k = 1:length(beacons)
           if strcmp(scan{i}{j}.uuid,beacons(k).uuid) || strcmp(scan{i}{j}.address,beacons(k).address)
                scan{i}{j}.beacon_id = k;
                if vis
                norm_reading = min((105 + scan{i}{j}.value),30)/30;
                a = (norm_reading*0.8)^2;
                radius = ((1-norm_reading)*7)^2;
                circle(beacons(k).position(1), beacons(k).position(2), radius, [1 0 0], a);
                end
                break;
            end
        end
    end
        
    %NN detector
    s = [scan{i}{:}];
    v = [s.value];
    bid = [s.beacon_id];
    v(find(bid==0))=-Inf;
    [m mi] = max(v);
    k = scan{i}{mi}.beacon_id;
    if vis
    circle(beacons(k).position(1), beacons(k).position(2), 3, [0 1 0], 0.8);
    end
    if k 
    out_pos(1,i) = beacons(k).position(1);
    out_pos(2,i) = beacons(k).position(2);
    else
    out_pos(:,i) = out_pos(:,i-1);
    end
    if vis
    hold off;
    pause(0.01);
    end
end
fprintf('%.2f %.2f %.2f\n',t,alpha,mean(sqrt(sum((out_pos-pos).^2))));
 
    end
end
 