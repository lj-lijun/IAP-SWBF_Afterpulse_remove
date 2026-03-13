function [sea_surf_id, below_id, above_id] = getSeaSurfacePhontons_v2(x, y, bin_width, vertical_bin_size)

disp('>> Getting sea surface photons')

x_min = min(x);
x_max = max(x);
bin_edges = x_min-bin_width : bin_width : x_max+bin_width;

sea_surf_id = [];
below_id = [];
above_id = [];

for i = 1:length(bin_edges)-1
    x_start = bin_edges(i);
    x_end = bin_edges(i+1);

    idx = x >= x_start & x < x_end;
    x_seg = x(idx);
    y_seg = y(idx);
    idx_all = find(idx);

    if numel(y_seg) < 1
        continue;
    end

    [counts, edges] = histcounts(y_seg, 'BinWidth', vertical_bin_size);
    bin_centers = edges(1:end-1) + diff(edges)/2;
    if length(counts) < 3
        continue;
    end

    [peaks, locs] = findpeaks(counts, 'MinPeakProminence', 5);
    

    if length(peaks) > 1
        last_peak_index = locs(end);
        last_peak_center = bin_centers(last_peak_index);

        if last_peak_index > 1 && last_peak_index < length(bin_centers)
            idx_range = last_peak_index-1:last_peak_index+1;
            last_peak_data = counts(idx_range);
            last_peak_centers = bin_centers(idx_range);

            ft = fittype('a*exp(-((x-b)^2)/(2*c^2))', ...
                'independent','x','coefficients',{'a','b','c'});
            opts = fitoptions(ft);
            [~, max_idx] = max(counts);
            opts.StartPoint = [counts(max_idx), bin_centers(max_idx), 0.1];

            [gauss_fit, ~] = fit(double(last_peak_centers)', double(last_peak_data)', ft, opts);
            sigma = abs(gauss_fit.c);
            lower_bound = last_peak_center - 6*sigma;   % 6
            upper_bound = last_peak_center + 3*sigma;
        else
            disp('Peak too close to edge for Gaussian fit, using ±0.3m rule');
            lower_bound = last_peak_center - 0.5;
            upper_bound = last_peak_center + 0.3;
        end

    else
        ft = fittype('a*exp(-((x-b)^2)/(2*c^2))', ...
            'independent','x','coefficients',{'a','b','c'});
        opts = fitoptions(ft);
        [~, max_idx] = max(counts);
        opts.StartPoint = [counts(max_idx), bin_centers(max_idx), 0.3];

        [gauss_fit, ~] = fit(double(bin_centers)', double(counts)', ft, opts);
        mu = gauss_fit.b;
        sigma = abs(gauss_fit.c);
        lower_bound = mu - 6*sigma;  
        upper_bound = mu + 3*sigma;
    end

    in_range = y_seg >= lower_bound & y_seg <= upper_bound;
    below_range = y_seg < lower_bound;
    above_range = y_seg > upper_bound;

    sea_surf_id = [sea_surf_id; idx_all(in_range)];
    below_id    = [below_id; idx_all(below_range)];
    above_id    = [above_id; idx_all(above_range)];
end
end
