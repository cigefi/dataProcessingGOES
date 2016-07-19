% Function dataProcessingIR4
%
% Prototype: dataProcessingIR4(dirName)
%
% dirName = Path of the directory that contents the files and path for the
% processed files
function [IR4,VIS,WV,tlIR4,tlVIS,tlWV] = dataProcessingIR4(dirName,IR4,VIS,WV,tlIR4,tlVIS,tlWV)
    switch nargin
        case 1
            IR4 = [];
            VIS = [];
            WV = [];
            tlIR4 = [];
            tlVIS = [];
            tlWV = [];
    end
    if nargin < 1
        error('dataProcessingIR4: dirName is a required input')
    else
        dirName = strrep(dirName,'\','/'); % Clean dirName var
    end
    
    dirData = dir(char(dirName(1)));  % Get the data for the current directory
    path = java.lang.String(dirName(1));
    sTop = 99;
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
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        %lio = fileT.lastIndexOf('.');
        ext = fileT.substring(fileT.lastIndexOf('.')+1);
        if(ext.equalsIgnoreCase('gz'))
            name = fileT.substring(0,fileT.lastIndexOf('.'));
            try
                gunzip(char(fileT),char(path));
                fileT = name;
                l = length(name);
                var2Read = char(name.substring(l-3));
            catch e
                disp(e.message);
                continue;
            end
        %if lio == -1
            try
                prodata = [];
                [area,err] = getAreaDirectory(char(fileT));
                if isnan(err) && ~isempty(area)
                    fid = fopen(char(fileT),'rb');
                    data = fread(fid);
                    fclose(fid);
                    lenZ = area.W14;
                    n = getFilesCount(savePath,var2Read);
                    switch (var2Read)
                        case 'IR4'
                            if ~isempty(IR4)
                                posZ = length(IR4(1,1,:))+1;
                            else
                                posZ = 1;
                            end
                            newTimeStamp = cell(1,5);
                            newTimeStamp{1} = getDate(num2str(area.W4));
                            newTimeStamp{2} = getTime(num2str(area.W5));
                            newTimeStamp{3} = area.W33;
                            newTimeStamp{4} = posZ + (n-1)*100;
                            newTimeStamp{5} = lenZ;
%                             newTimeStamp = [getDate(num2str(area.W4)) area.W5 area.W33 posZ lenZ];
                            tlIR4 = cat(1,tlIR4,newTimeStamp);
                        case 'VIS'
                            if ~isempty(VIS)
                                posZ = length(VIS(1,1,:))+1;
                            else
                                posZ = 1;
                            end
                            newTimeStamp = cell(1,5);
                            newTimeStamp{1} = getDate(num2str(area.W4));
                            newTimeStamp{2} = getTime(num2str(area.W5));
                            newTimeStamp{3} = area.W33;
                            newTimeStamp{4} = posZ;
                            newTimeStamp{5} = lenZ;
%                             newTimeStamp = [area.W4 area.W5 area.W33 posZ lenZ];
                            tlVIS = cat(1,tlVIS,newTimeStamp);
                        case 'WV3'
                            if ~isempty(WV)
                                posZ = length(WV(1,1,:))+1;
                            else
                                posZ = 1;
                            end
                            newTimeStamp = cell(1,5);
                            newTimeStamp{1} = getDate(num2str(area.W4));
                            newTimeStamp{2} = getTime(num2str(area.W5));
                            newTimeStamp{3} = area.W33;
                            newTimeStamp{4} = posZ;
                            newTimeStamp{5} = lenZ;
%                             newTimeStamp = [area.W4 area.W5 area.W33 posZ lenZ];
                            tlWV = cat(1,tlWV,newTimeStamp);
                        otherwise
                            continue;
                    end
                    
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
                        %[nav,~] = getNAV('nav.goes');
                    end
                    % Calibration (CAL) block
                    if area.W63 > 0
                        fid2 = fopen('cal.goes','wb');
                        fwrite(fid2,data(area.W63+1:area.W34));
                        fclose(fid2);
                    end
                    % Digital data (DATA) block
                    % Configuration params
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
                        %[audit,~] = getAUDIT('audit.goes');
                    end
                    %fclose(fid);
                    
                    fid = fopen('data.goes');
                    rawdata = fread(fid);
                    fclose(fid);
                    if lpre == 0
                        prodata = reshape(rawdata,[],nele);%ldatasec,[]);
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
                    
%                     plotMap(prodata);
                    %plotMap(permute(prodata,[2 1]));
%                     a = filtrateData(prodata,100);
%                     if sum(a~=0) > 0
%                         disp('FOUND');
%                     end
                    %prodata1 = double(area.W7) + (prodata*double(area.W13));
                    %prodata2 = double(area.W6) + (prodata*double(area.W12));
                    %plotMap(prodata);
%                     figure;
%                     contourf(prodata);
%                     figure;
%                     contourf(permute(prodata,[2 1]));
                    try
                        clear data;
                        clear rawdata;
                    catch
                        disp('Error, cannot delete var data');
                    end
                end
                if ~isempty(prodata)
                    if ~exist(char(savePath),'dir')
                        mkdir(char(savePath));
                    end
                    switch (var2Read)
                        case 'IR4'
                            IR4 = cat(3,IR4,prodata);
                        case 'VIS'
                            VIS = cat(3,VIS,prodata);
                        case 'WV3'
                            WV = cat(3,WV,prodata);
                    end
%                     if ~mod(f,100)
%                         disp(char(strcat('Processed files ',{' '},num2str(f),{' of '},num2str(length(dirData)-3))));
%                     end
                    if ~isempty(IR4)
                        if length(IR4(1,1,:))>sTop
%                             if exist(char(savePath.concat('IR4.mat')),'file')
%                                 tmp = load(char(savePath.concat('IR4.mat')),'IR4');
%                                 IR4 = cat(3,tmp.('IR4'),IR4);
%                             end
%                             save(char(savePath.concat('IR4.mat')),'IR4','-v7.3');
                            %n = getFilesCount(savePath,'IR4');
                            save(char(savePath.concat(strcat('IR4-',num2str(n),'.mat'))),'IR4','-v7.3');
                            disp(char(strcat(num2str(length(IR4(1,1,:))*n),{' IR4 saved files (Processed files '},{' '},num2str(f),{' of '},num2str(length(dirData)-3),')')));
                            try
                                clear IR4;
                            catch
                                disp('Error, cannot delete var IR4');
                            end
                            IR4 = [];
                        end
                        if length(tlIR4(:,1))>sTop
%                             if exist(char(savePath.concat('tlIR4.mat')),'file')
%                                 tmp = load(char(savePath.concat('tlIR4.mat')),'tlIR4');
%                                 tlIR4 = cat(1,tmp.('tlIR4'),tlIR4);
%                             end
%                             save(char(savePath.concat('tlIR4.mat')),'tlIR4','-v7.3');
                            %n = getFilesCount(savePath,'tlIR4');
                            save(char(savePath.concat(strcat('tlIR4-',num2str(n),'.mat'))),'tlIR4','-v7.3');
                            try
                                clear tlIR4;
                            catch
                                disp('Error, cannot delete var tlIR4');
                            end
                            tlIR4 = [];
                        end
                    end
                    if ~isempty(VIS)
                        if length(VIS(1,1,:))>sTop
