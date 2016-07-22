function [res] = hasNeighbors(data)
    if sum(sum(data>0))>1
        res = data(5);
    else
        res = 0;
    end
end