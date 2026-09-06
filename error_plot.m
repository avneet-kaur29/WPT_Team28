% Error Plot

% Plot heat map of error between continuous and binary phase
% reflections

ERR = abs(cont_plot - bin_plot);

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
%hs = struct(HM);
%cb = hs.Colorbar;

% Add a label along the color bar
%cb.Label.String = sprintf(['\\fontsize{12}','E-Field (V/m)']);


title_addendum = '(Error b/t cont. & bin.)';


msgP = sprintf(['\\fontsize{12}', '        E-Field ', title_addendum], ig(1), ig(2), ig(3));

% Customize appearance
x_values = linspace(0, 2, 50);
y_values = linspace(0, 2, 50);
HM.XData = round(x_values, 2);
HM.YData = round(y_values, 2);

% Invert the y-axis
HM.YData = round(flip(y_values), 2);
HM.ColorData = flip(HM.ColorData, 1);

% n = 2; % show tic mark every 5th label;
% 
% x_labels = string(round(x_values, 2));
% x_labels(mod(0:dimens-1, n) ~= 0) = "";  % blank out all but every nth
% HM.XDisplayLabels = x_labels;
% 
% y_labels = string(round(y_values, 2));
% y_labels(mod(0:dimens-1, n) ~= 0) = "";
% HM.YDisplayLabels = flip(y_labels);

hs = struct(HM);
cb = hs.Colorbar;
cb.Label.String = 'E-Field Magnitude (V/m)';
cb.Label.FontSize = 12;


HM.Title = msgP;
HM.XLabel = sprintf(['\\fontsize{12}','Reflection Surface (X-Dir.), ', '%.1f', ' m wide'], 2);
HM.YLabel = sprintf(['\\fontsize{12}','Reflection Surface (Y-Dir.), ', '%.1f', ' m tall'], 2);
% Fix colormap limits
HM.ColorLimits = [0 2000];
HM.Colormap = bone;       
HM.ColorbarVisible = "on";
HM.GridVisible = "off";