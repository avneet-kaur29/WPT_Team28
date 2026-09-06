%TIME_ANIMATION Generate a time-domain animation using a local configuration.
% Before running, optionally set CONFIG_FILE_TA to 'config_CONT.m' or
% 'config_BIN.m'. LOW_RESOURCE_MODE_TA defaults to true for the stable
% 30-by-30, 48-frame animation; set it false for the full time animation.

script_dir_TA = fileparts(mfilename('fullpath'));
original_dir_TA = pwd;
restore_dir_TA = onCleanup(@() cd(original_dir_TA));
cd(script_dir_TA);

if ~exist('CONFIG_FILE_TA', 'var') || isempty(CONFIG_FILE_TA)
    CONFIG_FILE_TA = 'config_CONT.m';
end
config_file_TA = char(string(CONFIG_FILE_TA));
allowed_configs_TA = {'config_CONT.m', 'config_BIN.m'};
assert(any(strcmp(config_file_TA, allowed_configs_TA)), ...
    'time_animation:InvalidConfiguration', ...
    'CONFIG_FILE_TA must be ''config_CONT.m'' or ''config_BIN.m''.');

% Evaluate the selected configuration without its final plot_E_field call.
% This preserves its parameters and phase-generator selection while avoiding
% a HeatmapChart allocation before the animation starts.
config_TA = load_animation_config_TA(fullfile(script_dir_TA, config_file_TA));
FREQ = config_TA.FREQ;
DIM = config_TA.DIM;
TRAN = config_TA.TRAN;
FOC = config_TA.FOC;
PWR = config_TA.PWR;
PHASE_1 = config_TA.PHASE_1;
B_OR_C = config_TA.B_OR_C;

required_vars_TA = {'FREQ', 'DIM', 'TRAN', 'FOC', 'PWR', 'PHASE_1', 'B_OR_C'};
for index_TA = 1:numel(required_vars_TA)
    assert(exist(required_vars_TA{index_TA}, 'var') == 1, ...
        'time_animation:MissingConfiguration', ...
        '%s did not define %s.', config_file_TA, required_vars_TA{index_TA});
end
assert(isequal(size(PHASE_1), [DIM(1), DIM(2)]), ...
    'time_animation:PhaseSizeMismatch', ...
    'PHASE_1 must have size [%d, %d].', DIM(1), DIM(2));
assert(any(strcmpi(string(B_OR_C), ["B", "C"])), ...
    'time_animation:InvalidMaskType', ...
    'B_OR_C must be "B" or "C".');

% FOC is spherical [R, phi, theta]; plot_E_field expects Cartesian z.
POSITION_TA = FOC(1) * cos(FOC(3));
if ~exist('LOW_RESOURCE_MODE_TA', 'var') || isempty(LOW_RESOURCE_MODE_TA)
    LOW_RESOURCE_MODE_TA = true;
end
assert(islogical(LOW_RESOURCE_MODE_TA) && isscalar(LOW_RESOURCE_MODE_TA), ...
    'time_animation:InvalidLowResourceMode', ...
    'LOW_RESOURCE_MODE_TA must be a logical scalar.');

if LOW_RESOURCE_MODE_TA
    frames_per_cycle_TA = 24;
    num_cycles_TA = 2;
    frame_pause_TA = 0.05;
    num_samples_TA = 30;
else
    frames_per_cycle_TA = 33;
    num_cycles_TA = 4;
    frame_pause_TA = 0;
    num_samples_TA = 50;
end
export_resolution_TA = 300;
% Exclude the repeated t = 0 endpoint that would occur after an integer
% number of cycles, so the movie loops without a duplicate frame.
time_values_TA = (0:(frames_per_cycle_TA * num_cycles_TA - 1)) / ...
    (frames_per_cycle_TA * FREQ);

if ~exist('MAX_FRAMES_TA', 'var') || isempty(MAX_FRAMES_TA)
    MAX_FRAMES_TA = numel(time_values_TA);
end
validateattributes(MAX_FRAMES_TA, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'positive', 'integer'});

if ~exist('SMOKE_TEST_TA', 'var') || isempty(SMOKE_TEST_TA)
    SMOKE_TEST_TA = false;
