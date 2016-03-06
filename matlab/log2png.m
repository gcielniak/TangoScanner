%generate figures

path = 'H:\gcielniak\Google Drive (work)\beacon_logs\Bestways Feb 2016\';

file_name = dir([path,'wifi_bt_log_*.txt']);

for i=1:length(file_name)
    fprintf('%s\n',file_name(i).name);
    data = read_log([path, file_name(i).name]);
    pos = [data.position];
    plot(pos(1,:),pos(2,:));title(sprintf('%s',strrep(file_name(i).name,'_','\_')));
    print([path, strrep(file_name(i).name,'.txt','.png')],'-dpng');
    pause(1);
end

