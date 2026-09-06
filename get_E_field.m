function [mag_E_G, inst_E_G] = get_E_field(T_f_G, grid_dim_G, T_loc_G, T_p_G,  phases_G, meas_loc_G, time_G)
                               
%-----------------------------------------------------------------------
% FUNCTION SUMMARY
%-----------------------------------------------------------------------
% DESCRIPTION:
%-------------
% Given the the location of the transmitter (in spherical coordinates),
% operating center frequency (in Hz), power of the transmitter,
% dimensions of the RIS (in # of elements x # of elements),the matrix of
% phase delays per element produced by "get_phases()", and the 
% coordinates (in Cartesian) of the desired measurement location, this
% function sums the contributions from all RIS elements to the E-field
% at the indicated measurement location due to the wave reflected off of
% the RIS at a given focal setting. 
%-----------------------------------------------------------------------
% INPUTS (NOTE: "G" appendix denotes "get_E_field()" version of these 
% quantities, to distinguish the local variables from the names for the
% same quantities used in "plot_E_field()", which calls this function.
% Those quantities are denoted with a "P" appendix in "plot_E_field()".)
%--------
% T_loc_G =  Array of spherical coordinates (R, phi, theta) indicating the
% location of the transmitter. Coordinate system assumes RIS in XY plane
% w/ X axis along the RIS's horizontal, Y along its vertical, and 
% w/positive Z axis emerging normal to front of RIS.
% (ex. "[0.3 (pi/4) (0)]" for Tx @ mid-height of the RIS, 45deg. to right
% of normal, and 0.3 meters away from center of RIS)
%
% T_f_G = Operating frequency of transmitter (in Hz) 
% (ex. "(5.6*10^9)" for 5.6 GHz)
%
% T_p_G = Power of transmitter (in Watts)
% (ex. "1" for 1 Watt)
%
% grid_dim_G = array of height x width (in # of elements) of the RIS
% (ex. "[18 36]" for RIS w/18 rows, 36 columns of elements)
%
% phases_G = Matrix of phase delays produced by "get_phases()"
%
% meas_loc_G = array of Cartesian coordinates (x, y, z) indicating
% location of point in space at which the user wants to know the magnitude
% of the E-field due to the reflected wave off of the RIS.
% (ex. "[ 0.1 0.1 0.8 ]" for measurement location 0.1 m to the right of 
% middle and  0.1 m "up" from middle of RIS, 0.8 m away from RIS)
%
%-----------------------------------------------------------------------
% OUTPUT:
%--------
% mag_E_G = single scalar value denoting magnitude of electric field 
% intensity at the measurement location due to the RIS's reflected wave.

% Physical parameters
c_G = (2.998*10^8); % Speed of light in free space (m/s)
lambda_G = c_G / T_f_G; % Wavelength of operating frequency in free space (m)
k_G = (2 * pi) / lambda_G; % Free space wavenumber of operating frequency (rad/m)

mu_0_G = ( 4 * pi ) * ( 10^-7 ); % Permeability of free space (H/m)
eps_0_G = ( 8.854 * 10^-12 ); % Permittivity of free space (F/m)
eta_0_G = sqrt( mu_0_G / eps_0_G ); % Intrinsic impedance of free space (Ohms)

m_G = grid_dim_G(1); % Rows of RIS
n_G = grid_dim_G(2); % Columns of RIS

% upper left coordinate of RIS
corner_1_G = [( (-n_G / 2) * (lambda_G / 2) ) ( (m_G / 2) * (lambda_G / 2) )];

% Matrix of element x-coordinates
X_G = ones(m_G,n_G) * ( corner_1_G(1) + (lambda_G / 4) );

% Matrix of element y-coordinates
Y_G = ones(m_G,n_G) * ( corner_1_G(2) - (lambda_G / 4) );

for h_G = 2:n_G
    
    % Shift each column of X to the right, by the length of one element,
    % from the previous column
    X_G(:,h_G) = X_G(:,1) + ( (h_G-1) * (lambda_G / 2) );

end

for u_G = 2:m_G
    
    % Shift each row of Y down, by the length of one element, from the 
    % previous row
    Y_G(u_G,:) = Y_G(1,:) - ( (u_G-1) * (lambda_G / 2) );

end

% Convert transmitter location to Cartesian coordinates
R_tx_G = T_loc_G(1);
phi_tx_G = T_loc_G(2);
theta_tx_G = T_loc_G(3);

tx_x_G = R_tx_G * sin(theta_tx_G) * cos(phi_tx_G);
tx_y_G = R_tx_G * sin(theta_tx_G) * sin(phi_tx_G);
tx_z_G = R_tx_G * cos(theta_tx_G);

Tx_cart_G = [tx_x_G tx_y_G tx_z_G];

% Create matrix of distances b/t Tx and each element
R_t_G = zeros(m_G,n_G);
e1_G = zeros(1,3);
R_temp1_G = zeros(1,3);

for h_G = 1:m_G
    for u_G = 1:n_G

        e1_G = [X_G(h_G,u_G) Y_G(h_G,u_G) 0];

        R_temp1_G = Tx_cart_G - e1_G;

        R_t_G(h_G,u_G) = norm(R_temp1_G);

    end
end

% Create matrix of power incident upon each element
P_inc_G = zeros(m_G,n_G);

for h_G = 1:m_G
    for u_G = 1:n_G
        
        % Surface area of sphere with radius equal to distance between
        % transmitter and RIS element (h,u) (calculation assumes 
        % isotropic radiator)
        iso_sphere_surf = ( 4 * pi ) * ( ( R_t_G(h_G,u_G) )^2 );

        % Power incident on RIS element (h,u)
        P_inc_G(h_G,u_G) = T_p_G / iso_sphere_surf;

    end
end

% Create matrix of current induced in each element by wave from transmitter
I_el_G = zeros(m_G,n_G);

for h_G = 1:m_G
    for u_G = 1:n_G
        
        % Magnitude of H-field (A/m) at RIS element (h,u), derived from
        % relation between Poynting vector and E-field, and between
        % E-field and H-field
        num_G = sqrt( P_inc_G(h_G,u_G) * 2 * eta_0_G );
        den_G = eta_0_G;
        H_field_mag_G = ( num_G / den_G );
        
        % (A/m) induced by H-field times dimension of RIS element (m) gives
        % total current in RIS element (h,u)
        I_el_G(h_G,u_G) = H_field_mag_G * ( lambda_G / 2 );

    end
end

meas_cart_G = meas_loc_G;

% Create matrix of distances b/t measurement location and each element
R_m_G = zeros(m_G,n_G);
e2_G = zeros(1,3);
R_temp2_G = zeros(1,3);

for h_G = 1:m_G
    for u_G = 1:n_G

        e2_G = [X_G(h_G,u_G) Y_G(h_G,u_G) 0];

        R_temp2_G = meas_cart_G - e2_G;

        R_m_G(h_G,u_G) = norm(R_temp2_G);

    end
end

% Create matrix of elevation angles for antenna factor calculations
% for each RIS element relative to the measurement point
theta_AF_G = zeros(m_G,n_G);
a_G = zeros(1,3);
b_G = zeros(1,3);
meas_adj_G = zeros(1,3);

for h_G = 1:m_G
    for u_G = 1:n_G

        % vector between measurement location and element
        a_G = meas_cart_G - [X_G(h_G,u_G) Y_G(h_G,u_G) 0]; 
    
        % vector pointing to location above or below measurement point that
        % has same y component as the element
        meas_adj_G = [meas_cart_G(1) Y_G(h_G,u_G) meas_cart_G(3)];
    
        % vector between element and this point above or below the
        % measurement point that is at same "y-level" as element
        b_G = meas_adj_G - [X_G(h_G,u_G) Y_G(h_G,u_G) 0];
            
        % Use formal definition of dot product - 
        % cos(theta) = ( dot(a,b) )/( mag(a)*mag(b) ), 
        % for theta = angle b/t vectors a,b
        Y_theta_arg_G = ( dot(a_G, b_G) ) / ( ( norm(a_G) ) * ( norm(b_G) ) );
        Y_theta_G = acos( Y_theta_arg_G );
             
        % Measure from axis of "dipole"
        theta_AF_G(h_G,u_G) = ( ( pi / 2 ) - ( Y_theta_G ) );

    end
end

% Create matrix of the E_theta values contributed by each element to the
% E-field magnitude at the measurement location due to the reflection
E_thetas_G = zeros(m_G,n_G);

for h_G = 1:m_G
    for u_G = 1:n_G
        
        % Antenna Factor
        A_F_G_num = cos( (pi / 2) * cos( theta_AF_G(h_G,u_G) ) );

        A_F_G_den = sin( theta_AF_G(h_G,u_G) );
        
        A_F_G = A_F_G_num / A_F_G_den;
        
        % Complex exponential argument terms

        beta_G = k_G;

        wave_phase_G = ( phases_G(h_G,u_G) * (pi / 180) );

        pos_vec_R = ( R_m_G(h_G,u_G) );

        % Wave amplitude terms
        wave_amp_num_G = ( 1i * 60 * I_el_G(h_G, u_G) );

        wave_amp_den_G =  R_m_G(h_G,u_G);

        wave_amp_G = wave_amp_num_G / wave_amp_den_G;

        % Incident propagation, programmed reflection, outgoing propagation.
        incident_prop_G = exp(-1i * beta_G * R_t_G(h_G, u_G));

        Gamma_G = exp(1i * wave_phase_G);

        outgoing_prop_G = exp(-1i * beta_G * pos_vec_R);

        E_thetas_G(h_G, u_G) = wave_amp_G .* incident_prop_G .* Gamma_G .* ...
            outgoing_prop_G .* A_F_G;

    end
end

E_phasor_G = sum(E_thetas_G(:));

mag_E_G = abs(E_phasor_G);

inst_E_G = real(E_phasor_G * exp(1i * 2*pi*T_f_G*time_G));


end