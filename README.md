# MATLAB/Octave Implementation of Recommendation ITU-R P.1546

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6206015.svg)](https://doi.org/10.5281/zenodo.6206015)

This code repository contains a MATLAB/Octave software implementation of  [Recommendation ITU-R P.1546-6](https://www.itu.int/rec/R-REC-P.1546/en) with a method for point-to-area predictions for terrestrial services in the frequency range 30 MHz to 4000 MHz.  

This version of the code corresponds to the reference version approved by ITU-R Working Party 3K and published on [ITU-R SG 3 Software, Data, and Validation Web Page](https://www.itu.int/en/ITU-R/study-groups/rsg3/Pages/iono-tropo-spheric.aspx) as digital supplement to [Recommendation ITU-R P.1546](https://www.itu.int/rec/R-REC-P.1546/en).

The following table describes the structure of the folder `./matlab/` containing the MATLAB/Octave implementation of Recommendation ITU-R P.1546.

| File/Folder               | Description                                                         |
|----------------------------|---------------------------------------------------------------------|
|`P1546FieldStrMixed.m`                | MATLAB function implementing Recommendation ITU-R P.1546-6          |
|`validateP1546.m`          | MATLAB script used to validate the implementation of Recommendation ITU-R P.1546-6 in `P1546FieldStrMixed.m`             |
|`./validation_profiles/`    | Folder containing a proposed set of terrain profiles and inputs for validation of MATLAB implementation (or any other software implementation) of this Recommendation |
|`./validation_results/`	   | Folder containing all the results written during the transmission loss computations for the set of terrain profiles defined in the folder `./validation_profiles/` |
|`./private/`   |             Folder containing the functions used by `validateP1546.m` to read the test terrain profiles and compute all the parameters required as arguments of the function `P1546FieldStrMixed`|

## Function Call

The function `P1546FieldStrMixed` can be called

1. by invoking only the required input arguments:
~~~
[Ep, Lb] = P1546FieldStrMixed(f, t, heff, h2, R2, area, d_v, path_c, pathinfo);
~~~

2. by invoking additional optional arguments using Name-Value Pair Arguments. Name is the argument name and Value is the
corresponding value. Name must appear inside quotes. You can specify several name and value pair arguments in any order as
Name1,Value1,...,NameN,ValueN:
~~~
[Ep, Lb] = P1546FieldStrMixed(f, t, heff, h2, R2, area, d_v, path_c, pathinfo, ...
                            'q', 50, 'wa', 27, 'Ptx', 1, 'ha', 100);
~~~  

## Required input arguments of function `P1546FieldStrMixed`

| Variable          | Type   | Units | Limits       | Description  |
|-------------------|--------|-------|--------------|--------------|
| `f`               | scalar double | MHz   | 30 ≤ `f` ≤ 4000 | Frequency   |
| `t         `      | scalar double | %     | 1 ≤ `p` ≤ 50 | Time percentage for which the calculated basic transmission loss is not exceeded |
| `heff`          | scalar double | m    |   | Effective height of the transmitting/base antenna, height over the average level of the ground between distances of 3 and 15 km from the transmitting/base antenna in the direction of the receiving/mobile antenna.|
| `h2`           | scalar double    | m      |             |  Receiving/mobile antenna height above ground level |
| `R2`           | scalar double    | m      |              |  Representative clutter height around receiver. Typical values: `R2`=10 for `area`='Rural' or 'Suburban' or 'Sea',  `R2`=15 for `area`='Urban', `R2`=20 for `area`='Dense Urban'    |
| `area`           | string    |       | 'Land, 'Sea', 'Warm', 'Cald'            |  Area around the receiver.|
| `d_v`               | array double | km    | `sum(d_v)` ≤ ~1000 | Array of horizontal path lengths over different path zones starting from transmitter/base station terminal.|
| `path_c`           | cell string    |       |     'Land', 'Sea', 'Warm', 'Cold'         |  Cell of strings defining the path zone for each given path lenght in `d_v` starting from the transmitter/base terminal. |
| `pathinfo`           | scalar int    |      |        0, 1    |  0 - no terrain profile information available, 1 - terrain information available |


## Optional input arguments of function `P1546FieldStrMixed`
| Variable          | Type   | Units | Limits       | Description  |
|-------------------|--------|-------|--------------|--------------|
| `q`           | scalar double    | %      |   1 ≤ `q`  ≤ 99          |  Location percentage for which the calculated basic transmission loss is not exceeded. Default is 50%. |
| `wa`           | scalar double    | m      |   ~50 ≤ wa ≤ ~1000         |  The width of the square area over which the variabilitiy applies. Needs to be defined only if `pathinfo`= 1 and `q` ≠ 50. Default: 0 dB. |
| `Ptx`           | scalar double    | kW      |   `Ptx` > 0          |  Tx power; Default: 1. |
| `ha`           | scalar double    | m      |             |  Transmitter antenna height above ground. Defined in Annex 5 §3.1.1. Limits are defined in Annex 5 §3. |
| `hb`           | scalar double    | m      |             |  Height of transmitter/base antenna above terrain height averaged over 0.2d and d, when d is less than 15 km and where terrain information is available. |
| `R1`           | scalar double    | m      |              |  Representative clutter height around transmitter.   |
| `tca`           | scalar double    | deg      | 0.55   ≤  `tca`  ≤ 40        |  Terrain clearance angle.|
| `htter`           | scalar double    | m      |         | Terrain height in meters above sea level at the transmitter/base.|
| `hrter`           | scalar double    | m      |         | Terrain height in meters above sea level at the receiver/mobile.|
| `eff1`           | scalar double    | deg      |        |  The h1 terminal's terrain clearance angle calculated using the method in §4.3 case a), whether or not h1 is negative.|
| `eff2`           | scalar double    | deg      |        |  The h2 terminal's terrain clearance angle calculated using the method in §11, noting that this is the elevation angle relative to the local horizontal.|
| `debug`           | scalar int    |       |  0, 1           |  If `debug`= 1, the results are written in log files. Default: 0. |
| `fidlog`           | scalar int    |       |     Only used if `debug`= 1        |  File identifier of the log file opened for writing outside the function. If not provided, a default file with a filename containing a timestamp will be created. |


 
## Outputs ##

| Variable   | Type   | Units | Description |
|------------|--------|-------|-------------|
| `Ep`    | double | dB(uV/m)    | Electric field strength |
| `Lb`    | double | dB    | Basic transmission loss |

## Notes

Notes:
If sea path is selected for a `t` value less then 50% the default 10% table use is a cold sea path.

Not implemented in this version of the code:
* Annex 7: Adjustment for different climatic regions
* Annex 5, Section 4.3a): C_h1 calculation (terrain database is  available and the potential of discontinuities around h1 = 0 is of no concern)

## Software Versions
The code was tested and runs on:
* MATLAB versions 2017a and 2020a
* Octave version 6.1.0

## References

* [Recommendation ITU-R P.1546](https://www.itu.int/rec/R-REC-P.1546/en)

* [ITU-R SG 3 Software, Data, and Validation Web Page](https://www.itu.int/en/ITU-R/study-groups/rsg3/Pages/iono-tropo-spheric.aspx)
