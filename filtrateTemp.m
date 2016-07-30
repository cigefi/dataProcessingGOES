function[data,data2] = filtrateTemp(data,temp,err)
    if nargin < 3
        err = 10;
    end
    data(data<(temp-err)) = 0;
    data(data>(temp+err)) = 0;
    data2 = nlfilter(data,[3 3],'hasNeighbors');
    try
        clear data
    catch
    end
    data = NaN;
    %data2 = nlfilter(data,[3 3],@(b) b(5)*all(sum(sum([1 2 3 4 6 7 8 9])) > 0));
%     data2 = data(:,:);
%     for i=1:length(data(:,1))
%         for j=1:length(data(1,:))
%             temp = data(:,:);
%             if data(i,j)~=0
%                 fr = i;
%                 lr = i;
%                 fc = j;
%                 lc = j;
%                 if i+1 <= length(data(:,1))
%                     lr = i+1;
%                 end
%                 if j+1 <= length(data(1,:))
%                     lc = j+1;
%                 end
%                 if i-1>=1
%                     fr = i-1;
%                 end
%                 if j-1>=1
%                     fc = j-1;
%                 end
%                 temp(i,j) = 0;
%                 cof = temp(fr:lr,fc:lc);
%                 if ~hasNeighbors(cof)
%                     %data2(i,j) = data(i,j);
%                     data2(i,j) = 0;
%                 end
%             end
%         end
%         disp(char(strcat('POS(',num2str(i),')')));
%     end
end