function [beams_available, ancillary, dfs, dfs_tlm, dfs_tlm_tb] = read_atl03_after_pulse(filename, geoid_h, gtxs_to_read,lat_min_threshold,lat_max_threshold)

if nargin < 2, geoid_h = true; end
if nargin < 3, gtxs_to_read = 'all'; end

fprintf('>> reading in %s\n', filename);
[~, fname, ~] = fileparts(filename);
granule_id = extractBetween(fname, 'ATL03_', '.h5');
if isempty(granule_id)
    granule_id = fname;
end

all_beams = {'gt1l', 'gt1r', 'gt2l', 'gt2r', 'gt3l', 'gt3r'};
beams_available = {};

for i = 1:length(all_beams)
    beam = all_beams{i};
    try
        h5info(filename, ['/' beam '/heights']);
        beams_available{end+1} = beam;
    catch
        continue;
    end
end

if isequal(gtxs_to_read, 'all')
    beamlist = beams_available;
elseif isequal(gtxs_to_read, 'none')
    beamlist = {};
elseif iscell(gtxs_to_read)
    beamlist = intersect(gtxs_to_read, beams_available);
elseif ischar(gtxs_to_read)
    beamlist = intersect({gtxs_to_read}, beams_available);
else
    beamlist = beams_available;
end

dfs = struct();
dfs_tlm = struct();


orient = h5read(filename, '/orbit_info/sc_orient');
orient_str = {'backward', 'forward', 'transition', 'error'};
sc_orient = orient_str{orient(1)+1};

gtx_beam_dict = [];
gtx_strength_dict = [];

beam_strength_table = {'weak','strong'};
if strcmp(sc_orient, 'backward')
    beam_ids = 1:6;
else
    beam_ids = 6:-1:1;
end
for i = 1:6
    gtx_beam_dict.(all_beams{i}) = beam_ids(i);
    gtx_strength_dict.(all_beams{i}) = beam_strength_table{mod(beam_ids(i),2)+1};
end

ancillary = struct();
ancillary.granule_id = granule_id;
ancillary.atlas_sdp_gps_epoch = h5read(filename, '/ancillary_data/atlas_sdp_gps_epoch');
ancillary.rgt = h5read(filename, '/orbit_info/rgt');
ancillary.cycle_number = h5read(filename, '/orbit_info/cycle_number');
ancillary.sc_orient = sc_orient;
ancillary.gtx_beam_dict = gtx_beam_dict;
ancillary.gtx_strength_dict = gtx_strength_dict;
ancillary.gtx_dead_time_dict = struct();

