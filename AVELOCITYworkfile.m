%% Average Velocity Figure WORKFILE
% Generate figure and stats concerning the average speed of animals
% with and without colbalt treatment.  
%
% For NPF 15-19, trial 1 is run under ringers solution and trial 2 is run
% under cobalt solution.  Here the tracked data is loaded and the averages
% are calcuated
close all; clear all; clc;
DIFF=[];
CONTROL=[];
COBALT=[];
for kanimal=[15:17 21:25]
    for ktrial=1:2
        %Generate filename
        FNAME=['NPF' num2str(kanimal) '_' num2str(ktrial) '_NF.mat'];
        
        %load data file
        load(['datafiles/' FNAME])       
        
        %run data and calculate average velocity for trial
        DATA=filterdata(DATA);
        DATA=velocity_plot(DATA);
        ANIMAL(kanimal).TRIAL(ktrial).speed=DATA.speed;
        ANIMAL(kanimal).TRIAL(ktrial).average_speed=mean(DATA.speed); 
        
    end
    
    DIFF=[DIFF (ANIMAL(kanimal).TRIAL(1).average_speed-ANIMAL(kanimal).TRIAL(2).average_speed)];
    CONTROL=[CONTROL ANIMAL(kanimal).TRIAL(1).average_speed];
    COBALT=[COBALT ANIMAL(kanimal).TRIAL(2).average_speed];
end

XBINS=[0:.1:1.5];

FIG(1)=figure;
subplot(2,1,1)
HISTC=histc(CONTROL,XBINS);
bar(XBINS,HISTC,'histc')

subplot(2,1,2)
HISTC=hist(COBALT,XBINS);
bar(XBINS,HISTC,'histc')



disp(['CONTROL Velocity = ' num2str(mean(CONTROL)) ' +/- ' num2str(std(CONTROL)) '  N = ' num2str(length(CONTROL))])
disp(['COBALT Velocity = ' num2str(mean(COBALT)) ' +/- ' num2str(std(COBALT))  ' N = ' num2str(length(COBALT))]) 

