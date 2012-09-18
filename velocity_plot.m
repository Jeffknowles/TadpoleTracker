function DATA=velocity_plot(DATA)
        

xyz=DATA.xyzfilt;
vxyz=findvel(xyz,30);

 for k=1:length(vxyz)
         speed(k)=norm(vxyz(k,:));
 end
 
 axyz=findvel(vxyz,30);
        
                
 for k=1:length(axyz)
    accel(k)=norm(axyz(k,:));
 end
                
 %figure
 subplot(2,1,1)
 plot(DATA.timesfilt,speed)
 subplot(2,1,2)
 plot(DATA.timesfilt,accel)
 
 
 DATA.speed=speed;
 DATA.accel=accel;