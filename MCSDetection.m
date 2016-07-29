function MCSDetection(dirName,extra)
    if nargin < 1
        error('MCSDetection: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    vars = [];
    tempVec = 215;
    toleVec = 25;
    var2Read = 'IR4'; % Default value IR4
    switch nargin
        case 2 
            if ~mod(length(extra),2)
                tmp = reshape(extra,2,[])'; 
                for i=1:1:length(tmp(:,1))
                    switch lower(char(tmp{i,1}))
                        case 'temp'
                            tempVec = tmp{i,2};
                        case 'var2read'
                            vars = tmp{i,2};
                            if length(vars) < 2
                                var2Read = vars{1};
                            end
                    end
                end
            end
    end
    if length(tempVec) ~= length(toleVec)
        error('MCSDetection: the lengths of temps and tolerances, must be the same');
    end
    dirData = dir(char(dirName(1)));  % Get the data for the current directory
    path = java.lang.String(dirName(1));
    if(path.charAt(path.length-1) ~= '/')
        path = path.concat('/');
    end
    
    if(length(dirName)>1)
        savePath = java.lang.String(dirName(2));
        if(length(dirName)>2)
            logPath = java.lang.String(dirName(3));
        else
            logPath = java.lang.String(dirName(2));
        end
    else
        savePath = java.lang.String(dirName(1));
        logPath = java.lang.String(dirName(1));
    end
    
	if(savePath.charAt(savePath.length-1) ~= '/')
		savePath = savePath.concat('/');
	end
    if(logPath.charAt(logPath.length-1) ~= '/')
        logPath = logPath.concat('/');
    end
    if ~exist(char(savePath),'dir')
        mkdir(char(savePath));
    end
    if ~exist(char(logPath),'dir')
        mkdir(char(logPath));
    end

    out = [];
    cofIndex = [];
    con = 1;
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        try
            fsplit = fileT.split('-');
            name = fsplit(1).substring(fsplit(1).lastIndexOf('/')+1).concat('.mat');
            nameTS = strcat('tl',var2Read,'-',char(fsplit(2)),'-',char(fsplit(3)));
%             name = fileT.substring(fileT.lastIndexOf('/')+1),fileT.lastIndexOf('-')).concat('.mat');
%             nameTS = strcat('tl',var2Read,char(fileT.substring(fileT.lastIndexOf('-'))));
            nName = fileT.substring(fileT.lastIndexOf('/')+1);
        catch
            try
                name = fileT.substring(fileT.lastIndexOf('/')+1).concat('.mat');
                nameTS = strcat('tl',var2Read,'.mat');
                nName = name;
            catch
                continue;
            end
        end
        if(name.equalsIgnoreCase(strcat(var2Read,'.mat')))
            try
                tmp = load(char(fileT));
                data = tmp.(var2Read)(:,:,:);
                try
                    clear tmp;
                catch
                end
                tmp = load(char(path.concat(nameTS)));
                timeStamp = tmp.(strcat('tl',var2Read))(:,:);
                try
                    clear tmp;
                catch
                end
                for z=1:length(data(1,1,:))
                    if isempty(cofIndex)
                        cofIndex = generateIndexMatrix(length(data(:,1,1)),length(data(1,:,1)));
                    else
                        if length(data(:,1,1))~=length(cofIndex(:,1)) || length(data(1,:,1))~=length(cofIndex(1,:))
                            cofIndex = generateIndexMatrix(length(data(:,1,1)),length(data(1,:,1)));
                        end
                    end
                    for t=1:length(tempVec)
                        %disp(char(strcat({'Processing files for: '},num2str(tempVec(t)),'+-',num2str(toleVec(t)),{' K'})));
                        [dumb,nF] = filtrateTemp(data(:,:,z),tempVec(t),toleVec(t));
                        nFT = nF(:,:);
                        MCS = [];
                        neighborhoods = cell(32,32);
                        if sum(sum(nFT>0))>0
                            for q=1:32
                                for w=1:32
                                    subNFT = nFT(1+(q-1)*15:15+(q-1)*15,1+(w-1)*20:20+(w-1)*20);
                                    if ~(sum(sum(subNFT>0))> 0)
                                        continue;
                                    end
                                    %[bPos,nE] = borderDetection(subNFT);
                                    for j=1:length(subNFT(:,1))
                                        if sum(subNFT(j,:)>0)>0
                                            cols = find(subNFT(j,:)>0);
                                            for c=1:1%length(cols)
                                                [ele,subNFT] = findNeighbors(subNFT,[j,cols(c)],cofIndex(1+(q-1)*15:15+(q-1)*15,1+(w-1)*20:20+(w-1)*20));
                                                %nMCS = cell(1,3);
                                                if ~isempty(ele)
                                                    ele = unique(ele,'rows');
                                                    neighborhoods{q,w} = ele;% = cat(3,neighborhoods,ele);
