function [AVG_ERR] = error_plot_func(PLT_Y_N, bin_plot, cont_plot)
% Error Plot

% Plot heat map of error between continuous and binary phase
% reflections

ERR = abs(cont_plot - bin_plot);

SUM = sum(ERR, 'all');
num_elements = numel(ERR);

AVG_ERR = SUM / num_elements;

if (PLT_Y_N == 'Y' || PLT_Y_N == 'y')

    HM = heatmap(ERR);

    % Nice Colors

    iblue = '#648FFF';       % (lightish blue)
    ipurple = '#785EF0';     % (lightish purple/lilac)
    imagenta = '#DC267F';    % (pinkish red)
    iorange = '#FE6100';     % (lightish orange)
    igold = '#FFB000';       % (bright mustard)

    ib = hex2rgb(iblue);
    ip = hex2rgb(ipurple);
    im = hex2rgb(imagenta);
    io = hex2rgb(iorange);
    ig = hex2rgb(igold);


    HM.CellLabelColor = 'none';

    % Access the hidden color bar handle
    hs = struct(HM);
    axis(hs.Axes, 'square');
    cb = hs.Colorbar;

    % Add a label along the color bar
    cb.Label.String = sprintf(['\\fontsize{12}','Power (dB)']);


    msgP = sprintf(['\\fontsize{12}', 'Error b/t Continuous, Binary Phase ', '\\color[rgb]{%f,%f,%f}', '(dB)  '], ib(1), ib(2), ib(3));

    % Customize appearance
    HM.Title = msgP;
    HM.XLabel = sprintf(['\\fontsize{12}','Reflection Surface (X-Dir.), ', '%.1f', ' m wide'], 2);
    HM.YLabel = sprintf(['\\fontsize{12}','Reflection Surface (Y-Dir.), ', '%.1f', ' m tall'], 2);
    HM.Colormap = bone;       
    HM.ColorbarVisible = "on";
    HM.GridVisible = "off";

end