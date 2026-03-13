function [point_x, point_y, tag] = encryptionPhononsPoint_v2(ph_d, ph_h, fit_ph_d, fit_ph_h)
disp('Encryption Photons Points')
    point_x = [];
    point_y = [];
    tag = zeros(length(ph_d), 1);

    for m = 1:(length(fit_ph_d) - 1)
        % 拟合段两个点
        x1 = fit_ph_d(m);
        y1 = fit_ph_h(m);
        x2 = fit_ph_d(m+1);
        y2 = fit_ph_h(m+1);

        if m == 1
            idx = find(ph_d >= ph_d(1) & ph_d < x2);
        elseif m == length(fit_ph_d) - 1
            idx = find(ph_d >= x1 & ph_d <= ph_d(end));
        else
            idx = find(ph_d >= x1 & ph_d < x2);
        end

        x_seg = ph_d(idx);
        y_seg = ph_h(idx);

        if isempty(x_seg)
            continue;
        end

        d = norm([x2 - x1, y2 - y1]);
        a = d / 2;
        n = numel(x_seg);
        b = a / n;

        center = [(x1 + x2)/2, (y1 + y2)/2];
        theta = atan2(y2 - y1, x2 - x1);  

        x_rel = x_seg - center(1);
        y_rel = y_seg - center(2);
        x_rot = x_rel * cos(theta) + y_rel * sin(theta);
        y_rot = -x_rel * sin(theta) + y_rel * cos(theta);

        in_ellipse = (x_rot/a).^2 + (y_rot/b).^2 <= 1; 

        point_x = [point_x; x_seg(in_ellipse)];
        point_y = [point_y; y_seg(in_ellipse)];
        tag(idx(in_ellipse)) = 1;
    end

    [point_x, idx_unique] = unique(point_x);
    point_y = point_y(idx_unique);

    
end
