%path = 'H:\gcielniak\Downloads\wifi_bt_log_20150928T173444.0044.txt';
%path = 'H:\gcielniak\Downloads\wifi_bt_log_20150928T173202.0002.txt';
path = 'D:\Google Drive\beacon_logs\wifi_bt_log_20150929T105334.0034.txt';

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

for i=1:size(address_unique,2)
    ss = get_ss_map(scan,address_unique{i}, resolution, kernel_width);
    ind = find(not(cellfun('isempty', strfind({scan.address},address_unique{i}))));
    subplot(ceil(sqrt(size(address_unique,2))),ceil(sqrt(size(address_unique,2))),i); imshow(flipud(ss'),[min([scan.value]) max([scan.value])]);colormap('jet');colorbar;title(sprintf('%s - %s',scan(ind(1)).name,address_unique{i}));
end
