function scan = read_log_remap(file_name, ref_file_name)

fid = fopen(file_name);
t = fgetl(fid);
fclose(fid);
fid = fopen(ref_file_name);
t_ref = fgetl(fid);
fclose(fid);

t = str2num(t(22:end));
t_ref = str2num(t_ref(22:end));
dt = t-t_ref;

scan = read_log(file_name);
scan_ref = read_log(ref_file_name);

ts = [scan.timestamp];
ts_ref = [scan_ref.timestamp];

ts = ts-ts(1)+dt+ts_ref(1);
[~, xmap] = min( abs(bsxfun(@minus, ts, ts_ref')) );
pos = [scan_ref(xmap).position];
for i=1:length(scan)
    scan(i).position = pos(:,i);
end


