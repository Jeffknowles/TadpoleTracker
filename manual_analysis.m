function [DATA OUTPUTFILENAME]=manual_analysis(param,vid)

%% Settings
FPS=param.FPS; %Select Framerate
TYPE=param.CAMTYPE;
nmov=4;


START=input('Enter the start time of the trial (in seconds):');
STOP=input('Enter the stop time of the trial (in seconds):');
JUMP=input('Enter the interval between measurments (in seconds):'); %Select amount of time between measurments

OUTPUTFILENAME=input('Enter the output file name for this trial:','s');

% Load DLT coeffs
load(['CalFiles/' param.fnames.coeffs])

% Find number of frames
nframes=min([vid(:).NumberOfFrames]);

% initialize figures
POS(1).pos=[.01 .55 .45 .45];
POS(2).pos=[.55 .55 .45 .45];
POS(3).pos=[.01 .01 .45 .45];
POS(4).pos=[.55 .01 .45 .45];

FIG(1)=figure('position',[100 500 1000 300]);
for kmov=1:nmov
    SP(kmov)=axes('units','normalized','position',POS(kmov).pos);
end

FIG(2)=figure('position',[100,100 1000 300]);



TRACKINGSTATE=0;
COUNT=0;

STARTFRAME=round(START*FPS); STARTFRAME=max(STARTFRAME,1);
STOPFRAME=round(STOP*FPS); STOPFRAME=min(STOPFRAME,nframes);
JUMPFRAME=round(JUMP*FPS);

for kframe=STARTFRAME:JUMPFRAME:STOPFRAME
    COUNT=COUNT+1;
    TIMES(COUNT,1)=round(kframe/FPS)-START;
    
    
    %% Get frame imaages for each camera
    switch lower(TYPE)
        case {'one'}
            FRAME=read(vid(1),kframe);
            for kmov=1:nmov
                MOV(kmov).frame=FRAME(param.mov(kmov).ylims(1):param.mov(kmov).ylims(2),param.mov(kmov).xlims(1):param.mov(kmov).xlims(2),:,:);
            end
            
        case {'many'}
            for kmov=1:nmov
                FRAME=read(vid(kmov),kframe);
                MOV(kmov).frame=FRAME(param.mov(kmov).ylims(1):param.mov(kmov).ylims(2),param.mov(kmov).xlims(1):param.mov(kmov).xlims(2),:,:);
            end
    end
    
    %% Display images and get user's position
    figure(FIG(1))
    
    
    for kmov=1:nmov
        axes(SP(kmov))
        
        imshow(MOV(kmov).frame)
        
    end
    for kmov=1:nmov
        axes(SP(kmov))
        p(kmov,1)=impoint(gca);
        campos(kmov).pixels=getPosition(p(kmov));
    end
    
    %% Calculate position
    
    % Cam Selection - Select which camera set to use based on ROI areas
    camset(1).set=[1 4];
    camset(2).set=[2 3];
    exset(1).set=[1 2];
    exset(2).set=[4 3];
    
    % Decide set and recontruct
    for kset=1:length(camset)
        camset(kset).residual=1e3;
        
        camset(kset).pos=dlt_reconstruct([cset(camset(kset).set(1)).c cset(camset(kset).set(2)).c],[campos(camset(kset).set(1)).pixels campos(camset(kset).set(2)).pixels]);
        
        camset(kset).residual=0;
        for kcam=camset(kset).set
            campos(kcam).rstruc=dlt_inverse(cset(kcam).c,camset(kset).pos);
            camset(kset).residual=camset(kset).residual+norm(campos(kcam).pixels-campos(kcam).rstruc);
        end
        camset(kset).residual=camset(kset).residual/length(camset(kset).set);
        
    end
    
    
    [tmp SETIDX]=min([camset(:).residual]) %find camera set with minimum localization error
    
    % if residual is lower than threshold then use position and set
    % tracking state accordingly.
    if tmp<25
        xyz(COUNT,:)=round(camset(SETIDX).pos);
        xyz(COUNT,:)=max(xyz(COUNT,:),[1 1 1]);
        TRACKINGSTATE=1;
        
    else
        xyz(COUNT,:)=[NaN NaN NaN];
        TRACKINGSTATE=0;
        
    end
    
    %% Calculate Orientation
    
    if isequal(TRACKINGSTATE,1)
        figure(FIG(2))
        imshow(MOV(camset(SETIDX).set(1)).frame);
        op(1)=impoint(gca);
        op(2)=impoint(gca);
        
        BACK=getPosition(op(1));
        FRONT=getPosition(op(2));
        OVECTOR=FRONT-BACK;
        clf
        
        [OANGLE R]=cart2pol(OVECTOR(1),OVECTOR(2));
        OANGLE=radtodeg(OANGLE);
        if OANGLE<0
            OANGLE=360+OANGLE;
        end
        
        ORIENTATION(COUNT,1)=round(OANGLE);
        
        
    else
        ORIENTATION(COUNT,1)=NaN;
    end
    
    
    
    
    clc
    disp(['TIME:  ' num2str(TIMES(COUNT))]);
    disp(['Position:   ' num2str(xyz(COUNT,:))]);
    disp(['ANGLE:   '    num2str(ORIENTATION(COUNT))])
    
    
    
