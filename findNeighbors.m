function [MCS,data] = findNeighbors(data,coords,cofIndex,MCS)
    if nargin < 4
        MCS = [];
    end
    size = 0;
    nuclei = coords;
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
%     cofIndex = cell(lr-fr+1,lc-fc+1);
%     for h=1:length(cofIndex(:,1))
%         for g=1:length(cofIndex(1,:))
%             if h == 1
%                 cofIndex{h,g} = [fr,
%             cofIndex{h,g} = [fr*(h-1)-lr*(g-2),fc*(h-1)-lc*(g-2)];
%         end
%     end
    cofIndexTmp = cofIndex(fr:lr,fc:lc);
    cof = data(fr:lr,fc:lc);
    for h=1:length(cof(:,1))
        for g=1:length(cof(1,:))
            if cof(h,g) > 0
                nPos = cofIndexTmp{h,g};
                MCS = cat(1,MCS,nPos);
                data(nPos(1),nPos(2)) = 0;
                [MCS,data] = findNeighbors(data,nPos,cofIndex,MCS);
%                 if sum(nPos ~= coords)
%                     MCS = cat(1,MCS,nPos);
%                     data(nPos(1),nPos(2)) = 0;
%                     [MCS,data] = findNeighbors(data,nPos,cofIndex,MCS);
%                 end
            end
        end
    end
end