function [] = GOES(dirName)
    if nargin < 1
        error('GOES: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    if(length(dirName)>1)
        save_path = java.lang.String(dirName(2));
	else
		save_path = java.lang.String(dirName(1));
    end
    if(save_path.charAt(save_path.length-1) ~= '/')
        save_path = save_path.concat('/');
    end
    [IR4,VIS,WV,tlIR4,tlVIS,tlWV] = dataProcessingIR4(dirName);
    if ~isempty(IR4)
        save(char(save_path.concat('IR4.mat')),'IR4');
    end
    if ~isempty(tlIR4)
        save(char(save_path.concat('IR4-timeline.mat')),'tlIR4');
    end
    if ~isempty(VIS)
        save(char(save_path.concat('VIS.mat')),'VIS');
    end
    if ~isempty(tlVIS)
        save(char(save_path.concat('VIS-timeline.mat')),'tlVIS');
    end
    if ~isempty(WV)
        save(char(save_path.concat('WV.mat')),'WV');
    end
    if ~isempty(tlWV)
        save(char(save_path.concat('WV-timeline.mat')),'tlWV');
    end