end

DATA.xyz=xyz;
DATA.times=TIMES;
DATA.orientation=ORIENTATION;
DATA.MAT=[TIMES xyz ORIENTATION];


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subfinctions %%%


%% dlt_reconstruct %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xyz,rmse] = dlt_reconstruct(c,camPts)

% function [xyz,rmse] = dlt_reconstruct(c,camPts)
%
% This function reconstructs the 3D position of a coordinate based on a set
% of DLT coefficients and [u,v] pixel coordinates from 2 or more cameras
%
% Inputs:
%  c - 11 DLT coefficients for all n cameras, [11,n] array
%  camPts - [u,v] pixel coordinates from all n cameras over f frames,
%   [f,2*n] array
%
% Outputs:
%  xyz - the xyz location in each frame, an [f,3] array
%  rmse - the root mean square error for each xyz point, and [f,1] array,
%   units are [u,v] i.e. camera coordinates or pixels
%
% Ty Hedrick

% number of frames
nFrames=size(camPts,1);

% number of cameras
nCams=size(camPts,2)/2;

% setup output variables
xyz(1:nFrames,1:3)=NaN;
rmse(1:nFrames,1)=NaN;

% process each frame
for i=1:nFrames
    
    % get a list of cameras with non-NaN [u,v]
    cdx=find(isnan(camPts(i,1:2:nCams*2))==false);
    
    % if we have 2+ cameras, begin reconstructing
    if numel(cdx)>=2
        
        % initialize least-square solution matrices
        m1=[];
        m2=[];
        
        m1(1:2:numel(cdx)*2,1)=camPts(i,cdx*2-1).*c(9,cdx)-c(1,cdx);
        m1(1:2:numel(cdx)*2,2)=camPts(i,cdx*2-1).*c(10,cdx)-c(2,cdx);
        m1(1:2:numel(cdx)*2,3)=camPts(i,cdx*2-1).*c(11,cdx)-c(3,cdx);
        m1(2:2:numel(cdx)*2,1)=camPts(i,cdx*2).*c(9,cdx)-c(5,cdx);
        m1(2:2:numel(cdx)*2,2)=camPts(i,cdx*2).*c(10,cdx)-c(6,cdx);
        m1(2:2:numel(cdx)*2,3)=camPts(i,cdx*2).*c(11,cdx)-c(7,cdx);
        
        m2(1:2:numel(cdx)*2,1)=c(4,cdx)-camPts(i,cdx*2-1);
        m2(2:2:numel(cdx)*2,1)=c(8,cdx)-camPts(i,cdx*2);
        
        % get the least squares solution to the reconstruction
        xyz(i,1:3)=linsolve(m1,m2);
        
        % compute ideal [u,v] for each camera
        uv=m1*xyz(i,1:3)';
        
        % compute the number of degrees of freedom in the reconstruction
        dof=numel(m2)-3;
        
        % estimate the root mean square reconstruction error
        rmse(i,1)=(sum((m2-uv).^2)/dof)^0.5;
    end
end


%% dlt_inverse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [uv] = dlt_inverse(c,xyz)

% function [uv] = dlt_inverse(c,xyz)
%
% This function reconstructs the pixel coordinates of a 3D coordinate as
% seen by the camera specificed by DLT coefficients c
%
% Inputs:
%  c - 11 DLT coefficients for the camera, [11,1] array
%  xyz - [x,y,z] coordinates over f frames,[f,3] array
%
% Outputs:
%  uv - pixel coordinates in each frame, [f,2] array
%
% Ty Hedrick

% write the matrix solution out longhand for Matlab vector operation over
% all points at once
uv(:,1)=(xyz(:,1).*c(1)+xyz(:,2).*c(2)+xyz(:,3).*c(3)+c(4))./ ...
    (xyz(:,1).*c(9)+xyz(:,2).*c(10)+xyz(:,3).*c(11)+1);
uv(:,2)=(xyz(:,1).*c(5)+xyz(:,2).*c(6)+xyz(:,3).*c(7)+c(8))./ ...
    (xyz(:,1).*c(9)+xyz(:,2).*c(10)+xyz(:,3).*c(11)+1);




