function [bPos,nE] = borderDetection(data)
    bPos = zeros(4,1);
    nE = zeros(4,1);
    for i=1:length(data(1,:)) % North border
        if data(1,i) > 0
            bPos(1) = 1;
            nE(1) = nE(1)+1;
        end
    end
    for i=1:length(data(:,end)) % East border
        if data(:,end) > 0
            bPos(2) = 1;
            nE(2) = nE(2)+1;
        end
    end
    for i=1:length(data(end,:)) % South border
        if data(end,i) > 0
            bPos(3) = 1;
            nE(3) = nE(3)+1;
        end
    end
    for i=1:length(data(:,1)) % West border
        if data(:,1) > 0
            bPos(4) = 1;
            nE(4) = nE(4)+1;
        end
    end
end