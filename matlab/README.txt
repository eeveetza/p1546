P1546 Version 1.26.05.16

MATLAB implementation of Recommendation ITU-R P.1546-5

GENERAL NOTES
--------------

Files and subfolders in the distribution .zip package.

 P1546FieldStrMixed.m	     - MATLAB function implementing Recommendation ITU-R P.1546-5.

 validateP1546.m             - MATLAB script used to validate the implementation of
                               Recommendation ITU-R P.1546-5 as defined in the file
                               P1546FieldStrMixed.m using a set of test terrain profiles
                               provided in the folder ./test_profiles/

 ./test_profiles/	     - Folder containing a proposed set of test terrain profiles for
                               validation of MATLAB implementation (or any other software
                               implementation) of Recommendation ITU-R P.1546-5.

 result_validation_log.csv   - Template for reporting final and intermediate results of field
                               strength computation according to Recommendation ITU-R P.1546-5.

 ./test_results/             - Folder containing all the results written during the field strength
                               computations for the test terrain profiles defined
                               in the folder ./test_profiles/

 ./src/                      - Folder containing the functions used by validateP1546.m to read
                               the test terrain profiles and compute all the parameters required
                               as arguments of the function P1546FieldStrMixed.

