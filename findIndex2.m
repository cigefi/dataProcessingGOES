function [i] = findIndex2(index)
    if sum(sum(index>0))>1
       i = -1; 
       return;
    end
    for j=1:length(index)
        if index(j)
            i = j;
            return
        end
    end
end