function write_log(scan, file_name)

fid = fopen(file_name,'wt+');

if (fid == -1)
    return
end

fprintf(fid, '%s', scan.sync_line);
fprintf(fid, '\n');

for i=1:length(scan)
   fprintf(fid, '%s: ', scan(i).type);
   fprintf(fid, 't=%ld ', scan(i).timestamp);
   fprintf(fid, 'n="%s" ', scan(i).name);
   fprintf(fid, 'a=%s ', scan(i).address);
   fprintf(fid, 'v=%.1f ', scan(i).value);
   fprintf(fid, 'p=%.18f %.18f %.18f ', scan(i).position);
   fprintf(fid, 'r=%.18f %.18f %.18f %.18f ', scan(i).rotation);
   fprintf(fid, 'u=%s\n', scan(i).uuid);
end

fclose(fid);