%                             if exist(char(savePath.concat('VIS.mat')),'file')
%                                 tmp = load(char(savePath.concat('VIS.mat')),'VIS');
%                                 VIS = cat(3,tmp.('VIS'),VIS);
%                             end
%                             save(char(savePath.concat('VIS.mat')),'VIS','-v7.3');
                            %n = getFilesCount(savePath,'VIS');
                            save(char(savePath.concat(strcat('VIS-',num2str(n),'.mat'))),'VIS','-v7.3');
                            disp(char(strcat(num2str(length(VIS(1,1,:))*n),{' VIS saved files (Processed files '},{' '},num2str(f),{' of '},num2str(length(dirData)-3),')')));
                            try
                                clear VIS;
                            catch
                                disp('Error, cannot delete var VIS');
                            end
                            VIS = [];
                        end
                        if length(tlVIS(:,1))>sTop
%                             if exist(char(savePath.concat('tlVIS.mat')),'file')
%                                 tmp = load(char(savePath.concat('tlVIS.mat')),'tlVIS');
%                                 tlVIS = cat(1,tmp.('tlVIS'),tlVIS);
%                             end
%                             save(char(savePath.concat('tlVIS.mat')),'tlVIS','-v7.3');
                            %n = getFilesCount(savePath,'tlVIS');
                            save(char(savePath.concat(strcat('tlVIS-',num2str(n),'.mat'))),'tlVIS','-v7.3');
                            try
                                clear tlVIS;
                            catch
                                disp('Error, cannot delete var tlVIS');
                            end
                            tlVIS = [];
                        end
                    end
                    if ~isempty(WV)
                        if length(WV(1,1,:))>sTop
%                             if exist(char(savePath.concat('WV.mat')),'file')
%                                 tmp = load(char(savePath.concat('WV.mat')),'WV');
%                                 WV = cat(3,tmp.('WV'),WV);
%                             end
%                             save(char(savePath.concat('WV.mat')),'WV','-v7.3');
                            %n = getFilesCount(savePath,'WV');
                            save(char(savePath.concat(strcat('WV-',num2str(n),'.mat'))),'WV','-v7.3');
                            disp(char(strcat(num2str(length(WV(1,1,:))*n),{' WV saved files (Processed files '},{' '},num2str(f),{' of '},num2str(length(dirData)-3),')')));
                            try
                                clear WV;
                            catch
                                disp('Error, cannot delete var WV');
                            end
                            WV = [];
                        end
                        if length(tlWV(:,1))>sTop
%                             if exist(char(savePath.concat('tlWV.mat')),'file')
%                                 tmp = load(char(savePath.concat('tlWV.mat')),'tlWV');
%                                 tlWV = cat(1,tmp.('tlWV'),tlWV);
%                             end
%                             save(char(savePath.concat('tlWV.mat')),'tlWV','-v7.3');
                            %n = getFilesCount(savePath,'tlWV');
                            save(char(savePath.concat(strcat('tlWV-',num2str(n),'.mat'))),'tlWV','-v7.3');
                            try
                                clear tlWV;
                            catch
                                disp('Error, cannot delete var tlWV');
                            end
                            tlWV = [];
                        end
                    end
                    %GOES = cat(3,GOES,prodata);
                end
                fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                fprintf(fid, '[SAVED][%s] %s\n',char(datestr(now)),char(fileT));
                fclose(fid);
%                 disp(char(strcat({'Data saved: '},char(fileT))));
                delete(char(fileT));

            catch exception
                if(exist(char(logPath),'dir'))
                    try
                        fid = fopen(strcat(char(logPath),'log.txt'), 'at+');
                        fprintf(fid, '[ERROR][%s] %s\n %s\n',char(datestr(now)),char(fileT),char(exception.message));
                        fclose(fid);
                    catch
                    end
                end
                disp(exception.message);
                disp(char(fileT));
                continue;
            end
        else
            if isequal(dirData(f).isdir,1)
                newPath = char(path.concat(dirData(f).name));
                [IR4,VIS,WV,tlIR4,tlVIS,tlWV] = dataProcessingIR4({newPath,char(savePath.concat(dirData(f).name)),char(logPath)},IR4,VIS,WV,tlIR4,tlVIS,tlWV);
            end
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

function [audit,err] = getAUDIT(fileName)
    err = NaN;
    try
        fid = fopen(fileName);
        rawdata = fread(fid);
        audit = reshape(rawdata,80,[])';%ldatasec,[]);
    catch exception
        audit = NaN;
        char(exception.message);
    end
end

