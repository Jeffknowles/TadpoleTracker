%% Average Velocity Figure WORKFILE
% Generate figure and stats concerning the average speed of animals
% with and without colbalt treatment.  
%
% For NPF 15-19, trial 1 is run under ringers solution and trial 2 is run
% under cobalt solution.  Here the tracked data is loaded and the averages
% are calcuated
close all; clear all; clc;




COBALT.DIFF=[];
COBALT.PRE=[];
COBALT.TREATMENT=[];
for kanimal=[15:17 21:25]
    for ktrial=1:2
        %Generate filename
        FNAME=['NPF' num2str(kanimal) '_' num2str(ktrial) '_NF.mat'];
        
        %load data file
        %load(['datafiles/' FNAME])       
        load(['/Volumes/JK_TRAVEL/TadpoleDatafiles/' FNAME])
        
        %run data and calculate average velocity for trial
        DATA=filterdata(DATA);
        DATA=velocity_plot(DATA);
        ANIMAL(kanimal).TRIAL(ktrial).speed=DATA.speed;
        ANIMAL(kanimal).TRIAL(ktrial).average_speed=mean(DATA.speed); 
        
    end
    
    COBALT.DIFF=[COBALT.DIFF (ANIMAL(kanimal).TRIAL(2).average_speed-ANIMAL(kanimal).TRIAL(1).average_speed)];
    COBALT.PRE=[COBALT.PRE ANIMAL(kanimal).TRIAL(1).average_speed];
    COBALT.TREATMENT=[COBALT.TREATMENT ANIMAL(kanimal).TRIAL(2).average_speed];
end


CONTROL.DIFF=[];
CONTROL.PRE=[];
CONTROL.TREATMENT=[];
for kanimal=[5 6 7 8 9 10]
    for ktrial=1:2
        %Generate filename
        FNAME=['NPF' num2str(kanimal) '_' num2str(ktrial) '_NF.mat'];
        
        %load data file
        %load(['datafiles/' FNAME])       
        load(['/Volumes/JK_TRAVEL/TadpoleDatafiles/' FNAME])
        
        %run data and calculate average velocity for trial
        DATA=filterdata(DATA);
        DATA=velocity_plot(DATA);
        ANIMAL(kanimal).TRIAL(ktrial).speed=DATA.speed;
        ANIMAL(kanimal).TRIAL(ktrial).average_speed=mean(DATA.speed); 
        
    end
    
    CONTROL.DIFF=[CONTROL.DIFF (ANIMAL(kanimal).TRIAL(2).average_speed-ANIMAL(kanimal).TRIAL(1).average_speed)];
    CONTROL.PRE=[CONTROL.PRE ANIMAL(kanimal).TRIAL(1).average_speed];
    CONTROL.TREATMENT=[CONTROL.TREATMENT ANIMAL(kanimal).TRIAL(2).average_speed];
end



CONTROL.PRE_mean=mean(CONTROL.PRE);
CONTROL.PRE_std=std(CONTROL.PRE);
CONTROL.TREATMENT_mean=mean(CONTROL.TREATMENT);
CONTROL.TREATMENT_std=std(CONTROL.TREATMENT);

COBALT.PRE_mean=mean(COBALT.PRE);
COBALT.PRE_std=std(COBALT.PRE);
COBALT.TREATMENT_mean=mean(COBALT.TREATMENT);
COBALT.TREATMENT_std=std(COBALT.TREATMENT);
%%
figure

CONTROL
COBALT


BARS=[CONTROL.PRE_mean CONTROL.TREATMENT_mean; COBALT.PRE_mean COBALT.TREATMENT_mean];
ERRORS=[CONTROL.PRE_std CONTROL.TREATMENT_std; COBALT.PRE_std COBALT.TREATMENT_std];

GROUPNAMES={'Control';'Cobalt'};
LEGEND={'Pretreatment';'Treatment'};

barweb(BARS,ERRORS,[],GROUPNAMES,[],[],'Average Speed Cm/s','gray',[],[],2)
legend('Pretreatment','Treatment')
return

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

