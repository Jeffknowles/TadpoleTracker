%% Make Track figure
close all; clear all; clc;

% Set data directory
DATADIREC='/Volumes/JK_TRAVEL/TadpoleDatafiles/';

% Set Trials
TRACK(1).TRIAL='NPF5_1_';
TRACK(2).TRIAL='NPF6_1_';
TRACK(3).TRIAL='NPF9_1_';
TRACK(4).TRIAL='NPF17_1_';



% generate figure
FIG=figure;



%% TRACK 1 (NPF 
load([DATADIREC TRACK(1).TRIAL 'NF.mat'])
DATANF=DATA;
load([DATADIREC TRACK(1).TRIAL 'F.mat'])
DATAC.xyz=vertcat(DATANF.xyz,DATA.xyz);
DATAC.times=[DATANF.times DATA.times+DATANF.times(end)];
DATAC=filterdata(DATAC);

subplot('position',[.1 .55 .4 .4])
plot([0 DATAC.timesfilt(1)],[35 DATAC.xyzfilt(1,1)],'--k','linewidth',1)
hold on
plot(DATAC.timesfilt,DATAC.xyzfilt(:,1),'k','linewidth',3)
plot([300 300],[0 70],'--k','linewidth',2)
set(gca,'xtick',[])
ylabel('X Position')
ylim([0 70])
xlim([0 600])

%% TRACK 2
load([DATADIREC TRACK(2).TRIAL 'NF.mat'])
DATANF=DATA;
load([DATADIREC TRACK(2).TRIAL 'F.mat'])
DATAC.xyz=vertcat(DATANF.xyz,DATA.xyz);
DATAC.times=[DATANF.times DATA.times+DATANF.times(end)];
DATAC=filterdata(DATAC);

subplot('position',[.55 .55 .4 .4])
plot([0 DATAC.timesfilt(1)],[35 DATAC.xyzfilt(1,1)],'--k','linewidth',1)
hold on
plot(DATAC.timesfilt,DATAC.xyzfilt(:,1),'k','linewidth',3)
plot([300 300],[0 70],'--k','linewidth',2)
set(gca,'xtick',[])
set(gca,'ytick',[])
%xlabel('TIME (S)')
%ylabel('X Position')
ylim([0 70])
xlim([0 600])

%% TRACK 3
load([DATADIREC TRACK(3).TRIAL 'NF.mat'])
DATANF=DATA;
load([DATADIREC TRACK(3).TRIAL 'F.mat'])
DATAC.xyz=vertcat(DATANF.xyz,DATA.xyz);
DATAC.times=[DATANF.times DATA.times+DATANF.times(end)];
DATAC=filterdata(DATAC);

subplot('position',[.1 .1 .4 .4])
plot([0 DATAC.timesfilt(1)],[35 DATAC.xyzfilt(1,1)],'--k','linewidth',1)
hold on
plot(DATAC.timesfilt,DATAC.xyzfilt(:,1),'k','linewidth',3)
plot([300 300],[0 70],'--k','linewidth',2)
xlabel('TIME (S)')
ylabel('X Position')
ylim([0 70])
xlim([0 600])

%% TRACK 4 (NPF 6)
load([DATADIREC TRACK(4).TRIAL 'NF.mat'])
DATANF=DATA;
load([DATADIREC TRACK(4).TRIAL 'F.mat'])
DATAC.xyz=vertcat(DATANF.xyz,DATA.xyz);
DATAC.times=[DATANF.times DATA.times+DATANF.times(end)];
DATAC=filterdata(DATAC);

subplot('position',[.55 .1 .4 .4])
plot([0 DATAC.timesfilt(1)],[35 DATAC.xyzfilt(1,1)],'--k','linewidth',1)
hold on
plot(DATAC.timesfilt,DATAC.xyzfilt(:,1),'k','linewidth',3)
plot([300 300],[0 70],'--k','linewidth',2)
set(gca,'ytick',[])
xlabel('TIME (S)')
ylim([0 70])
xlim([0 600])

