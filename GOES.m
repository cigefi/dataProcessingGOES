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
        n = getFilesCount(savePath,'IR4');
        save(char(savePath.concat(strcat('IR4-',num2str(n),'.mat'))),'IR4','-v7.3');
        %save(char(savePath.concat('IR4.mat')),'IR4','-v7.3');
    end
    if ~isempty(tlIR4)
        n = getFilesCount(savePath,'tlIR4');
        save(char(savePath.concat(strcat('tlIR4-',num2str(n),'.mat'))),'tlIR4','-v7.3');
        %save(char(savePath.concat('IR4-timeline.mat')),'tlIR4');
    end
    if ~isempty(VIS)
        n = getFilesCount(savePath,'VIS');
        save(char(savePath.concat(strcat('VIS-',num2str(n),'.mat'))),'VIS','-v7.3');
        %save(char(savePath.concat('VIS.mat')),'VIS','-v7.3');
    end
    if ~isempty(tlVIS)
        n = getFilesCount(savePath,'tlVIS');
        save(char(savePath.concat(strcat('tlVIS-',num2str(n),'.mat'))),'tlVIS','-v7.3');
        %save(char(savePath.concat('VIS-timeline.mat')),'tlVIS');
    end
    if ~isempty(WV)
        n = getFilesCount(savePath,'WV');
        save(char(savePath.concat(strcat('WV-',num2str(n),'.mat'))),'WV','-v7.3');
        %save(char(savePath.concat('WV.mat')),'WV','-v7.3');
    end
    if ~isempty(tlWV)
        n = getFilesCount(savePath,'tlWV');
        save(char(savePath.concat(strcat('tlWV-',num2str(n),'.mat'))),'tlWV','-v7.3');
        %save(char(savePath.concat('WV-timeline.mat')),'tlWV');
    end
end