function [nav,err] = getNAV(fileName)
    err = NaN;
    try
        %map = memmapfile(fileName,'Format',{'int32',1,'W1';'int32',1,'W2';'int32',1,'W3';'int32',1,'W4';'int32',1,'W5';'int32',1,'W6';'int32',1,'W7';'int32',1,'W8';'int32',1,'W9';'int32',1,'W10';'int32',1,'W11';'int32',1,'W12';'int32',1,'W13';'int32',1,'W14';'int32',1,'W15';'int32',1,'W16';'int32',1,'W17';'int32',1,'W18';'int32',1,'W19';'int32',1,'W20';'int32',1,'W21';'int32',1,'W22';'int32',1,'W23';'int32',1,'W24';'int32',1,'W25';'int32',1,'W26';'int32',1,'W27';'int32',1,'W28';'int32',1,'W29';'int32',1,'W30';'int32',1,'W31';'int32',1,'W32';'int32',1,'W33';'int32',1,'W34';'int32',1,'W35';'int32',1,'W36';'int32',1,'W37';'int32',1,'W38';'int32',1,'W39';'int32',1,'W40';'int32',1,'W41';'int32',1,'W42';'int32',1,'W43';'int32',1,'W44';'int32',1,'W45';'int32',1,'W46';'int32',1,'W47';'int32',1,'W48';'int32',1,'W49';'int32',1,'W50';'int32',1,'W51';'int32',1,'W52';'int32',1,'W53';'int32',1,'W54';'int32',1,'W55';'int32',1,'W56';'int32',1,'W57';'int32',1,'W58';'int32',1,'W59';'int32',1,'W60';'int32',1,'W61';'int32',1,'W62';'int32',1,'W63';'int32',1,'W64';'int32',1,'W65';'int32',1,'W66';'int32',1,'W67';'int32',1,'W68';'int32',1,'W69';'int32',1,'W70';'int32',1,'W71';'int32',1,'W72';'int32',1,'W73';'int32',1,'W74';'int32',1,'W75';'int32',1,'W76';'int32',1,'W77';'int32',1,'W78';'int32',1,'W79';'int32',1,'W80';'int32',1,'W81';'int32',1,'W82';'int32',1,'W83';'int32',1,'W84';'int32',1,'W85';'int32',1,'W86';'int32',1,'W87';'int32',1,'W88';'int32',1,'W89';'int32',1,'W90';'int32',1,'W91';'int32',1,'W92';'int32',1,'W93';'int32',1,'W94';'int32',1,'W95';'int32',1,'W96';'int32',1,'W97';'int32',1,'W98';'int32',1,'W99';'int32',1,'W100';'int32',1,'W101';'int32',1,'W102';'int32',1,'W103';'int32',1,'W104';'int32',1,'W105';'int32',1,'W106';'int32',1,'W107';'int32',1,'W108';'int32',1,'W109';'int32',1,'W110';'int32',1,'W111';'int32',1,'W112';'int32',1,'W113';'int32',1,'W114';'int32',1,'W115';'int32',1,'W116';'int32',1,'W117';'int32',1,'W118';'int32',1,'W119';'int32',1,'W120';'int32',1,'W121';'int32',1,'W122';'int32',1,'W123';'int32',1,'W124';'int32',1,'W125';'int32',1,'W126';'int32',1,'W127';'int32',1,'W128';'int32',1,'W129';'int32',1,'W130';'int32',1,'W131';'int32',1,'W132';'int32',1,'W133';'int32',1,'W134';'int32',1,'W135';'int32',1,'W136';'int32',1,'W137';'int32',1,'W138';'int32',1,'W139';'int32',1,'W140';'int32',1,'W141';'int32',1,'W142';'int32',1,'W143';'int32',1,'W144';'int32',1,'W145';'int32',1,'W146';'int32',1,'W147';'int32',1,'W148';'int32',1,'W149';'int32',1,'W150';'int32',1,'W151';'int32',1,'W152';'int32',1,'W153';'int32',1,'W154';'int32',1,'W155';'int32',1,'W156';'int32',1,'W157';'int32',1,'W158';'int32',1,'W159';'int32',1,'W160';'int32',1,'W161';'int32',1,'W162';'int32',1,'W163';'int32',1,'W164';'int32',1,'W165';'int32',1,'W166';'int32',1,'W167';'int32',1,'W168';'int32',1,'W169';'int32',1,'W170';'int32',1,'W171';'int32',1,'W172';'int32',1,'W173';'int32',1,'W174';'int32',1,'W175';'int32',1,'W176';'int32',1,'W177';'int32',1,'W178';'int32',1,'W179';'int32',1,'W180';'int32',1,'W181';'int32',1,'W182';'int32',1,'W183';'int32',1,'W184';'int32',1,'W185';'int32',1,'W186';'int32',1,'W187';'int32',1,'W188';'int32',1,'W189';'int32',1,'W190';'int32',1,'W191';'int32',1,'W192';'int32',1,'W193';'int32',1,'W194';'int32',1,'W195';'int32',1,'W196';'int32',1,'W197';'int32',1,'W198';'int32',1,'W199';'int32',1,'W200';'int32',1,'W201';'int32',1,'W202';'int32',1,'W203';'int32',1,'W204';'int32',1,'W205';'int32',1,'W206';'int32',1,'W207';'int32',1,'W208';'int32',1,'W209';'int32',1,'W210';'int32',1,'W211';'int32',1,'W212';'int32',1,'W213';'int32',1,'W214';'int32',1,'W215';'int32',1,'W216';'int32',1,'W217';'int32',1,'W218';'int32',1,'W219';'int32',1,'W220';'int32',1,'W221';'int32',1,'W222';'int32',1,'W223';'int32',1,'W224';'int32',1,'W225';'int32',1,'W226';'int32',1,'W227';'int32',1,'W228';'int32',1,'W229';'int32',1,'W230';'int32',1,'W231';'int32',1,'W232';'int32',1,'W233';'int32',1,'W234';'int32',1,'W235';'int32',1,'W236';'int32',1,'W237';'int32',1,'W238';'int32',1,'W239';'int32',1,'W240';'int32',1,'W241';'int32',1,'W242';'int32',1,'W243';'int32',1,'W244';'int32',1,'W245';'int32',1,'W246';'int32',1,'W247';'int32',1,'W248';'int32',1,'W249';'int32',1,'W250';'int32',1,'W251';'int32',1,'W252';'int32',1,'W253';'int32',1,'W254';'int32',1,'W255';'int32',1,'W256';'int32',1,'W257';'int32',1,'W258';'int32',1,'W259';'int32',1,'W260';'int32',1,'W261';'int32',1,'W262';'int32',1,'W263';'int32',1,'W264';'int32',1,'W265';'int32',1,'W266';'int32',1,'W267';'int32',1,'W268';'int32',1,'W269';'int32',1,'W270';'int32',1,'W271';'int32',1,'W272';'int32',1,'W273';'int32',1,'W274';'int32',1,'W275';'int32',1,'W276';'int32',1,'W277';'int32',1,'W278';'int32',1,'W279';'int32',1,'W280';'int32',1,'W281';'int32',1,'W282';'int32',1,'W283';'int32',1,'W284';'int32',1,'W285';'int32',1,'W286';'int32',1,'W287';'int32',1,'W288';'int32',1,'W289';'int32',1,'W290';'int32',1,'W291';'int32',1,'W292';'int32',1,'W293';'int32',1,'W294';'int32',1,'W295';'int32',1,'W296';'int32',1,'W297';'int32',1,'W298';'int32',1,'W299';'int32',1,'W300';'int32',1,'W301';'int32',1,'W302';'int32',1,'W303';'int32',1,'W304';'int32',1,'W305';'int32',1,'W306';'int32',1,'W307';'int32',1,'W308';'int32',1,'W309';'int32',1,'W310';'int32',1,'W311';'int32',1,'W312';'int32',1,'W313';'int32',1,'W314';'int32',1,'W315';'int32',1,'W316';'int32',1,'W317';'int32',1,'W318';'int32',1,'W319';'int32',1,'W320';'int32',1,'W321';'int32',1,'W322';'int32',1,'W323';'int32',1,'W324';'int32',1,'W325';'int32',1,'W326';'int32',1,'W327';'int32',1,'W328';'int32',1,'W329';'int32',1,'W330';'int32',1,'W331';'int32',1,'W332';'int32',1,'W333';'int32',1,'W334';'int32',1,'W335';'int32',1,'W336';'int32',1,'W337';'int32',1,'W338';'int32',1,'W339';'int32',1,'W340';'int32',1,'W341';'int32',1,'W342';'int32',1,'W343';'int32',1,'W344';'int32',1,'W345';'int32',1,'W346';'int32',1,'W347';'int32',1,'W348';'int32',1,'W349';'int32',1,'W350';'int32',1,'W351';'int32',1,'W352';'int32',1,'W353';'int32',1,'W354';'int32',1,'W355';'int32',1,'W356';'int32',1,'W357';'int32',1,'W358';'int32',1,'W359';'int32',1,'W360';'int32',1,'W361';'int32',1,'W362';'int32',1,'W363';'int32',1,'W364';'int32',1,'W365';'int32',1,'W366';'int32',1,'W367';'int32',1,'W368';'int32',1,'W369';'int32',1,'W370';'int32',1,'W371';'int32',1,'W372';'int32',1,'W373';'int32',1,'W374';'int32',1,'W375';'int32',1,'W376';'int32',1,'W377';'int32',1,'W378';'int32',1,'W379';'int32',1,'W380';'int32',1,'W381';'int32',1,'W382';'int32',1,'W383';'int32',1,'W384';'int32',1,'W385';'int32',1,'W386';'int32',1,'W387';'int32',1,'W388';'int32',1,'W389';'int32',1,'W390';'int32',1,'W391';'int32',1,'W392';'int32',1,'W393';'int32',1,'W394';'int32',1,'W395';'int32',1,'W396';'int32',1,'W397';'int32',1,'W398';'int32',1,'W399';'int32',1,'W400';'int32',1,'W401';'int32',1,'W402';'int32',1,'W403';'int32',1,'W404';'int32',1,'W405';'int32',1,'W406';'int32',1,'W407';'int32',1,'W408';'int32',1,'W409';'int32',1,'W410';'int32',1,'W411';'int32',1,'W412';'int32',1,'W413';'int32',1,'W414';'int32',1,'W415';'int32',1,'W416';'int32',1,'W417';'int32',1,'W418';'int32',1,'W419';'int32',1,'W420';'int32',1,'W421';'int32',1,'W422';'int32',1,'W423';'int32',1,'W424';'int32',1,'W425';'int32',1,'W426';'int32',1,'W427';'int32',1,'W428';'int32',1,'W429';'int32',1,'W430';'int32',1,'W431';'int32',1,'W432';'int32',1,'W433';'int32',1,'W434';'int32',1,'W435';'int32',1,'W436';'int32',1,'W437';'int32',1,'W438';'int32',1,'W439';'int32',1,'W440';'int32',1,'W441';'int32',1,'W442';'int32',1,'W443';'int32',1,'W444';'int32',1,'W445';'int32',1,'W446';'int32',1,'W447';'int32',1,'W448';'int32',1,'W449';'int32',1,'W450';'int32',1,'W451';'int32',1,'W452';'int32',1,'W453';'int32',1,'W454';'int32',1,'W455';'int32',1,'W456';'int32',1,'W457';'int32',1,'W458';'int32',1,'W459';'int32',1,'W460';'int32',1,'W461';'int32',1,'W462';'int32',1,'W463';'int32',1,'W464';'int32',1,'W465';'int32',1,'W466';'int32',1,'W467';'int32',1,'W468';'int32',1,'W469';'int32',1,'W470';'int32',1,'W471';'int32',1,'W472';'int32',1,'W473';'int32',1,'W474';'int32',1,'W475';'int32',1,'W476';'int32',1,'W477';'int32',1,'W478';'int32',1,'W479';'int32',1,'W480';'int32',1,'W481';'int32',1,'W482';'int32',1,'W483';'int32',1,'W484';'int32',1,'W485';'int32',1,'W486';'int32',1,'W487';'int32',1,'W488';'int32',1,'W489';'int32',1,'W490';'int32',1,'W491';'int32',1,'W492';'int32',1,'W493';'int32',1,'W494';'int32',1,'W495';'int32',1,'W496';'int32',1,'W497';'int32',1,'W498';'int32',1,'W499';'int32',1,'W500';'int32',1,'W501';'int32',1,'W502';'int32',1,'W503';'int32',1,'W504';'int32',1,'W505';'int32',1,'W506';'int32',1,'W507';'int32',1,'W508';'int32',1,'W509';'int32',1,'W510';'int32',1,'W511';'int32',1,'W512';'int32',1,'W513';'int32',1,'W514';'int32',1,'W515';'int32',1,'W516';'int32',1,'W517';'int32',1,'W518';'int32',1,'W519';'int32',1,'W520';'int32',1,'W521';'int32',1,'W522';'int32',1,'W523';'int32',1,'W524';'int32',1,'W525';'int32',1,'W526';'int32',1,'W527';'int32',1,'W528';'int32',1,'W529';'int32',1,'W530';'int32',1,'W531';'int32',1,'W532';'int32',1,'W533';'int32',1,'W534';'int32',1,'W535';'int32',1,'W536';'int32',1,'W537';'int32',1,'W538';'int32',1,'W539';'int32',1,'W540';'int32',1,'W541';'int32',1,'W542';'int32',1,'W543';'int32',1,'W544';'int32',1,'W545';'int32',1,'W546';'int32',1,'W547';'int32',1,'W548';'int32',1,'W549';'int32',1,'W550';'int32',1,'W551';'int32',1,'W552';'int32',1,'W553';'int32',1,'W554';'int32',1,'W555';'int32',1,'W556';'int32',1,'W557';'int32',1,'W558';'int32',1,'W559';'int32',1,'W560';'int32',1,'W561';'int32',1,'W562';'int32',1,'W563';'int32',1,'W564';'int32',1,'W565';'int32',1,'W566';'int32',1,'W567';'int32',1,'W568';'int32',1,'W569';'int32',1,'W570';'int32',1,'W571';'int32',1,'W572';'int32',1,'W573';'int32',1,'W574';'int32',1,'W575';'int32',1,'W576';'int32',1,'W577';'int32',1,'W578';'int32',1,'W579';'int32',1,'W580';'int32',1,'W581';'int32',1,'W582';'int32',1,'W583';'int32',1,'W584';'int32',1,'W585';'int32',1,'W586';'int32',1,'W587';'int32',1,'W588';'int32',1,'W589';'int32',1,'W590';'int32',1,'W591';'int32',1,'W592';'int32',1,'W593';'int32',1,'W594';'int32',1,'W595';'int32',1,'W596';'int32',1,'W597';'int32',1,'W598';'int32',1,'W599';'int32',1,'W600';'int32',1,'W601';'int32',1,'W602';'int32',1,'W603';'int32',1,'W604';'int32',1,'W605';'int32',1,'W606';'int32',1,'W607';'int32',1,'W608';'int32',1,'W609';'int32',1,'W610';'int32',1,'W611';'int32',1,'W612';'int32',1,'W613';'int32',1,'W614';'int32',1,'W615';'int32',1,'W616';'int32',1,'W617';'int32',1,'W618';'int32',1,'W619';'int32',1,'W620';'int32',1,'W621';'int32',1,'W622';'int32',1,'W623';'int32',1,'W624';'int32',1,'W625';'int32',1,'W626';'int32',1,'W627';'int32',1,'W628';'int32',1,'W629';'int32',1,'W630';'int32',1,'W631';'int32',1,'W632';'int32',1,'W633';'int32',1,'W634';'int32',1,'W635';'int32',1,'W636';'int32',1,'W637';'int32',1,'W638';'int32',1,'W639';'int32',1,'W640'});
        %map = memmapfile(fileName,'Format',{'int64',1,'W1';'int64',1,'W2';'int64',1,'W3';'int64',1,'W4';'int64',1,'W5';'int64',1,'W6';'int64',1,'W7';'int64',1,'W8';'int64',1,'W9';'int64',1,'W10';'int64',1,'W11';'int64',1,'W12';'int64',1,'W13';'int64',1,'W14';'int64',1,'W15';'int64',1,'W16';'int64',1,'W17';'int64',1,'W18';'int64',1,'W19';'int64',1,'W20';'int64',1,'W21';'int64',1,'W22';'int64',1,'W23';'int64',1,'W24';'int64',1,'W25';'int64',1,'W26';'int64',1,'W27';'int64',1,'W28';'int64',1,'W29';'int64',1,'W30';'int64',1,'W31';'int64',1,'W32';'int64',1,'W33';'int64',1,'W34';'int64',1,'W35';'int64',1,'W36';'int64',1,'W37';'int64',1,'W38';'int64',1,'W39';'int64',1,'W40';'int64',1,'W41';'int64',1,'W42';'int64',1,'W43';'int64',1,'W44';'int64',1,'W45';'int64',1,'W46';'int64',1,'W47';'int64',1,'W48';'int64',1,'W49';'int64',1,'W50';'int64',1,'W51';'int64',1,'W52';'int64',1,'W53';'int64',1,'W54';'int64',1,'W55';'int64',1,'W56';'int64',1,'W57';'int64',1,'W58';'int64',1,'W59';'int64',1,'W60';'int64',1,'W61';'int64',1,'W62';'int64',1,'W63';'int64',1,'W64';'int64',1,'W65';'int64',1,'W66';'int64',1,'W67';'int64',1,'W68';'int64',1,'W69';'int64',1,'W70';'int64',1,'W71';'int64',1,'W72';'int64',1,'W73';'int64',1,'W74';'int64',1,'W75';'int64',1,'W76';'int64',1,'W77';'int64',1,'W78';'int64',1,'W79';'int64',1,'W80';'int64',1,'W81';'int64',1,'W82';'int64',1,'W83';'int64',1,'W84';'int64',1,'W85';'int64',1,'W86';'int64',1,'W87';'int64',1,'W88';'int64',1,'W89';'int64',1,'W90';'int64',1,'W91';'int64',1,'W92';'int64',1,'W93';'int64',1,'W94';'int64',1,'W95';'int64',1,'W96';'int64',1,'W97';'int64',1,'W98';'int64',1,'W99';'int64',1,'W100';'int64',1,'W101';'int64',1,'W102';'int64',1,'W103';'int64',1,'W104';'int64',1,'W105';'int64',1,'W106';'int64',1,'W107';'int64',1,'W108';'int64',1,'W109';'int64',1,'W110';'int64',1,'W111';'int64',1,'W112';'int64',1,'W113';'int64',1,'W114';'int64',1,'W115';'int64',1,'W116';'int64',1,'W117';'int64',1,'W118';'int64',1,'W119';'int64',1,'W120';'int64',1,'W121';'int64',1,'W122';'int64',1,'W123';'int64',1,'W124';'int64',1,'W125';'int64',1,'W126';'int64',1,'W127';'int64',1,'W128'});
        %map = memmapfile(fileName,'Format',{'int32',1,'W1';'int32',1,'W2';'int32',1,'W3';'int32',1,'W4';'int32',1,'W5';'int32',1,'W6';'int32',1,'W7';'int32',1,'W8';'int32',1,'W9';'int32',1,'W10';'int32',1,'W11';'int32',1,'W12';'int32',1,'W13';'int32',1,'W14';'int32',1,'W15';'int32',1,'W16';'int32',1,'W17';'int32',1,'W18';'int32',1,'W19';'int32',1,'W20';'int32',1,'W21';'int32',1,'W22';'int32',1,'W23';'int32',1,'W24';'int32',1,'W25';'int32',1,'W26';'int32',1,'W27';'int32',1,'W28';'int32',1,'W29';'int32',1,'W30';'int32',1,'W31';'int32',1,'W32';'int32',1,'W33';'int32',1,'W34';'int32',1,'W35';'int32',1,'W36';'int32',1,'W37';'int32',1,'W38';'int32',1,'W39';'int32',1,'W40';'int32',1,'W41';'int32',1,'W42';'int32',1,'W43';'int32',1,'W44';'int32',1,'W45';'int32',1,'W46';'int32',1,'W47';'int32',1,'W48';'int32',1,'W49';'int32',1,'W50';'int32',1,'W51';'int32',1,'W52';'int32',1,'W53';'int32',1,'W54';'int32',1,'W55';'int32',1,'W56';'int32',1,'W57';'int32',1,'W58';'int32',1,'W59';'int32',1,'W60';'int32',1,'W61';'int32',1,'W62';'int32',1,'W63';'int32',1,'W64';'int32',1,'W65';'int32',1,'W66';'int32',1,'W67';'int32',1,'W68';'int32',1,'W69';'int32',1,'W70';'int32',1,'W71';'int32',1,'W72';'int32',1,'W73';'int32',1,'W74';'int32',1,'W75';'int32',1,'W76';'int32',1,'W77';'int32',1,'W78';'int32',1,'W79';'int32',1,'W80';'int32',1,'W81';'int32',1,'W82';'int32',1,'W83';'int32',1,'W84';'int32',1,'W85';'int32',1,'W86';'int32',1,'W87';'int32',1,'W88';'int32',1,'W89';'int32',1,'W90';'int32',1,'W91';'int32',1,'W92';'int32',1,'W93';'int32',1,'W94';'int32',1,'W95';'int32',1,'W96';'int32',1,'W97';'int32',1,'W98';'int32',1,'W99';'int32',1,'W100';'int32',1,'W101';'int32',1,'W102';'int32',1,'W103';'int32',1,'W104';'int32',1,'W105';'int32',1,'W106';'int32',1,'W107';'int32',1,'W108';'int32',1,'W109';'int32',1,'W110';'int32',1,'W111';'int32',1,'W112';'int32',1,'W113';'int32',1,'W114';'int32',1,'W115';'int32',1,'W116';'int32',1,'W117';'int32',1,'W118';'int32',1,'W119';'int32',1,'W120';'int32',1,'W121';'int32',1,'W122';'int32',1,'W123';'int32',1,'W124';'int32',1,'W125';'int32',1,'W126';'int32',1,'W127';'int32',1,'W128'});
        map = memmapfile(fileName,'Format',{'uint8',[1 4],'W1';'uint8',[1 4],'W2';'int32',1,'W3';'int32',1,'W4';'int32',1,'W5';'int32',1,'W6';'int32',1,'W7';'int32',1,'W8';'int32',1,'W9';'int32',1,'W10';'int32',1,'W11';'int32',1,'W12';'int32',1,'W13';'int32',1,'W14';'int32',1,'W15';'int32',1,'W16';'int32',1,'W17';'int32',1,'W18';'int32',1,'W19';'int32',1,'W20';'int32',1,'W21';'int32',1,'W22';'int32',1,'W23';'int32',1,'W24';'int32',1,'W25';'int32',1,'W26';'int32',1,'W27';'int32',1,'W28';'int32',1,'W29';'int32',1,'W30';'int32',1,'W31';'int32',1,'W32';'int32',1,'W33';'int32',1,'W34';'int32',1,'W35';'int32',1,'W36';'int32',1,'W37';'int32',1,'W38';'int32',1,'W39';'int32',1,'W40';'int32',1,'W41';'int32',1,'W42';'int32',1,'W43';'int32',1,'W44';'int32',1,'W45';'int32',1,'W46';'int32',1,'W47';'int32',1,'W48';'int32',1,'W49';'int32',1,'W50';'int32',1,'W51';'int32',1,'W52';'int32',1,'W53';'int32',1,'W54';'int32',1,'W55';'int32',1,'W56';'int32',1,'W57';'int32',1,'W58';'int32',1,'W59';'int32',1,'W60';'int32',1,'W61';'int32',1,'W62';'int32',1,'W63';'int32',1,'W64';'int32',1,'W65';'int32',1,'W66';'int32',1,'W67';'int32',1,'W68';'int32',1,'W69';'int32',1,'W70';'int32',1,'W71';'int32',1,'W72';'int32',1,'W73';'int32',1,'W74';'int32',1,'W75';'int32',1,'W76';'int32',1,'W77';'int32',1,'W78';'int32',1,'W79';'int32',1,'W80';'int32',1,'W81';'int32',1,'W82';'int32',1,'W83';'int32',1,'W84';'int32',1,'W85';'int32',1,'W86';'int32',1,'W87';'int32',1,'W88';'int32',1,'W89';'int32',1,'W90';'int32',1,'W91';'int32',1,'W92';'int32',1,'W93';'int32',1,'W94';'int32',1,'W95';'int32',1,'W96';'int32',1,'W97';'int32',1,'W98';'int32',1,'W99';'int32',1,'W100';'int32',1,'W101';'int32',1,'W102';'int32',1,'W103';'int32',1,'W104';'int32',1,'W105';'int32',1,'W106';'int32',1,'W107';'int32',1,'W108';'int32',1,'W109';'int32',1,'W110';'int32',1,'W111';'int32',1,'W112';'int32',1,'W113';'int32',1,'W114';'int32',1,'W115';'int32',1,'W116';'int32',1,'W117';'int32',1,'W118';'int32',1,'W119';'int32',1,'W120';'int32',1,'W121';'int32',1,'W122';'int32',1,'W123';'int32',1,'W124';'int32',1,'W125';'int32',1,'W126';'int32',1,'W127';'int32',1,'W128'});
        nav = map.Data;
        clear map;
        if length(nav)>1
            map = memmapfile(fileName,'Format',{'uint8',[1 4],'W1';'uint8',[1 4],'W2';'uint32',1,'W3';'uint32',1,'W4';'int32',1,'W5';'int32',1,'W6';'int32',1,'W7';'int32',1,'W8';'int32',1,'W9';'uint32',1,'W10';'int32',1,'W11';'int32',1,'W12';'int32',1,'W13';'int32',1,'W14';'int32',1,'W15';'int32',1,'W16';'int32',1,'W17';'int32',1,'W18';'int32',1,'W19';'int32',1,'W20';'int32',1,'W21';'int32',1,'W22';'int32',1,'W23';'int32',1,'W24';'int32',1,'W25';'int32',1,'W26';'int32',1,'W27';'int32',1,'W28';'int32',1,'W29';'int32',1,'W30';'int32',1,'W31';'int32',1,'W32';'int32',1,'W33';'int32',1,'W34';'int32',1,'W35';'int32',1,'W36';'int32',1,'W37';'int32',1,'W38';'int32',1,'W39';'int32',1,'W40';'int32',1,'W41';'int32',1,'W42';'int32',1,'W43';'int32',1,'W44';'int32',1,'W45';'int32',1,'W46';'int32',1,'W47';'int32',1,'W48';'int32',1,'W49';'int32',1,'W50';'int32',1,'W51';'int32',1,'W52';'int32',1,'W53';'int32',1,'W54';'int32',1,'W55';'int32',1,'W56';'int32',1,'W57';'int32',1,'W58';'int32',1,'W59';'int32',1,'W60';'int32',1,'W61';'int32',1,'W62';'int32',1,'W63';'int32',1,'W64';'int32',1,'W65';'int32',1,'W66';'int32',1,'W67';'int32',1,'W68';'int32',1,'W69';'int32',1,'W70';'int32',1,'W71';'int32',1,'W72';'int32',1,'W73';'int32',1,'W74';'int32',1,'W75';'int32',1,'W76';'int32',1,'W77';'int32',1,'W78';'int32',1,'W79';'int32',1,'W80';'int32',1,'W81';'int32',1,'W82';'int32',1,'W83';'int32',1,'W84';'int32',1,'W85';'int32',1,'W86';'int32',1,'W87';'int32',1,'W88';'int32',1,'W89';'int32',1,'W90';'int32',1,'W91';'int32',1,'W92';'int32',1,'W93';'int32',1,'W94';'int32',1,'W95';'int32',1,'W96';'int32',1,'W97';'int32',1,'W98';'int32',1,'W99';'int32',1,'W100';'int32',1,'W101';'int32',1,'W102';'int32',1,'W103';'int32',1,'W104';'int32',1,'W105';'int32',1,'W106';'int32',1,'W107';'int32',1,'W108';'int32',1,'W109';'int32',1,'W110';'int32',1,'W111';'int32',1,'W112';'int32',1,'W113';'int32',1,'W114';'int32',1,'W115';'int32',1,'W116';'int32',1,'W117';'int32',1,'W118';'int32',1,'W119';'int32',1,'W120';'int32',1,'W121';'int32',1,'W122';'int32',1,'W123';'int32',1,'W124';'int32',1,'W125';'int32',1,'W126';'int32',1,'W127';'uint8',[1 4],'W128';'uint8',[1 4],'W129';'int32',1,'W130';'int32',1,'W131';'int32',1,'W132';'int32',1,'W133';'int32',1,'W134';'int32',1,'W135';'int32',1,'W136';'int32',1,'W137';'int32',1,'W138';'int32',1,'W139';'int32',1,'W140';'int32',1,'W141';'int32',1,'W142';'int32',1,'W143';'int32',1,'W144';'int32',1,'W145';'int32',1,'W146';'int32',1,'W147';'int32',1,'W148';'int32',1,'W149';'int32',1,'W150';'int32',1,'W151';'int32',1,'W152';'int32',1,'W153';'int32',1,'W154';'int32',1,'W155';'int32',1,'W156';'int32',1,'W157';'int32',1,'W158';'int32',1,'W159';'int32',1,'W160';'int32',1,'W161';'int32',1,'W162';'int32',1,'W163';'int32',1,'W164';'int32',1,'W165';'int32',1,'W166';'int32',1,'W167';'int32',1,'W168';'int32',1,'W169';'int32',1,'W170';'int32',1,'W171';'int32',1,'W172';'int32',1,'W173';'int32',1,'W174';'int32',1,'W175';'int32',1,'W176';'int32',1,'W177';'int32',1,'W178';'int32',1,'W179';'int32',1,'W180';'int32',1,'W181';'int32',1,'W182';'int32',1,'W183';'int32',1,'W184';'int32',1,'W185';'int32',1,'W186';'int32',1,'W187';'int32',1,'W188';'int32',1,'W189';'int32',1,'W190';'int32',1,'W191';'int32',1,'W192';'int32',1,'W193';'int32',1,'W194';'int32',1,'W195';'int32',1,'W196';'int32',1,'W197';'int32',1,'W198';'int32',1,'W199';'int32',1,'W200';'int32',1,'W201';'int32',1,'W202';'int32',1,'W203';'int32',1,'W204';'int32',1,'W205';'int32',1,'W206';'int32',1,'W207';'int32',1,'W208';'int32',1,'W209';'int32',1,'W210';'int32',1,'W211';'int32',1,'W212';'int32',1,'W213';'int32',1,'W214';'int32',1,'W215';'int32',1,'W216';'int32',1,'W217';'int32',1,'W218';'int32',1,'W219';'int32',1,'W220';'int32',1,'W221';'int32',1,'W222';'int32',1,'W223';'int32',1,'W224';'int32',1,'W225';'int32',1,'W226';'int32',1,'W227';'int32',1,'W228';'int32',1,'W229';'int32',1,'W230';'int32',1,'W231';'int32',1,'W232';'int32',1,'W233';'int32',1,'W234';'int32',1,'W235';'int32',1,'W236';'int32',1,'W237';'int32',1,'W238';'int32',1,'W239';'int32',1,'W240';'int32',1,'W241';'int32',1,'W242';'int32',1,'W243';'int32',1,'W244';'int32',1,'W245';'int32',1,'W246';'int32',1,'W247';'int32',1,'W248';'int32',1,'W249';'int32',1,'W250';'int32',1,'W251';'int32',1,'W252';'int32',1,'W253';'int32',1,'W254';'int32',1,'W255';'int32',1,'W256';'int32',1,'W257';'int32',1,'W258';'int32',1,'W259';'int32',1,'W260';'int32',1,'W261';'int32',1,'W262';'int32',1,'W263';'int32',1,'W264';'int32',1,'W265';'int32',1,'W266';'int32',1,'W267';'int32',1,'W268';'int32',1,'W269';'int32',1,'W270';'int32',1,'W271';'int32',1,'W272';'int32',1,'W273';'int32',1,'W274';'int32',1,'W275';'int32',1,'W276';'int32',1,'W277';'int32',1,'W278';'int32',1,'W279';'int32',1,'W280';'int32',1,'W281';'int32',1,'W282';'int32',1,'W283';'int32',1,'W284';'int32',1,'W285';'int32',1,'W286';'int32',1,'W287';'int32',1,'W288';'int32',1,'W289';'int32',1,'W290';'int32',1,'W291';'int32',1,'W292';'int32',1,'W293';'int32',1,'W294';'int32',1,'W295';'int32',1,'W296';'int32',1,'W297';'int32',1,'W298';'int32',1,'W299';'int32',1,'W300';'int32',1,'W301';'int32',1,'W302';'int32',1,'W303';'int32',1,'W304';'int32',1,'W305';'int32',1,'W306';'int32',1,'W307';'int32',1,'W308';'int32',1,'W309';'int32',1,'W310';'int32',1,'W311';'int32',1,'W312';'int32',1,'W313';'int32',1,'W314';'int32',1,'W315';'int32',1,'W316';'int32',1,'W317';'int32',1,'W318';'int32',1,'W319';'int32',1,'W320';'int32',1,'W321';'int32',1,'W322';'int32',1,'W323';'int32',1,'W324';'int32',1,'W325';'int32',1,'W326';'int32',1,'W327';'int32',1,'W328';'int32',1,'W329';'int32',1,'W330';'int32',1,'W331';'int32',1,'W332';'int32',1,'W333';'int32',1,'W334';'int32',1,'W335';'int32',1,'W336';'int32',1,'W337';'int32',1,'W338';'int32',1,'W339';'int32',1,'W340';'int32',1,'W341';'int32',1,'W342';'int32',1,'W343';'int32',1,'W344';'int32',1,'W345';'int32',1,'W346';'int32',1,'W347';'int32',1,'W348';'int32',1,'W349';'int32',1,'W350';'int32',1,'W351';'int32',1,'W352';'int32',1,'W353';'int32',1,'W354';'int32',1,'W355';'int32',1,'W356';'int32',1,'W357';'int32',1,'W358';'int32',1,'W359';'int32',1,'W360';'int32',1,'W361';'int32',1,'W362';'int32',1,'W363';'int32',1,'W364';'int32',1,'W365';'int32',1,'W366';'int32',1,'W367';'int32',1,'W368';'int32',1,'W369';'int32',1,'W370';'int32',1,'W371';'int32',1,'W372';'int32',1,'W373';'int32',1,'W374';'int32',1,'W375';'int32',1,'W376';'int32',1,'W377';'int32',1,'W378';'int32',1,'W379';'int32',1,'W380';'int32',1,'W381';'int32',1,'W382';'int32',1,'W383';'int32',1,'W384';'int32',1,'W385';'int32',1,'W386';'int32',1,'W387';'int32',1,'W388';'int32',1,'W389';'int32',1,'W390';'int32',1,'W391';'int32',1,'W392';'int32',1,'W393';'int32',1,'W394';'int32',1,'W395';'int32',1,'W396';'int32',1,'W397';'int32',1,'W398';'int32',1,'W399';'int32',1,'W400';'int32',1,'W401';'int32',1,'W402';'int32',1,'W403';'int32',1,'W404';'int32',1,'W405';'int32',1,'W406';'int32',1,'W407';'int32',1,'W408';'int32',1,'W409';'int32',1,'W410';'int32',1,'W411';'int32',1,'W412';'int32',1,'W413';'int32',1,'W414';'int32',1,'W415';'int32',1,'W416';'int32',1,'W417';'int32',1,'W418';'int32',1,'W419';'int32',1,'W420';'int32',1,'W421';'int32',1,'W422';'int32',1,'W423';'int32',1,'W424';'int32',1,'W425';'int32',1,'W426';'int32',1,'W427';'int32',1,'W428';'int32',1,'W429';'int32',1,'W430';'int32',1,'W431';'int32',1,'W432';'int32',1,'W433';'int32',1,'W434';'int32',1,'W435';'int32',1,'W436';'int32',1,'W437';'int32',1,'W438';'int32',1,'W439';'int32',1,'W440';'int32',1,'W441';'int32',1,'W442';'int32',1,'W443';'int32',1,'W444';'int32',1,'W445';'int32',1,'W446';'int32',1,'W447';'int32',1,'W448';'int32',1,'W449';'int32',1,'W450';'int32',1,'W451';'int32',1,'W452';'int32',1,'W453';'int32',1,'W454';'int32',1,'W455';'int32',1,'W456';'int32',1,'W457';'int32',1,'W458';'int32',1,'W459';'int32',1,'W460';'int32',1,'W461';'int32',1,'W462';'int32',1,'W463';'int32',1,'W464';'int32',1,'W465';'int32',1,'W466';'int32',1,'W467';'int32',1,'W468';'int32',1,'W469';'int32',1,'W470';'int32',1,'W471';'int32',1,'W472';'int32',1,'W473';'int32',1,'W474';'int32',1,'W475';'int32',1,'W476';'int32',1,'W477';'int32',1,'W478';'int32',1,'W479';'int32',1,'W480';'int32',1,'W481';'int32',1,'W482';'int32',1,'W483';'int32',1,'W484';'int32',1,'W485';'int32',1,'W486';'int32',1,'W487';'int32',1,'W488';'int32',1,'W489';'int32',1,'W490';'int32',1,'W491';'int32',1,'W492';'int32',1,'W493';'int32',1,'W494';'int32',1,'W495';'int32',1,'W496';'int32',1,'W497';'int32',1,'W498';'int32',1,'W499';'int32',1,'W500';'int32',1,'W501';'int32',1,'W502';'int32',1,'W503';'int32',1,'W504';'int32',1,'W505';'int32',1,'W506';'int32',1,'W507';'int32',1,'W508';'int32',1,'W509';'int32',1,'W510';'int32',1,'W511';'int32',1,'W512';'int32',1,'W513';'int32',1,'W514';'int32',1,'W515';'int32',1,'W516';'int32',1,'W517';'int32',1,'W518';'int32',1,'W519';'int32',1,'W520';'int32',1,'W521';'int32',1,'W522';'int32',1,'W523';'int32',1,'W524';'int32',1,'W525';'int32',1,'W526';'int32',1,'W527';'int32',1,'W528';'int32',1,'W529';'int32',1,'W530';'int32',1,'W531';'int32',1,'W532';'int32',1,'W533';'int32',1,'W534';'int32',1,'W535';'int32',1,'W536';'int32',1,'W537';'int32',1,'W538';'int32',1,'W539';'int32',1,'W540';'int32',1,'W541';'int32',1,'W542';'int32',1,'W543';'int32',1,'W544';'int32',1,'W545';'int32',1,'W546';'int32',1,'W547';'int32',1,'W548';'int32',1,'W549';'int32',1,'W550';'int32',1,'W551';'int32',1,'W552';'int32',1,'W553';'int32',1,'W554';'int32',1,'W555';'int32',1,'W556';'int32',1,'W557';'int32',1,'W558';'int32',1,'W559';'int32',1,'W560';'int32',1,'W561';'int32',1,'W562';'int32',1,'W563';'int32',1,'W564';'int32',1,'W565';'int32',1,'W566';'int32',1,'W567';'int32',1,'W568';'int32',1,'W569';'int32',1,'W570';'int32',1,'W571';'int32',1,'W572';'int32',1,'W573';'int32',1,'W574';'int32',1,'W575';'int32',1,'W576';'int32',1,'W577';'int32',1,'W578';'int32',1,'W579';'int32',1,'W580';'int32',1,'W581';'int32',1,'W582';'int32',1,'W583';'int32',1,'W584';'int32',1,'W585';'int32',1,'W586';'int32',1,'W587';'int32',1,'W588';'int32',1,'W589';'int32',1,'W590';'int32',1,'W591';'int32',1,'W592';'int32',1,'W593';'int32',1,'W594';'int32',1,'W595';'int32',1,'W596';'int32',1,'W597';'int32',1,'W598';'int32',1,'W599';'int32',1,'W600';'int32',1,'W601';'int32',1,'W602';'int32',1,'W603';'int32',1,'W604';'int32',1,'W605';'int32',1,'W606';'int32',1,'W607';'int32',1,'W608';'int32',1,'W609';'int32',1,'W610';'int32',1,'W611';'int32',1,'W612';'int32',1,'W613';'int32',1,'W614';'int32',1,'W615';'int32',1,'W616';'int32',1,'W617';'int32',1,'W618';'int32',1,'W619';'int32',1,'W620';'int32',1,'W621';'int32',1,'W622';'int32',1,'W623';'int32',1,'W624';'int32',1,'W625';'int32',1,'W626';'int32',1,'W627';'int32',1,'W628';'int32',1,'W629';'int32',1,'W630';'int32',1,'W631';'int32',1,'W632';'int32',1,'W633';'int32',1,'W634';'int32',1,'W635';'int32',1,'W636';'int32',1,'W637';'int32',1,'W638';'int32',1,'W639';'int32',1,'W640'});
            nav = map.Data;
            clear map;
            nav.W6 = nav.W6/10000000;
            nav.W7 = nav.W7/10000000;
            nav.W8 = nav.W8/10000000;
            nav.W9 = nav.W9/10000000;
            nav.W10 = nav.W10/10000000;
            nav.W11 = nav.W11/10000000;
            nav.W12 = nav.W12/10000000;
        end
    catch exception
        nav = NaN;
        err = char(exception.message);
    end
