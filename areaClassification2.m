function [] = areaClassification2(dirName)
    if nargin < 1
        error('areaClassification2: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    
    dirData = dir(char(dirName(1)));  % Get the data for the current directory
    path = java.lang.String(dirName(1));

    if(path.charAt(path.length-1) ~= '/')
        path = path.concat('/');
    end
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        name = fileT;
        try
            fileT = name;
            l = length(name);
            var2Read = char(name.substring(l-3));
        catch e
            disp(e.message);
            continue;
        end
        try
            [area,err] = getAreaDirectory(char(fileT));
            if isnan(err) && ~isempty(area)
                nPath = path.concat(char(strcat(num2str(area.W33),'/',var2Read,'/')));
                if ~exist(char(nPath),'dir')
                    mkdir(char(nPath));
                end
                gzip(char(fileT),char(nPath));%.concat(char(strcat(char(name.substring(name.lastIndexOf('/')+1)),'.gz')))));
            end
            delete(char(fileT));
            if ~mod(f-2,100)
                disp(char(strcat({'Processed files '},{' '},num2str(f-2),{' of '},num2str(length(dirData)-2))));
            end
            %disp(char(strcat({'Moved file: '},char(fileT))));

        catch exception
            disp(exception.message);
            disp(char(fileT));
            continue;
        end
    end
end

function [areaDir,err] = getAreaDirectory(fileName)
    err = NaN;
    try
        fid = fopen(fileName,'rb');
        data = fread(fid,256);
        fclose(fid);
        fid = fopen('area-dir.goes','wb');
        fwrite(fid,data);
        fclose(fid);
        map = memmapfile('area-dir.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint8',[4 1],'W25';'uint8',[4 1],'W26';'uint8',[4 1],'W27';'uint8',[4 1],'W28';'uint8',[4 1],'W29';'uint8',[4 1],'W30';'uint8',[4 1],'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint8',[4 1],'W52';'uint8',[4 1],'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
        areaDir = map.Data;
        clear map;
        %delete('area-dir.goes');
    catch exception
        areaDir = NaN;
        char(exception.message);
    end
end