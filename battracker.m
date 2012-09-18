function [lf rf]=battracker(gray)

%% Load data and variabels
clc


%% Parameters 


lev=.1;        %Threshold for each Difference level. Increasing lev decreases type 3 errors, increases type 1 errors
npres=1;        %Required number of dframes containing a pixel for it to be active. Increasing decreases type 3 errors
roithresh=1;     %Threshold area for ROI's
jumpthresh=20;  %Threshold Pixel Jump for Type 3 Error
nframes=length(gray);
%% Difference Video
  
for k2=5:(nframes-5) %Frame Differencing and summation of the results  
    clc
    disp(['Polydifferencing: frame ' int2str(k2) ' of ' int2str(nframes)]) 
      
    db1=imabsdiff(gray(k2).data, gray(k2-1).data);      %d(current,1 back)
    df1=imabsdiff(gray(k2).data, gray(k2+1).data);      %d(current,1 forward)
    db2=imabsdiff(gray(k2).data, gray(k2-2).data);      %d(current,2 back)
    df2=imabsdiff(gray(k2).data, gray(k2+2).data);      %d(current,2 forward)
    db3=imabsdiff(gray(k2).data, gray(k2-3).data);      %d(current,3 back)
    df3=imabsdiff(gray(k2).data, gray(k2+3).data);      %d(current,3 forward)
    db4=imabsdiff(gray(k2).data, gray(k2-4).data);      %d(current,4 back)
    df4=imabsdiff(gray(k2).data, gray(k2+4).data);      %d(current,4 forward)
   
    bsm=im2bw(im2bw(db1,lev)+im2bw(db2,lev)+im2bw(db3,lev)+im2bw(db4,lev)...
        +im2bw(df1,lev)+im2bw(df2,lev)+im2bw(df3,lev)+im2bw(df4,lev)-npres); %bsm is a binary image created by first converting frames to binary                               
                                                                        %summing them, then accepting only those pixels present in at least set number of them.
                                                
    bw2(:,:,k2)=bwareaopen(bsm,roithresh, 8);                            %bw2 is the resultant of filtering bw for roi's under a specified area (see bwareaopen)
end                      %bw2 is the resultant of filtering bw for roi's under a specified area (see bwareaopen)


clear gray;
%% Search Loop Left Frame
centroids = zeros(nframes, 2);   %initilize centroids as record of bat position (column 1=x 2=y) at frame (row) 
errorlog=zeros(nframes,4);       % error log records when bat is missing

clc
vmin=1;
vmax=360;
hmin=1;
hmax=640;

for k=5:nframes-5
    clc
    disp(['searching left frame... ' int2str(k) ' of ' int2str(nframes)]) 
    
 interpguess=interp1((k-3):(k-1),centroids((k-3):(k-1),:),k,'linear','extrap');
 
 s = regionprops(bwlabel(bw2(vmin:vmax,hmin:hmax,k)),'area','centroid');  %set s as list of roi's in bw2
 sw=s;                                                            %sw will be s weighted
 slen=length(s);
 
 if slen>=1
    for k2=1:slen
    sw(k2).Area=sw(k2).Area/sqrt(norm(sw(k2).Centroid-interpguess));     %for each roi in sw, weight area by sqrt(distance from interpolation guess)

    end

    area_vector = [sw.Area];                     %if there exsist any roi's, pick that with the maximum weighted area
    [tmp, idx] = max(area_vector);              
    centroids(k, :) = sw(idx(1)).Centroid;       %take the center of mass of biggest roi and record position in centroids
