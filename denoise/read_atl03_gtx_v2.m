
function [gtx_hdata] = read_atl03_gtx_v2(file_name,beam,lat_min_threshold,lat_max_threshold)
  
    file_delta_transmit_time = ['/',beam ,'/heights/delta_time' ];
    delta_time = h5read(file_name,file_delta_transmit_time);

    file_h_ph= ['/',beam ,'/heights/h_ph' ];
    h_ph = h5read(file_name,file_h_ph);

    file_lat_ph = ['/',beam ,'/heights/lat_ph' ];
    lat_ph = h5read(file_name,file_lat_ph);
    lat_max = max(lat_ph);
    lat_min = min(lat_ph);
    file_lon_ph = ['/',beam ,'/heights/lon_ph' ];
    lon_ph = h5read(file_name,file_lon_ph);
  
    file_dist_ph_along = ['/',beam ,'/heights/dist_ph_along' ];
    dist_ph_along = h5read(file_name,file_dist_ph_along);

    file_ref_elev = ['/',beam ,'/geolocation/ref_elev' ];
    ref_elev = h5read(file_name,file_ref_elev);

    file_ref_azimuth = ['/',beam ,'/geolocation/ref_azimuth' ];
    ref_azimuth = h5read(file_name,file_ref_azimuth);

    file_ph_index_beg = ['/',beam ,'/geolocation/ph_index_beg' ];
    ph_index_beg = h5read(file_name,file_ph_index_beg);

    file_segment_dist_x = ['/',beam ,'/geolocation/segment_dist_x' ];
    segment_dist_x = h5read(file_name,file_segment_dist_x);

    file_segment_ph_cnt = ['/',beam ,'/geolocation/segment_ph_cnt' ];
    segment_ph_cnt = h5read(file_name,file_segment_ph_cnt);

    index_zero = segment_ph_cnt == 0;

    segment_ph_cnt(index_zero) = [];
    segment_ph_cnt_accumulate=cumsum(double(segment_ph_cnt));
    ph_index_beg(index_zero)=[];
    ref_elev(index_zero)=[];
    ref_azimuth(index_zero)=[];
    segment_dist_x(index_zero)=[];
  
    ph_ref_elev = zeros(length(h_ph),1);
    ph_ref_azimuth = zeros(length(h_ph),1); 
    ph_distance=zeros(length(h_ph),1);

    for i = 1:length(segment_ph_cnt)
        ph_beg = double(ph_index_beg(i));
        ph_end = segment_ph_cnt_accumulate(i);
        ph_range = ph_beg:ph_end;
        ph_ref_elev(ph_range) = double(ref_elev(i));
        ph_ref_azimuth(ph_range) = double(ref_azimuth(i));
        ph_distance(ph_range)=double(dist_ph_along(ph_range))+segment_dist_x(i);

    end

    file_signal_conf_ph= ['/',beam ,'/heights/signal_conf_ph' ];
    signal_conf_ph = h5read(file_name,file_signal_conf_ph);
 
    index = find(lat_ph>=lat_min_threshold & lat_ph<=lat_max_threshold);

    h_i = double(h_ph(index,:));
    delta_time_i = delta_time(index,:);
    Signal_conf_ph = signal_conf_ph';
    signal_conf_ph_i = Signal_conf_ph(index,:);
    lat_ph_i = lat_ph(index,:);
    lon_ph_i = lon_ph(index,:);
    ph_ref_elev_i = double(ph_ref_elev(index));
    ph_distance_i = double(ph_distance(index));
    ph_ref_azimuth_i = double(ph_ref_azimuth(index));
    
gtx_hdata = struct('signal_conf_ph',signal_conf_ph,'delta_time_i',delta_time_i,'h_i',h_i,...
        'delta_time',delta_time,'h_ph',h_ph,'signal_conf_ph_i',signal_conf_ph_i,...
    'lat_ph_i',lat_ph_i,'lon_ph_i',lon_ph_i,'lat_max',lat_max,'lat_min',lat_min,...
    'lat_ph',lat_ph,'lon_ph',lon_ph,...
    'ref_elev',ref_elev,'ph_ref_elev',ph_ref_elev,'ph_ref_elev_i',ph_ref_elev_i,...
    'ph_distance',ph_distance,'ph_distance_i',ph_distance_i,...
    'dist_ph_along',dist_ph_along,'ph_index_beg',ph_index_beg,'segment_dist_x',segment_dist_x,'segment_ph_cnt',segment_ph_cnt,'ph_ref_azimuth_i',ph_ref_azimuth_i);
   
end
