function MCSDetection(dirName,extra)
    if nargin < 1
        error('MCSDetection: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    vars = [];
    tempVec = 220;
    toleVec = 20;
%     temp = java.lang.String(dirName(1)).split('/');
%     temp = temp(end).split('_');
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
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        try
            name = fileT.substring(fileT.lastIndexOf('/')+1,fileT.lastIndexOf('-')).concat('.mat');
            nameTS = strcat('tl',var2Read,char(fileT.substring(fileT.lastIndexOf('-'))));
        catch
            try
                name = fileT.substring(fileT.lastIndexOf('/')+1).concat('.mat');
                nameTS = strcat('tl',var2Read,'.mat');
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
                if isempty(cofIndex)
                    cofIndex = generateIndexMatrix(length(data(:,1,1)),length(data(1,:,1)));
                else
                    if length(data(:,1,1))~=length(cofIndex(:,1)) || length(data(1,:,1))~=length(cofIndex(1,:))
                        cofIndex = generateIndexMatrix(length(data(:,1,1)),length(data(1,:,1)));
                    end
                end
                for z=1:length(data(1,1,:))
                    for t=1:length(tempVec)
                        %disp(char(strcat({'Processing files for: '},num2str(tempVec(t)),'+-',num2str(toleVec(t)),{' K'})));
                        [nT,nF] = filtrateTemp(data(:,:,z),tempVec(t),toleVec(t));
                        nFT = nF(:,:);
                        MCS = [];
                        if sum(sum(nFT>0))>0
                            for j=1:length(nFT(:,1))
                                if sum(nFT(j,:)>0)>0
                                    cols = find(nFT(j,:)>0);
                                    for c=1:length(cols)
                                        [ele,nFT] = findNeighbors(nFT,[j,cols(c)],cofIndex);
                                        nMCS = cell(1,3);
                                        if ~isempty(ele)
                                            [lat,lon] = findCentroid(ele);
                                            nMCS{1} = lat;
                                            nMCS{2} = lon;
                                            nMCS{3} = length(ele(:,1));
                                            MCS = cat(1,MCS,nMCS);
                                        else
                                            continue;
                                        end
                                    end
                                end
                            end
                            newMCS = cell(1,3);
                            newMCS{1} = nF;
                            newMCS{2} = timeStamp(z,1:2);
                            newMCS{3} = MCS;
                            out = cat(1,out,newMCS);
                        end
                    end
%                     disp(num2str(z));
                end
                if ~isempty(out)
                    newName = savePath.concat(strcat({'[MCS] '},char(name)));
                    S.(var2Read) = out;
                    save(char(newName),'-struct','S','-v7.3');
                end
            catch e
                disp(e.message);
                try
                    fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                    fprintf(fid, '[ERROR][%s] %s\n %s\n',char(datestr(now)),char(fileT),char(exception.message));
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