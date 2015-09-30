path = 'H:\gcielniak\Google Drive (work)\beacon_logs\';
path = [path, 'wifi_bt_log_20150930T170909.0009.txt'];
%path = path + 'wifi_bt_log_20150930T170914.0014.txt'
%path = path + 'wifi_bt_log_20150930T171052.0052.txt'
%path = path + 'wifi_bt_log_20150930T171059.0059.txt'
%path = path + 'wifi_bt_log_20150930T171345.0045.txt'
%path = path + 'wifi_bt_log_20150930T171353.0053.txt'

%parameters
resolution = 0.1; % resolution
kernel_width = 0.5; % kernel width

%read data
scan = read_log(path);

%filter AP addresses
%scan = group_ap_address(scan);

%assign the same address to all readings
%good for generating the overall signal map
%scan = assign_single_address(scan);

address_unique = unique({scan.address});

hold on;

for i=1:size(address_unique,2)
    ind = find(not(cellfun('isempty', strfind({scan.address},address_unique{i}))));
    plot([scan(ind).value]);
end
hold off;