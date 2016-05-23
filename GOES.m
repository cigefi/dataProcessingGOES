function [] = GOES(dirName)
    if nargin < 1
        error('GOES: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    [IR4,VIS,WV,tlIR4,tlVIS,tlWV] = dataProcessingIR4(dirName);
    if ~isempty(IR4)
        save IR4.mat IR4;
    end
    if ~isempty(tlIR4)
        save IR4-timeline.mat tlIR4
    end
    if ~isempty(VIS)
        save VIS.mat VIS;
    end
    if ~isempty(tlVIS)
        save VIS-timeline.mat tlVIS
    end
    if ~isempty(WV)
        save WV.mat WV;
    end
    if ~isempty(tlWV)
        save WV-timeline.mat tlWV
    end