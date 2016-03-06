%generate figures

path = 'H:\gcielniak\Google Drive (work)\beacon_logs\Bestways Feb 2016\';

file_name = dir([path,'wifi_bt_log_*.txt']);

map = imresize(imread([path, 'Bestways_map.png']),0.5);
scale = size(map,2)/95.56;

file_name = dir([path,'wifi_bt_log_*.txt']);

offset = [57 20.0 0]';
theta = -0.03;

beacons = read_beacon_settings([path, 'beacon_settings.txt']);

for i=1:1%length(file_name)
    fprintf('%s\n',file_name(i).name);
    data = read_log([path, file_name(i).name]);
    pos = [data.position];
    pos_n = pos;
    %rotation
    pos_n(1,:) = pos(1,:)*cos(theta) - pos(2,:)*sin(theta);
    pos_n(2,:) = pos(2,:)*cos(theta) + pos(1,:)*sin(theta);
    %offset
    offset_m = repmat(offset,1,length(pos));
    pos = pos_n + offset_m;
    %convert
    for j=1:length(pos)
        data(j).position = pos(:,j);
    end
    %write_log(data,[path, strrep(file_name,'.txt','_corr.txt')]);

    %visualise
    subplot(1,2,1); imshow(imrotate(map,90));
    hold on;
    subplot(1,2,1); plot(pos(1,:)*scale,size(map,2)-pos(2,:)*scale);
    hold off;
    subplot(1,2,2); plot(pos(1,:),pos(2,:));
    axis equal;
    hold on;
    for j=1:length(beacons)
        rectangle('Position',[beacons(j).position(1) beacons(j).position(2) 1 1],'Curvature',[1 1],'FaceColor',[.5 .5 .5],'EdgeColor','none');
    end
    axis([0 80 0 100]);
    hold off
end


