function param=paramgen(SEL)


%% General Params
param.lev=4.5;        %Threshold for each Difference level. Increasing lev decreases type 3 errors, increases type 1 errors
param.npres=1;        %Required number of dframes containing a pixel for it to be active. Increasing decreases type 3 errors
param.roithresh=1;     %Threshold area for ROI's
param.jumpthresh=20;  %Threshold Pixel Jump for Type 3 Error

%bluring settings
param.BLURTEST=1; %switch for bluring
param.BLURWINDOW=3; %(pixels)
param.BLURSIGMA=3;  %(pixels)

% query usersettings
param.QUERYUSERTEST=1;

param.LOSTTHRESH=30; % (frames) Number of frames to stay in one put after loosing object

param.JUMPTHRESH1=15; % (pixels)  radius of search window when tracking state is 1
param.JUMPTHRESH2=30; % (pixels)  radius of search window when tracking state is -1



%% Select Calibration  % {cal1,calold}
%SEL='cal2009';


%%
switch lower(SEL)
    case {'cal0'}
        %% File Names
        param.fnames.uvpts='cal1uvpts.mat';
        param.fnames.coeffs='cal0coeffs.mat';
        param.fnames.frame='frame0.mat'; %'frame1.mat';
        %% Mov 1 Params
        param.mov(1).xlims=[1 260];
        param.mov(1).ylims=[70 175];
        
        %% Mov 2 Params
        param.mov(2).xlims=[25 236];
        param.mov(2).ylims=[72 170];
        
        %% Mov 3 Params
        param.mov(3).xlims=[60 320];
        param.mov(3).ylims=[60 162];
        
        %% Mov 4 Params
        param.mov(4).xlims=[10 232];
        param.mov(4).ylims=[60 160];
        
        %% All Mov Params
        param.FPS=3;
        param.CAMTYPE='many';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {'cal1'}
        %% File Names
        param.fnames.uvpts='cal1uvpts.mat';
        param.fnames.coeffs='cal1coeffs.mat';
        param.fnames.frame='frame1.mat';
        %% Mov 1 Params
        param.mov(1).xlims=[18 260];
        param.mov(1).ylims=[70 184];
        
        %% Mov 2 Params
        param.mov(2).xlims=[10 236];
        param.mov(2).ylims=[72 178];
        
        %% Mov 3 Params
        param.mov(3).xlims=[60 320];
        param.mov(3).ylims=[54 162];
        
        %% Mov 4 Params
        param.mov(4).xlims=[10 232];
        param.mov(4).ylims=[60 160];
        
        %% All Mov Params
        param.FPS=3;
        param.CAMTYPE='many';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case{'cal2'}
        %% File Names
        param.fnames.uvpts='cal2uvpts.mat';
        param.fnames.coeffs='cal2coeffs.mat';
        param.fnames.frame='frame2.mat';
        %% Mov 1 Params
        param.mov(1).xlims=[6 260];
        param.mov(1).ylims=[70 175];
        
        %% Mov 2 Params
        param.mov(2).xlims=[22 250];
        param.mov(2).ylims=[72 170];
        
        %% Mov 3 Params
        param.mov(3).xlims=[105 320];
        param.mov(3).ylims=[110 195];
        
        %% Mov 4 Params
        param.mov(4).xlims=[10 300];
        param.mov(4).ylims=[120 200];
        
        %% All Mov Params
        param.FPS=3;
        param.CAMTYPE='many';
        
        
    case {'calold'}
        %% File Names
        param.fnames.uvpts='calolduvpts.mat';
        param.fnames.coeffs='caloldcoeffs.mat';
        param.fnames.frame='frameold.mat';
        
        %% Mov 1 Params
        param.mov(1).xlims=[40 145];
        param.mov(1).ylims=[20 74];
        
        %% Mov 2 Params
        param.mov(2).xlims=[188 295];
        param.mov(2).ylims=[12 70];
        
        %% Mov 3 Params
        param.mov(3).xlims=[43 134];
        param.mov(3).ylims=[130 180];
        
        %% Mov 4 Params
        param.mov(4).xlims=[165 290];
        param.mov(4).ylims=[136 190];
        
        %% All mov Params
        param.FPS=30;
        param.CAMTYPE='one';
        
    case {'cal2009'}
        %% File Names
        param.fnames.uvpts='cal2009uvpts.mat';
        param.fnames.coeffs='cal2009coeffs.mat';
        param.fnames.frame='frame2009.mat';
        
        
        %% Mov 1 Params
        param.mov(1).xlims=[35 290];
        param.mov(1).ylims=[92 196];
        
        %% Mov 2 Params
        param.mov(2).xlims=[410 650];
        param.mov(2).ylims=[80 195];
        
        %% Mov 3 Params
        param.mov(3).xlims=[80 360];
        param.mov(3).ylims=[275 380];
        
        %% Mov 4 Params
        param.mov(4).xlims=[360 610];
        param.mov(4).ylims=[290 385];
        
        
        param.FPS=30;       %Frames per second of the video
        param.CAMTYPE='one';
        
        
    case {'cal3'}
        %% File Names
        param.fnames.uvpts='cal3uvpts.mat';
        param.fnames.coeffs='cal3coeffs.mat';
        
        
        
        %% Mov 1 Params
        param.mov(1).xlims=[1 313];
        param.mov(1).ylims=[70 220];
        
        %% Mov 2 Params
        param.mov(2).xlims=[440 723];
        param.mov(2).ylims=[70 220];
        
        %% Mov 3 Params
        param.mov(3).xlims=[110 383];
        param.mov(3).ylims=[400 540];
        
        %% Mov 4 Params
        param.mov(4).xlims=[485 800];
        param.mov(4).ylims=[400 540];
        
        
        param.FPS=30;       %Frames per second of the video
        param.CAMTYPE='one';
        
    case {'cal5'}
        %% File Names
        param.fnames.uvpts='cal5uvpts.mat';
        param.fnames.coeffs='cal5coeffs.mat';
        
        
        
        %% Mov 1 Params
        param.mov(1).xlims=[30 365];
        param.mov(1).ylims=[82 193];
        
        %% Mov 2 Params
        param.mov(2).xlims=[360 625];
        param.mov(2).ylims=[70 184];
        
        %% Mov 3 Params
        param.mov(3).xlims=[62 364];
        param.mov(3).ylims=[352 453];
        
        %% Mov 4 Params
        param.mov(4).xlims=[360 682];
        param.mov(4).ylims=[350 448];
        
        
        param.FPS=30;       %Frames per second of the video
        param.CAMTYPE='one';
        
    case {'cal6'}
        %% File Names
        param.fnames.uvpts='cal6uvpts.mat';
        param.fnames.coeffs='cal6coeffs.mat';
        
        
        
        %% Mov 1 Params
        param.mov(1).xlims=[22 360];
        param.mov(1).ylims=[55 230];
        
        %% Mov 2 Params
        param.mov(2).xlims=[360 690];
        param.mov(2).ylims=[44 200];
        
        %% Mov 3 Params
        param.mov(3).xlims=[60 320];
        param.mov(3).ylims=[340 450];
        
        %% Mov 4 Params
        param.mov(4).xlims=[445 684];
        param.mov(4).ylims=[345 450];
        
        
        param.FPS=30;       %Frames per second of the video
        param.CAMTYPE='one';
        
    otherwise
        %% File Names
        param.fnames.uvpts=[SEL 'uvpts.mat'];
        param.fnames.coeffs=[SEL 'coeffs.mat'];
        
        
        
        %% Mov 1 Params
        param.mov(1).xlims=[1 360];
        param.mov(1).ylims=[1 250];
        
        %% Mov 2 Params
        param.mov(2).xlims=[360 712];
        param.mov(2).ylims=[1 250];
        
        %% Mov 3 Params
        param.mov(3).xlims=[1 360];
        param.mov(3).ylims=[250 480];
        
        %% Mov 4 Params
        param.mov(4).xlims=[360 712];
        param.mov(4).ylims=[250 480];
        
        
        param.FPS=30;       %Frames per second of the video
        param.CAMTYPE='one';
end



