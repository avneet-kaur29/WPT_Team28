%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIONAL: If encountering crashing, %
% use code to flush cache.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 

% Flushing cache
%clear all

%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set following variables to desired values. Then,    %
% copy/paste following section to CMD Window to prep  %
% for "plot_E_field()", or simply run the whole file  %
% to generate the plot as well.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNITS:                                              %
% FREQ = Hz                                           %
% DIM = [element # element #] (width, height)         %
% TRAN = [R PHI THETA]                                %
% FOC = [R PHI THETA]                                 %
% PWR = P_in of Tx in Watts                           %
% TIME = time from t = 0, in seconds                  %
% plt_y_n = "Y" to plot phase mask, "N" o.w.          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FREQ = ( 5.6 * 10^9 );                  % in Hz
DIM = [18 36];                          % element # X element #
TRAN = [0.5 ( 0 ) (pi/4)];              % (R, phi, theta)
FOC = [3.5 ( 5*pi / 4 ) ( 1*pi / 6 )];  % (R, phi, theta)
TX_PWR = 1;                               % in Watts (P_in)
TIME = 0.0;                             % in seconds
plt_y_n = "N";                          % "Y" to plot phase distribution
SPACE_OR_TIME = "S";
REFL_DIST = FOC(1) * cos(FOC(3));       % Reflection plane distance from RIS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               DO NOT MODIFY BELOW                   %
% (Unless to comment out "cont_plot = plot_E_field()" %
% to view phase mask or to specify non-focal point    %
% distance at which to view reflection.)              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B_OR_C = "C";
PHASE_1 = get_phases_v3(FREQ, DIM, TRAN, FOC, plt_y_n);
cont_plot = plot_power(FREQ, DIM, TRAN, TX_PWR, PHASE_1, (REFL_DIST), TIME, SPACE_OR_TIME, B_OR_C);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



