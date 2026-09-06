function [phases_PH] = get_phases_v3(f_c_PH, grid_dim_PH, T_x_PH, foc_pt_PH, plt_y_n)

%-----------------------------------------------------------------------
% FUNCTION SUMMARY
%-----------------------------------------------------------------------
% DESCRIPTION:
%-------------
% Given the operating center frequency (in Hz), dimensions of the RIS
% (in # of elements x # of elements), the location of the transmitter
% (in spherical coordinates), and the desired focal point (in spherical
% coordinates), this function calculates the required phase shift for 
% each element in the RIS to focus the reflection on the desired 
% location. It returns a matrix of phase values,each in the location of
% the element it corresponds to on the RIS.
%-----------------------------------------------------------------------
% INPUTS: 
%--------
% f_c = Operating frequency of transmitter (in Hz) 
% (ex. "(5.6*10^9)" for 5.6 GHz)
%
% grid_dim = array of height x width (in # of elements) of the RIS
% (ex. "[18 36]" for RIS w/18 rows, 36 columns of elements)
%
% T_x = Array of spherical coordinates (R, phi, theta) indicating the
% location of the transmitter. Coordinate system assumes RIS in XY plane
% w/ X axis along the RIS's horizontal, Y along its vertical, and 
% w/positive Z axis emerging normal to front of RIS.
% (ex. "[0.3 (0) (pi/4)]" for Tx @ mid-height of the RIS, 45deg. to right
% of normal, and 0.3 meters away from center of RIS)
% 
% foc_pt = Array of spherical coordinates (R, phi, theta) indicating the
% location of the desired focal point. Assumes same axis system as "T_x".
% (ex. "[0.5 (pi/2) (pi/6)]" for focal point 0.5 meters away from center 
% of RIS, angled 30 degrees from the normal to the RIS in the y-direction
% ("up", if standing in front and looking at RIS))
%
%-----------------------------------------------------------------------
% OUTPUT:
%--------
% phases_PH = Matrix of phase shifts that each element of the RIS must
% provide in order to achieve desired focal point. Values' positions
% in the matrix correspond to their respective elements' location in the 
% RIS grid.


c_PH = (2.998*10^8); % Speed of light in free space
lambda_PH = c_PH / f_c_PH; % Wavelength of operating frequency in free space
k_PH = (2 * pi) / lambda_PH; % Free space wavenumber of operating frequency

m_PH = grid_dim_PH(1); % Rows of RIS
n_PH = grid_dim_PH(2); % Columns of RIS

% upper left coordinate of RIS
corner_1_PH = [(( -n_PH/2 ) * ( lambda_PH / 2 )) ((m_PH / 2) * (lambda_PH / 2))]; 

% Matrix of element x-coordinates
X_PH = ones(m_PH,n_PH)*(corner_1_PH(1) + (lambda_PH / 4) );

% Matrix of element y-coordinates
Y_PH = ones(m_PH,n_PH)*(corner_1_PH(2) - (lambda_PH / 4) );

for a_PH = 2:n_PH
    
    % Shift each column of X to the right by the length of one element
    X_PH(:,a_PH) = X_PH(:,1) + ( (a_PH - 1) * (lambda_PH / 2) );

end

for v_PH = 2:m_PH
    
    % Shift each row of Y down by the length of one element
    Y_PH(v_PH,:) = Y_PH(1,:) - ( (v_PH - 1) * (lambda_PH / 2) );

end

% Convert transmitter location to Cartesian coordinates
R_tx_PH = T_x_PH(1);
phi_tx_PH = T_x_PH(2);
theta_tx_PH = T_x_PH(3);

tx_x_PH = R_tx_PH * sin(theta_tx_PH) * cos(phi_tx_PH);
tx_y_PH = R_tx_PH * sin(theta_tx_PH) * sin(phi_tx_PH);
tx_z_PH = R_tx_PH * cos(theta_tx_PH);


% Create matrix of distances b/t Tx and each element
R_i_PH = sqrt( (X_PH - tx_x_PH).^2 + (Y_PH - tx_y_PH).^2 + (tx_z_PH).^2 );

% Convert focal point location to Cartesian coordinates
R_foc_PH = foc_pt_PH(1);
phi_foc_PH = foc_pt_PH(2);
theta_foc_PH = foc_pt_PH(3);

x_f_PH = R_foc_PH * sin(theta_foc_PH) * cos(phi_foc_PH);
y_f_PH = R_foc_PH * sin(theta_foc_PH) * sin(phi_foc_PH);
z_f_PH = R_foc_PH * cos(theta_foc_PH);

% Create matrix of distances b/t focal point and each element
R_f_PH = sqrt( (X_PH - x_f_PH).^2 + (Y_PH - y_f_PH).^2 + (z_f_PH).^2 );


% exp(-j*k*R_t) * exp(+j*phi) * exp(-j*k*R_f) is constant at the focus.
phi_0_PH = 0;  % Arbitrary common phase; it does not change focusing.
phi_PH = mod(k_PH * (R_i_PH + R_f_PH) + phi_0_PH, 2*pi);

phases_PH = rad2deg(phi_PH);


if plt_y_n == "y" || plt_y_n == "Y"
    % ideal phase profile heat map for the ideal phase profile

    % Plot heat map of phase distribution

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

    % Create heatmap

    h = heatmap(phases_PH);
    h.CellLabelColor = 'none';

    % Access the hidden color bar handle
    hs = struct(h);
    cb = hs.Colorbar;

    % Add a label along the color bar
    cb.Label.String = sprintf(['\\fontsize{12}','Phase Delay (Degrees)']);

    msg = '      RIS Phase Distribution';
    tx_loc = 'Tx Location: ';

    dir = 'Focus Location: ';

    title_str = sprintf(['\\fontsize{18}', '\\color{white}', msg, '\\fontsize{12}', ' (Ideal, Continuous)', '\n', '\\fontsize{12}', '\\color[rgb]{%f,%f,%f}', tx_loc,  '\\color{white}',  '    R = ', '\\color[rgb]{%f,%f,%f}', '%.4f m', '\\color{white}', ', ', 'θ = ', '\\color[rgb]{%f,%f,%f}', ' %.4f deg',  '\\color{white}', ', ', 'φ = ', '\\color[rgb]{%f,%f,%f}', ' %.4f deg.', '\n',  '\\color[rgb]{%f,%f,%f}', dir, '\\color{white}', 'R = ', '\\color[rgb]{%f,%f,%f}', '%.4f m', '\\color{white}', ', ',  'θ =', '\\color[rgb]{%f,%f,%f}', ' %.4f deg', '\\color{white}', ', ',  'φ = ', '\\color[rgb]{%f,%f,%f}', ' %.4f deg.', '\n'], ib(1), ib(2), ib(3),  ib(1), ib(2), ib(3), T_x_PH(1),  ib(1), ib(2), ib(3), (T_x_PH(2)*(180/pi)),  ib(1), ib(2), ib(3), (T_x_PH(3)*(180/pi)), ig(1), ig(2), ig(3), ig(1), ig(2), ig(3), foc_pt_PH(1), ig(1), ig(2), ig(3), (foc_pt_PH(2)*(180/pi)), ig(1), ig(2), ig(3), (foc_pt_PH(3)*(180/pi)));

    % Customize appearance
    h.Title = title_str;
    h.XLabel = sprintf(['\\fontsize{12}','RIS Elements (X-Dir.)']);
    h.YLabel = sprintf(['\\fontsize{12}','RIS Elements (Y-Dir.)']);
    h.Colormap = parula;        % any colormap: parula, jet, hot, viridis, etc.
    h.ColorbarVisible = "on";
    h.GridVisible = "off";
end

end


