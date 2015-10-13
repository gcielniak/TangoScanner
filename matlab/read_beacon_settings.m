function beacons = read_beacon_settings(file_name)

fid = fopen(file_name,'rt');

if (fid == -1)
    return
end

fgetl(fid);

beacons = [];
i = 1;

while ~feof(fid)
   beacons(i).address = fscanf(fid, 'a=%s', 1);
   beacons(i).position = fscanf(fid, ' p=%f %f %f',3);
   fgetl(fid);
   i = i + 1;
end

fclose(fid);
