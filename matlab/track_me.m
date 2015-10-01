path = 'H:\gcielniak\Google Drive (work)\beacon_logs\';
file_name = [path, 'wifi_bt_log_20151001T092647.0047.txt'];

%'wifi_bt_log_20150930T170914.0014.txt'
%'wifi_bt_log_20150930T170909.0009.txt'

%'wifi_bt_log_20150930T171059.0059.txt'
%'wifi_bt_log_20150930T171052.0052.txt'

%'wifi_bt_log_20150930T171353.0053.txt'
%'wifi_bt_log_20150930T171345.0045.txt'

%parameters
resolution = 0.5; % resolution
kernel_width = 2; % kernel width

%read data
scan = read_log(file_name);
%scan = read_log_remap(file_name,ref_file_name);

%filter AP addresses
%scan = group_ap_address(scan);

%assign the same address to all readings
%good for generating the overall signal map
%scan = assign_single_address(scan);

address_unique = unique({scan.address});
address_unique = address_unique(1:8);

ss = [];
cnf = [];

for i=1:size(address_unique,2)
    [ss{i}, cnf{i}] = get_ss_map(scan,address_unique{i}, resolution, kernel_width);
    cnf{i} = cnf{i}/sum(cnf{i}(:));
    ind = find(not(cellfun('isempty', strfind({scan.address},address_unique{i}))));
%    subplot(ceil(sqrt(size(address_unique,2))),ceil(sqrt(size(address_unique,2))),i); imshow(flipud(ss{i}'),[-100 -50]);colormap('jet');colorbar;title(sprintf('%s - %s',scan(ind(1)).name,address_unique{i}));
end

%%
file_name_trck = [path, 'wifi_bt_log_20151001T092810.0010.txt'];
scan_trck = read_log(file_name_trck);

pos = [scan_trck.position];
min_x = min(pos(1,:));
max_x = max(pos(1,:));
min_y = min(pos(2,:));
max_y = max(pos(2,:));


%%
lik = [];
for i = 1:length(scan_trck)
    ind = find(not(cellfun('isempty', strfind(address_unique,scan_trck(i).address))));
    if ~isempty(ind)
        lik{i} = 50 - abs(scan_trck(i).value-ss{ind});
        lik{i} = lik{i}/sum(lik{i}(:));
        i
    else
        lik{i} = ones(size(ss{1}))./length(ss{1}(:));
    end
end

%%
w = 10;

lik_slice = [];

for i=1:length(address_unique)
    lik_slice{i} = ones(size(ss{1}))./length(ss{1}(:));
end

for i = 1:length(lik)
    ind = find(not(cellfun('isempty', strfind(address_unique,scan_trck(i).address))));
    if isempty(ind)
        continue
    end
    lik_slice{ind} = lik{i};
    est = ones(size(lik{1}));
    for j = 1:length(lik_slice)
        est = est.*lik{i+j};
        est = est./sum(est(:));
    end
    imshow(flipud(est'),[]);
    hold on;
    i_loc = round((pos(1,i)-min_x)/resolution) + 1;
    j_loc = size(ss{1},2) - round((pos(2,i)-min_y)/resolution) + 1;
    plot(i_loc, j_loc, 'r.');
    hold off;    
    pause(0.01);
end

