function [] = plot_photons(gtx_struct)
    figure;
    xx = gtx_struct.ph_distance_i - min(gtx_struct.ph_distance_i);
    yy = gtx_struct.h_i;

    plot(xx, yy, '.', 'Color', [0.6, 0.6, 0.6], 'MarkerSize', 4);  
    xlabel('Along-Track (m)', 'FontSize', 14, 'FontName', 'Times New Roman');
    ylabel('Elevation (m)', 'FontSize', 14, 'FontName', 'Times New Roman');

    ax = gca;
    ax.FontSize = 12;
    ax.FontName = 'Times New Roman';
    ax.Box = 'on';            
    ax.LineWidth = 1;      
    ax.TickDir = 'out';       
    ax.TickLength = [0.005 0.03];
    
end