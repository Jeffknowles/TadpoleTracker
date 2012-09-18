% Plot Manual Datafiles

clear all; close all; clc;

DIR=dir('datafiles/');

PREFIX='NPF';

TRIALCOUNT=0;
for kfile=1:length(DIR)
    
    if (length(DIR(kfile).name)>5 && strcmp(DIR(kfile).name(1:length(PREFIX)),PREFIX) && strcmp(DIR(kfile).name(end-3:end),'.csv'))
        
        
        
        TRIALCOUNT=TRIALCOUNT+1;
        
        MAT=csvread(['datafiles/' DIR(kfile).name]);
        
        TRIAL(TRIALCOUNT).t=MAT(:,1);
        TRIAL(TRIALCOUNT).xyz=MAT(:,2:4);
        TRIAL(TRIALCOUNT).angle=MAT(:,5);
        
        TRIAL(TRIALCOUNT).name=DIR(kfile).name;
        
        
        
        if strcmp(TRIAL(TRIALCOUNT).name(end-5:end-4),'NF')
            TRIAL(TRIALCOUNT).CONDITION=0;
            
        elseif strcmp(TRIAL(TRIALCOUNT).name(end-5:end-4),'_F')
            TRIAL(TRIALCOUNT).CONDITION=1;
        end
            
    end
end

ALLDATA.NOFLOW.t=TRIAL(2).t;
ALLDATA.FLOW.t=TRIAL(2).t;


ALLDATA.NOFLOW.X(1).DATA=[];
ALLDATA.NOFLOW.X(1:length(ALLDATA.NOFLOW.t))=ALLDATA.NOFLOW.X(1);

ALLDATA.FLOW.X(1).DATA=[];
ALLDATA.FLOW.X(1:length(ALLDATA.FLOW.t))=ALLDATA.FLOW.X(1);


for ktrial=1:length(TRIAL)
    if TRIAL(ktrial).CONDITION==0
        
        for ktime=1:length(ALLDATA.NOFLOW.X)
            try
            if ~isnan(TRIAL(ktrial).xyz(ktime,1))
                ALLDATA.NOFLOW.X(ktime).DATA=[ALLDATA.NOFLOW.X(ktime).DATA TRIAL(ktrial).xyz(ktime,1)];
            end
            end
        end
        
        
    elseif TRIAL(ktrial).CONDITION==1
        
        for ktime=1:length(ALLDATA.FLOW.X)
            try
            if ~isnan(TRIAL(ktrial).xyz(ktime,1))
                ALLDATA.FLOW.X(ktime).DATA=[ALLDATA.FLOW.X(ktime).DATA TRIAL(ktrial).xyz(ktime,1)];
            end
            end
        end
        
        
    end
end



for ktime=1:length(ALLDATA.FLOW.X)
    ALLDATA.FLOW.xmeans(ktime)=mean(ALLDATA.FLOW.X(ktime).DATA);
    ALLDARA.FLOW.xstd(ktime)=std(ALLDATA.FLOW.X(ktime).DATA);
end
for ktime=1:length(ALLDATA.NOFLOW.X)
    ALLDATA.NOFLOW.xmeans(ktime)=mean(ALLDATA.NOFLOW.X(ktime).DATA);
    ALLDARA.NOFLOW.xstd(ktime)=std(ALLDATA.NOFLOW.X(ktime).DATA);
end



FIG(1)=figure;
plot(ALLDATA.NOFLOW.t,ALLDATA.NOFLOW.xmeans,'k')
hold on
plot(ALLDATA.FLOW.t,ALLDATA.FLOW.xmeans,'r')
ylim([0 68.5])


    