for i = 1:length(beamlist)
    beam = beamlist{i};
    disp(['>> Processing beam: ' beam]);

    try
        dead_time = h5read(filename, ['/ancillary_data/calibrations/dead_time/' beam '/dead_time']);
        if strcmp(gtx_strength_dict.(beam), 'strong')
            ancillary.gtx_dead_time_dict.(beam) = mean(dead_time(1:16));
        else
            ancillary.gtx_dead_time_dict.(beam) = mean(dead_time(17:end));
        end

        lat_all = h5read(filename, ['/' beam '/heights/lat_ph']);     
        lon_all = h5read(filename, ['/' beam '/heights/lon_ph']);     
        h_all   = h5read(filename, ['/' beam '/heights/h_ph']);       
        dt_all  = h5read(filename, ['/' beam '/heights/delta_time']); 
        mframe_all = h5read(filename, ['/' beam '/heights/pce_mframe_cnt']); 
        pulseid_all = h5read(filename, ['/' beam '/heights/ph_id_pulse']);   
        qual_all = h5read(filename, ['/' beam '/heights/quality_ph']); 
       
        dist_ph_along = h5read(filename, ['/',beam ,'/heights/dist_ph_along' ]);  
        ref_elev = h5read(filename, ['/',beam ,'/geolocation/ref_elev' ]);       
        ref_azimuth = h5read(filename, ['/',beam ,'/geolocation/ref_azimuth' ]);  
        segment_ph_cnt = h5read(filename, ['/',beam ,'/geolocation/segment_ph_cnt' ]);   
        signal_conf_ph = h5read(filename, ['/',beam ,'/heights/signal_conf_ph' ]);    
        Signal_conf_ph = signal_conf_ph';

        ph_index_beg = h5read(filename, ['/' beam '/geolocation/ph_index_beg']);  
        segment_dist_x = h5read(filename, ['/' beam '/geolocation/segment_dist_x']);   
        segment_length = h5read(filename, ['/' beam '/geolocation/segment_length']); 
        geoid = h5read(filename, ['/' beam '/geophys_corr/geoid']);  

        index_zero = segment_ph_cnt == 0;
        segment_ph_cnt(index_zero) = [];   
        segment_ph_cnt_accumulate = cumsum(double(segment_ph_cnt)); 

        ph_index_beg(index_zero) = [];
        ref_elev(index_zero) = [];
        ref_azimuth(index_zero) = [];
        segment_dist_x(index_zero) = [];

        h_all = double(h_all);                     
        ph_ref_elev = zeros(length(h_all),1);      
        ph_ref_azimuth = zeros(length(h_all),1);   
        ph_distance = zeros(length(h_all),1);         

        for j = 1:length(segment_ph_cnt)
            ph_beg = double(ph_index_beg(j));
            ph_end = segment_ph_cnt_accumulate(j);
            ph_range = ph_beg : ph_end;
            ph_ref_elev(ph_range) = double(ref_elev(j));
            ph_ref_azimuth(ph_range) = double(ref_azimuth(j));
            ph_distance(ph_range) = double(dist_ph_along(ph_range)) + segment_dist_x(j); 
        end

        xatc_all = nan(size(lat_all));
        for j = 1:length(ph_index_beg)
            if ph_index_beg(j) > 0 && ph_index_beg(j) <= length(xatc_all)
                xatc_all(ph_index_beg(j)) = segment_dist_x(j);
            end
        end
        xatc_all = fillmissing(xatc_all, 'previous');

        mask = (qual_all < 3) & (lat_all >= lat_min_threshold) & (lat_all <= lat_max_threshold);

        df.signal_conf_ph_i = Signal_conf_ph(mask,:);
        df.ph_ref_elev_i = double(ph_ref_elev(mask));
        df.ph_distance_i = double(ph_distance(mask));
        df.ph_ref_azimuth_i = double(ph_ref_azimuth(mask));
        df.lat = lat_all(mask);
        df.lon = lon_all(mask);
        df.h   = h_all(mask);
        df.dt  = dt_all(mask);
        df.mframe = mframe_all(mask);
        df.ph_id_pulse = pulseid_all(mask);

        dist_along = dist_ph_along(mask);
        df.xatc = xatc_all(mask) + dist_along;

        if geoid_h
            geoid_x = segment_dist_x + 0.5 * segment_length;
            valid_geoid = geoid < 1e10;
            geoid_interp = interp1(geoid_x(valid_geoid), geoid(valid_geoid), df.xatc, 'linear', 0);
            df.h = double(df.h - geoid_interp);
            df.geoid = half(geoid_interp);
        else
            df.geoid = zeros(size(df.h), 'like', df.h);
        end

        [df.xatc, idx] = sort(df.xatc);
        fields = fieldnames(df);
        for f = 1:length(fields)
            df.(fields{f}) = df.(fields{f})(idx);
        end

        dfs.(beam) = df;

        df_tlm = struct();
        df_tlm.pce_mframe_cnt = h5read(filename, ['/' beam '/bckgrd_atlas/pce_mframe_cnt']);    
        df_tlm.tlm_height_band1 = h5read(filename, ['/' beam '/bckgrd_atlas/tlm_height_band1']); 
        df_tlm.tlm_height_band2 = h5read(filename, ['/' beam '/bckgrd_atlas/tlm_height_band2']); 
        df_tlm.tlm_top_band1 = h5read(filename, ['/' beam '/bckgrd_atlas/tlm_top_band1']);  
        df_tlm.tlm_top_band2 = h5read(filename, ['/' beam '/bckgrd_atlas/tlm_top_band2']);
        dfs_tlm.(beam) = df_tlm;

        pce_mframe_cnt = h5read(filename, ['/' beam '/bckgrd_atlas/pce_mframe_cnt']);
        tlm_height_band1 = h5read(filename, ['/' beam '/bckgrd_atlas/tlm_height_band1']);
        tlm_height_band2 = h5read(filename, ['/' beam '/bckgrd_atlas/tlm_height_band2']);
        tlm_top_band1 = h5read(filename, ['/' beam '/bckgrd_atlas/tlm_top_band1']);
        tlm_top_band2 = h5read(filename, ['/' beam '/bckgrd_atlas/tlm_top_band2']);


        dfs_tlm_table = table(pce_mframe_cnt, tlm_height_band1, tlm_height_band2, ...
            tlm_top_band1, tlm_top_band2, 'VariableNames', ...
            {'pce_mframe_cnt', 'tlm_height_band1', 'tlm_height_band2', ...
            'tlm_top_band1', 'tlm_top_band2'});

        [unique_mframes, ~, mframe_idx] = unique(dfs_tlm_table.pce_mframe_cnt);
        df_tlm_grouped = table();
        df_tlm_grouped.pce_mframe_cnt = unique_mframes;


        for k = 1:length(unique_mframes)
            group_idx = mframe_idx == k;
            df_tlm_grouped.tlm_height_band1(k) = max(dfs_tlm_table.tlm_height_band1(group_idx));
            df_tlm_grouped.tlm_height_band2(k) = max(dfs_tlm_table.tlm_height_band2(group_idx));
            df_tlm_grouped.tlm_top_band1(k) = max(dfs_tlm_table.tlm_top_band1(group_idx));
            df_tlm_grouped.tlm_top_band2(k) = max(dfs_tlm_table.tlm_top_band2(group_idx));
        end

        dfs_tlm_tb = df_tlm_grouped;

    catch ME
        warning('Error reading %s on %s: %s', filename, beam, ME.message);
    end
end
fprintf('>> Data reading complete.\n');
end



