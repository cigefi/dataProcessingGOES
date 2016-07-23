function [MCS,data] = findNeighbors2(data,coords,cofIndex,MCS)
    if nargin < 4
        MCS = [];
    end
    if isempty(data)
        return;
    end
    i = coords(1);
    j = coords(2);
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
    cofIndexTmp = cofIndex(fr:lr,fc:lc);
    cof = data(fr:lr,fc:lc);
    for h=1:length(cof(:,1))
        for g=1:length(cof(1,:))
            if ~cellfun(@isempty,cof(h,g)) > 0
                nPos = cofIndexTmp{h,g};
                MCS = cat(1,MCS,nPos);
                data{nPos(1),nPos(2)}= [];
                [MCS,data] = findNeighbors2(data,nPos,cofIndex,MCS);
            end
        end
    end
end