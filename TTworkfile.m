%% Tacker Workfile
clear all; close all; clc;

%% Settings

% Choose file
direc='/DATA/TadpoleData/ERIKADATA/'; % set directory containing the video
VFNAME='GR-1_converted.mp4';                % set the video name
DFNAME='GR-1pre';             % set the data file name


CALIBRATION='cal14';                  % set the calibration for the video

% Set Frame Limits
STARTTIME=30; %25;
STOPTIME=320;

% load the video
vid(1)=VideoReader([direc VFNAME]);      %
        
% 
STARTFRAME=round(STARTTIME*vid(1).FrameRate);
STOPFRAME=round(STOPTIME*vid(1).FrameRate);
STOPFRAME=min(min([vid(:).NumberOfFrames])-40,STOPFRAME);

%% Make Calibration and query params
param=paramgen(CALIBRATION);
[cset rmse]=calscript(param);

%% Create Blank
INITIAL=create_blank(param,vid);
param.INITIAL=INITIAL;

%% Run tracker
DATA.xyz=TPtracker(param,vid,STARTFRAME,STOPFRAME);
DATA.times=(1:STOPFRAME)/param.FPS;

save(['datafiles/' DFNAME],'DATA','param','vid')

tadpole_plot(DATA)
