function [] = GOES(dirName)
    if nargin < 1
        error('GOES: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    [IR4] = dataProcessingIR4(dirName);
    if ~isempty(GOES)
        save IR4.mat IR4;
    end