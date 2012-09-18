function vxyz=findvel(xyz,FPS)
%% Find Velocities
STEPLENGTH=1;
vxyz=zeros(size(xyz));

nsteps=length(xyz);



vxyz(STEPLENGTH:nsteps,:)=(xyz(STEPLENGTH:nsteps,:)-xyz(1:nsteps-STEPLENGTH+1,:))/(STEPLENGTH/FPS);
    