function xyz=TPtracker(param,vid,startframe,stopframe)
% Tadpole Tracker V1 - Jeff Knowles, Simmons Lab 2010
% A Automated Tracking System for multiple DLT calibrated cameras have
% partially overlapping fields of view.  Orriginally created for tracking
% tadpoles in a flow tank for AM Simmons and K Lee.  
%
% Inputs: Params containing camera field of view and Z score level ratings
% for the cameras.  
%
% Vid: A structure containing the video objects created by the mmreader
% function in MATLAB
%% Settings
PLOTTEST=0; %% Plot Tracking Results while processing (should be 0 generally)
stashsize=30; % Set number of frames to load per file query

ncam=4;
CAMTYPE=param.CAMTYPE; %'one'; %either 'one' or 'many' depending on how may streems of video
BLURTEST=param.BLURTEST; %0;
QUERYUSERTEST=param.QUERYUSERTEST;% 1;
LOSTTHRESH=param.LOSTTHRESH;% 30;
JUMPTHRESH1=param.JUMPTHRESH1; %15;
JUMPTHRESH2=param.JUMPTHRESH2; %30;


%% Select Frames to track
startframe=max(startframe,4);
stopframe=min(stopframe,vid(1).NumberOfFrames-4); % Check framebounds

nframes=stopframe-startframe;

%% Preallocate settings
load(['CalFiles/' param.fnames.coeffs])

if isfield(param,'INITIAL')  %if INITIAL is fed as part of PARAM then use it
    INITIAL=param.INITIAL;
else
    load(['CalFiles/' param.fnames.frame]) %otherwise load INITIAL from fiel
end

if BLURTEST==1          % if blur test is on then load PSF
    PSF=fspecial('gaussian',param.BLURWINDOW,param.BLURSIGMA);
end


if PLOTTEST==1  % If plot is on, load figures
    close all
    fig(1)=figure;
    fig(2)=figure;
    tankplot
end



switch lower(CAMTYPE)  %decide which type of video to use
    case {'many'}
    
           for kmov=1:ncam  % Iterate thru cameras to preallocate 

            campos(kmov).pixels=zeros(nframes,2); %preallocate frame pixel locations
            campos(kmov).ratings=zeros(nframes,1);
    
            %%Grab first set of frames for differencing
            MOV(kmov).i=INITIAL(kmov).i;
            MOV(kmov).i=sum(MOV(kmov).i,3)/(3*255);
            
            if BLURTEST==1
                MOV(kmov).i=imfilter(MOV(kmov).i,PSF,'symmetric','conv');
            end
            
            MOV(kmov).i=MOV(kmov).i(param.mov(kmov).ylims(1):param.mov(kmov).ylims(2),param.mov(kmov).xlims(1):param.mov(kmov).xlims(2),:,:);
            MOV(kmov).frames=read(vid(kmov),[startframe-2 startframe+2]);
            MOV(kmov).frames=MOV(kmov).frames(param.mov(kmov).ylims(1):param.mov(kmov).ylims(2),param.mov(kmov).xlims(1):param.mov(kmov).xlims(2),:,:);
            MOV(kmov).frames=squeeze(sum(MOV(kmov).frames,3)/(3*255));
    
            
            MOV(kmov).stash=read(vid(kmov),[(startframe+3) (startframe+3+stashsize)]);
            MOV(kmov).stash=squeeze(sum(MOV(kmov).i,3)/(3*255));
            
           end
           stashcount(1:ncam)=0; 
           
    case {'one'}
        STASH=read(vid(1),[(startframe+3) (startframe+3+stashsize)]);
        STASH=squeeze(sum(STASH,3)/(3*255));
        FRAMES=read(vid(1),[startframe-2 startframe+2]);
        FRAMES=squeeze(sum(FRAMES,3)/(3*255));
        
        INITIAL.i=sum(INITIAL.i,3)/(3*255);
        
        if BLURTEST==1
            INITIAL.i=imfilter(INITIAL.i,PSF,'symmetric','conv');
        end
        
        for kmov=1:ncam
            campos(kmov).pixels=zeros(nframes,2); %preallocate frame pixel locations
            campos(kmov).ratings=zeros(nframes,1);
            
            MOV(kmov).frames=FRAMES(param.mov(kmov).ylims(1):param.mov(kmov).ylims(2),param.mov(kmov).xlims(1):param.mov(kmov).xlims(2),:,:);
            MOV(kmov).i=INITIAL.i(param.mov(kmov).ylims(1):param.mov(kmov).ylims(2),param.mov(kmov).xlims(1):param.mov(kmov).xlims(2),:);
        end
            stashcount=0;
        
end


%% Run Tracker

