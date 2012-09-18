%% Manual Workfile
close all; clear all; clc
%% Set Calibration
CALIBRATION='cal6';

%% Select Computer
COMPUTER='erika';


%% Get Parameters and Calculate DLT Coeffs
param=paramgen(CALIBRATION);
calscript(param);

%% Generate File Names
switch lower(COMPUTER)
    case {'erika'}%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Enter DATAFILE NAME HERE
        [FNAME DIREC]=uigetfile('/Volumes/FreeAgent GoFlex Drive/,.mp4');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        vid=mmreader([DIREC FNAME]);
        DATADIREC='datafiles/';     
end


%% Run manual analysis program
[DATA DFNAME]=manual_analysis(param,vid);
close all;


%% Save DATA as a CSV File
csvwrite([DATADIREC DFNAME '.csv'],DATA.MAT)