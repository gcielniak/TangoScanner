path = 'H:\gcielniak\Downloads\wifi_bt_log_20150927T210702.0002.txt';

fid = fopen(path);

fgetl(fid);

i = 1;
a = [];
v = [];

while ~feof(fid)
   fscanf(fid, '%s', 1);
   fscanf(fid, ' t=%d', 1);
   fscanf(fid, ' n=%s', 1);
   a{i} = fscanf(fid, ' a=%s', 1);
   v{i} = fscanf(fid, ' v=%d', 1);
   fgetl(fid);
   i = i + 1;
end

fclose(fid);

ind = find(not(cellfun('isempty', strfind(a,'0C:F3:EE:00:4D:57'))));
plot([v{ind}],'b')
hold on;
ind = find(not(cellfun('isempty', strfind(a,'0C:F3:EE:00:2D:AC'))));
plot([v{ind}],'r')
hold off;
