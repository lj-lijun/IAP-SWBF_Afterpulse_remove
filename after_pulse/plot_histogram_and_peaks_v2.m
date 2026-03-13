function plot_histogram_and_peaks_v2(mids, hist_h, hist_h_plot_smooth, mids_peakfind, hist_peakfind, df_sat)

    figure('Position', [50, 50, 1200, 800]);

    subplot(1, 2, 1);
    yyaxis left;
    plot(mids, hist_h, 'b-', 'LineWidth', 1, 'DisplayName', 'Original Histogram');
    ylabel('Photon Count (Raw)');
    
    yyaxis right;
    plot(mids, hist_h_plot_smooth, 'r-', 'LineWidth', 2, 'DisplayName', 'Smoothed Data');
    ylabel('Photon Density (Smoothed)');
    
    xlabel('Elevation (m)');
    title('Histogram Data and Smoothing');
    grid on;
    legend({'Original Histogram', 'Smoothed Data'}, 'Location', 'best');

    subplot(1, 2, 2);
    plot(mids_peakfind, hist_peakfind, 'g-', 'LineWidth', 1, 'DisplayName', 'Peak Detection Region');
    hold on;

    if ~isempty(df_sat)
        plot(df_sat.elev, df_sat.height, 'ro', 'MarkerSize', 5, ...
            'MarkerFaceColor', 'r', 'DisplayName', 'Detected Peaks');

        for i = 1:height(df_sat)
            text(df_sat.elev(i), df_sat.height(i) + max(hist_peakfind) * 0.05, ...
                sprintf('P%d: %.2fm', i, df_sat.elev(i)), ...
                'FontSize', 5, 'HorizontalAlignment', 'center');
        end
    end

    xlabel('Elevation (m)');
    ylabel('Photon Count');
    title('Peak Detection Results (≤ -0.35 m)');
    legend('Location', 'best');
    grid on;

end