function scan_out = group_ap_address(scan_in)

scan_out = scan_in;

address_unique = unique({scan_in.address});

address_int = zeros(1,length(address_unique));

for i=1:length(address_unique)
    address_int(i) = hex2dec(strrep(address_unique{i},':',''));
end

address_sorted = sort(address_int);
sort_ind = find(diff(address_sorted)==1);

for i=sort_ind
    s1 = sprintf('%012X',address_sorted(i));
    s1 = [s1(1:2),':',s1(3:4),':',s1(5:6),':',s1(7:8),':',s1(9:10),':',s1(11:12)];
    s2 = sprintf('%012X',address_sorted(i+1));
    s2 = [s2(1:2),':',s2(3:4),':',s2(5:6),':',s2(7:8),':',s2(9:10),':',s2(11:12)];
    sort_ind = find(not(cellfun('isempty', strfind({scan_in.address},s2))));
    for j = sort_ind
        scan_out(j).address = s1;        
    end
    address_sorted(i+1) = address_sorted(i);
end

