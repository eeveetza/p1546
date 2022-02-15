% MATLAB script that is used to validate the implementation of 
% Recommendation ITU-R P.1546-5 as defined in the file P1546FieldStrMixed.m. 
% using a set of test terrain profiles provided by the user.
%
% The script reads all the test profiles from the folder defined by 
% the variable <test_profiles>, calculates path profile parameters, 
% computes the field strength for the input parameters defined in those files, 
% and (in case flag_debug is set to 1) logs all the intermediate results 
% in *.csv files (placed in the folder defined by the variable: test_results). 
% Additionally, the script plots terrain profiles in case flag_plot is set to 1. 
%
% Author: Ivica Stevanovic (IS), Federal Office of Communications, Switzerland
% Revision History:
% Date            Revision
% 13May2016       Introduced pathinfo flag (IS)
% 29May2015       Modified backward to forward stroke so the code runs on
%                 Linux as suggested by M. Rohner (IS) 
% 29Apr2015       Introduced 'default' as an option in ClutterCode (IS)
% 26Nov2014       Initial version (IS)

%% Input variables

clear all;
close all;
fclose all; 

% add path to the folder where the functions are defined
addpath('./src')

% path to the folder containing test profiles 
test_profiles = './test_profiles/';
 
% path to the folder where the resulting log files will be saved
test_results = './test_results/';

% format of the test profile (measurement) files
fileformat='Fryderyk_csv';

% Clutter code type 

ClutterCode = 'DNR1812';

%     ClutterCode='default'; % default clutter code assumes land, rural area with R1 = R2 = 10;
%     ClutterCode='TBD'
%     ClutterCode='OFCOM';
%     ClutterCode='NLCD';
%     ClutterCode='LULC';
%     ClutterCode='GlobCover';
%     ClutterCode='DNR1812';

% set to 1 if the csv log files need to be produced
flag_debug = 1;

% set to 1 if the plots of the height profile are to be shown
flag_plot = 0;

% pathprofile is available (=1), not available (=0)
flag_path = 1;

%% begin code
% Collect all the filenames .csv in the folder pathname that contain the profile data
filenames = dir(fullfile(test_profiles, '*.csv')); % filenames(i).name is the filename

% create the output directory
[s,mess,messid] = mkdir(test_results);

if (flag_debug==1)
    fid_all = fopen([test_results 'combined_results.csv'], 'w');
    if (fid_all == -1)
        error('The file combined_results.csv could not be opened');
    end
    fprintf(fid_all,'%% %s;%s;%s;%s;%s;%s;\n','Folder','Filename','Dataset #','Reference','Predicted','Deviation: Predicted-Reference');
end

if (length(filenames) < 1)
    error(['There are no .csv files in the test profile folder ' test_profiles]);
end

