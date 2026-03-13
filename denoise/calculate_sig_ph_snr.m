function [SNR] = calculate_sig_ph_snr(Hp_frame, delta_z)

e_a =  2;                 
e_m = 3.5;               
r1 = 2.5;                

Zmin = min(Hp_frame);
nbin = ceil((max(Hp_frame) + 0.1*delta_z - min(Hp_frame))/delta_z);  

ph_count_sum = length(Hp_frame);        
ph_count = zeros(nbin,1);               
bin_id_index = zeros(ph_count_sum,1);  

for ph_id = 1 : ph_count_sum
    bin_id_index(ph_id) = floor ((Hp_frame(ph_id) - Zmin)/delta_z) + 1;
    ph_count(bin_id_index(ph_id)) = ph_count(bin_id_index(ph_id)) + 1;
end

Ha_u = sum(ph_count(:))/nbin;

if nbin > 1
    Ha_segma = sqrt(sum( (ph_count(:) - Ha_u).^2 )/(nbin-1));
  
    
    Ha_bg_mask = zeros(nbin,1);    
    Ha_bg_ph_count = zeros(nbin,1);   
    for j = 1 : nbin
        if ph_count(j) <= Ha_u + e_a*Ha_segma
            Ha_bg_mask(j) = 1;         
            Ha_bg_ph_count(j) =  ph_count(j);
        else
            Ha_bg_mask(j) = 0;
            Ha_bg_ph_count(j) = 0;
        end
    end

    
    Nb_Ha_bg    = sum(Ha_bg_mask(:));    
    Ha_bg_u     = sum(Ha_bg_ph_count(:))/Nb_Ha_bg;
    Ha_bg_segma = sqrt(sum((Ha_bg_ph_count(:) - Ha_bg_u).^2)/(Nb_Ha_bg-1));
    ubg_deltazpc_deltatPC    = Ha_bg_u;
    segmabg_deltazpc_deltatPC = Ha_bg_segma;
    
    
    Thsig = ubg_deltazpc_deltatPC + e_m * segmabg_deltazpc_deltatPC;
    SNR   = zeros(nbin,1);             
    Ha_sig_mask = zeros(nbin,1);     
    Ha_sig_ph_count = zeros(nbin,1);
    % Ha_sig_SNR = zeros(nbin,1);      
    for j = 1 : nbin
        SNR(j) = ph_count(j)/ubg_deltazpc_deltatPC; 
        if (ph_count(j) > Thsig) && (SNR(j) > r1)
            Ha_sig_mask(j) = 1;                    
            Ha_sig_ph_count(j) = ph_count(j);       
        else
            Ha_sig_mask(j) = 0;
            Ha_sig_ph_count(j) = 0;
        end
        % Ha_sig_SNR(j) = Ha_sig_ph_count(j)/ubg_deltazpc_deltatPC;  
    end
end
end