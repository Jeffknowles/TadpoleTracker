%cat worfile
    
nframes=vid.NumberOfFrames;
stash=50;

for k=1:stash:nframes
    clc; disp(k)
    FRAMES=read(vid,[k (k+stash)]);
    
    imshow(FRAMES(:,:,:,1))
    pause(.1)
    if max(FRAMES(:))==0
        return
    end
end
    
    