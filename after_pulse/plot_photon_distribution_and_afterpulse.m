
function plot_photon_distribution_and_afterpulse(df, dfseg, df_join, mframe)

    figure('Position', [50, 50, 1200, 400]);

    
    subplot(1, 3, 1);
    scatter(df.lat, df.h, 6, [0.8 0.8 0.8], 'MarkerFaceAlpha', 0.6);
    hold on;
    scatter(dfseg.lat, dfseg.h, 6, 'b', 'filled', 'MarkerFaceAlpha', 0.6);
    xlabel('Latitude (°)');
    ylabel('Height (m)');
    title(sprintf('Original Photons - Mframe %d', mframe));
    grid on;
    hold off;

 
    subplot(1, 3, 2);
    afterpulse_id = find(df_join.is_afterpulse == 1);
    normal_id = find(df_join.is_afterpulse == 0);
%     normal_photons = df_join(~df_join.is_afterpulse, :);
%     afterpulse_photons = df_join(df_join.is_afterpulse, :);

    scatter(df.lat, df.h, 6, [0.8 0.8 0.8], 'MarkerFaceAlpha', 0.6);
    hold on;
    scatter(df_join.lat(normal_id), df_join.h(normal_id), 6, 'b', 'filled', 'MarkerFaceAlpha', 0.6, 'DisplayName', 'Normal');
    scatter(df_join.lat(afterpulse_id), df_join.h(afterpulse_id), 6, 'r', 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', 'Afterpulse');
    xlabel('Latitude (°)');
    ylabel('Height (m)');
    title('Afterpulse Detection');
    legend;
    grid on;
    hold off;

    subplot(1, 3, 3);
    scatter(df.lat, df.h, 6, [0.8 0.8 0.8], 'MarkerFaceAlpha', 0.6);
    hold on;
    scatter(df_join.lat, df_join.h, 6, df_join.prob_afterpulse, 'filled', 'MarkerFaceAlpha', 0.7);
    colorbar;
    xlabel('Latitude (°)');
    ylabel('Height (m)');
    title('Afterpulse Probability');
    grid on;
    hold off;
end



