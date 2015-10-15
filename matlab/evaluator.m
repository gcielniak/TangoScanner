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
        
    %select max
    [v, max_index] = max([current_scan.value]);
    
    %select the most frequent in N frames
    b_count = zeros(size(beacons));
    
    %update the list of N last detections
    b_ind = find(strcmp({beacons.address},current_scan(max_index).address));
    past_readings = [past_readings b_ind];
    if length(past_readings) > N
        past_readings(1) = [];
    end
       
    for j=1:length(past_readings)
        b_count(past_readings(j)) = b_count(past_readings(j)) + 1;
    end
    
    [v, max_b] = find(b_count,1);    
%    output(k,1) = find(strcmp({beacons.address},current_scan(max_index).address));   
    output(k,1) = max_b;   
    output(k,3) = sqrt(sum((beacons(output(k,1)).position-beacons(output(k,2)).position).^2));
    k = k + 1;
end
avg_error = sum(output(:,3))/size(output,1);
100*length(find(output(:,3)==0))/size(output,1);
aerr(nn,aa) = avg_error;
aper(nn,aa) = 100*length(find(output(:,3)==0))/size(output,1);
subplot(2,1,1); plot(output(:,1:2));
subplot(2,1,2); plot(output(:,3));
nn = nn + 1
end
aa = aa + 1
end