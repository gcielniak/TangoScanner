path = 'H:\gcielniak\Google Drive (work)\beacon_logs\';
file_name = [path, 'wifi_bt_log_20151012T170402.0002.txt'];
ref_file_name = [path, 'wifi_bt_log_20150930T171052.0052.txt'];
beacon_file_name = [path, 'beacon_settings.txt'];

beacons = read_beacon_settings(beacon_file_name);

%parameters
resolution = 0.05; % resolution
kernel_width = 0.2; % kernel width

%read data
scan = read_log(file_name);
%scan = read_log_remap(file_name,ref_file_name);

%filter AP addresses
%scan = group_ap_address(scan);

%assign the same address to all readings
%good for generating the overall signal map
scan = assign_single_address(scan);

address_unique = unique({scan.address});
%address_unique = address_unique(4);

for i=1:size(address_unique,2)
    ss = get_ss_map(scan,address_unique{i}, kernel_width,resolution);
    ind = find(not(cellfun('isempty', strfind({scan.address},address_unique{i}))));
    subplot(ceil(sqrt(size(address_unique,2))),ceil(sqrt(size(address_unique,2))),i); imshow(flipud(ss'),[-120 -40]);colormap('jet');colorbar;title(sprintf('%s - %s',scan(ind(1)).name,address_unique{i}));
end

%%
beacons = read_beacon_settings(beacon_file_name);

floor_plan = imresize(imread([path, 'floor_plan.png']),0.5);
imshow(ones(size(floor_plan)));

params = to_image_coor(scan,beacons,resolution);

scale = 53/2;
x_offset = 2.6*scale;
y_offset = 16*scale;
w = .4*scale;
pos = [beacons.position]*scale;
hold on;

ss = ss_map(scan,address_unique{1}, kernel_width,resolution);
ss = imresize(ss,2.65/2);
ss = padarray(ss,[0 0]);
imshow(ss,[-120 -60]);colormap('jet')

for i=1:size(beacons,2)
    rectangle('Position', [pos(1,i)+x_offset -pos(2,i)+y_offset w w], 'Curvature', [1 1], 'EdgeColor', 'none','FaceColor', [0 1 0]); 
end

pos = [scan.position]*scale;
plot(pos(2,:)+x_offset,pos(1,:)+y_offset,'r');

h = imshow(floor_plan);
alpha = ones([size(floor_plan,1) size(floor_plan,2)])*0.1;
set(h,'AlphaData',alpha);
hold off;

