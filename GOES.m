% GOES
% Function capable of process a bunch of McIDAS (Man computer Interactive Data
% Access System) files. Variables: IR4, VIS, and WV33.
%
% Prototype:
%           GOES(dirName,joinFiles)
% dirName (required) = must be a cell-array of the form {'PATH-IN','PATH-OUT'}
% joinFiles (optional) = is an optional flag, must be an binary value, if 1 (true)
% then at the end of the routine the files will be merged.
function [] = GOES(dirName,joinFiles)
    if nargin < 1
        error('GOES: dirName is a required input')
    elseif nargin < 2
        joinFiles = 0; % Default value
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
    [IR4,VIS,WV3,tlIR4,tlVIS,tlWV3] = dataProcessingIR4(dirName);
    if ~isempty(IR4)
        n = getFilesCount(savePath,'IR4');
        save(char(savePath.concat(strcat('IR4-',num2str(n),'.mat'))),'IR4','-v7.3');
        disp('IR4 files processed');
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
        disp('VIS files processed');
        %save(char(savePath.concat('VIS.mat')),'VIS','-v7.3');
    end
    if ~isempty(tlVIS)
        n = getFilesCount(savePath,'tlVIS');
        save(char(savePath.concat(strcat('tlVIS-',num2str(n),'.mat'))),'tlVIS','-v7.3');
        %save(char(savePath.concat('VIS-timeline.mat')),'tlVIS');
    end
    if ~isempty(WV3)
        n = getFilesCount(savePath,'WV3');
        save(char(savePath.concat(strcat('WV3-',num2str(n),'.mat'))),'WV3','-v7.3');
        disp('WV3 files processed');
        %save(char(savePath.concat('WV3.mat')),'WV3','-v7.3');
    end
    if ~isempty(tlWV3)
        n = getFilesCount(savePath,'tlWV3');
        save(char(savePath.concat(strcat('tlWV3-',num2str(n),'.mat'))),'tlWV3','-v7.3');
        %save(char(savePath.concat('WV3-timeline.mat')),'tlWV3');
    end
    if joinFiles
        try
            filesJoin(savePath,'IR4');
            filesJoin(savePath,'tlIR4',1);
            filesJoin(savePath,'VIS');
            filesJoin(savePath,'tlVIS',1);
            filesJoin(savePath,'WV3');
            filesJoin(savePath,'tlWV3',1);
        catch e
            disp(e.message);
        end 
    end
end