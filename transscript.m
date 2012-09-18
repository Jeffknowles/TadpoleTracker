%transformation workfile
cam(1).O=[22 88; 24 168; 258 67; 256 187];
cam(1).N=[63 102; 66 183; 295 80; 295 198];

cam(2).O=[21 70; 23 181; 231 84; 233 163];
cam(2).N=[402 82; 408 199; 617 92; 629 184];

cam(3).O=[68 38; 75 161; 278 33];
cam(3).N=[80 250; 90 380; 308 244];

cam(4).O=[15 33; 230 47; 235 153];
cam(4).N=[380 253; 612 255; 608 379];


for kcam=1:4
TMP=polyfit(cam(kcam).O(:,1),cam(kcam).N(:,1),1);
trans(kcam).A(1)=TMP(1);
trans(kcam).B(1)=TMP(2);

TMP=polyfit(cam(kcam).O(:,2),cam(kcam).N(:,2),1);
trans(kcam).A(2)=TMP(1);
trans(kcam).B(2)=TMP(2);
end

load('cal1uvpts.mat')
for kcam=1:4
    for kpt=1:12
        camcalnew(kcam).pts(kpt,:)=(trans(kcam).A.*camcal(kcam).pts(kpt,:)+trans(kcam).B);
    end
end
camcal=camcalnew;
save('cal2009uvpts.mat','camcal')

%%

MOV=mmreader('/Volumes/JK_TRAVEL/tadpoletracking2009/NPF9_1_F.avi')
imshow(read(MOV,1))
hold on
plot(camcal(1).pts(:,1),camcal(1).pts(:,2),'.k')
hold on
plot(camcal(2).pts(:,1),camcal(2).pts(:,2),'.r')
plot(camcal(3).pts(:,1),camcal(3).pts(:,2),'.g')
plot(camcal(4).pts(:,1),camcal(4).pts(:,2),'.b')