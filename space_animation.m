%SPACE_ANIMATION Generate spatial magnitude slices using a local configuration.
% Before running, optionally set CONFIG_FILE_SA to 'config_CONT.m' or
% 'config_BIN.m'. LOW_RESOURCE_MODE_SA defaults to true for the stable
% 30-by-30, 30-frame animation; set it false for the full spatial sweep.

script_dir_SA = fileparts(mfilename('fullpath'));
original_dir_SA = pwd;
restore_dir_SA = onCleanup(@() cd(original_dir_SA));
cd(script_dir_SA);

if ~exist('CONFIG_FILE_SA', 'var') || isempty(CONFIG_FILE_SA)
    CONFIG_FILE_SA = 'config_CONT.m';
end
config_file_SA = char(string(CONFIG_FILE_SA));
allowed_configs_SA = {'config_CONT.m', 'config_BIN.m'};
assert(any(strcmp(config_file_SA, allowed_configs_SA)), ...
    'space_animation:InvalidConfiguration', ...
    'CONFIG_FILE_SA must be ''config_CONT.m'' or ''config_BIN.m''.');

% Evaluate the selected configuration without its final plot_E_field call.
% This preserves its parameters and phase-generator selection while avoiding
% a HeatmapChart allocation before the animation starts.
config_SA = load_animation_config_SA(fullfile(script_dir_SA, config_file_SA));
FREQ = config_SA.FREQ;
DIM = config_SA.DIM;
TRAN = config_SA.TRAN;
FOC = config_SA.FOC;
PWR = config_SA.PWR;
PHASE_1 = config_SA.PHASE_1;
B_OR_C = config_SA.B_OR_C;

required_vars_SA = {'FREQ', 'DIM', 'TRAN', 'FOC', 'PWR', 'PHASE_1', 'B_OR_C'};
for index_SA = 1:numel(required_vars_SA)
    assert(exist(required_vars_SA{index_SA}, 'var') == 1, ...
        'space_animation:MissingConfiguration', ...
        '%s did not define %s.', config_file_SA, required_vars_SA{index_SA});
end
assert(isequal(size(PHASE_1), [DIM(1), DIM(2)]), ...
    'space_animation:PhaseSizeMismatch', ...
    'PHASE_1 must have size [%d, %d].', DIM(1), DIM(2));
assert(any(strcmpi(string(B_OR_C), ["B", "C"])), ...
    'space_animation:InvalidMaskType', ...
    'B_OR_C must be "B" or "C".');

TIME_SA = 0;
if ~exist('LOW_RESOURCE_MODE_SA', 'var') || isempty(LOW_RESOURCE_MODE_SA)
    LOW_RESOURCE_MODE_SA = true;
end
assert(islogical(LOW_RESOURCE_MODE_SA) && isscalar(LOW_RESOURCE_MODE_SA), ...
    'space_animation:InvalidLowResourceMode', ...
    'LOW_RESOURCE_MODE_SA must be a logical scalar.');

if LOW_RESOURCE_MODE_SA
    frame_positions_SA = 0.1:0.1:3.0;
    frame_pause_SA = 0.05;
    num_samples_SA = 30;
else
    frame_positions_SA = 0.1:0.05:3.0;
    frame_pause_SA = 0;
    num_samples_SA = 50;
end
export_resolution_SA = 300;

if ~exist('MAX_FRAMES_SA', 'var') || isempty(MAX_FRAMES_SA)
    MAX_FRAMES_SA = numel(frame_positions_SA);
end
validateattributes(MAX_FRAMES_SA, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'positive', 'integer'});

if ~exist('SMOKE_TEST_SA', 'var') || isempty(SMOKE_TEST_SA)
    SMOKE_TEST_SA = false;
end
assert(islogical(SMOKE_TEST_SA) && isscalar(SMOKE_TEST_SA), ...
    'space_animation:InvalidSmokeTest', ...
    'SMOKE_TEST_SA must be a logical scalar.');
if SMOKE_TEST_SA
    MAX_FRAMES_SA = min(MAX_FRAMES_SA, 2);
end

mask_name_SA = upper(char(string(B_OR_C)));
fig_SA = figure('Visible', 'off', 'Renderer', 'painters');
figure_cleanup_SA = onCleanup(@() close_figure_safely_SA(fig_SA));
ax_SA = axes(fig_SA);
field_image_SA = [];
colorbar_SA = [];
video_path_SA = fullfile(script_dir_SA, ...
    sprintf('RIS_Space_Animation_%s.mp4', mask_name_SA));
frame_path_SA = fullfile(script_dir_SA, ...
    sprintf('.RIS_Space_Animation_%s_frame.png', mask_name_SA));
frame_cleanup_SA = onCleanup(@() delete_file_safely_SA(frame_path_SA));
v_SA = VideoWriter(video_path_SA, 'MPEG-4');
v_SA.FrameRate = 10;
frames_written_SA = 0;
video_frame_size_SA = [];

