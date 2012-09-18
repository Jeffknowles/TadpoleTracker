function animateswim(xyz)

close all

ncoords=length(xyz);

for ktime=5:50:ncoords
    clc; disp(ktime)
    hold off
    tankplot
    plot3(xyz(1:ktime,1),xyz(1:ktime,2),xyz(1:ktime,3),'.k')
    view(35,70)
    hold on
    
    pause(.01);
end
