function [cset rmse]=calscript(param)


load(['CalFiles/' 'TANKOBJECTDATA.mat'])

leftdata=calobjectref+repmat(leftoffset,12,1)+repmat(objectoffset,12,1);
rightdata=calobjectref+repmat(rightoffset,12,1)+repmat(objectoffset,12,1);

load(['CalFiles/' param.fnames.uvpts])

for k=1:4
    camcal(k).pts=camcal(k).pts-repmat([param.mov(k).xlims(1) param.mov(k).ylims(1)],12,1);
    
end

[cset(2).c rmse(2)]=dlt_computeCoefficients(leftdata,camcal(2).pts);
[cset(3).c rmse(3)]=dlt_computeCoefficients(leftdata,camcal(3).pts);

[cset(1).c rmse(1)]=dlt_computeCoefficients(rightdata,camcal(1).pts);
[cset(4).c rmse(4)]=dlt_computeCoefficients(rightdata,camcal(4).pts);

save(['CalFiles/' param.fnames.coeffs],'cset')


%% test residual


for k=1:4
    %plot(camcal(k).pts(:,1),camcal(k).pts(:,2),'.k')
    %pause
end

rightreconstruct=dlt_reconstruct([cset(2).c cset(3).c],[camcal(2).pts camcal(3).pts]);
leftreconstruct=dlt_reconstruct([cset(1).c cset(4).c],[camcal(1).pts camcal(4).pts]);

%testreconstruct=dlt_reconstruct([cset(1).c cset(4).c],[42 136 286 135])
if 0
tankplot
plot3(leftdata(:,1),leftdata(:,2),leftdata(:,3),'.k')
plot3(rightdata(:,1),rightdata(:,2),rightdata(:,3),'.k')

plot3(rightreconstruct(:,1),rightreconstruct(:,2),rightreconstruct(:,3),'.r')
plot3(leftreconstruct(:,1),leftreconstruct(:,2),leftreconstruct(:,3),'.r')
%plot3(testreconstruct(:,1),testreconstruct(:,2),testreconstruct(:,3),'.g')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% dlt_computeCoefficients Hendrick
function  [c,rmse] = dlt_computeCoefficients(frame,camPts)

% function  [c,rmse] = dlt_computeCoefficients(frame,camPts)
%
% A basic implementation of 11 parameter DLT
%
% Inputs:
%  frame - an array of x,y,z calibration point coordinates
%  camPts - an array of u,v pixel coordinates from the camera
%
% Outputs:
%  c - the 11 DLT coefficients
%  rmse - root mean square error for the reconstruction; units =
%
% Notes - frame and camPts must have the same number of rows.  A minimum of
% 6 rows are required to compute the coefficients.  The frame points must
% not all lie within a single plane
%
% Ty Hedrick

% check for any NaN rows (missing data) in the frame or camPts
ndx=find(sum(isnan([frame,camPts]),2)>0);

% remove any missing data rows
frame(ndx,:)=[];
camPts(ndx,:)=[];

% re-arrange the frame matrix to facilitate the linear least squares
% solution
M=zeros(size(frame,1)*2,11);
for i=1:size(frame,1)
  M(2*i-1,1:3)=frame(i,1:3);
  M(2*i,5:7)=frame(i,1:3);
  M(2*i-1,4)=1;
  M(2*i,8)=1;
  M(2*i-1,9:11)=frame(i,1:3).*-camPts(i,1);
  M(2*i,9:11)=frame(i,1:3).*-camPts(i,2);
end

% re-arrange the camPts array for the linear solution
camPtsF=reshape(flipud(rot90(camPts)),numel(camPts),1);

% get the linear solution to the 11 parameters
c=linsolve(M,camPtsF);

% compute the position of the frame in u,v coordinates given the linear
% solution from the previous line
Muv=dlt_inverse(c,frame);

% compute the root mean square error between the ideal frame u,v and the
% recorded frame u,v
rmse=(sum(sum((Muv-camPts).^2))./numel(camPts))^0.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% dlt_inverse

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

