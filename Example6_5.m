clear all;
DAT=xlsread('dry air table.xlsx');
T=DAT(:,1);Cp=DAT(:,2);h=DAT(:,3);s=DAT(:,4);Pr=DAT(:,5); %dry air table
O2=xlsread('O2 table.xlsx');
TO2=O2(:,1);CpO2=O2(:,2);hO2=O2(:,3);sO2=O2(:,4);PrO2=O2(:,6); %O2 table
Co2=xlsread('Co2 table.xlsx');
TCo2=Co2(:,1);CpCo2=Co2(:,2);hCo2=Co2(:,3);sCo2=Co2(:,4);PrCo2=Co2(:,6); %Co2 table
H2O=xlsread('H2O table.xlsx');
TH2O=H2O(:,1);CpH2O=H2O(:,2);hH2O=H2O(:,3);sH2O=H2O(:,4);PrH2O=H2O(:,6); %H2O table
T_1=288;P_1=101.35;n_c=0.87;n_GT=0.89;n_PT=0.90;m_cdot=50.5;PRF=1.38;n_fc=0.86;n_fn=1;alpha=6; %variable
h_1f=interp1(T,h,T_1,'spline');Pr_1f=interp1(T,Pr,T_1,'spline');
Pr_2fs=Pr_1f*PRF;
h_2fs=interp1(Pr,h,Pr_2fs,'spline');
w_fa=(h_2fs-h_1f)/n_fc;
h_2fa=h_1f+w_fa;
Pr_2fa=interp1(h,Pr,h_2fa,'spline');
Pr_5fs=Pr_2fa/PRF;
h_5fs=interp1(Pr,h,Pr_5fs,'spline');
V_5f=sqrt(2*(h_2fa-h_5fs)*1000);
for T_3=1600%1400:200:2000
    i=0;
    for PR=35.4%10:1:60
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
        f(i)=114.2336/(X(i)*28.965); %fuel air ratio
        q_in(i)=44422*f(i);
        w_GTabar(i)=(w_ca(i)+alpha*w_fa)*28.965*X(i);
        w_GTsbar(i)=w_GTabar(i)/n_GT;
        H_3(i)=8*hCo2_3+9*hH2O_3+X(i)*28.965*h_3-12.5*hO2_3;
        H_4s(i)=H_3(i)-w_GTsbar(i);
        a=300;b=2500;
        tol=20;
        while abs(tol)>0.001
            m=(a+b)/2;
            hCo2_m=interp1(TCo2,hCo2,m,'spline');hH2O_m=interp1(TH2O,hH2O,m,'spline');hO2_m=interp1(TO2,hO2,m,'spline');h_m=interp1(T,h,m,'spline');
            eq=8*hCo2_m+9*hH2O_m+X(i)*28.965*h_m-12.5*hO2_m-H_4s(i);
            hCo2_a=interp1(TCo2,hCo2,a,'spline');hH2O_a=interp1(TH2O,hH2O,a,'spline');hO2_a=interp1(TO2,hO2,a,'spline');h_a=interp1(T,h,a,'spline');
            eqa=8*hCo2_a+9*hH2O_a+X(i)*28.965*h_a-12.5*hO2_a-H_4s(i);
            hCo2_b=interp1(TCo2,hCo2,b,'spline');hH2O_b=interp1(TH2O,hH2O,b,'spline');hO2_b=interp1(TO2,hO2,b,'spline');h_b=interp1(T,h,b,'spline');
            eqb=8*hCo2_b+9*hH2O_b+X(i)*28.965*h_b-12.5*hO2_b-H_4s(i);
            if eq*eqa<0
                b=m;
            elseif eq*eqb<0
                a=m;
            end
            tol=eq;
        end
        T_4s(i)=m;
        sCo2_3=interp1(TCo2,sCo2,T_3,'spline');sH2O_3=interp1(TH2O,sH2O,T_3,'spline');sO2_3=interp1(TO2,sO2,T_3,'spline');s_3=interp1(T,s,T_3,'spline');
        sCo2_4s(i)=interp1(TCo2,sCo2,T_4s(i),'spline');sH2O_4s(i)=interp1(TH2O,sH2O,T_4s(i),'spline');sO2_4s(i)=interp1(TO2,sO2,T_4s(i),'spline');s_4s(i)=interp1(T,s,T_4s(i),'spline');
        syms x;
        eqn=8*sCo2_4s(i)+9*sH2O_4s(i)+X(i)*28.965*s_4s(i)-12.5*sO2_4s(i)-(8*sCo2_3+9*sH2O_3+X(i)*28.965*s_3-12.5*sO2_3)==8.314*(8+9+X(i)-12.5)*log(x/P_3(i));
        x=solve(eqn,x);
        P_4(i)=double(x);
        H_4a(i)=H_3(i)-w_GTabar(i);
        h_4a(i)=H_4a(i)/(X(i)*28.965);
        a=300;b=2500;
        tol=20;
        while abs(tol)>0.001
            m=(a+b)/2;
            hCo2_m=interp1(TCo2,hCo2,m,'spline');hH2O_m=interp1(TH2O,hH2O,m,'spline');hO2_m=interp1(TO2,hO2,m,'spline');h_m=interp1(T,h,m,'spline');
            eq=8*hCo2_m+9*hH2O_m+X(i)*28.965*h_m-12.5*hO2_m-H_4a(i);
            hCo2_a=interp1(TCo2,hCo2,a,'spline');hH2O_a=interp1(TH2O,hH2O,a,'spline');hO2_a=interp1(TO2,hO2,a,'spline');h_a=interp1(T,h,a,'spline');
            eqa=8*hCo2_a+9*hH2O_a+X(i)*28.965*h_a-12.5*hO2_a-H_4a(i);
            hCo2_b=interp1(TCo2,hCo2,b,'spline');hH2O_b=interp1(TH2O,hH2O,b,'spline');hO2_b=interp1(TO2,hO2,b,'spline');h_b=interp1(T,h,b,'spline');
            eqb=8*hCo2_b+9*hH2O_b+X(i)*28.965*h_b-12.5*hO2_b-H_4a(i);
            if eq*eqa<0
                b=m;
            elseif eq*eqb<0
                a=m;
            end
            tol=eq;
        end
        T_4a(i)=m;
        sCo2_4a(i)=interp1(TCo2,sCo2,T_4a(i),'spline');sH2O_4a(i)=interp1(TH2O,sH2O,T_4a(i),'spline');sO2_4a(i)=interp1(TO2,sO2,T_4a(i),'spline');s_4a(i)=interp1(T,s,T_4a(i),'spline');
        P_5=P_1;
        a=300;b=2500;
        tol=20;
        while abs(tol)>0.001
            m=(a+b)/2;
            sCo2_m=interp1(TCo2,sCo2,m,'spline');sH2O_m=interp1(TH2O,sH2O,m,'spline');sO2_m=interp1(TO2,sO2,m,'spline');s_m=interp1(T,s,m,'spline');
            eq=8*sCo2_m+9*sH2O_m+X(i)*28.965*s_m-12.5*sO2_m-(8*sCo2_4a(i)+9*sH2O_4a(i)+X(i)*28.965*s_4a(i)-12.5*sO2_4a(i))-8.314*(8+9+X(i)-12.5)*log(P_5/P_4(i));
            sCo2_a=interp1(TCo2,sCo2,a,'spline');sH2O_a=interp1(TH2O,sH2O,a,'spline');sO2_a=interp1(TO2,sO2,a,'spline');s_a=interp1(T,s,a,'spline');
            eqa=8*sCo2_a+9*sH2O_a+X(i)*28.965*s_a-12.5*sO2_a-(8*sCo2_4a(i)+9*sH2O_4a(i)+X(i)*28.965*s_4a(i)-12.5*sO2_4a(i))-8.314*(8+9+X(i)-12.5)*log(P_5/P_4(i));
            sCo2_b=interp1(TCo2,sCo2,b,'spline');sH2O_b=interp1(TH2O,sH2O,b,'spline');sO2_b=interp1(TO2,sO2,b,'spline');s_b=interp1(T,s,b,'spline');
            eqb=8*sCo2_b+9*sH2O_b+X(i)*28.965*s_b-12.5*sO2_b-(8*sCo2_4a(i)+9*sH2O_4a(i)+X(i)*28.965*s_4a(i)-12.5*sO2_4a(i))-8.314*(8+9+X(i)-12.5)*log(P_5/P_4(i));
            if eq*eqa<0
                b=m;
            elseif eq*eqb<0
                a=m;
            end
            tol=eq;
        end
        T_5s(i)=m;
        hCo2_5s(i)=interp1(TCo2,hCo2,T_5s(i),'spline');hH2O_5s(i)=interp1(TH2O,hH2O,T_5s(i),'spline');hO2_5s(i)=interp1(TO2,hO2,T_5s(i),'spline');h_5s(i)=interp1(T,h,T_5s(i),'spline');
        H_5s(i)=8*hCo2_5s(i)+9*hH2O_5s(i)+X(i)*28.965*h_5s(i)-12.5*hO2_5s(i);
        h_5s(i)=H_5s(i)/(X(i)*28.965);
        V_5(i)=sqrt(2*(h_4a(i)-h_5s(i))*1000);
        Q_indot(i)=q_in(i)*m_cdot;
        m_fdot(i)=m_cdot*f(i);
        w_out(i)=((1+f(i))*V_5(i)^2+alpha*V_5f^2)/(2*1000);
        W_out(i)=m_cdot*w_out(i);
        thrust(i)=m_cdot*((1+f(i))*V_5(i)+alpha*V_5f);
        n_th(i)=W_out(i)*100/Q_indot(i);
        TSFC(i)=m_fdot(i)*10^6/thrust(i);
        thrust_frome_core(i)=(1+f(i))*V_5(i)/thrust(i)*100;
    end
    PR=10:1:60;
    figure(1);
    subplot(3,2,1);
    plot(PR,n_th);
    xlabel('PR');
    ylabel('n_t_h');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
    subplot(3,2,2);
    plot(PR,TSFC);
    xlabel('PR');
    ylabel('TSFC(mg/N*s)');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
    subplot(3,2,3);
    plot(PR,w_out);
    xlabel('PR');
    ylabel('w_n_e_t');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
    subplot(3,2,4);
    plot(PR,thrust);
    xlabel('PR');
    ylabel('Thrust(N)');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
    subplot(3,2,[5,6]);
    plot(PR,thrust_frome_core);
    xlabel('PR');
    ylabel('thrust frome the core');
    newcolors={'r','g','b','k'};
    colororder(newcolors);
    labels={'1400','1600','1800','2000'};
    legend(labels,'Location','northeast');
    hold on;
end
sgtitle('real combustion');