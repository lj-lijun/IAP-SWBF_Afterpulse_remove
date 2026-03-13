
function [horzoff, vertoff, lat_fix, lon_fix, h_fix] = ICESat2_RefractionCorrection(azi, elev, lat, lon, h, mean_h)
disp('ICESat2 Refraction Correction')
%Extract strong ground track LiDAR data (Latitude, Longitude, Ellipsoidal Height) from ICESat-2 ALT03 HDF5 file as .CSV files and run 
%the conversion from ellipsoid to orthometric datum. The tool GPS-H from the Canadian 
%Hydrographic Survey was used for this code (Transformation from ITRF2014 to CGVD2013), however it is recommended to 
%convert the data to the orthometric model which best fits your study area. The following refraction correction has been adapted 
%for MATLAB from equations validated by Parrish, C., Magruder, L., Neuenschwander, A., Forfinski-Sarkozi, N., Alonzo, M., Jasinski, M. 2019. 
%"Validation of ICESat-2 ATLAS Bathymetry and Analysis of ATLASs Bathymetric Mapping Performance" Remote Sensing 11, no. 14: 1634.
% https://doi.org/10.3390/rs11141634
h = double(h);
theta1 = pi/2 - elev;
kappa  = azi; 
% n1 = 1.00029;  %n1 and n2 are the refractive indices of air and water 
% n2 = 1.343; 
n1 = 1.00029;
n2 = 1.34116; 
theta2= asin( n1 * sin(theta1) / n2 ); 
S     = (h - mean_h) ./ cos(theta1);  
R     = S * n1/n2; 
gamma = pi/2 - theta1; 
P     = sqrt( R.*R + S.*S - 2*R.*S.*cos(theta1 - theta2) ); 
alpha = asin( R.* sin( theta1 - theta2 ) ./ P); 
beta  = gamma - alpha; 

horzoff = P .* cos(beta); % delta Y in the paper 
vertoff = P .* sin(beta); % delta Z in the paper 

latoff = horzoff .* cos(kappa); % delta N in the paper 
lonoff = horzoff .* sin(kappa); % delta E in the paper 

[x, y, z] = ell2xyz(deg2rad(lat), deg2rad(lon), h);

x_fix = x + double(latoff); 
y_fix = y + double(lonoff); 
z_fix = z + double(vertoff); 

[lat_fix, lon_fix, h_fix] = xyz2ell(x_fix, y_fix, z_fix);
lat_fix = rad2deg(lat_fix);
lon_fix = rad2deg(lon_fix);


end