for iname = 1 : length(filenames)
    
    filename1 = filenames(iname).name;
    fprintf(1,'***********************************************\n');
    fprintf(1,'Processing file %s%s ...\n', test_profiles, filename1);
    fprintf(1,'***********************************************\n');
    
    % read the file and populate sg3db input data structure
    
    sg3db=read_sg3_measurements2([test_profiles filename1],fileformat);
    
    % make sure that the transmitter is the first point
    
    sg3db.first_point_transmitter = 1;
    
    sg3db.debug = flag_debug;
    
    % pathprofile is available (=1), not available (=0)
    sg3db.pathinfo = flag_path;
    
    % update the data structure with the Tx Power (kW)
    for kindex=1:sg3db.Ndata;
        PERP= sg3db.ERPMaxTotal(kindex);
        HRED= sg3db.HRPred(kindex);
        PkW=10^(PERP/10)*1e-3; %kW
        
        if(isnan(PkW))
            % use complementary information from Basic Transmission Loss and
            % received measured strength to compute the transmitter power +
            % gain
            E=sg3db.MeasuredFieldStrength(kindex);
            PL=sg3db.BasicTransmissionLoss(kindex);
            f=sg3db.frequency(kindex);
            PdBkW=-137.2217+E-20*log10(f)+PL;
            PkW=10^(PdBkW/10);
        end
        
        sg3db.TransmittedPower(kindex)=PkW;
    end
    
    % discriminate land and sea portions
    dland=0;
    dsea=0;
    if(~isempty(sg3db.radio_met_code) && ~isempty(sg3db.coveragecode))
        for i=1:length(sg3db.x)
            if (i==length(sg3db.x))
                dinc=(sg3db.x(end)-sg3db.x(end-1))/2;
            elseif (i==1)
                dinc=(sg3db.x(2)-sg3db.x(1))/2;
            else
                dinc=(sg3db.x(i+1)- sg3db.x(i-1))/2;
            end
            
            if ( sg3db.radio_met_code(i)==1 ||  sg3db.coveragecode(i)==1) %sea
                dsea=dsea+dinc;
            else
                dland=dland+dinc;
            end
        end
    elseif(isempty( sg3db.radio_met_code) && ~isempty( sg3db.coveragecode))
        for i=1:length( sg3db.x)
            if (i==length( sg3db.x))
                dinc=( sg3db.x(end)- sg3db.x(end-1))/2;
            elseif (i==1)
                dinc=( sg3db.x(2)- sg3db.x(1))/2;
            else
                dinc=( sg3db.x(i+1)- sg3db.x(i-1))/2;
            end
            
            if ( sg3db.coveragecode(i)==2) %sea - when radio-met code is missing, it is supposed that the file is organized
                %as in DNR p.1812...
                dsea=dsea+dinc;
            else
                dland=dland+dinc;
            end
        end
        
    else
        dland=NaN;
        dsea = NaN;
    end
    
    xx= sg3db.x(end)- sg3db.x(1);
    
    sg3db.LandPath=dland;
    sg3db.SeaPath=dsea;
    
    sg3db.ClutterCode=[];
    
    % plot the height profile
    
    x=sg3db.x;
    h_gamsl=sg3db.h_gamsl;
    
    
    
    %% plot the profile
    if (flag_plot)
        figure;
        ax=axes;
        h_plot=plot(ax,x,h_gamsl,'LineWidth',2,'Color','k');
        set(ax,'XLim',[min(x) max(x)]);
        hTx=sg3db.hTx;
        hRx=sg3db.hRx;
        %area(ax,x,h_gamsl)
        set(0,'DefaulttextInterpreter','none');
        title(ax,['Tx: ' sg3db.TxSiteName ', Rx: ' sg3db.RxSiteName ', ' sg3db.TxCountry sg3db.MeasurementFileName]);
        set(ax,'XGrid','on','YGrid','on');
        xlabel(ax,'distance [km]');
        ylabel(ax,'height [m]');
    end
    
    %% plot the position of transmitter/receiver
    
    x=sg3db.x;
    h_gamsl=sg3db.h_gamsl;
    
    hTx=sg3db.hTx;
    hRx=sg3db.hRx;
    
    if(flag_plot)
        ax=gca;
        
        hold(ax, 'on');
        
    end
    for userChoiceInt = 1:length(hRx)
        if(~isempty(userChoiceInt))
            if (userChoiceInt > length(hRx) || userChoiceInt <1)
                error('The chosen dataset does not exist.')
            end
            fprintf(1,'Computing the fields for Dataset #%d\n', userChoiceInt);
            sg3db.userChoiceInt = userChoiceInt;
            hhRx=hRx(userChoiceInt);
            % this will be a separate function
            % Transmitter
            if(flag_plot)
                if (sg3db.first_point_transmitter)
                    plot(ax,[ x(1) x(1)], [h_gamsl(1),h_gamsl(1)+hTx(1)],'LineWidth',2,'Color','b');
                    plot(ax, x(1), h_gamsl(1)+hTx(1), 'Marker','v','Color','b');
                    plot(ax,[ x(end) x(end)], [h_gamsl(end),h_gamsl(end)+hhRx],'LineWidth',2,'Color','r');
                    plot(ax, x(end), h_gamsl(end)+hhRx, 'Marker','v','Color','r');
                else
                    plot(ax,[ x(end) x(end)], [h_gamsl(end),h_gamsl(end)+hTx(1)],'LineWidth',2,'Color','b');
                    plot(ax, x(end), h_gamsl(1)+hTx(1), 'Marker','v','Color','b');
                    plot(ax,[ x(1) x(1)], [h_gamsl(1),h_gamsl(1)+hhRx],'LineWidth',2,'Color','r');
                    plot(ax, x(1), h_gamsl(1)+hhRx, 'Marker','v','Color','r');
                end
            end
        end
        if(~isempty(userChoiceInt))
            
            % compute the terrain clearance angle
            tca = tcaCalc(x,h_gamsl,hRx(userChoiceInt),hTx(userChoiceInt));
            sg3db.tca = tca;
            if(flag_plot)
                plotTca(ax,x,h_gamsl,hRx(userChoiceInt),tca);
                
            end
            
            % compute the terrain clearance angle at transmitter side
            teff1 = teff1Calc(x,h_gamsl,hTx(userChoiceInt),hRx(userChoiceInt));
            sg3db.eff1 = teff1;
            if(flag_plot)
                plotTeff1(ax,x,h_gamsl,hTx(userChoiceInt),teff1);
                
            end
            %if(get(handles.heffCheck,'Value'))
            heff=heffCalc(x,h_gamsl,hTx(1));
            
            sg3db.heff=heff;
            % plot the average height above the ground
            if (flag_plot)
                x1=x(1);
                x2=x(end);
                if x2>15
                    x2=15;
                end
                yy=get(ax,'YLim');
                dy=yy(2)-yy(1);
                y1=hTx(1)+h_gamsl(1)-heff;
                y2=y1;
                
                plot(ax,[x1 x2], [y1 y2],'r');
                if x(end)<15
                    
                    text((x1+x2)/2,y1+0.05*dy,['hav(0.2d,d) = ' num2str(y1)],'Parent',ax);
                else
                    
                    text(x2,y1+0.05*dy,['hav(3,15) = ' num2str(y1)],'Parent',ax);
                end
                
            end
            
        end
        
        if(~isempty(sg3db.coveragecode))
            
            
            % fill in the  missing fields in Rx clutter
            i=sg3db.coveragecode(end);
            [RxClutterCode RxP1546Clutter R2external] = clutter(i, ClutterCode);
            i=sg3db.coveragecode(1);
            [TxClutterCode TxP1546Clutter R1external] = clutter(i, ClutterCode);
            
            % Once the clutter has been chosen, the second terminal becomes a
            % transmitter in the following cases according to �5 1.11
            % a) both 1 and 2 are below clutter (h1<R1, h2<R2) and h2>h1
            % b) 2 is above clutter and 1 is below clutter (h1<R1, h2>R2)
            % c) both 1 and 2 are above clutter (h1>R1 h2>R2) and h2eff > h1eff
            
            sg3db.RxClutterCodeP1546 = RxP1546Clutter;
            
            if(~isempty(sg3db.h_ground_cover))
                if(~isnan(sg3db.h_ground_cover(end)))
                    if (sg3db.h_ground_cover(end) > 3)
                        sg3db.RxClutterHeight = sg3db.h_ground_cover(end);
                    else
                        sg3db.RxClutterHeight = R2external;
                    end
                else
                    sg3db.RxClutterHeight = R2external;
                end
                
                if(~isnan(sg3db.h_ground_cover(1)))
                    sg3db.TxClutterHeight = sg3db.h_ground_cover(1);
                    if (sg3db.h_ground_cover(1) > 3)
                        sg3db.TxClutterHeight = sg3db.h_ground_cover(1);
                    else
                        sg3db.TxClutterHeight = R1external;
                    end
                else
                    sg3db.TxClutterHeight = R1external;
                end
                
                
            else
                sg3db.RxClutterHeight = R2external;
                sg3db.TxClutterHeight = R1external;
            end
        end
        
        % Execute P.1546
        fid_log = -1;
        if (flag_debug)

            filename2 = [test_results filename1(1:end-4)  num2str(userChoiceInt) '_log.csv'];
            fid_log = fopen(filename2, 'w');
            if (fid_log == -1)
                error_str = [filename2 ' cannot be opened.'];
                error(error_str);
            end
        end
        
        sg3db.fid_log = fid_log;
        
        sg3db = P1546Compute(sg3db);
        
        if (flag_debug)
            fclose(fid_log);
  
            % print the deviation of the predicted from the measured value,
            % double check this line
            % Measurement folder | Measurement File | Dataset | Measured Field Strength | Predicted Field Strength | Deviation from Measurement
            fprintf(fid_all,'%s;%s;%d;%.2f;%.2f;%.2f\n',sg3db.MeasurementFolder,sg3db.MeasurementFileName,userChoiceInt, sg3db.MeasuredFieldStrength(userChoiceInt), sg3db.PredictedFieldStrength, sg3db.PredictedFieldStrength - sg3db.MeasuredFieldStrength(userChoiceInt));
        end
    end
end % for all files in ./tests

if (flag_debug)
    fclose(fid_all);
end

fprintf(1,'***********************************************\n');
fprintf(1,'Results are written in folder: %s \n', test_results);
fprintf(1,'***********************************************\n');
