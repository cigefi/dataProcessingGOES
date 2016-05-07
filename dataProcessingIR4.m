% Function dataProcessingIR4
%
% Prototype: dataProcessingIR4(dirName)
%
% dirName = Path of the directory that contents the files and path for the
% processed files
function [IR4] = dataProcessingIR4(dirName,IR4)
    switch nargin
        case 1
            IR4 = [];
    end
    if nargin < 1
        error('dataProcessingIR4: dirName is a required input')
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
                prodata = [];
                [area,err] = getAreaDirectory(char(fileT));
                if isnan(err) && ~isempty(area)
                    fid = fopen(char(fileT),'rb');
                    data = fread(fid);
                    % Auxiliary (AUX) block
                    if (area.W61 - area.W60) > 0
                        fid2 = fopen('aux.goes','wb');
                        fwrite(fid2,data(area.W60,area.W61));
                        fclose(fid2);
                    end
                    % Navigation (NAV) block
                    if area.W35 > 0
                        if area.W63 > 0
                            lpos = area.W63;
                        else
                            lpos = area.W34;
                        end
                        fid2 = fopen('nav.goes','wb');
                        fwrite(fid2,data(area.W35+1:lpos));
                        fclose(fid2);
                        nav = getNAV('nav.goes');
                    end
                    % Calibration (CAL) block
                    if area.W63 > 0
                        fid2 = fopen('cal.goes','wb');
                        fwrite(fid2,data(area.W63+1:area.W34));
                        fclose(fid2);
                    end
                    % Digital data (DATA) block
                    %% Configuration params
                    if area.W36 > 0
                        valcode = 4; % Validity code length
                    else
                        valcode = 0;
                    end
                    doc = area.W49; % Documentation length
                    cal = area.W50; % Calibration length
                    level = area.W51; % Level map length
                    nbands = area.W14; % Number of bands per line
                    nele = area.W10; % Number of elements per line
                    nbytes = area.W11; % Number of bytes per element
                    nlines = area.W9; % Number of lines in the area
                    
                    lpre = valcode + doc + cal + level; % Line prefix length
                    ldatasec = nbands*nele*nbytes; % Line data section length
                    lines = lpre + ldatasec; % Line length
                    datablock = nlines * lines; % DATA block length
                    
                    fid2 = fopen('data.goes','wb');
                    fpos = area.W34+1;
                    lpos = fpos - 1 + datablock;
                    fwrite(fid2,data(fpos:lpos));
                    %fwrite(fid2,data(area.W34+1:datablock));
                    fclose(fid2);
                    
                    % Comment Records (AUDIT) block
                    fpos = area.W34 + datablock + 1;
                    if area.W64 > 0 && fpos < length(data)
                        fid2 = fopen('audit.goes','wb');
                        fwrite(fid2,data(fpos:end));
                        fclose(fid2);
                    end
                    fclose(fid);
                    
                    fid = fopen('data.goes');
                    rawdata = fread(fid);
                    if lpre == 0
                        prodata = reshape(rawdata,ldatasec,[]);
                    else
                        for i=1:length(nlines)
                            offset = lines*(i-1);
                            fpos = offset;%lpos + 1; %+ offset;
                            lpos = valcode*fpos - 1 + fpos;
                            if valcode > 0
                                valcodeD = rawdata(fpos:lpos);
                            else
                                valcodeD = 0;
                            end
                            if valcodeD == area.W36
                                % Line prefix
                                fpos = lpos + 1;%(valcode + 1)*offset + lpos + 1;
                                lpos = fpos - 1 + doc;%(doc + valcode)*offset;
                                docD = rawdata(fpos:lpos);
                                fpos = lpos + 1;
                                lpos = fpos - 1 + cal;%lpos + cal*offset;
                                calD = rawdata(fpos:lpos);
                                calD = reshape(calD,nbands,[]);
                                fpos = lpos + 1;
                                lpos = fpos - 1 + level;%lpos + level*offset;
                                levelD = rawdata(fpos:lpos);
                                levelD = reshape(levelD,nbands,[]);
                                % Line data
                                fpos = lpos + 1;
                                lpos = fpos - 1 + ldatasec;%lpos + ldatasec*offset;
                                data = rawdata(fpos:lpos);
                                nline = reshape(data,nele,[],nbands);
                                prodata = cat(2,prodata,nline);
                            end
                        end
                    end
                    figure;
                    contourf(prodata);
                    figure;
                    contourf(permute(prodata,[2 1]));
                end
                if ~isempty(prodata)
                    IR4 = cat(3,output,prodata);
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
                [IR4] = dataProcessingIR4({newPath,char(save_path.concat(dirData(f).name)),char(logPath)},IR4);
            end
        end
    end
    if ~isempty(output)
        dlmwrite(strcat(char(save_path),'output.dat'),output);
    end
end

