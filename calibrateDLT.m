%% Calibrate DLT script
clear all; close all; clc

% DLT Left
LEFTfname='F:\Premiere Projects\VideoFiles\DLTCal_CNR5_LEFT.avi';
% DLT Right
RIGHTfname='F:\Premiere Projects\VideoFiles\DLTCal_CNR5_Right.avi';

% Calibration name
CALNAME='cal10';


FNAME{1}=LEFTfname;
FNAME{2}=RIGHTfname;




% fixed settings
NCAM=4;
NPTS=12;
CAMSET{1}=[2 3];
CAMSET{2}=[1 4];

camcal.pts=zeros(NPTS,2);
camcal(1:NCAM)=camcal(1);

FIG(1)=figure('color','w');
for kcam=1:NCAM
    disp(['CAM ' num2str(kcam)]) 
    for kpts=1:NPTS
        disp(['CAM ' num2str(kcam) ' Point ' num2str(kpts)])
        
        if ismember(kcam,CAMSET{1})
            VID=mmreader(FNAME{1});
        else
            VID=mmreader(FNAME{2});
        end
        figure(FIG(1))
        imshow(read(VID,1));
        H=impoint(gca);
        pause
        POS=getPosition(H);
        camcal(kcam).pts(kpts,:)=POS;
        disp(POS);

    end
    clc
end


%%
save(['CalFiles\' CALNAME 'uvpts.mat'],'camcal');
    