%beacon location from exel
load('D:\Google Drive\beacon_logs\beacons_leicester_test.mat');

fid = fopen('D:\Google Drive\beacon_logs\beacon_settings.txt','w+');

if fid == -1
    fprintf('Could not open the specified file.');
    return;
end
    
fprintf(fid, '#set beacon location in meters\n');
for i=1:size(beacon_layout,1)
    label = beacon_layout{i,1};
    beacon_label = beacon_layout{i,2};
    uuid = beacon_layout{i,3};
    uuid([9 14 19 24]) = [];
    maj_min = sprintf('%04X%04X',beacon_layout{i,4},beacon_layout{i,5});
    uuid = upper([uuid, maj_min]);
    x = beacon_layout{i,6}/100;
    y = beacon_layout{i,7}/100;
    fprintf(fid, 'u=%s p=%.2f %.2f 0.00 l=%s b=%s\n',uuid,x,y,label,beacon_label);
end
fclose(fid);