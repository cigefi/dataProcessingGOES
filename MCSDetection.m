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

    out = [];
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
                for z=1:length(data(1,1,:))
                    for t=1:length(tempVec)
                        [~,nF] = filtrateTemp(data(:,:,z),tempVec(t),toleVec(t));
                        if sum(sum(nF>0))>0
                            newMCS = cell(1,2);
                            newMCS{1} = nF;
                            newMCS{2} = timeStamp(f,1:2);
                            out = cat(1,out,newMCS);
                        end
                    end 
                end
                if ~isempty(out)
                    newName = path.concat(strcat({'[MCS] '},name));
                    save(newName,'tlIR4','-v7.3');
                end
            catch e
                disp(e.message);
            end
        end
    end
end