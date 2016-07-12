function [] = GOES(dirName)
    if nargin < 1
        error('GOES: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    if(length(dirName)>1)
        savePath = java.lang.String(dirName(2));
	else
		savePath = java.lang.String(dirName(1));
    end
    if(savePath.charAt(savePath.length-1) ~= '/')
        savePath = savePath.concat('/');
    end
    [IR4,VIS,WV,tlIR4,tlVIS,tlWV] = dataProcessingIR4(dirName);
    if ~isempty(IR4)
        save(char(savePath.concat('IR4.mat')),'IR4');
    end
    if ~isempty(tlIR4)
        save(char(savePath.concat('IR4-timeline.mat')),'tlIR4');
    end
    if ~isempty(VIS)
        save(char(savePath.concat('VIS.mat')),'VIS');
    end
    if ~isempty(tlVIS)
        save(char(savePath.concat('VIS-timeline.mat')),'tlVIS');
    end
    if ~isempty(WV)
        save(char(savePath.concat('WV.mat')),'WV');
    end
    if ~isempty(tlWV)
        save(char(savePath.concat('WV-timeline.mat')),'tlWV');
    end