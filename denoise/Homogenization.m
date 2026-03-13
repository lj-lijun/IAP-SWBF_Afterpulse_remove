function [dist_new] = Homogenization(along_dist,winsise)

bin_width = winsise;

[pdf, ~, ~] = histcounts(along_dist, 'BinWidth', bin_width, 'Normalization', 'probability');

cdf = cumsum(pdf);
N = length(pdf);

k = floor(along_dist ./ bin_width);
dist_rell = along_dist - k * bin_width;

dist_new = zeros(length(along_dist), 1);
for i = 1:length(dist_new)
    k_num = k(i);
    if k_num == 0
        dist_new_num = N * dist_rell(i) * pdf(k_num + 1);
    elseif k_num == N
        dist_new_num = N * bin_width * cdf(k_num);
    else
        dist_new_num = N * bin_width * cdf(k_num) + N * dist_rell(i) * pdf(k_num + 1);
    end
    dist_new(i) = dist_new_num;
end

end