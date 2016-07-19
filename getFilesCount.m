function [n] = getFilesCount(path,root)
    n = 0;
    dirData = dir(char(path));
    for f = 3:length(dirData)
        fileT = path.concat(dirData(f).name);
        ext = fileT.substring(fileT.lastIndexOf('.')+1);
        if(ext.equalsIgnoreCase('mat'))
            try
                name = fileT.substring(fileT.lastIndexOf('/')+1,fileT.lastIndexOf('-'));
                if name.equals(root)
                    n = n + 1;
                end
            catch
                continue;
            end
        end
     end
     n  = n + 1;
end