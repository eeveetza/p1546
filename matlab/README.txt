P1546 Version 5.14 (01.05.19)

MATLAB implementation of Recommendation ITU-R P.1546-5

GENERAL NOTES
--------------

Files and subfolders in the distribution .zip package.

 P1546FieldStrMixed.m	     - MATLAB function implementing Recommendation ITU-R P.1546-5

 validateP1546.m             - MATLAB script used to validate the implementation of
                               Recommendation ITU-R P.1546-5 as defined in the file
                               P1546FieldStrMixed.m using a set of terrain profiles
                               provided in the folder ./validation_profiles/

 ./validation_profiles/	     - Folder containing a proposed set of terrain profiles for
                               validation of MATLAB implementation (or any other software
                               implementation) of Recommendation ITU-R P.1546-5

 result_validation_log.csv   - Template for reporting final and intermediate results of field
                               strength computation according to Recommendation ITU-R P.1546-5

 ./validation_results/       - Folder containing all the results written during the field strength
                               computations for the set of terrain profiles defined
                               in the folder ./validation_profiles/

 ./src/                      - Folder containing the functions used by validateP1546.m to read
                               the test terrain profiles and compute all the parameters required
                               as arguments of the function P1546FieldStrMixed


UPDATES AND FIXES
-----------------
Version 3 (01.05.19)
    - Steps 1-16 use d = 1 km in interpolation for distances 0.04 < d < 1 km as per ITU-R P.1546-5
    - Introduced a caveat in smooth_earth_heights when only two points exist in the profile
Version 2 (09.08.17)
    - Introduced new validation examples that exercise almost all of the method from ITU-R P.1546-5
    - The validation examples contain an indication whether calculations are performed for cold or warm seas
    - Designation to 'sea and coastal' and 'land' done according to the radio-meteorological code only,
      and not anymore according to the coverage code in validateP1546.m
	- The format of validation examples in ./validation_profiles aligned with the newest SG 3 data format
	- Corrected compatibility issue with Matlab version 2016 (an newer) occurring in Step_17a when PTx = []
	- Corrected a typo in eq. (26) of Step_11
	- Corrected a bug in Dh1 computation in function step82 for sea path
	- Changed the naming: test_profiles -> validation_profiles, test_results -> validation results


Version 1 (26.05.16)
     - Initial implementation