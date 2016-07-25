% Batch file
%     ren *.nco *.
%     ren *.gz *.
%     ren *. *.zip
%     pause
function [] = areaClassification3(dirName)
    if nargin < 1
        error('areaClassification3: dirName is a required input')
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
        ext = fileT.substring(fileT.lastIndexOf('.')+1);
        if(ext.equalsIgnoreCase('zip'))
            try
                unzip(char(fileT),char(path.concat('nreg')));
                if dir2file(path.concat('nreg'),path);
                    rmdir(char(path.concat('nreg')),'s');
                    delete(char(fileT));
                end
            catch e
                disp(e.message);
                continue;
            end
            if ~mod(f-2,100)
                disp(char(strcat({'Processed files '},{' '},num2str(f-2),{' of '},num2str(length(dirData)-2))));
            end
        end
    end
end

function [i] = dir2file(path,destiny)
    if nargin < 2
        destiny = path;
    end
    i = 0;
    dirData = dir(char(path));  % Get the data for the current directory
    path = java.lang.String(char(path));
    if(path.charAt(path.length-1) ~= '/')
        path = path.concat('/');
    end
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        try
            ext = fileT.substring(fileT.lastIndexOf('.')+1);
            name = fileT.substring(0,fileT.lastIndexOf('.'));
        catch
            ext = fileT;
        end
        if(ext.equalsIgnoreCase('gz'))
            fileT = path.concat(dirData(f).name);
            movefile(char(fileT),char(destiny.concat(char(strcat(char(name.substring(name.lastIndexOf('/')+1)),'.gz')))));
            i = 1;
            return;
        elseif isequal(dirData(f).isdir,1)
            newPath = char(path.concat(dirData(f).name));
            i = dir2file(newPath,destiny);
        end
    end
end