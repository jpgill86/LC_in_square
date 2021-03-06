% Consider two regions, above and below the wedge
% Generate local timing response curve for the region I that is above the wedge, usng the function find_prc in LC_in_square
% and compute the piecewise relative change in frequency nu_above_wedge and nu_below_wedge

alpha=0.2;
T0=6.766182958128617;

% Region I: 
% above Sigma^in: y-x=0 for y nonnegative, and above Sigma^out: y+x=0 for y nonnegative
y=(0:0.1:1.5);
x_sigma_in = y; % define the entry boundary of region I
x_sigma_out = -y; % define the exit boundary of region II. 

% xinit=[0.6547,1];
% model = LC_in_square('varOn', 'false', 'xinit', xinit);
% model.solve;
% ind_out=(abs(model.yext(:,1)+model.yext(:,2))<5e-3) & (model.yext(:,2)>=0);
% ind_in=(abs(model.yext(:,1)-model.yext(:,2))<5e-3) & (model.yext(:,2)>=0);
% x_out=model.yext(ind_out,:); % the exit point from region 1
% x_in=model.yext(ind_in,:); % the entry point into region 1

x_in=[0.811047481339979   0.811181234361245];  % the entry point into region 1
x_out=[-0.813550109151894   0.809463778128291]; % the exit point from region 1
model0 = LC_in_square('xinit', x_out);  % Compute the solution trajectory from x_out
model0.solve;

% Compute the total time spent in the region I, that is above the wedge
ind_above_wedge=(model0.yext(:,1) + model0.yext(:,2) >=0) & (model0.yext(:,2) - model0.yext(:,1) >=0);
time_above_wedge=model0.t(ind_above_wedge);
T0_above_wedge=time_above_wedge(end)-time_above_wedge(1); % total time spent in region I

% To only compute the lTRC in region I, compute the solution from x_in to x_out
model = LC_in_square('xinit', x_in, 'vinit', [0,0], 'tmax', T0_above_wedge);
model.solve;

% To compute the lTRC over the full cycle, compute the solution with IC at x_out on [0,T0]
% model = LC_in_square('xinit', x_out, [0,0],T0);
% model.solve;


% Compute the boundary value of lTRC at the exit point, lTRCinit,
% This will be the initial condition for the lTRC since we will integrate the adjoint equation backward in time
lTRCinit0=[1,1]'; % the normal vector to the exit boundary of the wedge (y=-x)
dummy=0;
f10=model.LC_ODE(dummy,x_out',model.checkdomain(x_out)); % vector field at the exit point
rescale=f10'*lTRCinit0;
lTRCinit=-lTRCinit0'/(rescale); % the value for the lTRC at the exit point 

model.find_prc(lTRCinit); 
% model.plot_prc;          % visualize the lTRC result

% Compute lTRC(xin)* (xin_pert-xin)/eps, the first term in T1_above_wedge
vinit = [3.074e-10 -4.7892e-10]; % (xin_pert-xin)/eps, the IC for iSRC at the entry point into region I, obtained from 'shape_response_curve_piecewise_nu_plot'
T1_above_wedge_1=model.prc(end,:)*vinit'; 

% integral of the lTRC over the region above the wedge,
% there is a minus sign in front of the integral since time is backward
int=-trapz(model.prct,(wrev(model.yext(:,1))+wrev(model.yext(:,2))).*model.prc(:,1)+(-wrev(model.yext(:,1))+wrev(model.yext(:,2))).*model.prc(:,2));% time is backward,so the integral has the opposite sign 

T1_above_wedge_int=int; 
T1_above_wedge = T1_above_wedge_1 + T1_above_wedge_int; % relative shift in time in region I
nu_above_wedge=T1_above_wedge/T0_above_wedge; % relative change in frequency in the region above the wedge

disp('nu_above_wedge is')
disp(nu_above_wedge)

%%
figure
set(gcf,'Position',[50 800 800 360])
subplot(1,2,1)
plot(model0.yext(:,1),model0.yext(:,2),'k','linewidth',2)
hold on
plot(x_sigma_in,y,'g--','linewidth',2)
plot(x_sigma_out,y,'b--','linewidth',2)
text(0.78,0.95,'$x^{\rm in}$','Interpreter','latex','FontSize',18,'Color','g')
text(-0.85,0.95,'$x^{\rm out}$','Interpreter','latex','FontSize',18,'Color','b')
text(-0.3,0.6,'Region I','Interpreter','latex','FontSize',18,'Color','k')
text(-0.3,-0.5,'Region II','Interpreter','latex','FontSize',18,'Color','k')
text(0.45,0.3,'$\Sigma^{\rm in}$','Interpreter','latex','FontSize',18,'Color','g')
text(-0.7,0.3,'$\Sigma^{\rm out}$','Interpreter','latex','FontSize',18,'Color','b')
plot(x_in(1),x_in(2),'ko','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',18)
plot(x_out(1),x_out(2),'ko','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',18)
xlabel('$x$','interpreter','latex','fontsize',30)
ylabel('$y$','interpreter','latex','fontsize',30,'rot',0)
set(gca,'FontSize',18)
axis([-1.1 1.1 -1.1 1.1])
axis square

subplot(1,2,2)
plot(model.prct,model.prc(:,1:2),'linewidth',2)
xlim([0 model.tmax])
xlabel('$\rm time$','interpreter','latex','fontsize',30)
ylabel('$\eta^{\rm I}$','interpreter','latex','fontsize',30,'rot',0)
legend('x-direction','y-direction','AutoUpdate','off')
title('$\rm lTRC\ in\ region\ I$','interpreter','latex','fontsize',30)
% grid on
set(gca,'FontSize',18)
hold on
plot([T0_above_wedge T0_above_wedge], [-2 2],'b-.','linewidth',2)
plot([0 0], [-2 2],'g-.','linewidth',2)
text(0.03,-1.5,'$t_{\rm in}$','Interpreter','latex','FontSize',30,'Color','g')
text(1.55,-1.5,'$t_{\rm out}$','Interpreter','latex','FontSize',30,'Color','b')
model.draw_wall_contact_rectangles
