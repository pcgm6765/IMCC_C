clear all;
DAT=xlsread('dry air table.xlsx');
T=DAT(:,1);Cp=DAT(:,2);h=DAT(:,3);s=DAT(:,4);Pr=DAT(:,5); %dry air table
O2=xlsread('O2 table.xlsx');
TO2=O2(:,1);CpO2=O2(:,2);hO2=O2(:,3);sO2=O2(:,4);PrO2=O2(:,6); %O2 table
Co2=xlsread('Co2 table.xlsx');
TCo2=Co2(:,1);CpCo2=Co2(:,2);hCo2=Co2(:,3);sCo2=Co2(:,4);PrCo2=Co2(:,6); %Co2 table
H2O=xlsread('H2O table.xlsx');
TH2O=H2O(:,1);CpH2O=H2O(:,2);hH2O=H2O(:,3);sH2O=H2O(:,4);PrH2O=H2O(:,6); %H2O table
T_1=288;P_1=101.35;P_5=101.35;n_c=0.87;n_GT=0.89;n_PT=0.89;m_dot=0.453; %variable
for T_3=1400:200:2000
    i=0;
    for PR=10:1:60
        i=i+1;
        P_2(i)=PR*P_1;P_3(i)=PR*P_1;
        Pr_1=interp1(T,Pr,T_1,'spline');h_1=interp1(T,h,T_1,'spline');
        Pr_2(i)=Pr_1*PR;
        h_2s(i)=interp1(Pr,h,Pr_2(i),'spline');
        w_cs(i)=h_2s(i)-h_1;w_ca(i)=w_cs(i)/n_c;h_2a(i)=h_1+w_ca(i);T_2a(i)=interp1(h,T,h_2a(i),'spline'); %1->2
        hCo2_3=interp1(TCo2,hCo2,T_3,'spline');hH2O_3=interp1(TH2O,hH2O,T_3,'spline');hO2_3=interp1(TO2,hO2,T_3,'spline');h_3=interp1(T,h,T_3,'spline');h_2a(i)=interp1(T,h,T_2a(i),'spline');
        syms x;
        eqn=8*hCo2_3+9*hH2O_3+x*h_3*28.965-12.5*hO2_3==1*(-249957)+x*h_2a(i)*28.965;
        x=solve(eqn,x);
        X(i)=double(x); %find dry air's mole
        excess_air(i)=(X(i)-59.67)/59.67*100; % %excess air
        f(i)=114.2336/(X(i)*28.9665); %fuel air ratio
        q_in(i)=44422*f(i);
        w_GTa(i)=w_ca(i)/(1+f(i));
        w_GTs(i)=w_GTa(i)/n_GT;
        h_4s(i)=h_3-w_GTs(i);
        Pr_4s(i)=interp1(h,Pr,h_4s(i),'spline');
        Pr_3=interp1(T,Pr,T_3,'spline');
        P_4(i)=P_3(i)*Pr_4s(i)/Pr_3;
        h_4a(i)=h_3-w_GTa(i);
        Pr_4a(i)=interp1(h,Pr,h_4a(i),'spline');
        Pr_5s(i)=Pr_4a(i)*P_5/P_4(i);
        h_5s(i)=interp1(Pr,h,Pr_5s(i),'spline');
        w_PTa(i)=(h_4a(i)-h_5s(i))*n_PT*(1+f(i));
        n_th(i)=w_PTa(i)*100/q_in(i);
        SFC(i)=f(i)*3600/w_PTa(i);
        HR(i)=q_in(i)*3600/w_PTa(i);
    end
    PR=10:1:60;
    figure(1);
    subplot(2,2,1);
    plot(PR,n_th);
    xlabel('PR');
    ylabel('n_t_h');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
    subplot(2,2,2);
    plot(PR,HR);
    xlabel('PR');
    ylabel('HR(kJ/kwh)');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
    subplot(2,2,3);
    plot(PR,SFC);
    xlabel('PR');
    ylabel('SFC(kg/kwh)');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
    subplot(2,2,4);
    plot(PR,w_PTa);
    xlabel('PR');
    ylabel('w_n_e_t');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
end
sgtitle('air equivalent VS. real combustion');