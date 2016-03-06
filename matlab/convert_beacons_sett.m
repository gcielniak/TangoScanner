%beacon location from exel
%variable name has to be beacon_layout

fid = fopen('beacon_settings.txt','w+');

if fid == -1
    fprintf('Could not open the specified file.');
    return;
end
    
fprintf(fid, '#set beacon location in meters\n');
for i=1:size(beacon_layout,1)
    label = beacon_layout{i,3};
    beacon_label = beacon_layout{i,1};
    uuid = beacon_layout{i,4};
    uuid([9 14 19 24]) = [];
    maj_min = sprintf('%04X%04X',beacon_layout{i,5},beacon_layout{i,6});
    uuid = upper([uuid, maj_min]);
    address = beacon_layout{i,7};
    x = beacon_layout{i,8}/100;
    y = beacon_layout{i,9}/100;
    fprintf(fid, 'u=%s p=%.2f %.2f 0.00 l=%s b=%s a=%s\n',uuid,x,y,label,beacon_label,address);
end
fclose(fid);