function [areaDir,err] = getAreaDirectory(fileName)
    err = NaN;
    % Temp file
    try
        fid = fopen(fileName,'rb');
        data = fread(fid,256);
        fclose(fid);
        fid = fopen('area-dir.goes','wb');
        fwrite(fid,data);
        fclose(fid);
        map = memmapfile('area-dir.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
        areaDir = map.Data;
        clear map;
        delete('area-dir.goes');
    catch exception
        areaDir = NaN;
        char(exception.message);
    end
end

% function [aux,err] = getAUX(fileName)
%     err = NaN;
%     % Temp file
%     try
%         fid = fopen(fileName,'rb');
%         data = fread(fid,256);
%         fclose(fid);
%         fid = fopen('temp.goes','wb');
%         fwrite(fid,data);
%         fclose(fid);
%         map = memmapfile('temp.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
%         aux = map.Data;
%         clear map;
%         delete('temp.goes');
%     catch exception
%         aux = NaN;
%         char(exception.message);
%     end
% end

function [nav,err] = getNAV(fileName)
    err = NaN;
    try
        map = memmapfile(fileName,'Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64';'uint32',1,'W65';'uint32',1,'W66';'uint32',1,'W67';'uint32',1,'W68';'uint32',1,'W69';'uint32',1,'W70';'uint32',1,'W71';'uint32',1,'W72';'uint32',1,'W73';'uint32',1,'W74';'uint32',1,'W75';'uint32',1,'W76';'uint32',1,'W77';'uint32',1,'W78';'uint32',1,'W79';'uint32',1,'W80';'uint32',1,'W81';'uint32',1,'W82';'uint32',1,'W83';'uint32',1,'W84';'uint32',1,'W85';'uint32',1,'W86';'uint32',1,'W87';'uint32',1,'W88';'uint32',1,'W89';'uint32',1,'W90';'uint32',1,'W91';'uint32',1,'W92';'uint32',1,'W93';'uint32',1,'W94';'uint32',1,'W95';'uint32',1,'W96';'uint32',1,'W97';'uint32',1,'W98';'uint32',1,'W99';'uint32',1,'W100';'uint32',1,'W101';'uint32',1,'W102';'uint32',1,'W103';'uint32',1,'W104';'uint32',1,'W105';'uint32',1,'W106';'uint32',1,'W107';'uint32',1,'W108';'uint32',1,'W109';'uint32',1,'W110';'uint32',1,'W111';'uint32',1,'W112';'uint32',1,'W113';'uint32',1,'W114';'uint32',1,'W115';'uint32',1,'W116';'uint32',1,'W117';'uint32',1,'W118';'uint32',1,'W119';'uint32',1,'W120';'uint32',1,'W121';'uint32',1,'W122';'uint32',1,'W123';'uint32',1,'W124';'uint32',1,'W125';'uint32',1,'W126';'uint32',1,'W127';'uint32',1,'W128'});
        nav = map.Data;
        clear map;
    catch exception
        nav = NaN;
        char(exception.message);
    end
end
% 
% function [cal,err] = getCAL(fileName)
%     err = NaN;
%     % Temp file
%     try
%         fid = fopen(fileName,'rb');
%         data = fread(fid,256);
%         fclose(fid);
%         fid = fopen('temp.goes','wb');
%         fwrite(fid,data);
%         fclose(fid);
%         map = memmapfile('temp.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
%         cal = map.Data;
%         clear map;
%         delete('temp.goes');
%     catch exception
%         cal = NaN;
%         char(exception.message);
%     end
% end

% function [data,err] = getDATA(fileName)
%     err = NaN;
%     % Temp file
%     try
%         fid = fopen(fileName,'rb');
%         data = fread(fid,256);
%         fclose(fid);
%         fid = fopen('temp.goes','wb');
%         fwrite(fid,data);
%         fclose(fid);
%         map = memmapfile('temp.goes','Format',{'uint32',1,'W1';'uint32',1,'W2';'uint32',1,'W3';'uint32',1,'W4';'uint32',1,'W5';'uint32',1,'W6';'uint32',1,'W7';'uint32',1,'W8';'uint32',1,'W9';'uint32',1,'W10';'uint32',1,'W11';'uint32',1,'W12';'uint32',1,'W13';'uint32',1,'W14';'uint32',1,'W15';'uint32',1,'W16';'uint32',1,'W17';'uint32',1,'W18';'uint32',1,'W19';'uint32',1,'W20';'uint32',1,'W21';'uint32',1,'W22';'uint32',1,'W23';'uint32',1,'W24';'uint32',1,'W25';'uint32',1,'W26';'uint32',1,'W27';'uint32',1,'W28';'uint32',1,'W29';'uint32',1,'W30';'uint32',1,'W31';'uint32',1,'W32';'uint32',1,'W33';'uint32',1,'W34';'uint32',1,'W35';'uint32',1,'W36';'uint32',1,'W37';'uint32',1,'W38';'uint32',1,'W39';'uint32',1,'W40';'uint32',1,'W41';'uint32',1,'W42';'uint32',1,'W43';'uint32',1,'W44';'uint32',1,'W45';'uint32',1,'W46';'uint32',1,'W47';'uint32',1,'W48';'uint32',1,'W49';'uint32',1,'W50';'uint32',1,'W51';'uint32',1,'W52';'uint32',1,'W53';'uint32',1,'W54';'uint32',1,'W55';'uint32',1,'W56';'uint32',1,'W57';'uint32',1,'W58';'uint32',1,'W59';'uint32',1,'W60';'uint32',1,'W61';'uint32',1,'W62';'uint32',1,'W63';'uint32',1,'W64'});
%         data = map.Data;
%         clear map;
%         delete('temp.goes');
%     catch exception
%         data = NaN;
%         char(exception.message);
%     end
% end