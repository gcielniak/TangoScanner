function scan = read_log(file_name)

fid = fopen(file_name,'rt');

if (fid == -1)
    return
end

%this line will be important for synchronisation
fgetl(fid);

scan = [];
i = 1;

while ~feof(fid)
   scan(i).type = fscanf(fid, '%s', 1);
   scan(i).type = scan(i).type(1:2);
   scan(i).timestamp = fscanf(fid, ' t=%d', 1);
   name = textscan(fid, ' n=%q');
   scan(i).name = name{1}{1};   
   scan(i).address = fscanf(fid, ' a=%s', 1);
   scan(i).value = fscanf(fid, ' v=%f', 1);
   scan(i).position = fscanf(fid, ' p=%f %f %f',3);
   scan(i).rotation = fscanf(fid, ' r=%f %f %f %f',4);
   fgetl(fid);
   i = i + 1;
end

fclose(fid);
