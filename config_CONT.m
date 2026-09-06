%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIONAL: If encountering crashing, %
% use code to flush cache.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 

% Flushing cache
%clear all

%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy/Paste following section to CMD Window to prep  %
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
% B_OR_C = "B" for binary phase mask, "C" for cont.   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FREQ = ( 5.6 * 10^9 );    % in Hz
DIM = [18 36];    % element # X element #
TRAN = [0.3 ( 0 ) (pi/4)];  % (R, phi, theta)
FOC = [1.0 ( 1*pi / 6 ) ( 1*pi / 6 )];  % (R, phi, theta)
PWR = 1000;  % in Watts (P_in)
TIME = 0.0;  % in seconds
plt_y_n = "N"; % "Y" to plot phase distribution
SPACE_OR_TIME = "S";


PHASE_1 = get_phases_v3(FREQ, DIM, TRAN, FOC, plt_y_n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FOC_DIST = FOC(1) * cos(FOC(3)); % Focal plane distance from RIS
B_OR_C = "C";
cont_plot = plot_E_field(FREQ, DIM, TRAN, PWR, PHASE_1, (FOC_DIST), TIME, SPACE_OR_TIME, B_OR_C);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



