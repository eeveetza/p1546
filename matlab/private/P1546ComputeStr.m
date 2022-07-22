function sg3db = P1546ComputeStr(sg3db)
% this function computes the field strength and path loss for the data
% structure defined in sg3db, according to ITU-R P.1546-5
%
% Author: Ivica Stevanovic, Federal Office of Communications, Switzerland
% Revision History:
% Date            Revision
% 30OCT2019       Aligned with P.1546-6
% 28AUG2018       Introduced P1546d5 using struct as output
% 13MAY2016       Introduced pathinfo
% 05APR2016       Corrected bugs (data.htter, data.hrter)
% 24NOV2014       Modified to fit non-GUI implementation
% 22JUL2013       Initial version (IS)
%% Collect all the input data

userChoiceInt = sg3db.userChoiceInt;

if(isempty(userChoiceInt))
    error ('Dataset not defined.');
    return
end

data.PTx =  sg3db.TransmittedPower(userChoiceInt);

data.f =  sg3db.frequency(userChoiceInt);

data.t =  sg3db.TimePercent(userChoiceInt);

data.q = 50;

% data.heff = str2double(get( heff,'String'));
data.heff =  sg3db.heff;

data.area = sg3db.RxClutterCodeP1546;
if ~(strcmpi( data.area,'Sea') || ...
        strcmpi( data.area,'Rural') || ...
        strcmpi( data.area,'Suburban') || ...
        strcmpi( data.area,'Urban') || ...
        strcmpi( data.area,'Dense Urban'))
    warndlg({'Allowed P.1546 Rx Clutter Types: Sea, Rural, Suburban, Urban, or Dense Urban'});
end
tt= data.area;

data.pathinfo = sg3db.pathinfo;
data.wa = sg3db.wa;

kindex=1;

if ( sg3db.LandPath > 0)
    
    data.d_v(kindex)= sg3db.LandPath;
    data.path_c{kindex}='Land';
    kindex=kindex+1;
end

if ( sg3db.SeaPath > 0)
    data.d_v(kindex)= sg3db.SeaPath;
    data.path_c{kindex}='Sea';
end

data.NN=kindex;

data.h2= sg3db.h2;

data.ha= sg3db.ha;


data.htter=[];
data.hrter=[];
data.eff1=[];
data.eff2=[];

% Correction 5.4.16, IS (there were several typos here, including <= sign
% in the if clause and x(1) and x(end) instead of h_gamsl(1), h_gamsl(end)
if (sum( data.d_v)<1)
    
    data.htter= sg3db.htter;
    data.hrter= sg3db.hrter;
end

data.hb=[]; %% correction to follow section 3.1.2
if (sum( data.d_v)<15)
    data.hb= sg3db.heff;
end
data.R1=sg3db.TxClutterHeight;
data.R2=sg3db.RxClutterHeight;

%  data.tca=str2double(get( tca,'String'));
% data.eff1=str2double(get( teff1,'String'));
data.eff1= sg3db.eff1;
data.eff2= sg3db.tca;
data.tca = sg3db.tca;

data.debug = sg3db.debug;
data.fid_log = sg3db.fid_log;
data.tcaflag = sg3db.tcaflag;


% check input variables

if (checkInput(data))
    %data
    p1546  =  P1546d5(...
        data.f, ...
        data.t,...
        data.heff,...
        data.h2,...
        data.R2,...
        data.area,...
        data.d_v,...
        data.path_c,...
        data.pathinfo,...
        data.q,...
        data.wa,...
        data.PTx,...
        data.ha,...
        data.hb,...
        data.R1,...
        data.tca,...
        data.htter,...
        data.hrter,...
        data.eff1,...
        data.eff2,...
        data.debug, ...
        data.fid_log, ...
        data.tcaflag ...
        );
    
    
end
%% report the field strenght in the P1546dBuV text field
sg3db.PredictedFieldStrength = p1546.E;
sg3db.PredictedPathLoss = p1546.L;
sg3db.p1546 = p1546;