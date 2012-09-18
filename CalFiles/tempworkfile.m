%temp workfile

clear all; clc; close all;


MOV=mmreader('/Volumes/JK_TRAVEL/tadpoletracking2009/NPF9_1_F.avi')


load('cal2009uvpts.mat')

imshow(read(MOV,1))

hold on


for kcam=1:4
    
    
    plot(camcal(kcam).pts(:,1),camcal(kcam).pts(:,2),'.r')
    hold on
    
    xlim([1 720])
    ylim([1 480])
end



