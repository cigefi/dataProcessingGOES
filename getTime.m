function time = getTime(stamp)
    if length(stamp) < 6
       zeros = '';
       for i =1:6-length(stamp)
           zeros = strcat(zeros,'0');
       end
       stamp = strcat(zeros,stamp);
    end
    time = strcat(stamp(1:2),':',stamp(3:4),':',stamp(5:6));
end