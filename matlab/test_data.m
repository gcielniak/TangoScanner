path = 'H:\gcielniak\Google Drive (work)\beacon_logs\';
file_name = [path, 'wifi_bt_log_20150930T171059.0059.txt'];
ref_file_name = [path, 'wifi_bt_log_20150930T171052.0052.txt'];

%'wifi_bt_log_20150930T170914.0014.txt'
%'wifi_bt_log_20150930T170909.0009.txt'

%'wifi_bt_log_20150930T171059.0059.txt'
%'wifi_bt_log_20150930T171052.0052.txt'

%'wifi_bt_log_20150930T171353.0053.txt'
%'wifi_bt_log_20150930T171345.0045.txt'

%parameters
resolution = 0.1; % resolution
kernel_width = 2; % kernel width

%read data
%scan = read_log(ref_file_name);
scan = read_log_remap(file_name,ref_file_name);

%filter AP addresses
%scan = group_ap_address(scan);

%assign the same address to all readings
%good for generating the overall signal map
%scan = assign_single_address(scan);

address_unique = unique({scan.address});

for i=1:size(address_unique,2)
    ss = get_ss_map(scan,address_unique{i}, resolution, kernel_width);
    ind = find(not(cellfun('isempty', strfind({scan.address},address_unique{i}))));
    subplot(ceil(sqrt(size(address_unique,2))),ceil(sqrt(size(address_unique,2))),i); imshow(flipud(ss'),[min([scan.value]) max([scan.value])]);colormap('jet');colorbar;title(sprintf('%s - %s',scan(ind(1)).name,address_unique{i}));
end
