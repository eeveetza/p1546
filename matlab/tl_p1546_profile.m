function [E, L] = tl_p1546_profile(f, t, d, h, zone, h1, h2, R1, R2, area2, varargin)
%% tl_p1546_profile: Recommendation ITU-R P.1546-6 with terrain profile
% This function computes the terrain profile parameters and calls function
% P1546MixedFieldStr that implements Rec. ITU-R P.1546-6
% 
% [E, L] = tl_p1546(f, t, d, h, zone, R1, R2, area1, area2, varargin);
%
% where:    Units,  Definition                             Limits
% f:        MHz     Required frequency                     30 MHz - 4000 MHz
% t:        %       Required percentage time               1% - 50 %
% d:        m       Vector of terrain profile distances from the Tx
% h:        m       Vector of terrain profile heights
% zone:     -       Vector of zone types: Land (1), Sea (2), Cold Sea (3) or Warm Sea (4)
%                   starting from transmitter/base terminal
% h1,h2:    m       Tx/Rx antenna height above ground
% R1:       m       Representative clutter height around Transmitter
%                   R1 = -1 for uncluttered/open zone, otherwise
%                   R1=10 for area='Rural' or 'Suburban' or 'Sea'
%                   R1=15 for area='Urban'
%                   R1=20 for area='Dense Urban'
% R2:       m       Representative clutter height around Receiver
%                   Typical values:
%                   R1=10 for area='Rural' or 'Suburban' or 'Sea'
%                   R2=15 for area='Urban'
%                   R2=20 for area='Dense Urban'
% area2:    string  Area around the Receiver              'Rural', 'Urban',
%                                                          'Dense Urban'
%                                                          'Sea'
% q:        %       Location variability (default 50%)      1% - 99%
% wa:       m       the width of the square area over which the variability applies (m)
%                   needs to be defined only if pathinfo is 1 and q <> 50
%                   typically in the range between 50 m and 1000 m
% PTx:      kW      Transmitter (e.r.p) power in kW (default 1 kW)
% debug:    0/1     Set to 1 if the log files are to be written,
%                   otherwise set to default 0
% fidlog:           if debug == 1, a file identifier of the log file can be
%                   provided, if not, the default file with a file
%                   containin a timestamp will be created
%
% Output variables:
%
% E:        dBuV/m  Electric field strength
%
% L:        dB      Basic transimission loss
%
%
% How to use:
%
% 1) by invoking only the first nine required input arguments:
%
%   [E, L] = tl_p1546(f, t, d, h, zone, h1, h2, R1, R2, area2);
%
% 2) by invoking optional arguments in addition to the first nine required arguments
%  using Name-Value Pair Arguments. Name is the argument name and Value is the
%  corresponding value. Name must appear inside quotes. You can specify
%  several name and value pair arguments in any order as
%  Name1,Value1,...,NameN,ValueN.
%
%  [E, L] = tl_p1546(f, t, d, h, zone, h1, h2, R1, R2, area2 ...
%                              'q', 50, 'wa', 27, 'Ptx', 1);
%
%
%



% Rev   Date        Author                          Description
%-------------------------------------------------------------------------------
% v1   20SEP23     Ivica Stevanovic, OFCOM
%
%  Copyright (c) 2023, Ivica Stevanovic
%  All rights reserved.
%

%
%
% MATLAB Version 9.12.0.1975300 (R2022a) Update 3 used in development of this code
%%
% The Software is provided "AS IS" WITH NO WARRANTIES, EXPRESS OR IMPLIED,
% INCLUDING BUT NOT LIMITED TO, THE WARRANTIES OF MERCHANTABILITY, FITNESS
% FOR A PARTICULAR PURPOSE AND NON-INFRINGMENT OF INTELLECTUAL PROPERTY RIGHTS
%
% Neither the Software Copyright Holder (or its affiliates) nor the ITU
% shall be held liable in any event for any damages whatsoever
% (including, without limitation, damages for loss of profits, business
% interruption, loss of information, or any other pecuniary loss)
% arising out of or related to the use of or inability to use the Software.
%
% THE AUTHOR(S) AND OFCOM (CH) DO NOT PROVIDE ANY SUPPORT FOR THIS SOFTWARE
%
%%


%% Read the input arguments and check them

if nargin < 10
    fclose all;
    error('tl_p1546: function requires at least 10 input parameters.');
end
%

% Optional arguments

% Parse the optional input
iP = inputParser;
iP.addParameter('q',50)
iP.addParameter('wa',500)
iP.addParameter('PTx',1)
iP.addParameter('debug',0)
iP.addParameter('fid_log',[])
iP.parse(varargin{:});


% Unpack from input parser
q = iP.Results.q;
wa = iP.Results.wa;
PTx = iP.Results.PTx;
debug = iP.Results.debug;
fid_log = iP.Results.fid_log;

% terrain profile information available
pathinfo = 1;

% Compute terrain clearance angles for Tx and Rx
teff1 = teff1Calc(d, h, h1, h2);
tca   = tcaCalc  (d, h, h2, h1);

% Compute Tx/Rx terrain height
h1ter = h(1);
h2ter = h(end);

% Compute effective Tx antenna height
heff = heffCalc(d, h, h1);

% discriminate land and sea portions
dland = 0;
dsea = 0;
dcold = 0;
dwarm = 0;
for i=1:length(d)
    if (i==length(d))
        dinc=(d(end)-d(end-1))/2;
    elseif (i==1)
        dinc=(d(2)-d(1))/2;
    else
        dinc=(d(i+1) - d(i-1))/2;
    end

    if ( zone(i) == 1) % Land
        dland=dland+dinc;
    elseif (zone(i) == 2) %Sea
        dsea=dsea+dinc;
    elseif (zone(i) == 3) %Cold
        dcold = dcold + dinc;
    else % zone == 4, Warm
        dwarm = dwarm + dinc;
    end
end

d_v = [];
pathstr = '';
if dland > 0
    d_v = [d_v, dland];
    pathstr = [pathstr, 'Land,'];
end
if (dsea > 0)
    d_v = [d_v, dsea];
    pathstr = [pathstr, 'Sea,'];
end
if (dcold > 0)
    d_v = [d_v, dcold];
    pathstr = [pathstr, 'Cold,'];
end
if (dwarm > 0)
    d_v = [d_v, dwarm];
    pathstr = [pathstr, 'Warm,'];
end

dummy=regexp(pathstr,',','split');

path_c = dummy(1:end-1);

hb = [];
if (d(end)<15)
    hb = heff;
end


[E, L]  =  P1546FieldStrMixed(...
    f, ...
    t,...
    heff,...
    h2,...
    R2,...
    area2,...
    d_v,...
    path_c,...
    pathinfo,...
    'q', q,...
    'wa', wa,...
    'PTx', PTx,...
    'ha', h1,...
    'hb', hb,...
    'R1', R1,...
    'tca', tca,...
    'htter', h1ter,...
    'hrter', h2ter,...
    'eff1', teff1,...
    'eff2', tca,...
    'debug', debug, ...
    'fid_log', fid_log ...
    );

return
end

