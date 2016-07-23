function [timestamp] = getTimestamp(timeDate)
    hour = timeDate{2};
    timestamp = char(strcat(timeDate{1},{' -- '},strrep(hour,':','.')));
end