end

function [] = plotMap(data2D)
%     A=data2D(:,1);
%     data2Dh=[data2D,A];
    
    % Map grid
    lon = linspace(-91.3146,-77.2252,length(data2D(1,:)));%+1);
    lat = linspace(5.5728,14.5832,length(data2D(:,1)));
    
    [longrat,latgrat]=meshgrat(lon,lat);
    %testi=data2Dh;
    
    p=10;%p=round(latitud(2)-latitud(1));%[25:15:30];
    f = figure('visible', 'on');
    hold on;
    %worldmap([-91.3146,-77.2252],[5.5728,14.5832])
    worldmap([min(min(latgrat)) max(max(latgrat))],[min(min(longrat)) max(max(longrat))]);
    %mlabel('off')
    %plabel('off')
    framem('on')
    set(gcf,'Color',[1,1,1]);
    %hold on;
    %colormap(jet(50));%colormap(jet(50));
    load coastlines;
    [c,h]=contourfm(latgrat,longrat,data2D',p,'LineStyle','none');
    plotm(coastlat, coastlon, 'w');
%     hi = worldhi([-90 90],[-180 180]);
%     for i=1:length(hi)
%         disp(num2str(i));
%         plotm(hi(i).lat,hi(i).long,'k')
%     end
    print('SurfacePlot','-depsc','-tiff');
    disp('Map saved');
    %savefig('PeaksFile.fig')
    %close(f);
end

function[data] = filtrateData(data,temp)
    data(data<temp) = 0;
%     data(data<(temp-1)) = 0;
%     data(data>(temp+1)) = 0;
end

function findOverlapping(data,error)
    total = length(data(:,1,1))*length(data(1,:,1));
    for i=2:length(data(1,1,:))
        tmp = data(:,:,i)-data(:,:,i-1);
        n = sum(sum(abs(abs(tmp)<=error)));
        if (n/total)<0.5
            disp(num2str(i));
        end
    end
end