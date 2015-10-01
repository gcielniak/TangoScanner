function [ss, cnf] = get_ss_map(scan, address, resolution, kernel_width)

pos = [scan.position];
address_unique = unique({scan.address});

min_v = min([scan.value]);
min_x = min(pos(1,:));
max_x = max(pos(1,:));
min_y = min(pos(2,:));
max_y = max(pos(2,:));

width = round((max_x-min_x)/resolution);
height = round((max_y-min_y)/resolution);

ind = find(not(cellfun('isempty', strfind({scan.address},address))));

ss = zeros(width,height);
cnf = ones(width,height);
xx = pos(1,ind);
yy = pos(2,ind);
vv = [scan(ind).value];

for ii=1:size(ss,1)
    for jj=1:size(ss,2)
        x_loc = (ii-1)*resolution+min_x;
        y_loc = (jj-1)*resolution+min_y;
        dx = (x_loc-xx);
        dy = (y_loc-yy);
        d = sqrt(dx.*dx+dy.*dy);
        w = zeros(1,length(d));
        ind_d = find(d < kernel_width);
        if ~isempty(ind_d)
%            w(ind_d) = 1;%uniform kernel
            w(ind_d) = 1-d(ind_d)/kernel_width;%triangular
            w=w/sum(w);
            ss(ii,jj) = sum(w.*vv);
        else
            ss(ii,jj) = min_v;
        end
        cnf(ii,jj) = cnf(ii,jj) + length(ind_d);
    end
end
