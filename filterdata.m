function [DATA]=filterdata(DATA)


%% Remove zero points
IDX=find(DATA.xyz(:,1));
xyzfilt=DATA.xyz(IDX,:);
timesfilt=DATA.times(IDX);

%% Remove NANs
IDX=~isnan(xyzfilt(:,1));
xyzfilt=xyzfilt(IDX,:);
timesfilt=timesfilt(IDX);



windowSize = 200;
xyzfilt(:,1)=filtfilt(ones(1,windowSize)/windowSize,1,xyzfilt(:,1));
xyzfilt(:,2)=filtfilt(ones(1,windowSize)/windowSize,1,xyzfilt(:,2));
xyzfilt(:,3)=filtfilt(ones(1,windowSize)/windowSize,1,xyzfilt(:,3));


%plot(filter_bandpass(xyzfilt(:,1),.001,.1,30))

DATA.xyzfilt=xyzfilt;
DATA.timesfilt=timesfilt;




