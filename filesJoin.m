function filesJoin(path,root,dim)
    if nargin < 3
        dim = 3;
    end
    dirData = dir(char(path));
    data = [];
    n = 0;
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
    for i=1:n
        fileT = path.concat(strcat(root,'-',num2str(i),'.mat'));
        tmp = load(char(fileT),root);
        data = cat(dim,data,tmp.(root));
        disp(char(strcat({'File saved: '},char(fileT))));
        try
            clear tmp;
        catch
            disp('Error, cannot delete var tmp');
        end 
    end
    S.(root) = data;
    save(char(path.concat(strcat({'[CIGEFI] '},root,'.mat'))),'-struct','S','-v7.3');
    disp(char(strcat({'Data saved as: '},strcat({'[CIGEFI] '},root,'.mat'))));
end