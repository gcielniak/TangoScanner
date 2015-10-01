function scan_out = assign_single_address(scan_in)
scan_out = scan_in;

for i = 1:length(scan_out)
    scan_out(i).address = 'XX:XX:XX:XX:XX:XX';
end
