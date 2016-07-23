function [neighbors,elements] = neighborsClassification(coords,elements)
    neighbors = [];
    for i =1:length(elements(:,1))
        if elements(i,:) ~= coords
            ce = elements(i,:);
            if (ce(1)+1==coords(1)+1)&&(ce(2)+1==coords(2)+1)       %3x3
                neighbors = cat(1,neighbors,ce); 
            elseif (ce(1)-1==coords(1)-1)&&(ce(1)-1==coords(1)-1)   %1x1
                neighbors = cat(1,neighbors,ce); 
            elseif (ce(1)-1==coords(1)-1)&&(ce(2)==coords(2))       %1x2
                neighbors = cat(1,neighbors,ce); 
            elseif (ce(1)-1==coords(1)-1)&&(ce(2)+1==coords(2)+1)   %1x3
                neighbors = cat(1,neighbors,ce); 
            elseif (ce(1)+1==coords(1)+1)&&(ce(2)==coords(2))       %3x2
                neighbors = cat(1,neighbors,ce); 
            elseif (ce(1)+1==coords(1)+1)&&(ce(2)-1==coords(2)-1)   %3x1
                neighbors = cat(1,neighbors,ce); 
            elseif (ce(1)==coords(1))&&(ce(2)-1==coords(2)-1)       %2x1
                neighbors = cat(1,neighbors,ce); 
            elseif (ce(1)==coords(1))&&(ce(2)+1==coords(2)+1)       %2x3
                neighbors = cat(1,neighbors,ce); 
            end
        else
            elements(i,:) = [0,0];
        end
    end
end