%preallocate data storage and state variables
xyz=zeros(stopframe,3);
TRACKINGREC=zeros(stopframe,1);
LOSTCOUNT=LOSTTHRESH;
TRACKINGSTATE=0;
USERPOSSTATE=0;



%%Iterate thru desired frames
for kframe=startframe:stopframe
    
    switch lower(CAMTYPE)
        case {'many'}
            for kmov=1:ncam % Iterate thru cameras
            stashcount(kmov)=stashcount(kmov)+1; %counter for loading frames 
            MOV(kmov).new=MOV(kmov).stash(:,:,stashcount(kmov)); %get new frame from stash and process it
            if BLURTEST==1
            MOV(kmov).new=imfilter(MOV(kmov).new,PSF,'symmetric','conv');
            end
            
           
            MOV(kmov).new=MOV(kmov).new(param.mov(kmov).ylims(1):param.mov(kmov).ylims(2),param.mov(kmov).xlims(1):param.mov(kmov).xlims(2),:,:);
            
    
            if stashcount(kmov)>stashsize %if stashcount exceeds size then load new stash
            STARTF=kframe+3;
            STOPF=min(vid(1).NumberOfFrames,(kframe+3+stashsize));
        
            MOV(kmov).stash=read(vid(kmov),[STARTF STOPF]);
            MOV(kmov).stash=squeeze(sum(MOV(kmov).stash,3)/(3*255));
            stashcount(kmov)=0;
            end
    
            end
            
        case {'one'}
            stashcount=stashcount+1;
            
            if BLURTEST==1
                 STASH(:,:,stashcount)=imfilter(STASH(:,:,stashcount),PSF,'symmetric','conv');
            end
                   
            for kmov=1:ncam
                MOV(kmov).new=STASH(param.mov(kmov).ylims(1):param.mov(kmov).ylims(2),param.mov(kmov).xlims(1):param.mov(kmov).xlims(2),stashcount);
          
            end
            
            if isequal(max(MOV(1).new(:)),0)
              stashcount=stashcount+stashsize;
            end  
            
            
            if stashcount>stashsize
            STARTF=kframe+3;
            STOPF=min(vid(1).NumberOfFrames,(kframe+3+stashsize));
        
            STASH=read(vid(1),[STARTF STOPF]);
            STASH=squeeze(sum(STASH,3)/(3*255));
            stashcount=0;
            end
            
    end
            
    
    
    for kmov=1:ncam
        
    MOV(kmov).frames=cat(3,MOV(kmov).frames(:,:,2:end),MOV(kmov).new);  %Concatinate new frame from stash with existing frames 
    
    MOV(kmov).difference=(diffthresh(MOV(kmov).frames(:,:,1),MOV(kmov).frames(:,:,3),param.lev)+... %Difference Frames and inital frame
                        diffthresh(MOV(kmov).frames(:,:,2),MOV(kmov).frames(:,:,3),param.lev)+...   %Using subfunction diffthresh which
                        diffthresh(MOV(kmov).frames(:,:,4),MOV(kmov).frames(:,:,3),param.lev)+...   %Z-scores the pixel differnces in each of the 
                        diffthresh(MOV(kmov).frames(:,:,5),MOV(kmov).frames(:,:,3),param.lev)+...   %Subtraction steps
                        diffthresh(MOV(kmov).i,MOV(kmov).frames(:,:,3),param.lev)*3);
                    
    MOV(kmov).difference=MOV(kmov).difference>=3; %Find Pixels with significant differences on multiple subtractions (or just the inital subtraction)
    
    %if TRACKINGSTATE==1
     %   MOV(kmov).difference=campos
    %end
    
    s = regionprops(MOV(kmov).difference,'area','centroid');  %Find a list of list roi's in the final image
    sw = s;
 
    
    
    % Weight centrioid areas according to tracking state and distance to
    %last known position
    switch(TRACKINGSTATE)
        
        case {1} 
            for kroi=length(sw):-1:1
                if norm(sw(kroi).Centroid-campos(kmov).rstruc)>JUMPTHRESH1
                    sw(kroi).Area=s(kroi).Area/sqrt(norm(s(kroi).Centroid-campos(kmov).rstruc));     %for each roi in sw, weight area by sqrt of distance from reconstructed position
                    sw(kroi)=[];
                end
                
            end
            
        case {-1}
            for kroi=length(sw):-1:1
                if norm(sw(kroi).Centroid-campos(kmov).rstruc)>JUMPTHRESH2
                    sw(kroi).Area=s(kroi).Area/sqrt(norm(s(kroi).Centroid-campos(kmov).rstruc));     %for each roi in sw, weight area by sqrt of distance from reconstructed position
                    sw(kroi)=[];
                end
            end
            
    end
    
        
     if ~isempty(sw)
         area_vector = [sw.Area]; %if there exsist any roi's, pick that with the maximum weighted area
         [area idx] = max(area_vector);    
         campos(kmov).pixels(kframe,:)= sw(idx(1)).Centroid;
         campos(kmov).rating(kframe)=area;
    
     else
            campos(kmov).pixels(kframe,:)= [1e4 1e4]; %if there are no ROIs then set pos to 0,0 and rating to 0
            campos(kmov).rating(kframe)=0;
     end
       
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Query User if activated and tracking state is 0
    if isequal(QUERYUSERTEST,1) %
    
        USERPOSSTATE=0;
        if isequal(TRACKINGSTATE,0)
        
            USERPOS=query_user(param,MOV);
        
            for kmov=1:ncam
                campos(kmov).pixels(kframe,:)=USERPOS(kmov).pos;
                campos(kmov).rating(kframe)=1;
            end
            
            USERPOSSTATE=1;
    end
    
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Cam Selection - Select which camera set to use based on ROI areas
    camset(1).set=[1 4];
    camset(2).set=[2 3];
    exset(1).set=[1 2];
    exset(2).set=[4 3];
    
    
    
    %% Decide set and recontruct
    for kset=1:length(camset)
        camset(kset).residual=1e3;

        camset(kset).pos=dlt_reconstruct([cset(camset(kset).set(1)).c cset(camset(kset).set(2)).c],[campos(camset(kset).set(1)).pixels(kframe,:) campos(camset(kset).set(2)).pixels(kframe,:) ]);
        
        camset(kset).residual=0;
        for kcam=camset(kset).set
        campos(kcam).rstruc=dlt_inverse(cset(kcam).c,camset(kset).pos);
        camset(kset).residual=camset(kset).residual+norm(campos(kcam).pixels(kframe,:)-campos(kcam).rstruc);
        end
        camset(kset).residual=camset(kset).residual/length(camset(kset).set);
        
    end
    
    
    [tmp idx]=min([camset(:).residual]); %find camera set with minimum localization error
    
    % if residual is lower than threshold then use position and set
    % tracking state accordingly.  
    if tmp<10
            TRACKINGSTATE=1;
            camset(idx).pos
            xyz(kframe,:)=camset(idx).pos;
            LASTPOS=xyz(kframe,:);
            LOSTCOUNT=0;
        
    else
        
        switch TRACKINGSTATE
            case {0}
              xyz(kframe,:)=[NaN NaN NaN]; %if trackingstate is 0 then set position to NaN
            case {-1}
              xyz(kframe,:)=LASTPOS;
              LOSTCOUNT=LOSTCOUNT+1;       
              if LOSTCOUNT<LOSTTHRESH
                  TRACKINGSTATE=-1;
              else 
                  TRACKINGSTATE=0;
               end
            case {1}
                xyz(kframe,:)=LASTPOS;
                TRACKINGSTATE=-1;
                LOSTCOUNT=1;
            end
        
        
        end
  
    
    TRACKINGREC(kframe)=TRACKINGSTATE;
    
    for kcam=1:ncam
        campos(kcam).rstruc=dlt_inverse(cset(kcam).c,xyz(kframe,:));
    end
    
    
    clc
    disp(kframe)  
    
    if PLOTTEST==1 %If Plotter is on plot the tracking in a figure
    figure(fig(1))
    for k=1:ncam
    subplot(2,4,k)
    imshow(MOV(k).difference)
    subplot(2,4,k+4)
    imshow(MOV(k).frames(:,:,3))
    p(k,1)=impoint(gca,campos(k).pixels(kframe,:));
    p(k,2)=impoint(gca,campos(k).rstruc);
    setColor(p(k,2),'r')
    end
    figure(fig(2))
    plot3(xyz(kframe,1),xyz(kframe,2),xyz(kframe,3),'.k')
    hold on
   
    
    
    [camset(:).residual]
    TRACKINGSTATE
    pause(.1)
    end
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Query User

    function USERPOS=query_user(param,MOV)
    
    FIG=figure;
    
    for k=1:4
    SIZE=size(MOV(k).frames);
  
    subplot(2,1,1)
    imshow(MOV(k).difference)
    subplot(2,1,2)
    imshow(MOV(k).frames(:,:,3))
    
    
    
    fcn = makeConstrainToRectFcn('impoint',[1 (SIZE(2)+100)],[1 (SIZE(1)+100)]);
    
    p(k,1)=impoint(gca);
  
    
    api = iptgetapi(p(k));

    api.setPositionConstraintFcn(fcn);
    
    USERPOS(k).pos=getPosition(p(k)); 
    end
    
    close(FIG)
    
    
    
%% Diffthresh %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function   D=diffthresh(A,B,thresh)
        
       D=(A-B);
       STD=std(D(:));
       D=abs(A-B)>STD*thresh;
       
       
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


    
    