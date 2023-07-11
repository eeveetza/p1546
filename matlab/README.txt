P1546 Development Version 7.0 

MATLAB implementation of Recommendation ITU-R P.1546-6

GENERAL NOTES
--------------

Files and subfolders in the distribution .zip package.

 P1546FieldStrMixed.m	     - MATLAB function implementing Recommendation ITU-R P.1546-6

 validateP1546.m             - MATLAB script used to validate the implementation of
                               Recommendation ITU-R P.1546-6 as defined in the file
                               P1546FieldStrMixed.m using a set of terrain profiles
                               provided in the folder ./validation_profiles/

 ./validation_profiles/	     - Folder containing a proposed set of terrain profiles for
                               validation of MATLAB implementation (or any other software
                               implementation) of Recommendation ITU-R P.1546-6

 result_validation_log.csv   - Template for reporting final and intermediate results of field
                               strength computation according to Recommendation ITU-R P.1546-6

 ./validation_results/       - Folder containing all the results written during the field strength
                               computations for the set of terrain profiles defined
                               in the folder ./validation_profiles/

 ./private/                  - Folder containing the functions used by validateP1546.m to read
                               the test terrain profiles and compute all the parameters required
                               as arguments of the function P1546FieldStrMixed


UPDATES AND FIXES
-----------------
Development Version 7.0
    - Draft revision of Rec. ITU-R P.1546-6 (3/119Rev1):
    - Extension of upper frequency to 6 GHz,
    - Approxiation for time percentages above 50% and below 99%, 
    - Tx correction applied only for paths >= 1 km
    - Included antisymmetric formula for troposcatter field strength
    - Validation examples are not updated

Version 6.2 (22.05.22)
    - Simplified handling of optional input arguments
    - Renaming subfolder "src" into "private" which is automatically in the MATLAB search path
    - Minor editorial corrections
    - Correction of the coverage code column in validation profile b2iseac_sea

Version 6.1 (08.04.20)
    - Introduced changes according to ITU-R P.1546-6:
          Upper frequency limit, representative clutter heights, location variability in Step_18a
    - Additional validation examples to test implementation of P1546-6 Annex 5 Paragraph 1.1 (terminal designation)

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


License and copyright notice

Swiss Federal Office of Communications OFCOM (hereinafter the "Software Copyright Holder") makes the accompanying software 
(hereinafter the "Software") available free from copyright restriction. 

The Software Copyright Holder represents and warrants that to the best of its knowledge, 
it has the necessary copyright rights to waive all of the copyright rights as permissible under national law in the Software 
such that the Software can be used by implementers without further licensing concerns. 

No patent licence is granted, nor is a patent licensing commitment made, by implication, estoppel or otherwise. 

Disclaimer: Other than as expressly provided herein, 

(1) the Software is provided "AS IS" WITH NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, 
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGMENT OF INTELLECTUAL PROPERTY RIGHTS and 

(2) neither the Software Copyright Holder (or its affiliates) nor the ITU shall be held liable in any event for any damages whatsoever 
(including, without limitation, damages for loss of profits, business interruption, loss of information, or any other pecuniary loss) 
arising out of or related to the use of or inability to use the Software.