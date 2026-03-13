
function [sea_surf_h_fit] = fitSeaSurfacebyMODWT_v2(distance_i, sea_surf_h, Method,save_path)

if Method == "modwt"

    disp('Decompose Sea Surface Photons by the MODWT')
   
    levelForReconstruction = [false,false,false,false,true];
    wt = modwt(sea_surf_h,'sym4',4);
    mra = modwtmra(wt,'sym4');
    sea_surf_h_fit = sum(mra(levelForReconstruction,:),1);

else
    disp('Decompose Sea Surface Photons by the DWT')
    sea_surf_h_fit = wdenoise(sea_surf_h,5, ...
        Wavelet='sym5', ...
        DenoisingMethod='Bayes', ...
        ThresholdRule='Soft', ...
        NoiseEstimate='LevelIndependent');

end

figurehadle = figure;
hold on; box on
scatter(distance_i, sea_surf_h, 5, 'blue', 'filled', DisplayName='signal')
scatter(distance_i, sea_surf_h_fit, 5, 'red', 'filled', DisplayName='fit')
legend show
title('fitSeaSurface')

print(figurehadle,[save_path,'fit_sea_surface_photons.png'],'-r600','-dpng');

end


