function plot_photon_afterpulse(df,ph_afterpluse_id, gtx, varargin)

p = inputParser;
addParameter(p, 'save_plot', false);
addParameter(p, 'output_dir', './');
parse(p, varargin{:});
save_plot = p.Results.save_plot;
output_dir = p.Results.output_dir;

figure('Position', [50, 50, 1400, 800], 'Color', 'w');
fs = 12; 

lat_pluse = df.lat(ph_afterpluse_id);
lon_pluse = df.lon(ph_afterpluse_id);
hhh_pluse = df.h(ph_afterpluse_id);
prob_pulse = df.prob_afterpulse(ph_afterpluse_id);


x_range = [min(df.lat), max(df.lat)];
y_range = [min(df.h), max(df.h)];

subplot(2,2,1);
s1 = scatter(df.lat, df.h, 6, 'b', 'filled', 'MarkerFaceAlpha', 0.6);
xlabel('Latitude (°)', 'FontSize', fs);
ylabel('Height (m)', 'FontSize', fs);
title('Original Photon Distribution', 'FontSize', fs+1, 'FontWeight', 'bold');
xlim(x_range);
ylim(y_range);
legend(s1, 'Photons', 'Location', 'best', 'FontSize', fs-1);
grid on;
set(gca, 'FontSize', fs);


subplot(2,2,2);
hold on;
s2a = scatter(df.lat, df.h, 6, [0.85 0.85 0.85], 'filled', 'MarkerFaceAlpha', 0.5);
s2b = scatter(lat_pluse, hhh_pluse, 6, 'r', 'filled', 'MarkerFaceAlpha', 0.8);
hold off;
xlabel('Latitude (°)', 'FontSize', fs);
ylabel('Height (m)', 'FontSize', fs);
title('Afterpulse Detection', 'FontSize', fs+1, 'FontWeight', 'bold');
xlim(x_range);
ylim(y_range);
legend([s2a, s2b], {'Normal Photons', 'Afterpulses'}, 'Location', 'best', 'FontSize', fs-1);
grid on;
set(gca, 'FontSize', fs);


subplot(2,2,3);
s3a = scatter(df.lat, df.h, 6, [0.85 0.85 0.85], 'filled', 'MarkerFaceAlpha', 0.5); hold on;
s3b = scatter(lat_pluse, hhh_pluse, 6, prob_pulse, 'filled', 'MarkerFaceAlpha', 0.7);
colormap(gca, flipud(copper));
cb1 = colorbar;
cb1.Label.String = 'Afterpulse Probability';
cb1.Label.FontSize = fs;
xlabel('Latitude (°)', 'FontSize', fs);
ylabel('Height (m)', 'FontSize', fs);
title('Afterpulse Probability', 'FontSize', fs+1, 'FontWeight', 'bold');
xlim(x_range);
ylim(y_range);
legend([s3a, s3b], {'Normal Photons', 'Afterpulse Prob.'}, 'Location', 'best', 'FontSize', fs-1);
grid on;
set(gca, 'FontSize', fs);
hold off;

subplot(2,2,4);
s4 = scatter(df.lat, df.h, 5, df.snr, 'filled', 'MarkerFaceAlpha', 0.7);
colormap(gca, flipud(copper));
cb2 = colorbar;
cb2.Label.String = 'SNR / Photon Density';
cb2.Label.FontSize = fs;
xlabel('Latitude (°)', 'FontSize', fs);
ylabel('Height (m)', 'FontSize', fs);
title('Photons Density', 'FontSize', fs+1, 'FontWeight', 'bold');
xlim(x_range);
ylim(y_range);
legend(s4, 'SNR Weighted Photons', 'Location', 'best', 'FontSize', fs-1);
grid on;
set(gca, 'FontSize', fs);
hold off;

if save_plot
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    filename = fullfile(output_dir, sprintf('photon_afterpulse_%s.png', gtx));
    print(gcf, filename, '-dpng', '-r300');
    fprintf('Plot saved as: %s\n', filename);
end

end
