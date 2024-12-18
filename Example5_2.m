clear all;
DAT=xlsread('dry air table.xlsx');
T=DAT(:,1);Cp=DAT(:,2);h=DAT(:,3);s=DAT(:,4);Pr=DAT(:,5);
T_1=288;P_1=101.35;P_5=101.35;;n_c=0.87;n_GT=0.89;n_PT=0.89;
h_1=interp1(T,h,T_1,'spline');
Pr_1=interp1(T,Pr,T_1,'spline');
for T_3=1200:200:1800
    i=0;
    for PR=1:1:30
        i=i+1;
        Pr_2(i)=Pr_1*PR;
        h_2s(i)=interp1(Pr,h,Pr_2(i),'spline');
        w_cs(i)=h_2s(i)-h_1;
        w_ca(i)=w_cs(i)/n_c;
        h_2a(i)=h_1+w_ca(i);
        h_3=interp1(T,h,T_3,'spline');
        Pr_3=interp1(T,Pr,T_3,'spline');
        q_in=h_3-h_2a(i);
        w_GTa(i)=w_ca(i);
        w_GTs(i)=w_GTa(i)/n_GT;
        h_4s(i)=h_3-w_GTs(i);
        T_4s(i)=interp1(h,T,h_4s(i),'spline');
        Pr_4s(i)=interp1(h,Pr,h_4s(i),'spline');
        P_3(i)=P_1*PR;
        P_4(i)=P_3(i)*Pr_4s(i)/Pr_3;
        h_4a(i)=h_3-w_GTa(i);
        T_4a(i)=interp1(h,T,h_4a(i),'spline');
        Pr_4a(i)=interp1(h,Pr,h_4a(i),'spline');
        Pr_5s(i)=Pr_4a(i)*(P_5/P_4(i));
        h_5s(i)=interp1(Pr,h,Pr_5s(i),'spline');
        T_5s(i)=interp1(Pr,T,Pr_5s(i),'spline');
        w_PTs(i)=h_4a(i)-h_5s(i);
        w_PTa(i)=w_PTs(i)*n_PT;
        w_net(i)=w_PTa(i);
        A(i)=w_net(i);
    end
    PR=1:1:30;
    hold on;
    plot(PR,A);
    
end
newcolors={'r','g','b','c'};
colororder(newcolors);
legend('w_net1','w_net2','w_net3','w_net4');