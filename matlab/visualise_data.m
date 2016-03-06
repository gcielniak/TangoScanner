path = 'H:\gcielniak\Google Drive (work)\beacon leicester\';
file_name = [path, 'wifi_bt_log_20151104T153153.0053.txt'];

%parameters
resolution = 0.1; % resolution
kernel_width = 1.0; % kernel width

%read data
scan = read_log(file_name);
%scan = read_log_remap(file_name,ref_file_name);

%filter AP addresses
%scan = group_ap_address(scan);

%assign the same address to all readings
%good for generating the overall signal map
%scan = assign_single_address(scan);

%%
address_unique = unique({scan.address});
address_unique = address_unique(1+25:25+25);

for i=1:size(address_unique,2)
    ss = get_ss_map(scan,address_unique{i}, kernel_width, resolution);
    ind = find(not(cellfun('isempty', strfind({scan.address},address_unique{i}))));
    subplot(ceil(sqrt(size(address_unique,2))),ceil(sqrt(size(address_unique,2))),i); imshow(flipud(ss'),[-120 -50]);colormap('jet');title(sprintf('%s - %s',scan(ind(1)).name,address_unique{i}));%colorbar;
end