try
    open(v_SA);
    video_cleanup_SA = onCleanup(@() close_video_safely_SA(v_SA));

    for z_SA = frame_positions_SA
        if frames_written_SA >= MAX_FRAMES_SA
            break
        end

        % Avoid the repeated HeatmapChart allocation that caused native
        % graphics crashes. Reuse one standard image object instead.
        field_SA = sample_e_field_SA(FREQ, DIM, TRAN, PWR, PHASE_1, ...
            z_SA, TIME_SA, num_samples_SA);
        if isempty(field_image_SA)
            field_image_SA = imagesc(ax_SA, field_SA);
            axis(ax_SA, 'image');
            ax_SA.YDir = 'reverse';
            ax_SA.XLabel.String = 'Reflection surface sample (X direction)';
            ax_SA.YLabel.String = 'Reflection surface sample (Y direction)';
            colormap(fig_SA, bone);
            colorbar_SA = colorbar(ax_SA);
            colorbar_SA.Label.String = 'E-field magnitude (V/m)';
        else
            field_image_SA.CData = field_SA;
        end
        clim(ax_SA, 'auto');
        title(ax_SA, sprintf('E-Field (Spatial Magnitude, %s Mask)\n%.2f m from RIS', ...
            mask_name_SA, z_SA));

        drawnow;
        print(fig_SA, frame_path_SA, '-dpng', ...
            sprintf('-r%d', export_resolution_SA));
        frame_SA = imread(frame_path_SA);
        if ndims(frame_SA) == 2
            frame_SA = repmat(frame_SA, 1, 1, 3);
        end
        if isempty(video_frame_size_SA)
            video_frame_size_SA = 2 * ceil(size(frame_SA, [1 2]) / 2);
        end
        frame_SA = fit_video_frame_SA(frame_SA, video_frame_size_SA);
        writeVideo(v_SA, frame_SA);
        frames_written_SA = frames_written_SA + 1;
        clear field_SA frame_SA
        pause(frame_pause_SA);
    end
catch ME_SA
    warning('space_animation:StoppedEarly', ...
        'Animation stopped after %d frame(s): %s', ...
        frames_written_SA, ME_SA.message);
end

clear video_cleanup_SA
fprintf('Space animation finalized with %d frame(s): %s\n', ...
    frames_written_SA, video_path_SA);

function close_video_safely_SA(v_SA)
try
    close(v_SA);
catch ME_SA
    warning('space_animation:VideoCloseFailed', ...
        'Could not finalize the video file: %s', ME_SA.message);
end
end

function close_figure_safely_SA(fig_SA)
if isgraphics(fig_SA, 'figure')
    close(fig_SA);
end
end

function frame_SA = fit_video_frame_SA(frame_SA, target_size_SA)
% exportgraphics can vary by one pixel as chart labels change. Pad or crop
% to a fixed even canvas so the H.264 encoder receives identically sized frames.
frame_height_SA = min(size(frame_SA, 1), target_size_SA(1));
frame_width_SA = min(size(frame_SA, 2), target_size_SA(2));
fitted_frame_SA = zeros(target_size_SA(1), target_size_SA(2), size(frame_SA, 3), ...
    'like', frame_SA);
fitted_frame_SA(1:frame_height_SA, 1:frame_width_SA, :) = ...
    frame_SA(1:frame_height_SA, 1:frame_width_SA, :);
frame_SA = fitted_frame_SA;
end

function field_SA = sample_e_field_SA(freq_SA, dim_SA, tran_SA, pwr_SA, ...
        phase_SA, distance_SA, time_SA, num_samples_SA)
% Match plot_E_field's 2 m by 2 m observation surface without creating a
% HeatmapChart.
surface_coordinates_SA = 1 - (0:(num_samples_SA - 1)) * (2 / num_samples_SA);
field_SA = zeros(num_samples_SA, num_samples_SA);
for row_SA = 1:num_samples_SA
    for column_SA = 1:num_samples_SA
        location_SA = [surface_coordinates_SA(column_SA), ...
            surface_coordinates_SA(row_SA), distance_SA];
        [magnitude_SA, ~] = get_E_field(freq_SA, dim_SA, tran_SA, pwr_SA, ...
            phase_SA, location_SA, time_SA);
        field_SA(row_SA, column_SA) = magnitude_SA;
    end
end
end

function config_SA = load_animation_config_SA(config_path_SA)
source_SA = fileread(config_path_SA);
plot_call_index_SA = regexp(source_SA, ...
    '(?m)^[ \t]*(?:[A-Za-z]\w*[ \t]*=[ \t]*)?plot_E_field[ \t]*\(', 'once');
assert(~isempty(plot_call_index_SA), ...
    'space_animation:ConfigurationPlotNotFound', ...
    'Could not locate the final plot_E_field call in %s.', config_path_SA);

% Suppress a phase-mask plot even if the interactive configuration flag was
% enabled. The animation renders its own frames below.
setup_source_SA = source_SA(1:plot_call_index_SA - 1);
setup_source_SA = regexprep(setup_source_SA, ...
    '(?m)^\s*plt_y_n\s*=.*?;', 'plt_y_n = "N";');
eval(setup_source_SA);

required_names_SA = {'FREQ', 'DIM', 'TRAN', 'FOC', 'PWR', 'PHASE_1', 'B_OR_C'};
config_SA = struct();
for name_index_SA = 1:numel(required_names_SA)
    name_SA = required_names_SA{name_index_SA};
    assert(exist(name_SA, 'var') == 1, ...
        'space_animation:MissingConfiguration', ...
        '%s did not define %s.', config_path_SA, name_SA);
    config_SA.(name_SA) = eval(name_SA);
end
end

function delete_file_safely_SA(file_path_SA)
if isfile(file_path_SA)
    delete(file_path_SA);
end
end
