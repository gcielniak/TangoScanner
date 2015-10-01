function scan_out = read_log_remap(file_name, ref_file_name)

fid = fopen(path1);
t1 = fgetl(fid);
fclose(fid);
fid = fopen(path2);
t2 = fgetl(fid);
fclose(fid);

t1 = str2num(t1(22:end));
t2 = str2num(t2(22:end));
dt = t2-t1;

scan_1 = read_log(path1);
scan_2 = read_log(path2);

ts1 = [scan_1.timestamp];
ts2 = [scan_2.timestamp];

ts2 = ts2-ts2(1)+dt+ts1(1);
[~, xmap] = min( abs(bsxfun(@minus, ts2, ts1')) );
new_position = [scan_1(xmap).position];


