function MCSDetection(dirName,extra)
    if nargin < 1
        error('MCSDetection: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    vars = [];
    tempVec = [200];
    temp = java.lang.String(dirName(1)).split('/');
    temp = temp(end).split('_');
    var2Read = 'IR4'; % Default value IR4
%     yearZero = 0; % Default value
%     yearN = 0; % Default value
    switch nargin
        case 2 
            if ~mod(length(extra),2)
                tmp = reshape(extra,2,[])'; 
                for i=1:1:length(tmp(:,1))
                    switch lower(char(tmp{i,1}))
%                         case 'f'
%                             val = tmp{i,2};
%                             if length(val) == 1
%                                 yearZero = val;%str2double(char(val));
%                             end
%                         case 'l'
%                             val = tmp{i,2};
%                             if length(val) == 1
%                                 yearN = val;%str2double(char(val));
%                             end
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
    
    data = [];
    out = [];
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        if(fileT.substring(fileT.lastIndexOf('/')+1).equalsIgnoreCase(strcat(var2Read,'.mat')))
            load(char(fileT));
            switch(var2Read)
                case 'IR4'
                    data = IR4;
                case 'VIS'
                    data = VIS;
                case 'WV'
                    data = WV;
            end
            for z=1:length(data(1,1,:))
                for i=1:length(tempVec)
                    [nT,~] = filtrateTemp(data(:,:,z),tempVec(i));
                    if ~isempty(nT)
                        out = cat(3,out,nT);
                    end
                end 
            end
        end
    end
end