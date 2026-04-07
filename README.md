# IAP-SWBF_Afterpulse_correction

**1. Overview**

This repository provides an implementation of the IAP-SWBF (ICESat-2 AfterPulse-aware Shallow Water Bathymetry Framework), designed for extracting high-precision shallow-water bathymetry from ICESat-2 ATL03 photon-counting LiDAR data.

The framework explicitly considers afterpulse effects caused by detector saturation, enabling robust separation of:

Sea surface photons
Underwater terrain photons
Afterpulse noise photons

It is particularly suitable for saturated nearshore and extremely shallow-water environments (0–5 m).

**2. Main Features**
Physics-informed afterpulse detection and removal
Adaptive sea surface extraction using wavelet-based fitting
Robust underwater signal photon extraction
Photon densification and denoising strategy
Refraction correction for accurate bathymetry
Comparison with ATL24 official bathymetry product

**3. Workflow**

The main processing pipeline includes:

**ATL03 Data Reading**
Extract photon-level information (height, latitude, confidence, etc.)
**Afterpulse Correction (Optional)**
Identify afterpulse photons using:
Detector dead-time characteristics
Photon density-based probabilistic modeling
**Data Preprocessing**
Spatial clipping
Along-track distance normalization
**Sea Surface Extraction**
Histogram-based photon selection
Wavelet-based surface fitting (MODWT)
**Underwater Photon Extraction**
Adaptive sliding window segmentation
Signal photon detection (KED method)
**Signal Enhancement**
Photon densification
Noise filtering
**Refraction Correction**
Correct underwater photon positions using incidence angle
**Result Output & Visualization**
Bathymetric point clouds
CSV and MAT outputs
Comparison with ATL24

**4. File Structure**
.

├── main.m                      % Main processing script

├── data/

│   ├── ATL03/                 % Input ATL03 files

│   └── ATL24/                 % Reference ATL24 data

├── results/                   % Output directory

│   ├── sea_surf_cord.csv      % Sea surface photons

│   ├── sea_down_cord.csv      % Underwater photons

│   ├── sea_down_coordinate_m1.csv  % Final bathymetry

│   └── *_results_m1.mat       % Intermediate results

**5. Input Data**
Required:
ICESat-2 ATL03 data (.h5)
Beam selection (e.g., gt1l, gt3l)
Latitude range for subsetting
Optional:
ATL24 data (for validation/comparison)

**6. Key Parameters**
Parameter	Description
wd： Sliding window size (e.g., 70 m)
overlap： Window overlap ratio
after_pulse_tag： Enable/disable afterpulse correction
bin_hhh0： Vertical bin size for surface detection
y_min / y_max： Elevation filtering range

**7. Output**

The framework generates:

Sea surface photons
Underwater signal photons
Refraction-corrected bathymetry points
Visualization figures
MAT files for further analysis

**8. Example Usage**
after_pulse_tag = 1; % Enable afterpulse correction
wd = [70];
overlap = [0.5];

main; % Run processing pipeline

**9. Key Functions**

Function	Description
read_atl03_gtx_v2：	Read ATL03 photon data
read_atl03_after_pulse：	Load afterpulse-related parameters
get_densities_afterpulse_prob：	Detect afterpulse photons
getSeaSurfacePhontons_v2：	Extract sea surface photons
fitSeaSurfacebyMODWT_v2：	Fit sea surface
getSeaDownSignalPhotons_KED：	Extract underwater signals
ICESat2_RefractionCorrection：	Perform refraction correction

**10. Notes**
The framework is optimized for calm water surfaces where afterpulse effects are significant.
Parameter tuning (e.g., window size) may be required for different environments.

