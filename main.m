clc; clear; close all

% ATL03 data information (custom data list)
data_info_atl03 = {
    'data1', 'D:\Projects\matlab_Projects\水下地形\doc\slid\data\ATL03\data2\ATL03_20220106124003_02331402_006_01.h5', 'gt1l', 27.72, 27.739;
    'data2', 'D:\Projects\matlab_Projects\水下地形\code\IAP_SWBF_v1\data\ATL03\data2\ATL03_20220106124003_02331402_006_01.h5', 'gt3l', 28.70, 28.85;
};

% ATL24 data information (custom data list)
data_info_atl24 = {
    'data1', 'D:\Projects\matlab_Projects\水下地形\doc\slid\data\ATL24\data2_ATL24_20220106124003_02331402_006_01_001_01.h5';
    'data2', 'D:\Projects\matlab_Projects\水下地形\code\IAP_SWBF_v1\data\ATL24\data2_ATL24_20220106124003_02331402_006_01_001_01.h5';
};

result_path = 'D:\Projects\matlab_Projects\水下地形\code\IAP_SWBF_v1\results';

% Calculate x and y axis ranges
x_min = [69.014, 28.71];
x_max = [69.022, 28.84];
y_min = [915, -40];
y_max = [945, -22];

% Data clipping range
y_min1 = [915, -40];
y_max1 = [945, -22];

% IAP-SWBF framework parameter configuration
wd = [70, 140];
overlap = [0.5, 0.8];

% Whether to perform afterpulse correction (True:1 False:0)
after_pulse_tag = 1;

