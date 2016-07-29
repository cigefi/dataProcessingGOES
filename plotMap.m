function plotMap(data2D,label,path,display)
    if nargin < 4
        display = 0;
    end
    if display
        f = figure('visible', 'on');
    else
        f = figure('visible', 'off');
    end
    lon = linspace(-91,-76,length(data2D(1,:)));%640);
    lat = linspace(5,15,length(data2D(:,1)));%480);
    %[lon,lat] = meshgrid(lon,lat);
    [longrat,latgrat] = meshgrat(lon,lat);
    hold on;
    %[longrat,latgrat]=meshgrat(double(lons(:,1)),double(lats(1,:)));
    worldmap([min(min(latgrat)) max(max(latgrat))],[min(min(longrat)) max(max(longrat))]);
    set(gcf,'Color',[1,1,1]);
    newmap = parula;                 %starting map
    newmap(1,:) = [1 1 1];           %set that position to white
    colormap(newmap);
    %colormap(parula);
    load coastlines;
    %contourfm(latgrat',longrat',data(:,:,z),2,'LineStyle','none');
    contourfm(latgrat',longrat',data2D,10,'LineStyle','none');
    %plotm(coastlat, coastlon);
    plotm(coastlat, coastlon,'k');
    cb = colorbar();
    cb.Label.String = label;
    ax = gca; 
    ax.XTickMode = 'manual';
    ax.YTickMode = 'manual';
    ax.ZTickMode = 'manual';
    ax.XLimMode = 'manual';
    ax.YLimMode = 'manual';
    ax.ZLimMode = 'manual';
    set(cb,'ylim',[0 240],'ytick',cat(2,0:20:190,190:10:240));%190:10:240)
    caxis([0, 240]);
    print(path,'-dpng');%,'-r0');
    close(f);
    disp('Map saved');
end