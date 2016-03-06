path = 'H:\gcielniak\Google Drive (work)\beacon_logs\';
file_name = [path, 'wifi_bt_log_20151012T170402.0002.txt'];
beacon_file_name = [path, 'beacon_settings.txt'];
aa = 1;
nn = 1;
beacons = read_beacon_settings(beacon_file_name);
%read data
scan = read_log(file_name);
aerr = [];
aper = [];

for alpha=0.2%0.025:0.025:0.3
nn=1;
for N = 12%10:16
output = [];
current_scan = [];
past_readings = [];
k = 1;

for i=1:size(scan,2)
    %check if the scan matches beacons
    ind_beacon = find(strcmp({beacons.address},scan(i).address));
    if isempty(ind_beacon)
        continue;
    end    
    
    label = 0;
    gt_label = 0;
    min_dist = inf;
    %gt calculation
    pos = [scan(i).position(2) -scan(i).position(1) scan(i).position(3)]';
    for j=1:size(beacons,2)     
        dist = sum((pos - beacons(j).position).^2);
        if (dist < min_dist)
            min_dist = dist;
            output(k,2) = j;
        end
    end
    
    %update scan  
    if isempty(current_scan)
        current_scan = scan(i);
    end
    
    ind = find(strcmp({current_scan.address},scan(i).address));
    if isempty(ind)            
        current_scan = [current_scan scan(i)];
    else
        current_scan(ind).value = current_scan(ind).value*(1-alpha) + scan(i).value*alpha;            
    end
   
    scale = 5;
    im = zeros(50*scale,50*scale);
    for j=1:length(current_scan)
        ind = find(strcmp({beacons.address},current_scan(j).address));
        x = beacons(ind).position(1)+20;
        y = beacons(ind).position(2)+20;
        r = (-current_scan(j).value)*0.1;
        im = add_centroid(im,x*scale,y*scale,r*scale,2*scale);
    end
    imshow(im,[]);
    pause(0.1);
end
nn = nn + 1
end
aa = aa + 1
end