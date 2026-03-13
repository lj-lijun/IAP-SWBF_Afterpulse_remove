function plot_sig_noise(lat,ph_h, x1, y, sea_surf_lat, sea_surf_h, save_path, file_name,x_range,y_range)

    fig1 = figure('Color', 'w', 'Position', [200, 200, 550, 350]);
    hold on;

    s1 = scatter(lat,ph_h, 3, [0.8 0.8 0.8], 'filled','DisplayName', 'Raw photons');
    s2 = scatter(sea_surf_lat, sea_surf_h, 3, [0 0.3 0.8], 'filled','DisplayName', 'Water surface photons');
    s3 = scatter(x1, y, 3, [0.85 0.33 0.1], ...
    'Marker', 'x', 'LineWidth', 1, 'DisplayName', 'Underwater terrain photons');

    xlabel('Latitude (°)', 'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('Height (m)', 'FontSize', 12, 'FontName', 'Times New Roman');
    xlim(x_range)
    ylim(y_range)
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, ...
             'LineWidth', 1, 'TickDir', 'out', 'Box', 'on','TickLength',[0.005,0.015]);

    legend([s1, s2, s3], {'Raw photons', 'Water surface photons','Underwater terrain photons'}, ...
        'Location', 'northeast', 'FontSize', 11,'FontName', 'Times New Roman', ...
        'Box', 'off', 'NumColumns', 1);

    print(fig1, fullfile(save_path, [file_name, '.tif']), '-dtiffn', '-r600');
    print(fig1, fullfile(save_path, [file_name, '.png']), '-dpng', '-r600');
    savefig(fig1, fullfile(save_path, [file_name, '.fig']));
    disp('>> Figure saved successfully');

end
