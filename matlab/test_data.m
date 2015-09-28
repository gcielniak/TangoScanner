path = 'H:\gcielniak\Downloads\wifi_bt_log_20150928T173444.0044.txt';
%path = 'H:\gcielniak\Downloads\wifi_bt_log_20150928T173202.0002.txt';

fid = fopen(path,'rt');

fgetl(fid);

i = 1;
a = [];
n = [];
v = [];
pos = [];

while ~feof(fid)
   fscanf(fid, '%s', 1);
   fscanf(fid, ' t=%d', 1);
   nn = textscan(fid, ' n=%q');
   n{i} = nn{1}{1};   
   a{i} = fscanf(fid, ' a=%s', 1);
   v{i} = fscanf(fid, ' v=%f', 1);
   pos{i} = fscanf(fid, ' p=%f %f %f',3);
   fgetl(fid);
   i = i + 1;
end

fclose(fid);

xyz = [pos{:}];
uni_labels = unique(a);

min_v = min([v{:}]);
max_v = max([v{:}]);
min_x = min(xyz(1,:));
max_x = max(xyz(1,:));
min_y = min(xyz(2,:));
max_y = max(xyz(2,:));
res = 0.05;
d_t = 0.5;

width = round((max_x-min_x)/res);
height = round((max_y-min_y)/res);

for i=1:size(uni_labels,2)
ind = find(not(cellfun('isempty', strfind(a,uni_labels{i}))));
ss = zeros(width,height);
xx = xyz(1,ind);
yy = xyz(2,ind);
vv = [v{ind}];

for ii=1:size(ss,1)
    for jj=1:size(ss,2)
        x_loc = (ii-1)*res+min_x;
        y_loc = (jj-1)*res+min_y;
        dx = (x_loc-xx);
        dy = (y_loc-yy);
        d = sqrt(dx.*dx+dy.*dy);
        w = zeros(1,length(d));
        ind_d = find(d < d_t);
        if length(ind_d)
%            w(ind_d) = 1;%uniform kernel
            w(ind_d) = 1-d(ind_d)/d_t;%triangular
            w=w/sum(w);
            ss(ii,jj) = sum(w.*vv);
        else
            ss(ii,jj) = min_v;
        end
    end
end

subplot(ceil(sqrt(size(uni_labels,2))),ceil(sqrt(size(uni_labels,2))),i); imshow(flipud(ss'),[min_v max_v]);colormap('jet');colorbar;title(sprintf('%s - %s',n{ind(1)},uni_labels{i}));
end
