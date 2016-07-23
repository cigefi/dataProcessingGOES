function [date] = date2double(sDate)
    date =zeros(1,3);
    sDate = java.lang.String(sDate);
    sDate = sDate.split('-');
    date(1) = str2double(char(sDate(1)));
    date(2) = str2double(char(sDate(2)));
    date(3) = str2double(char(sDate(3)));
end