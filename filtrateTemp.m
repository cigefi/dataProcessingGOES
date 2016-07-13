function[data,data2] = filtrateTemp(data,temp,err)
    data(data<(temp-err)) = 0;
    data(data>(temp+err)) = 0;
    for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            temp = data(:,:);
            if data(i,j)~=0
                fr = i;
                lr = i;
                fc = j;
                lc = j;
                if i+1 <= length(data(:,1))
                    lr = i+1;
                end
                if j+1 <= length(data(1,:))
                    lc = j+1;
                end
                if i-1>=1
                    fr = i-1;
                end
                if j-1>=1
                    fc = j-1;
                end
                temp(i,j) = 0;
                cof = temp(fr:lr,fc:lc);
                if ~hasNeighbors(cof)%~hasNeighbors(cof)
                    %data2(i,j) = data(i,j);
                    data2(i,j) = 0;
                end
            end
        end
    end
end

function [res] = hasNeighbors(data)
    if sum(data~=0)>0
        res = 1;
    else
        res = 0;
    end
end