% Loop through each dataset
% for i = 1:size(data_info, 1)
for i = 2 : 2

    save_path = fullfile(result_path, num2str(i));
    if ~exist(save_path,'dir')
        mkdir(save_path)
    end

    x_range = [x_min(i) x_max(i)];
    y_range = [y_min(i) y_max(i)];

    data_name = data_info_atl03{i, 1};
    file_name = data_info_atl03{i, 2};
    beam      = data_info_atl03{i, 3};
    lat_min   = data_info_atl03{i, 4};
    lat_max   = data_info_atl03{i, 5};

    % Read data and preview photon distribution
    gtx_struct = read_atl03_gtx_v2(file_name, beam, lat_min, lat_max);
    figure('Position',[50, 50, 600, 400], 'Color', 'w');
    plot(gtx_struct.lat_ph_i, gtx_struct.h_i, '.', 'Color', [0.6, 0.6, 0.6], 'MarkerSize', 4);
    plot_photons(gtx_struct)

    if after_pulse_tag == 1
        %% >>>>>>>>>>>>>>>>> Afterpulse removal <<<<<<<<<<<<<<<<<<<<< %% 

        geoid_h = 0; % Geoid correction flag (already corrected)

        [beams_available, ancillary, dfs, dfs_tlm, tlm_data_tble] = ...
            read_atl03_after_pulse(file_name, geoid_h, beam, lat_min, lat_max);

        % Convert structure to table
        if isstruct(dfs.(beam))
            df = struct2table(dfs.(beam));
        end
        if isstruct(dfs_tlm.(beam))
            tlm_data = struct2table(dfs_tlm.(beam));
        end

        % Create major_frame level data table
        df_mframe = make_mframe_df(df, tlm_data_tble,'tag',1);

        % Identify flat water surface segments
        df_mframe = find_flat_water_surfaces(df_mframe, df);

        % Detect afterpulse photons
        [afterpulse_photons_all, df_new, df_mframe_new] = ...
            get_densities_afterpulse_prob(df, df_mframe, beam, ancillary);

        ph_afterpluse_id = afterpulse_photons_all.ph_index;

        % Visualization
        plot_photon_afterpulse(df_new, ph_afterpluse_id, beam, ...
            'save_plot', true, 'output_dir', save_path);

        % Extract photons without afterpulse
        hhh = df_new.h;
        hhh(ph_afterpluse_id) = NaN;
        ph_no_afterpluse_id = ~isnan(hhh);

        ph_distance = df_new.ph_distance_i(ph_no_afterpluse_id);
        Ph_Conf     = df_new.signal_conf_ph_i(ph_no_afterpluse_id);
        ref_elev    = df_new.ph_ref_elev_i(ph_no_afterpluse_id);
        ref_azi     = df_new.ph_ref_azimuth_i(ph_no_afterpluse_id);
        ph_h        = df_new.h(ph_no_afterpluse_id);
        lat         = df_new.lat(ph_no_afterpluse_id);
        lon         = df_new.lon(ph_no_afterpluse_id);

    else

        gtx_struct  = read_atl03_gtx_v2(file_name, beam, lat_min, lat_max);

        ph_distance = gtx_struct.ph_distance_i;
        Ph_Conf     = gtx_struct.signal_conf_ph_i;
        ref_elev    = gtx_struct.ph_ref_elev_i;
        ref_azi     = gtx_struct.ph_ref_azimuth_i;
        ph_h        = gtx_struct.h;
        lat         = gtx_struct.lat;
        lon         = gtx_struct.lon;

    end


    %% >>>>>>>>>>>>>>>>> Bathymetry extraction <<<<<<<<<<<<<<<<<< %%


    % Original photon data
    ori_lat = df_new.lat;
    ori_hhh = df_new.h;

    cut_up_th   = y_max1(i);
    cut_down_th = y_min1(i);

    cut_ph_id   = find(ph_h >= cut_down_th & ph_h <= cut_up_th);

    ph_distance = ph_distance(cut_ph_id);
    Ph_Conf     = Ph_Conf(cut_ph_id);
    ref_elev    = ref_elev(cut_ph_id);
    ref_azi     = ref_azi(cut_ph_id);
    ph_h        = ph_h(cut_ph_id);
    lat         = lat(cut_ph_id);
    lon         = lon(cut_ph_id);

    % Normalize along-track distance
    along_distance_ori = ph_distance - min(ph_distance);
    along_distance = Homogenization(along_distance_ori, 500);



    %% >>>>>>>>>>> Extract sea surface photons <<<<<<<<<<<<<<< %%

    % Histogram parameters
    % Along-track width: 16 m
    % Vertical bin height: 0.15 m
    bin_width0 = wd(i);
    bin_hhh0   = 0.15;

    [sea_surf_id, below_id, above_id] = ...
        getSeaSurfacePhontons_v2(along_distance, ph_h, bin_width0,bin_hhh0);

    % Sea surface fitting
    sea_surf_h     = ph_h(sea_surf_id);
    sea_surf_dist  = along_distance(sea_surf_id);
    sea_surf_lat   = lat(sea_surf_id);
    sea_surf_dist_ori = along_distance_ori(sea_surf_id);

    fit_sea_surf_h = fitSeaSurfacebyMODWT_v2(sea_surf_dist, sea_surf_h, "DWT",save_path);

    mean_seah = mean(sea_surf_h);

    % Remove abnormal sea surface photons
    sig_id_sf = smoothAndFilterSignalPhotons(along_distance, ph_h, sea_surf_id);
    sea_surf_lat = lat(sig_id_sf);
    sea_surf_h   = ph_h(sig_id_sf);



    %% >>>>>>>>>>> Extract underwater photons <<<<<<<<<<<<<<<< %% 

    sea_down_h        = ph_h(below_id);
    sea_down_dist     = along_distance(below_id);
    sea_down_dist_ori = along_distance_ori(below_id);
    sea_down_ref_elev = ref_elev(below_id);
    sea_down_ref_azi  = ref_azi(below_id);
    sea_down_lat      = lat(below_id);
    sea_down_lon      = lon(below_id);


    %% Save sea surface photons and underwater photons
    disp(">> Save sea-surface photons and underwater photons (exclude above-surface photons)")

    sea_surf = table(sea_surf_lat, sea_surf_h, ...
        'VariableNames', {'sea_surf_lat', 'sea_surf_h'});

    sea_down = table(sea_down_lat, sea_down_h, ...
        'VariableNames', {'sea_down_lat', 'sea_down_h'});

    if ~isempty(save_path)

        sea_surf_path  = strcat(save_path,'sea_surf_cord.csv');
        writetable(sea_surf, sea_surf_path);

        sea_down_path  = strcat(save_path,'sea_down_cord.csv');
        writetable(sea_down, sea_down_path);

    end


    %% >>>>>>>>>>> Underwater signal photon extraction <<<<<<<<<<<<<< %% 

    bin_width1 = wd(i);
    overlap_ratio1 = overlap(i);

    x = sea_down_dist;
    x1 = sea_down_lat;
    y = sea_down_h;

    [sig_id_all, med_id_all, x_sig, y_sig1, x_med, y_med] = ...
        getSeaDownSignalPhotons_KED(x, y, bin_width1, overlap_ratio1);

    % Photon densification
    [~, ~, point_id1] = encryptionPhononsPoint_v2(x, y, x_med, y_med);

    % Denoising signal photons
    sig_id_all_new = ismember((1:length(x))', sig_id_all) | logical(point_id1);
    sig_id_all_new = find(sig_id_all_new==1);

    sig_id_fin = smoothAndFilterSignalPhotons(x, y, sig_id_all_new);

    % Refraction correction
    [~, vertoff, lat_fix, lon_fix, ~] = ...
        ICESat2_RefractionCorrection( ...
        sea_down_ref_azi(sig_id_fin), ...
        sea_down_ref_elev(sig_id_fin), ...
        sea_down_lat(sig_id_fin), ...
        sea_down_lon(sig_id_fin), ...
        y(sig_id_fin), ...
        mean_seah);

    sea_down_h_fix = y(sig_id_fin) + vertoff;

    % Visualization
    file_name_1 = 'IAP-SWBF';
    plot_sig_noise(ori_lat, ori_hhh, x1(sig_id_fin), sea_down_h_fix, ...
        sea_surf_lat, sea_surf_h, save_path, file_name_1, x_range, y_range)



    %% Save results
    disp('>> Save Results')

    results_struct_m1 = struct( ...
        'ph_distance',ph_distance, ...
        'sea_surf_dist_ori',sea_surf_dist_ori, ...
        'sea_down_dist_ori',sea_down_dist_ori, ...
        'sea_surf_id',sea_surf_id, ...
        'along_distance_nom',along_distance, ...
        'sea_down_h',sea_down_h, ...
        'sea_down_dist',sea_down_dist, ...
        'below_id',below_id, ...
        'sig_id_all_new',sig_id_all_new, ...
        'sig_id_fin',sig_id_fin, ...
        'ph_h',ph_h, ...
        'sea_down_dist_new',sea_down_dist, ...
        'sea_down_h_new',sea_down_h, ...
        'sea_surf_h',sea_surf_h, ...
        'sea_surf_dist',sea_surf_dist, ...
        'fit_sea_surf_h',fit_sea_surf_h, ...
        'x_med',x_med, ...
        'y_med',y_med, ...
        'med_id_all',med_id_all, ...
        'sig_dist_fin',x(sig_id_fin), ...
        'sig_ph_fin',y(sig_id_fin), ...
        'sig_ph_refract',sea_down_h_fix, ...
        'lat_fix',lat_fix, ...
        'lon_fix',lon_fix);

    % Save MAT file
    if ~isempty(save_path)

        currentDateTime    = datetime('now', 'Format', 'yyyy_MM_dd');
        struct_save_path   = strcat(save_path,char(currentDateTime),'_results_m1.mat');
        save(struct_save_path,"results_struct_m1");

    end


    % Save coordinates
    sea_down_coordinate_m1 = table(lat_fix, lon_fix, sea_down_h_fix, ...
        'VariableNames', {'Lat', 'Lon', 'water_depth'});

    if ~isempty(save_path)

        sea_down_save_path = strcat(save_path,'sea_down_coordinate_m1.csv');
        writetable(sea_down_coordinate_m1, sea_down_save_path);

    end



    %% ATL24 comparison results

    file_name_24 = data_info_atl24{i,2};

    gtx_24_hdata = read_atl24_gtx(file_name_24, beam, lat_min, lat_max);

    id_40 = find(gtx_24_hdata.class_ph_i == 40); % seabed photons
    id_41 = find(gtx_24_hdata.class_ph_i == 41); % sea surface photons

    sea_lat = gtx_24_hdata.lat_ph_i(id_40);
    sea_lon = gtx_24_hdata.lon_ph_i(id_40);
    sea_elh = gtx_24_hdata.ellipse_h_i(id_40);

    water_lat = gtx_24_hdata.lat_ph_i(id_41);
    water_lon = gtx_24_hdata.lon_ph_i(id_41);
    water_elh = gtx_24_hdata.ellipse_h_i(id_41);

    file_name_5 = 'atl24';

    plot_sig_noise(ori_lat, ori_hhh, sea_lat, sea_elh, ...
        water_lat, water_elh, save_path, file_name_5, x_range, y_range);

end


