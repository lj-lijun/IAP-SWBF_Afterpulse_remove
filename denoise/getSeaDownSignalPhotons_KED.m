function [signal_indices_all, median_indices_all, x_sig, y_sig1, x_med, y_med] = getSeaDownSignalPhotons_KED(x, y, bin_width, overlap_ratio)
disp('Get Sea Down Signal Photons')

    bin_step = bin_width * (1 - overlap_ratio);
    bin_starts = min(x):bin_step:(max(x) - bin_width);
    bin_edges = [bin_starts' bin_starts' + bin_width];

    signal_indices_all = [];
    median_indices_all = [];

    for i = 1:size(bin_edges, 1)
        x_start = bin_edges(i, 1);
        x_end   = bin_edges(i, 2);

        idx_in_bin = x >= x_start & x < x_end;
        x_bin = x(idx_in_bin);
        y_bin = y(idx_in_bin);
        idx_all = find(idx_in_bin);

        if numel(y_bin) < 3
            continue;
        end
        
        SNR = calculate_sig_ph_snr(y_bin, 0.15);
        if max(SNR) < 9.5
            continue
        end

        bin_h = 0.15;  
        [density, density_x] = ksdensity(y_bin,'Bandwidth',bin_h);
        [peaks, locs] = findpeaks(density, density_x);
        if isempty(peaks)
            continue;
        end
        [~, max_idx] = max(peaks);
        peak_y = locs(max_idx); 

        win = 0.6;   % 
        peak_mask = abs(y_bin - peak_y) <= win;
        mu = mean(y_bin(peak_mask));
        sigma = std(y_bin(peak_mask));
        lower = mu - 1.5 * sigma;   % 
        upper = mu + 1.5 * sigma;

        keep_mask = y_bin >= lower & y_bin <= upper;
        indices_keep = idx_all(keep_mask);
        x_keep = x_bin(keep_mask);
        y_keep = y_bin(keep_mask);
        signal_indices_all = [signal_indices_all; indices_keep];

        if isempty(x_keep)
            continue;
        end
        x_center = (min(x_keep) + max(x_keep)) / 2;
        y_center = (min(y_keep) + max(y_keep)) / 2;

        dist_to_center = sqrt((x_keep - x_center).^2 + (y_keep - y_center).^2);
        [~, rel_idx] = min(dist_to_center);
        center_global_idx = indices_keep(rel_idx);

        median_indices_all = [median_indices_all; center_global_idx];
    end

    signal_indices_all = unique(signal_indices_all);
    median_indices_all = unique(median_indices_all);

    x_med = x(median_indices_all);
    y_med = y(median_indices_all);
    wt_med = modwt(y_med, 'sym4', 4);
    mra_med = modwtmra(wt_med, 'sym4');
    levels_med = [false, false, true, true, true];
    y_med_smooth = sum(mra_med(levels_med, :), 1)';
    d_med = y_med_smooth - y_med;
    outlier_mask_med = abs(d_med) > 2 * std(d_med);
    y_med(outlier_mask_med) = y_med_smooth(outlier_mask_med);

    x_sig = x(signal_indices_all);
    y_sig = y(signal_indices_all);
    wt_sig = modwt(y_sig, 'sym4', 4);
    mra_sig = modwtmra(wt_sig, 'sym4');
    levels_sig = [false, false, false, true, true];
    y_sig_smooth = sum(mra_sig(levels_sig, :), 1)';
    d_sig = y_sig_smooth - y_sig;
    valid_mask = abs(d_sig) <= 2 * std(d_sig);

    x_sig = x_sig(valid_mask);
    y_sig = y_sig(valid_mask);
    y_sig1 = y_sig_smooth(valid_mask);
    signal_indices_all = signal_indices_all(valid_mask);

end


