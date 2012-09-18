function tadpole_plot(DATA)
close all

DATA=filterdata(DATA);

xyz=DATA.xyzfilt;
times=DATA.timesfilt;





xlen=68.5;
ylen=15;
zlen=19.5;


% Plot 3d
figure
tankplot
plot3(xyz(:,1),xyz(:,2),xyz(:,3),'.k')

% Make 1d occupancy histograms
figure
subplot(3,1,1)
hist(xyz(:,1),40)
title('X Occupancy')
subplot(3,1,2)
hist(xyz(:,2),40)
title('Y Occupancy')
subplot(3,1,3)
hist(xyz(:,3),40)
title('Z Occupancy')

% Make 2d occupancy histograms
binsize=2;
binsx=-binsize:binsize:xlen+binsize;
binsy=-binsize:binsize:ylen+binsize;
binsz=-binsize:binsize:ylen+binsize;

clear XYHIST
figure
count=0;
for kbin=binsx;
    count=count+1;
    IDX=(xyz(:,1)>kbin-binsize/2 & xyz(:,1)<kbin+binsize/2);
    XYHIST(:,count)=histc(xyz(IDX,2),binsy);
end

surf(binsx,binsy,XYHIST)
axis equal
view(0,90)


%% Make Velocity Histogram
figure;
vxyz=findvel(xyz,30);

bins=[-20:1:20];


subplot(3,1,1)
hist(vxyz(:,1),40)
title('X Vel')
xlabel('CM/S')
xlim([-20 20])

subplot(3,1,2)
hist(vxyz(:,2),40)
title('Y Vel')
xlabel('CM/S')
xlim([-20 20])

subplot(3,1,3)
hist(vxyz(:,3),40)
title('Z Vel')
xlabel('CM/S')
xlim([-20 20])




%% Make Velocity(t) plots
velocity_plot(DATA);

%% Make X Position Plots
figure
plot(DATA.times,DATA.xyz(:,1),'r')
hold on
plot(DATA.timesfilt,DATA.xyzfilt(:,1),'k','linewidth',3)
ylim([0 70])
xlabel('TIME (S)')
ylabel('X Position')
    
    