%                                                     [lat,lon] = findCentroid(ele);
%                                                     nMCS{1} = lat;
%                                                     nMCS{2} = lon;
%                                                     nMCS{3} = length(ele(:,1));
%                                                     MCS = cat(1,MCS,nMCS);
                                                else
                                                    continue;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if ~isempty(neighborhoods)
                                if isempty(cofIndex)
                                    cofIndex = generateIndexMatrix(length(neighborhoods(:,1)),length(neighborhoods(1,:)));
                                else
                                    if length(neighborhoods(:,1))~=length(cofIndex(:,1)) || length(neighborhoods(1,:))~=length(cofIndex(1,:))
                                        cofIndex = generateIndexMatrix(length(neighborhoods(:,1)),length(neighborhoods(1,:)));
                                    end
                                end
                                cpyNeighborhood = neighborhoods;
                                for j=1:length(neighborhoods(:,1))
                                    if sum(~cellfun(@isempty,neighborhoods(j,:)))>0%sum(neighborhoods(j,:)>0)>0
                                        cols = find(~cellfun(@isempty,neighborhoods(j,:)));
                                        for c=1:length(cols)
                                            [ele,cpyNeighborhood] = findNeighbors2(cpyNeighborhood,[j,cols(c)],cofIndex);
                                            if ~isempty(ele)
                                                nMCS = cell(1,3);
                                                numEle = 0;
                                                latCen = NaN;
                                                lonCen = NaN;
                                                for ne=1:length(ele(:,1))
                                                    cPo = ele(ne,:);
                                                    cNe = neighborhoods{cPo(1),cPo(2)}; % Current neighborhood
                                                    szN = size(cNe); % Current neighborhood size
                                                    [lat,lon] = findCentroid(cNe); % Find central element
                                                    numEle = numEle+szN(1);
                                                    if ~isnan(latCen)
                                                        latCen = (latCen+lat)/2;
                                                    else
                                                        latCen = lat;
                                                    end
                                                    if ~isnan(lonCen)
                                                        lonCen = (lonCen+lon)/2;
                                                    else
                                                        lonCen = lon;
                                                    end
                                                end
                                                nMCS{1} = latCen;
                                                nMCS{2} = lonCen;
                                                nMCS{3} = numEle;
                                                MCS = cat(1,MCS,nMCS);
                                            end
                                        end
                                    end
                                end
                            end
%                             for j=1:length(nFT(:,1))
%                                 if sum(nFT(j,:)>0)>0
%                                     cols = find(nFT(j,:)>0);
%                                     for c=1:length(cols)
%                                         [ele,nFT] = findNeighbors(nFT,[j,cols(c)],cofIndex);
%                                         nMCS = cell(1,3);
%                                         if ~isempty(ele)
%                                             %elements = cat(1,elements,ele);
%                                             [lat,lon] = findCentroid(ele);
%                                             nMCS{1} = lat;
%                                             nMCS{2} = lon;
%                                             nMCS{3} = length(ele(:,1));
%                                             MCS = cat(1,MCS,nMCS);
%                                         else
%                                             continue;
%                                         end
%                                     end
%                                 end
%                             end
                            newMCS = cell(1,4);
                            newMCS{1} = nF;
                            newMCS{2} = timeStamp(z,1:2);
                            newMCS{3} = MCS;
                            newMCS{4} = data(:,:,z);
                            out = cat(1,out,newMCS);
                        end
                    end
                    rema = (length(dirData)-3)/2;
                    if mod(rema,2)~=0 
                        rema = (length(dirData)-4)/2;
                    end
                    disp(char(strcat({'Processed levels: '},num2str(z),{' (remaining images '},num2str(rema-con),')')));
                end
                con = con + 1; 
                if ~isempty(out)
                    newName = savePath.concat(strcat({'[MCS] '},char(nName)));
                    S.(var2Read) = out;
                    save(char(newName),'-struct','S','-v7.3');
                    try
                        clear out;
                        clear dumb;
                        clear neighborhoods;
                    catch
                    end
                    out = [];
                end
            catch e
                msg = e.message;
                disp(msg);
                try
                    fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                    fprintf(fid, '[ERROR][%s] %s\n %s\n',char(datestr(now)),char(fileT),msg);
                    fclose(fid);
                catch
                end
            end
        end
    end
end

function [cofIndex] = generateIndexMatrix(f,r)
    cofIndex = cell(f,r);
    for h=1:length(cofIndex(:,1))
        for g=1:length(cofIndex(1,:))
            cofIndex{h,g} = [h,g];
        end
    end
end

function [lat,lon] = findCentroid(MCS)
    lat = median(MCS(:,1));
    lon = median(MCS(:,2));
end