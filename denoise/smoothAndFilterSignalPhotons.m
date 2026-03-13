function [signal_indices_new] = smoothAndFilterSignalPhotons(x, y, signal_indices_all)
disp('Smooth and Filter Signal Photons')
    x_sig = x(signal_indices_all);
    y_sig = y(signal_indices_all);
    wt_sig = modwt(y_sig, 'sym4', 4);
    mra_sig = modwtmra(wt_sig, 'sym4');
    levels_sig = [false, false, false, true, true];
    y_sig_smooth = sum(mra_sig(levels_sig, :), 1)';
    d_sig = y_sig_smooth - y_sig;
    valid_mask = abs(d_sig) <= 1 * std(d_sig);   
    x_sig = x_sig(valid_mask);
    y_sig = y_sig(valid_mask);
    y_sig_smooth = y_sig_smooth(valid_mask);
    signal_indices_new = signal_indices_all(valid_mask);
end
