function date = getDate(stamp)
    months = [31,28,31,30,31,30,31,31,30,31,30,31];
    day = str2num(stamp(end-2:end));
    month = '';
    year = stamp(2:3);
    switch(stamp(1))
        case '0'
            year = strcat('19',year);
        case '1'
            year = strcat('20',year);
    end
    if day > 334
        month = '12';
        tmp = day;
        for i=1:11
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 304
        month = '11';
        tmp = day;
        for i=1:10
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 273
        month = '10';
        tmp = day;
        for i=1:9
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 243
        month = '9';
        tmp = day;
        for i=1:8
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 212
        month = '8';
        tmp = day;
        for i=1:7
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 181
        month = '7';
        tmp = day;
        for i=1:6
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 151
        month = '6';
        tmp = day;
        for i=1:5
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 120
        month = '5';
        tmp = day;
        for i=1:4
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 90
        month = '4';
        tmp = day;
        for i=1:3
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
    elseif day > 59
        month = '3';
        tmp = day;
        for i=1:2
            tmp = tmp - months(i);
        end
        if leapyear(str2num(year))
            tmp =  tmp -1;
        end
        day = tmp;
        
    elseif day > 31
        month = '2';
        day = day - months(1);
    else
        month = '1';
    end
    if day < 1
       switch(month)
           case '3'
               day = '29';
               month = '2';
           case '4'
               day = '31';
               month = '3';
           case '5'
               day = '30';
               month = '4';
           case '6'
               day = '31';
               month = '5';
           case '7'
               day = '30';
               month = '6';
           case '8'
               day = '31';
               month = '7';
           case '9'
               day = '31';
               month = '8';
           case '10'
               day = '30';
               month = '9';
           case '11'
               day = '31';
               month = '10';
           case '12'
               day = '30';
               month = '11';
       end
    end
    date = strcat(month,'-',num2str(day),'-',year);
end