function INITIAL=create_blank(param,vid)


if strcmp(param.CAMTYPE,'one')
    YPIXELS=vid.Height; %set dimesnions of the frame
    XPIXELS=vid.Width;
    nframes=vid.NumberOfFrames;
    INITIAL.i=zeros(YPIXELS,XPIXELS,3);
end





COMP=[0 0];

kframe=100;
fig=figure;
set(fig,'Windowstyle','docked')

while ~isequal(COMP,[1 1])
    
    
    
    clc
    
    switch lower(param.CAMTYPE)
        case {'one'}
            FRAME=read(vid,kframe);
            imshow(FRAME)
            
        case {'many'}
            for kvid=1:4
                FRAME(kvid).FRAME=read(vid(kvid),kframe);
                subplot(1,4,kvid)
                imshow(FRAME(kvid).FRAME)
            end
            
    end
    
    disp(['Frame ' num2str(kframe)])
    disp(['Pick a Blank Frame for each camera set.'])
    disp(['Enter set1 for a frame with cameras 1 and 4 free'])
    disp(['Enter set2 for a frame with cameras 2 and 3 free'])
    disp(['Blank to advance'])
    disp(['Q to quit'])
    
    INPUT=input('input: ','s');
    
    switch lower(INPUT)
        case {'set1'}
            if strcmp(param.CAMTYPE,'one')
                EMPTY(1).frame=FRAME;
                COMP(1)=1;
            else
                INITIAL(1).i=FRAME(1).FRAME;
                INITIAL(4).i=FRAME(4).FRAME;
            end
            
        case {'set2'}
            if strcmp(param.CAMTYPE,'one')
                EMPTY(2).frame=FRAME;
                COMP(2)=1;
            else
                INITIAL(2).i=FRAME(2).FRAME;
                INITIAL(3).i=FRAME(3).FRAME;
            end
            
            
        case {'Q'}
            break
            
        case {'a'}
            INPUT=input('Enter next frame')
            
            kframe=INPUT;
            
        otherwise
            kframe=kframe+200;
            
            continue
    end
end

if ~isequal(COMP,[1 1]);
    disp('You failed to enter a frame for both camera sets.  Please try again.')
    return
end

if strcmp(param.CAMTYPE,'one')
    INITIAL.i(1:round(YPIXELS/2),1:round(XPIXELS/2),:)=EMPTY(1).frame(1:round(YPIXELS/2),1:round(XPIXELS/2),:);
    INITIAL.i(round(YPIXELS/2):end,round(XPIXELS/2):end,:)=EMPTY(1).frame(round(YPIXELS/2):end,round(XPIXELS/2):end,:);
    
    INITIAL.i(1:round(YPIXELS/2),round(XPIXELS/2):end,:)=EMPTY(2).frame(1:round(YPIXELS/2),round(XPIXELS/2):end,:);
    INITIAL.i(round(YPIXELS/2):end,1:round(XPIXELS/2),:)=EMPTY(2).frame(round(YPIXELS/2):end,1:round(XPIXELS/2),:);
    
    INITIAL.i=uint8(INITIAL.i);
end


