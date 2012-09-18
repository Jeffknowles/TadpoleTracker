function tankplot


%% Set up axis
axis equal
hold on

%% Plot Wall Edges


plot3([0 68.5],[0 0] ,[0 0],'k','linewidth',2)
plot3([0 0],[0 15] ,[0 0],'k','linewidth',2)
plot3([0 68.5],[15 15] ,[0 0],'k','linewidth',2)
plot3([68.5 68.5],[0 15] ,[0 0],'k','linewidth',2)

plot3([0 68.5],[0 0],[19.7 19.7],'k','linewidth',2)
plot3([0 0],[0 15],[19.7 19.7],'k','linewidth',2)
plot3([0 68.5],[15 15],[19.7 19.7],'k','linewidth',2)
plot3([68.5 68.5],[0 15],[19.7 19.7],'k','linewidth',2)

plot3([68.5 68.5],[0 0],[0 19.7],'k','linewidth',2)
plot3([0 0],[0 0],[0 19.7],'k','linewidth',2)
plot3([68.5 68.5],[15 15],[0 19.7],'k','linewidth',2)
plot3([0 0],[15 15],[0 19.7],'k','linewidth',2)


%% Set View
view(0,90)




