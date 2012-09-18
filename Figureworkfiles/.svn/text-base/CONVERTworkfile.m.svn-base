%CONVERTWORKFILE
close all; clear all; clc;
INDIREC='/Volumes/JK_TWIN/CSV Files for BRIAN/10CMs/';
OUTDIREC='/Volumes/JK_TWIN/CSV Files for BRIAN/10CMsConverted/';


DIR=dir(INDIREC);

for kfile=1:length(DIR)
    if (length(DIR(kfile).name)>5 && strcmp(DIR(kfile).name(end-3:end),'.csv'))
        
        
        INMAT=dlmread([INDIREC DIR(kfile).name]);
                
        OUTMAT=INMAT'; %transpose
        
        OUTMAT=OUTMAT(:,2:end); %take away first row
        
        OUTMAT(2:end,:)=round(OUTMAT(2:end,:)/2.54)+1;
        
        csvwrite([OUTDIREC DIR(kfile).name],OUTMAT)
        
   
    end
    
    
end
