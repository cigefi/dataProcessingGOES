function [MCS,data] = findNeighbors(data,coords,cofIndex,MCS)
    if nargin < 4
        MCS = [];
    end
    if isempty(data)
        return;
    end
    if length(coords)<2
        [coords(1),coords(2)] = ind2sub(size(data),coords);
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
            if cof(h,g) > 0
                nPos = cofIndexTmp{h,g};
                MCS = cat(1,MCS,nPos);
                matri = reshape([cofIndex{:}],2,[])';
                [~, ind]=ismember(matri,nPos,'rows');
                i = findIndex2(ind);
                if i~=-1
                    data(i) = 0;
                    [MCS,data] = findNeighbors(data,i,cofIndex,MCS);
                end
                %data(nPos(1),nPos(2)) = 0;
                %[MCS,data] = findNeighbors(data,nPos,cofIndex,MCS);
            end
        end
    end
end

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