end
assert(islogical(SMOKE_TEST_TA) && isscalar(SMOKE_TEST_TA), ...
    'time_animation:InvalidSmokeTest', ...
    'SMOKE_TEST_TA must be a logical scalar.');
if SMOKE_TEST_TA
    MAX_FRAMES_TA = min(MAX_FRAMES_TA, 2);
end

mask_name_TA = upper(char(string(B_OR_C)));
fig_TA = figure('Visible', 'off', 'Renderer', 'painters');
figure_cleanup_TA = onCleanup(@() close_figure_safely_TA(fig_TA));
ax_TA = axes(fig_TA);
field_image_TA = [];
colorbar_TA = [];

% get_E_field returns Re{E_tilde*exp(j*omega*t)}. Sample the two
% quadratures once, then synthesize every movie frame without repeating
% the full RIS field calculation.
[in_phase_field_TA, quadrature_field_TA] = sample_field_quadratures_TA( ...
    FREQ, DIM, TRAN, PWR, PHASE_1, POSITION_TA, num_samples_TA);
field_limit_TA = max(hypot(in_phase_field_TA, quadrature_field_TA), [], 'all');
assert(isfinite(field_limit_TA) && field_limit_TA > 0, ...
    'time_animation:InvalidFieldLimit', ...
    'The precomputed instantaneous-field limit must be finite and positive.');

video_path_TA = fullfile(script_dir_TA, ...
    sprintf('RIS_Time_Animation_%s.mp4', mask_name_TA));
frame_path_TA = fullfile(script_dir_TA, ...
    sprintf('.RIS_Time_Animation_%s_frame.png', mask_name_TA));
frame_cleanup_TA = onCleanup(@() delete_file_safely_TA(frame_path_TA));
v_TA = VideoWriter(video_path_TA, 'MPEG-4');
v_TA.FrameRate = frames_per_cycle_TA;
frames_written_TA = 0;
video_frame_size_TA = [];

try
    open(v_TA);
    video_cleanup_TA = onCleanup(@() close_video_safely_TA(v_TA));

    for time_TA = time_values_TA
        if frames_written_TA >= MAX_FRAMES_TA
            break
        end

        phase_angle_TA = 2 * pi * FREQ * time_TA;
        field_TA = in_phase_field_TA * cos(phase_angle_TA) + ...
            quadrature_field_TA * sin(phase_angle_TA);
        if isempty(field_image_TA)
            field_image_TA = imagesc(ax_TA, field_TA);
            axis(ax_TA, 'image');
            ax_TA.YDir = 'reverse';
            ax_TA.XLabel.String = 'Reflection surface sample (X direction)';
            ax_TA.YLabel.String = 'Reflection surface sample (Y direction)';
            colormap(fig_TA, bone);
            colorbar_TA = colorbar(ax_TA);
            colorbar_TA.Label.String = 'Instantaneous E-field (V/m)';
        else
            field_image_TA.CData = field_TA;
        end
        clim(ax_TA, [-field_limit_TA, field_limit_TA]);
        title(ax_TA, sprintf('E-Field (Time Domain, %s Mask)\n%.2f m from RIS, %.2f ps', ...
            mask_name_TA, POSITION_TA, time_TA * 1e12));

        drawnow;
        print(fig_TA, frame_path_TA, '-dpng', ...
            sprintf('-r%d', export_resolution_TA));
        frame_TA = imread(frame_path_TA);
        if ndims(frame_TA) == 2
            frame_TA = repmat(frame_TA, 1, 1, 3);
        end
        if isempty(video_frame_size_TA)
            video_frame_size_TA = 2 * ceil(size(frame_TA, [1 2]) / 2);
        end
        frame_TA = fit_video_frame_TA(frame_TA, video_frame_size_TA);
        writeVideo(v_TA, frame_TA);
        frames_written_TA = frames_written_TA + 1;
        clear field_TA frame_TA
        pause(frame_pause_TA);
    end
catch ME_TA
    warning('time_animation:StoppedEarly', ...
        'Animation stopped after %d frame(s): %s', ...
        frames_written_TA, ME_TA.message);
