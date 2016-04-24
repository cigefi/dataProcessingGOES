% Function dataProcessingIR4
%
% Prototype: dataProcessingIR4(dirName)
%
% dirName = Path of the directory that contents the files and path for the
% processed files
function [] = dataProcessingIR4(dirName)
    if nargin < 1
        error('dataProcessing: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    
    dirData = dir(char(dirName(1)));  % Get the data for the current directory
    path = java.lang.String(dirName(1));
    if(path.charAt(path.length-1) ~= '/')
        path = path.concat('/');
    end
    if(length(dirName)>1)
        save_path = java.lang.String(dirName(2));
        if(length(dirName)>2)
            logPath = java.lang.String(dirName(3));
        else
            logPath = java.lang.String(dirName(2));
        end
	else
		save_path = java.lang.String(dirName(1));
		logPath = java.lang.String(dirName(1));
    end
    if(save_path.charAt(save_path.length-1) ~= '/')
        save_path = save_path.concat('/');
    end
    if(logPath.charAt(logPath.length-1) ~= '/')
        logPath = logPath.concat('/');
    end
    output = [];
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        lio = fileT.lastIndexOf('.');
        %ext = fileT.substring(fileT.lastIndexOf('.')+1);
        %if(~ext.equalsIgnoreCase('nco') && ~ext.equalsIgnoreCase('gz'))
        if lio == -1
            try
                o = double(readFile(char(fileT)));
                if ~isempty(o)
                    output = cat(3,output,o);
%                     if isempty(output)
%                         output = o;
%                     else
%                         output = cat(3,output,o);
%                     end
                end
            catch exception
                if(exist(char(logPath),'dir'))
                    fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                    fprintf(fid, '[ERROR][%s] %s\n %s\n\n',char(datetime('now')),char(fileT),char(exception.message));
                    fclose(fid);
                end
                continue;
            end
        else
            if isequal(dirData(f).isdir,1)
                newPath = char(path.concat(dirData(f).name));
                dataProcessing({newPath,char(save_path.concat(dirData(f).name)),char(logPath)});
            end
        end
    end
    if ~isempty(output)
        dlmwrite(strcat(char(save_path),'output.dat'),output);
    end
end

function [ir4] = readFile(fileName)
    map = memmapfile(fileName,'Format',{'single',1,'cloud_top_temperature';'single',1,'cloud_surface_temperature';'single',1,'cloud_cover';'single',1,'air_mass_boundaries';'single',1,'convergence_zones';'single',1,'surface_lows';'single',1,'thunderstorms'});
    out = map.Data;
    ir4 = [];
    ir4 = cat(1,ir4,extractfield(out,'cloud_top_temperature'));
    ir4 = cat(1,ir4,extractfield(out,'cloud_surface_temperature'));
    ir4 = cat(1,ir4,extractfield(out,'cloud_cover'));
    ir4 = cat(1,ir4,extractfield(out,'air_mass_boundaries'));
    ir4 = cat(1,ir4,extractfield(out,'convergence_zones'));
    ir4 = cat(1,ir4,extractfield(out,'surface_lows'));
    ir4 = cat(1,ir4,extractfield(out,'thunderstorms'));
    ir4 = permute(ir4,[2 1]);
    disp(strcat('Data saved: ',{' '},fileName));
end

function [areaDir,err] = getAreaDirectory(fileName)
    err = NaN;
    % Temp file
    try
        fid = fopen(fileName,'rb');
        data = fread(fid,256);
        fclose(fid);
        fid = fopen('temp.goes','wb');
        fwrite(fid,data);
        fclose(fid);
        map = memmapfile('temp.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
        areaDir = map.Data;
        clear map;
        delete('temp.goes');
    catch exception
        areaDir = NaN;
        char(exception.message);
    end
    % 'Offset',256
    %map = memmapfile('temp','Format',{'int32',1,'W1';'int32',1,'W2';'int32',1,'W3';'char',1,'W4';'char',1,'W5';'int32',1,'W6';'int32',1,'W7'});
end

function [aux,err] = getAUX(fileName)
    err = NaN;
    % Temp file
    try
        fid = fopen(fileName,'rb');
        data = fread(fid,256);
        fclose(fid);
        fid = fopen('temp.goes','wb');
        fwrite(fid,data);
        fclose(fid);
        map = memmapfile('temp.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
        aux = map.Data;
        clear map;
        delete('temp.goes');
    catch exception
        aux = NaN;
        char(exception.message);
    end
end

function [nav,err] = getNAV(fileName,OFFSET)
    err = NaN;
    % Temp file
    try
        fid = fopen(fileName,'rb');
        data = fread(fid,256);
        fclose(fid);
        fid = fopen('temp.goes','wb');
        fwrite(fid,data);
        fclose(fid);
        map = memmapfile('temp.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64';'uint32',1,'W65';'uint32',1,'W66';'uint32',1,'W67';'uint32',1,'W68';'uint32',1,'W69';'uint32',1,'W70';'uint32',1,'W71';'uint32',1,'W72';'uint32',1,'W73';'uint32',1,'W74';'uint32',1,'W75';'uint32',1,'W76';'uint32',1,'W77';'uint32',1,'W78';'uint32',1,'W79';'uint32',1,'W80';'uint32',1,'W81';'uint32',1,'W82';'uint32',1,'W83';'uint32',1,'W84';'uint32',1,'W85';'uint32',1,'W86';'uint32',1,'W87';'uint32',1,'W88';'uint32',1,'W89';'uint32',1,'W90';'uint32',1,'W91';'uint32',1,'W92';'uint32',1,'W93';'uint32',1,'W94';'uint32',1,'W95';'uint32',1,'W96';'uint32',1,'W97';'uint32',1,'W98';'uint32',1,'W99';'uint32',1,'W100';'uint32',1,'W101';'uint32',1,'W102';'uint32',1,'W103';'uint32',1,'W104';'uint32',1,'W105';'uint32',1,'W106';'uint32',1,'W107';'uint32',1,'W108';'uint32',1,'W109';'uint32',1,'W110';'uint32',1,'W111';'uint32',1,'W112';'uint32',1,'W113';'uint32',1,'W114';'uint32',1,'W115';'uint32',1,'W116';'uint32',1,'W117';'uint32',1,'W118';'uint32',1,'W119';'uint32',1,'W120';'uint32',1,'W121';'uint32',1,'W122';'uint32',1,'W123';'uint32',1,'W124';'uint32',1,'W125';'uint32',1,'W126';'uint32',1,'W127';'uint32',1,'W128'},'Offset',OFFSET);
        nav = map.Data;
        clear map;
        delete('tempa.goes');
    catch exception
        nav = NaN;
        char(exception.message);
    end
end

function [cal,err] = getCAL(fileName)
    err = NaN;
    % Temp file
    try
        fid = fopen(fileName,'rb');
        data = fread(fid,256);
        fclose(fid);
        fid = fopen('temp.goes','wb');
        fwrite(fid,data);
        fclose(fid);
        map = memmapfile('temp.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
        cal = map.Data;
        clear map;
        delete('temp.goes');
    catch exception
        cal = NaN;
        char(exception.message);
    end
end

function [data,err] = getDATA(fileName)
    err = NaN;
    % Temp file
    try
        fid = fopen(fileName,'rb');
        data = fread(fid,256);
        fclose(fid);
        fid = fopen('temp.goes','wb');
        fwrite(fid,data);
        fclose(fid);
        map = memmapfile('temp.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
        data = map.Data;
        clear map;
        delete('temp.goes');
    catch exception
        data = NaN;
        char(exception.message);
    end
end