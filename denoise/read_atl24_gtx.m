
function [gtx_hdata] = read_atl24_gtx(file_name,beam,lat_min_threshold,lat_max_threshold)

class_ph_name = ['/',beam ,'/class_ph' ];
class_ph = h5read(file_name,class_ph_name);

ortho_h_name = ['/',beam ,'/ortho_h' ];
ortho_h = h5read(file_name,ortho_h_name);

ellipse_h_name = ['/',beam ,'/ellipse_h' ];
ellipse_h = h5read(file_name,ellipse_h_name);

file_lat_ph = ['/',beam ,'/lat_ph' ];
lat_ph = h5read(file_name,file_lat_ph);

file_lon_ph = ['/',beam ,'/lon_ph' ];
lon_ph = h5read(file_name,file_lon_ph);

surface_h_name = ['/',beam ,'/surface_h' ];
surface_h = h5read(file_name,surface_h_name);

index = find(lat_ph >= lat_min_threshold & lat_ph <= lat_max_threshold);

class_ph_i  = class_ph(index,:);
ortho_h_i   = ortho_h(index,:);
ellipse_h_i = ellipse_h(index,:);
lat_ph_i    = lat_ph(index,:);
lon_ph_i    = lon_ph(index,:);
surface_h_i = surface_h(index);

gtx_hdata = struct('class_ph',class_ph,'ortho_h',ortho_h,'ellipse_h',ellipse_h, ...
    'lat_ph',lat_ph,'lon_ph',lon_ph,'surface_h',surface_h,...
    'class_ph_i',class_ph_i,'ortho_h_i',ortho_h_i,'ellipse_h_i',ellipse_h_i,'lat_ph_i',lat_ph_i,...
    'lon_ph_i',lon_ph_i,'surface_h_i',surface_h_i);

end