end

clear video_cleanup_TA
fprintf('Time animation finalized with %d frame(s): %s\n', ...
    frames_written_TA, video_path_TA);

function close_video_safely_TA(v_TA)
try
    close(v_TA);
catch ME_TA
    warning('time_animation:VideoCloseFailed', ...
        'Could not finalize the video file: %s', ME_TA.message);
end
end

function close_figure_safely_TA(fig_TA)
if isgraphics(fig_TA, 'figure')
    close(fig_TA);
end
end

function frame_TA = fit_video_frame_TA(frame_TA, target_size_TA)
% exportgraphics can vary by one pixel as chart labels change. Pad or crop
% to a fixed even canvas so the H.264 encoder receives identically sized frames.
frame_height_TA = min(size(frame_TA, 1), target_size_TA(1));
frame_width_TA = min(size(frame_TA, 2), target_size_TA(2));
fitted_frame_TA = zeros(target_size_TA(1), target_size_TA(2), size(frame_TA, 3), ...
    'like', frame_TA);
fitted_frame_TA(1:frame_height_TA, 1:frame_width_TA, :) = ...
    frame_TA(1:frame_height_TA, 1:frame_width_TA, :);
frame_TA = fitted_frame_TA;
end

function [in_phase_field_TA, quadrature_field_TA] = sample_field_quadratures_TA( ...
        freq_TA, dim_TA, tran_TA, pwr_TA, phase_TA, distance_TA, num_samples_TA)
% For E_tilde = A + jB, get_E_field returns A at t = 0 and -B at
% t = 1/(4f). Therefore E(t) = A*cos(omega*t) + (-B)*sin(omega*t).
surface_coordinates_TA = 1 - (0:(num_samples_TA - 1)) * (2 / num_samples_TA);
in_phase_field_TA = zeros(num_samples_TA, num_samples_TA);
quadrature_field_TA = zeros(num_samples_TA, num_samples_TA);
quadrature_time_TA = 1 / (4 * freq_TA);
for row_TA = 1:num_samples_TA
    for column_TA = 1:num_samples_TA
        location_TA = [surface_coordinates_TA(column_TA), ...
            surface_coordinates_TA(row_TA), distance_TA];
        [~, in_phase_field_TA(row_TA, column_TA)] = get_E_field( ...
            freq_TA, dim_TA, tran_TA, pwr_TA, phase_TA, location_TA, 0);
        [~, quadrature_field_TA(row_TA, column_TA)] = get_E_field( ...
            freq_TA, dim_TA, tran_TA, pwr_TA, phase_TA, location_TA, ...
            quadrature_time_TA);
    end
end
end

function config_TA = load_animation_config_TA(config_path_TA)
source_TA = fileread(config_path_TA);
plot_call_index_TA = regexp(source_TA, ...
    '(?m)^[ \t]*(?:[A-Za-z]\w*[ \t]*=[ \t]*)?plot_E_field[ \t]*\(', 'once');
assert(~isempty(plot_call_index_TA), ...
    'time_animation:ConfigurationPlotNotFound', ...
    'Could not locate the final plot_E_field call in %s.', config_path_TA);

% Suppress a phase-mask plot even if the interactive configuration flag was
% enabled. The animation renders its own frames below.
setup_source_TA = source_TA(1:plot_call_index_TA - 1);
setup_source_TA = regexprep(setup_source_TA, ...
    '(?m)^\s*plt_y_n\s*=.*?;', 'plt_y_n = "N";');
eval(setup_source_TA);

required_names_TA = {'FREQ', 'DIM', 'TRAN', 'FOC', 'PWR', 'PHASE_1', 'B_OR_C'};
config_TA = struct();
for name_index_TA = 1:numel(required_names_TA)
    name_TA = required_names_TA{name_index_TA};
    assert(exist(name_TA, 'var') == 1, ...
        'time_animation:MissingConfiguration', ...
        '%s did not define %s.', config_path_TA, name_TA);
    config_TA.(name_TA) = eval(name_TA);
end
end

function delete_file_safely_TA(file_path_TA)
if isfile(file_path_TA)
    delete(file_path_TA);
end
end
