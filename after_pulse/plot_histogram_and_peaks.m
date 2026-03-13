
function plot_histogram_and_peaks(mid1, hist1, smooth_hist1, locs1, pks1, peak_loc1, idx, ...
                                  mid2, hist2, smooth_hist2, locs2, pks2, peak_loc2, idx2, buffer, mframe)

    figure('Position', [100, 100, 1400, 600]);
    subplot(1, 2, 1);
    yyaxis left;
    bar(mid1, hist1, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none', 'BarWidth', 0.8);
    ylabel('Original frequency');  
    ylim([0 max(hist1) * 1.1]);
    yyaxis right;
    plot(mid1, smooth_hist1, 'b-', 'LineWidth', 1);
    hold on;
    scatter(mid1(locs1), pks1, 100, 'r^', 'filled', 'MarkerEdgeColor', 'k');
    if length(pks1) > 1
        scatter(peak_loc1, max(pks1(idx)), 100, 'rd', 'filled', 'MarkerEdgeColor', 'k');
    else
        scatter(peak_loc1, pks1, 100, 'rd', 'filled', 'MarkerEdgeColor', 'k');
    end
    grid on;
    
    legend('Frequency Histogram', 'Smooth Curve', 'Peak Detection', 'Main Peak ', 'Location', 'northwest');
    ylabel('Normalized Amplitude');
    xlabel('Elevation');
    
    subplot(1, 2, 2);
    
    yyaxis left;
    bar(mid2, hist2, 'FaceColor', [0.7 0.7 0.9], 'EdgeColor', 'none', 'BarWidth', 0.8);
    ylabel('Original frequency');  
    ylim([0 max(hist2) * 1.1]);
  
    yyaxis right;
    plot(mid2, smooth_hist2, 'b-', 'LineWidth', 2);
    hold on;
    
    plot([min(mid2) max(mid2)], [0.5 0.5], 'k--', 'LineWidth', 1); 
    plot([min(mid2) max(mid2)], [0.2 0.2], 'r--', 'LineWidth', 1);  
    
    scatter(mid2(locs2), pks2, 120, 'r^', 'filled', 'MarkerEdgeColor', 'k');
   
    if length(pks2) > 1
        scatter(peak_loc2, max(pks2(idx2)), 180, 'mp', 'filled', 'MarkerEdgeColor', 'k');
    else
        scatter(peak_loc2, pks2, 180, 'mp', 'filled', 'MarkerEdgeColor', 'k');
    end
    ylabel('Normalized Amplitude');
    xlabel('Elevation');
   
    leg_items = {'Frequency Histogram', 'Smoothed Curve', 'Height Threshold', 'Significance Threshold', 'Candidate Peak', 'Main Peak'};
    show_items = [true, true, true, true, ~isempty(locs2), true];
    legend(leg_items(show_items), 'Location', 'northwest');
end



