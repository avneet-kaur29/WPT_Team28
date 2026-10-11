function [tol_val, min_err] = tol_opt(cont_plot)

NUM_STEPS = 3;
inc = 1;

tol = 13.01;
AVG_ERR = zeros(1,NUM_STEPS);    % To hold all avg error values

for i = 1:NUM_STEPS

   bin_plot = config_BIN_PWR_EVEN_SPLIT(tol);
   AVG_ERR(1,i) = error_plot('N', bin_plot, cont_plot);

   tol = tol + inc;


end

[min_err, min_ind] = min(AVG_ERR);

tol_val = 13.01 + (min_ind * inc);