%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIONAL: Use following section to convert Cartesian %
% coordinates to the spherical coordinates the scripts %
% accept, or enter spherical coordinates directly      %
% into "TRAN" and "FOC" arrays.                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Convert from Cartesian to Spherical
% %{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enter coordinates here in meters %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_foc = 0.875;
y_foc = 0.0;
z_foc = 1.820;

x_tx = 0.0;
y_tx = 0.0;
z_tx = 2.25;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R_FOC = sqrt((x_foc^2) + (y_foc^2) + (z_foc^2));
PHI_FOC = atan2(y_foc, x_foc);
THETA_FOC = atan2( (sqrt(x_foc^2 + y_foc^2)), z_foc);

R_TX = sqrt((x_tx^2) + (y_tx^2) + (z_tx^2));
PHI_TX = atan2(y_tx, x_tx);
THETA_TX = atan2( (sqrt( x_tx^2 + y_tx^2)), z_tx);

%}

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

FREQ =          ( 5.8 * 10^9 );            % in Hz
DIM =           [18 36];                   % element # X element #
TRAN =          [R_TX PHI_TX THETA_TX];    % (R, phi, theta)
FOC =           [R_FOC PHI_FOC THETA_FOC]; % (R, phi, theta)
TX_PWR =        1;                         % in Watts (P_in)
TIME =          0.0;                       % in seconds
plt_y_n =       'N';                       % "Y" to plot phase distribution
SPACE_OR_TIME = 'S';
REFL_DIST =     FOC(1) * cos(FOC(3));      % Reflection plane distance from RIS

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



