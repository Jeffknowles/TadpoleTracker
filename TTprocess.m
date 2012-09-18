function TTprocess
% TTprocess is a script that allows a basic processing run in order to
% track tadpoles using TT tracker.  The user is asked to select the 4
% camera frames to track, enter the start and end frames, and enter an
% identification number for the data.  The data is the saved as its own mat
% file in datafiles.  


%% Settings
calname='cal1coeffs.mat';  %the name of the calibration object
direc=gettadpoledirec;
FPS=3;
ncam=4;
%% get paramteres
param=paramgen;


%% select videos
for kcam=1:ncam
    disp(['select camera ' num2str(kcam)])
    [fname fdirec]=uigetfile('*.avi',['select camera ' num2str(kcam)],'/Volumes/OneTouch4 Plus/Forced Flow/FFSASF/Video Clips');
    vid(kcam)=mmreader([fdirec fname]);
end


%% select frames
clc
startframe=input('Enter Startframe:   ');
stopframe=input('Enter Stopframe:   ');
clc

%% enter data filename
dfile=input('enter datafilename:   ','s');

%% run script
xyz=TPtracker(param,vid,startframe,stopframe);

%% Save data
save(['datafiles/' dfile '.mat'],'xyz','FPS')




