function scan = get_scan(data, time_interval, alpha)

scan{1}{1} = data(1);

for i = 2:length(data)
    curr_t = data(i).timestamp;

    %assign prev scan to the new one
    scan{i} = scan{i-1};
    
    %update/add the new reading
    s = [scan{i}{:}];
    add = {s.address};
    ind = find(strcmp(add,data(i).address));
    if ind
        old_value = scan{i}{ind}.value;
        scan{i}{ind} = data(i);
        scan{i}{ind}.value = scan{i}{ind}.value*alpha + old_value*(1-alpha);
    else
        scan{i}{length(scan{i})+1} = data(i);        
    end
        
    %remove old readings  
    s = [scan{i}{:}];
    dt = curr_t - [s.timestamp];
    ind = find(dt > time_interval*1000000);
    if ~isempty(ind)
        scan{i}(ind) = [];
        scan{i}(~cellfun('isempty',scan{i}));
    end
end