elseif errorlog(k-1)==0
    centroids(k,:)=interp1((k-3):(k-1),centroids((k-3):(k-1),:),k,'linear','extrap'); %if there are no roi's, then record error and extrapolate position position
    %centroids(k,:)=NaN;
    errorlog(k,1)=1;                     %record type 1 error (no roi's found and penultimate frame is error free)
else
    centroids(k,:)=centroids(k-1,:);     %if there was an error in the last frame and this one, then record last position rather than interpolate (stops problematic interpolation)
    %centroids(k,:)=NaN;
    errorlog(k,2)=1;                     %record type 2 error (no roi's and error in last frame)
 end

 if  (norm(centroids(k,:)-centroids(k-1,:))>jumpthresh && k>6 && errorlog(k-1,3)==0) %if the bat has jumped, then record error type 3
     %Centroids(k,:)=NaN;
     errorlog(k,3)=1;                     %record type 3 error (jump in position greater than set pixels)
     
 end
    
end
errorlogl=errorlog;
centroidsl=centroids;
%% search right frame
clc
disp('Searching Right Frame')
centroids = zeros(nframes, 2);   %intilize centroids as record of bat position (column 1=x 2=y) at frame (row) 
errorlog=zeros(nframes,4);       % error log records when bat is missing

clc
vmin=1;
vmax=360;
hmin=650;
hmax=1260;

for k=5:nframes-5
    clc
    disp(['searching left frame... ' int2str(k) ' of ' int2str(nframes)]) 
    
 interpguess=interp1((k-3):(k-1),centroids((k-3):(k-1),:),k,'linear','extrap');
 s = regionprops(bwlabel(bw2(vmin:vmax,hmin:hmax,k)),'area','centroid');  %set s as list of roi's in bw2
 sw=s;                                                            %sw will be s weighted
 slen=length(s);
 
 if slen>=1
    for k2=1:slen
    sw(k2).Area=sw(k2).Area/sqrt(norm(sw(k2).Centroid-interpguess));     %for each roi in sw, weight area by sqrt(distance from interpolation guess)
    end

    area_vector = [sw.Area];                     %if there exsist any roi's, pick that with the maximum weighted area
    [tmp, idx] = max(area_vector);              
    centroids(k, :) = sw(idx(1)).Centroid;       %take the center of mass of biggest roi and record position in centroids
elseif errorlog(k-1)==0
    centroids(k,:)=interp1((k-3):(k-1),centroids((k-3):(k-1),:),k,'linear','extrap'); %if there are no roi's, then record error and extrapolate position position
    %centroids(k,:)=NaN;
    errorlog(k,1)=1;                     %record type 1 error (no roi's found and penultimate frame is error free)
else
    centroids(k,:)=centroids(k-1,:);     %if there was an error in the last frame and this one, then record last position rather than interpolate (stops problematic interpolation)
    %centroids(k,:)=NaN;
    errorlog(k,2)=1;                     %record type 2 error (no roi's and error in last frame)
 end

 if  (norm(centroids(k,:)-centroids(k-1,:))>jumpthresh && k>6 && errorlog(k-1,3)==0) %if the bat has jumped, then record error type 3
     %Centroids(k,:)=NaN;
     errorlog(k,3)=1;                     %record type 3 error (jump in position greater than set pixels)
     
 end
    
end

centroidsr(:,1)=centroids(:,1)+650;
centroidsr(:,2)=centroids(:,2);
errorlogr=errorlog;
%clear bw2

%% Auto-Interpolate Left Frame
clc 
disp('Auto Interpolating Left Frame...')

for k=5:nframes-5                        %a crack at interpolation to fix errors. works fine for single frame errors. Needs work for muliframe errors
    if sum(errorlogl(k,:))==0
        centroidsl(k,:)=centroidsl(k,:);
    elseif (sum(errorlogl(k-1,:))==0 && sum(errorlogl(k+1,:)==0))
        interpguess=interp1([1 3],[centroidsl(k-1,:); centroidsl(k+1,:)],2,'linear');
        centroidsl(k,:)=interpguess;
    else
        errorlogl(k,4)=1;
    end
end

%% Auto Interpolate Right Fame
clc
disp('Auto Interpolate Right Frame')

for k=5:nframes-5                          %a crack at interpolation to fix errors. works fine for single frame errors. Needs work for muliframe errors
    if sum(errorlogr(k,:))==0
        centroidsr(k,:)=centroidsr(k,:);
    elseif (sum(errorlogr(k-1,:))==0 && sum(errorlogr(k+1,:))==0)
        interpguess=interp1([1 3],[centroidsr(k-1,:); centroidsr(k+1,:)],2,'linear');
        centroidsr(k,:)=interpguess;
    else
        errorlogr(k,4)=1;
    end
end

%% Report and save

clc
disp('Auto Tracking and Interpolation complete.')
disp('In the Left Video, There Were:')
disp([int2str(sum(errorlogl(:,1))) ' type 1 errors'])
disp([int2str(sum(errorlogl(:,2))) ' type 2 errors'])
disp([int2str(sum(errorlogl(:,3))) ' type 3 errors'])
disp(['and ' int2str(sum(errorlogl(:,4))) ' frames to fix manually'])
disp('')

disp('In the Right Video, There Were:')
disp('')
disp('Press any key to continue')
disp([int2str(sum(errorlogr(:,1))) ' type 1 errors'])
disp([int2str(sum(errorlogr(:,2))) ' type 2 errors'])
disp([int2str(sum(errorlogr(:,3))) ' type 3 errors'])
disp(['and ' int2str(sum(errorlogr(:,4))) ' frames to fix manually'])
disp('')

lf.pixeldata=centroidsl;
lf.errorlog=errorlogl;
rf.pixeldata=centroidsr;
rf.errorlog=errorlogr;


