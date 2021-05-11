clear
clc
%************************************************
%             �������״
%************************************************
%     figure(1)
%     Picture=imread('�������ʾ��ͼ.png');
%     imshow(Picture);
%     title('the diagram of the section','visible','on','color','b');
%     disp('�밴��ʾ��������������״�Ļ������Ʋ�����')
%������״�Ļ������Ʋ���
% B=500;B1=255;B2=250;B3=250;H1=80;H2=1;H3=220;H4=1;H5=300;
% B=input('��������B��mm��������2500����');
% B1=input('��������B1��mm��������1900����');
% B2=input('��������B2��mm��������300����');
% B3=input('��������B3��mm��������600����');
% H1=input('������߶�H1��mm��������250����');
% H2=input('������߶�H2��mm��������250����');
% H3=input('������߶�H3��mm��������1050����');
% H4=input('������߶�H4��mm��������150����');
% H5=input('������߶�H5��mm��������300����');
width=300;height=450;%��λmm
% set (gca,'position',[0.2,0.2,0.8,0.8] );
figure(1)
line([0 width width 0 0],[0 0 height height 0],'linewidth',3)
axis([-100,400,-100,500])
% text(0,H1/2,'B');text(0,-x1,'B1');text(0,-x2-H3/2,'B2');text(0,-x5+H5/2,'B3');
% text(-B/2-H1/2,-H1/2,'H1');text(-B/2-H1/2,-x1-H2/2,'H2');text(-B/2-H1/2,-x2-H3/2,'H3');text(-B/2-H1/2,-x3-H4/2,'H4');text(-B/2-H1/2,-x4-H5/2,'H5');
title('the shape of the section','visible','on','color','b');
 
%************************************************
%             ���ַ��ֿ����ÿ�����
%************************************************
%N=input('�������������з�����ĿN������250����');%�ֿ����
N=2000;
H=height;%����
W=width;%����
for i=1:N
    A(i)=H/N*W;
end
Ac=H*W;
disp('---------------------------');
disp(['****����߶�Ϊ',num2str(H/1000),'m']);
disp(['****�������Ϊ',num2str(Ac/1000000),'m^2']);
disp('---------------------------');
A=fliplr(A);
 
%************************************************
%             ����������
%************************************************
%������������
disp('�������������������')
% fcuk=input('�������������ţ�����C40����40����');%�����������忹ѹǿ�ȱ�׼ֵ��MPa��
% steeltype=input('������ֽ����ͣ�1-HPB235 2-HRB335 3-HRB400 4-RRB400��������HRB335�ֽ�������2����');%�ֽ��ǿ��
% As=input('������ֽ������mm^2�������Ϊһ������������[10000 20000]����');%�ֽ������mm^2)
% dsteel=input('������ֽ�±�Ե�ľ��루mm��������Ϊһ����������������Ӧ������[30 1970]����');%�ֽ�����ȣ�mm��
 fcuk=30;steeltype=3;As=[3079 763];dsteel=[70 410];
%************************************************
%             Ӧ��Ӧ���ϵͼ
%************************************************
cu=0.0033;%����������ѹӦ��
sk=0.01;%�ֽ����Ӧ��
for i=1:1000
    cs(i)=cu/1000*i;
    cstress(i)=concretestress(cs(i),fcuk);
end
figure(3)
plot(cs,cstress,'-','linewidth',2)       %��������Ӧ��Ӧ���ϵͼ
xlabel('Ӧ��strain')
ylabel('Ӧ��stress(MPa)')
grid on
title('������Ӧ��Ӧ���ϵͼ');
 
 
for i=1:1000
    ts(i)=sk/1000*i;
    tstress(i)=steelstress(ts(i),steeltype);
end
figure(4)
plot(ts,tstress,'-','linewidth',2)       %�ֽ�Ӧ��Ӧ���ϵͼ
ylabel('Ӧ��stress(MPa)')
axis([0,0.015,0,400])
grid on
title('�ֽ�Ӧ��Ӧ���ϵͼ');
%��������
for i=1:100
    strain=0.005/100*i;
    kmin=(H-dsteel(2))/H;
    kmax=(H-dsteel(1))/H;
    for j=1:100
        k(j)=(kmax-kmin)/100*j;
        y0(j)=H-k(j)*H;
        fai(j)=strain/(k(j)*H);
        N(j)=axialforce(fai(j),y0(j),A,H,fcuk,steeltype,As,dsteel)
    end
   strain_save(i)=strain;
   save_N(i)=min(abs(N));
   index=find(abs(N)==min(min(abs(N))));
   save_fai(i)=fai(index);
   save_k(i)=k(index);
   save_y0(i)=H-save_k(i)*H;
   M_save(i)=moment(save_fai(i),save_y0(i),A,H,fcuk,steeltype,As,dsteel);
   down_ts_save(i)=save_fai(i)*(save_y0(i)-dsteel(1));%�������������ֽ��Ӧ��
   up_ts_save(i)=save_fai(i)*( save_k(i)*H+dsteel(2)-H)
   if (down_ts_save(i)>sk)
       break;
   end   
end
%�������
figure(5)
plot(save_fai,M_save,'-','linewidth',2)       %�ֽ�Ӧ��Ӧ���ϵͼ
ylabel('���(N.mm)')
grid on
title('�������ͼ');

step=size(strain_save);
for i=1:step(2)
    stestress(i)=steelstress(down_ts_save(i),steeltype);
end
figure(6)
plot(stestress,M_save,'-','linewidth',2)       %�ֽ�Ӧ��Ӧ���ϵͼ
ylabel('���(N.mm)')
grid on
title('����������ֽ�Ӧ��ͼ');


step=size(strain_save);
for i=1:step(2)
    constress(i)=concretestress(strain_save(i),fcuk);
end
    
figure(7)
plot(constress,M_save,'-','linewidth',2);
ylabel('���(N.mm)')
grid on
title('�������ѹ��Ե������Ӧ��ͼ');

%2���ֽ�Ӧ������
function gs=steelstress(ts,steeltype)
canshu=[210 300 330 360;210000 200000 200000 200000;];
fy=canshu(1,steeltype);
Es=canshu(2,steeltype);
ts0=fy/Es;
if ts<=ts0
    gs=Es*ts;
else
    gs=fy;
end
end
%3��������Ӧ������
function hc=concretestress(cs,fcuk)  
 canshu=[15 20 25 30 35 40 45 50 55 60 65 70 75 80;
7.2 9.6 11.9 13.8 16.7 19.1 21.1 23.1 25.3 27.5 29.7 31.8 33.8 35.9;
22000 25500 28000 30000 31500 32500 33500 34500 35500 36000 36500 37000 37500 38000;];
[mm,nn]=size(canshu);
for i=1:nn
    if fcuk==canshu(1,i)
        fc=canshu(2,i);
        Ec=canshu(3,i);
    end
end
n=2-(fcuk-50)/60;n=min(n,2);
cs0=0.002+0.5*(fcuk-50)/100000;cs0=max(cs0,0.002);
 
if cs<=cs0&&cs>=0
    hc=fc*(1-(1-cs/cs0)^n);
else if cs>cs0&&cs<0.0033
    hc=fc;
 else             %�ǻ���������ʱӦ��Ϊ0
        hc=0;
    end
end

 
 
% cscu=0.0033-(fcuk-50)/100000;cscu=min(cscu,0.0033);
% if cs<=cs0&&cs>=0
%     hc=fc*(1-(1-cs/cs0)^n);
% else if cs>cs0&cs<=cscu
%     hc=fc;
%     else if cs>cscu
%             error('��������Ӧ��ֵ̫��');
%         else             %�ǻ���������ʱӦ��Ϊ0
%             hc=0;
%         end
%     end
% end
end
%4���������㺯��

function N=axialforce(fai,y0,A,h,fcuk,steeltype,As,dsteel)
          %mΪT�ν�����Ե��������nΪT�ν�����Եһ�¾��ν���������
Nc=0;
m=length(A);
for i=1:m
    csi=fai*(h/m*(i-0.5)-y0);   %��Եÿһ�������Ļ�������Ӧ��
    hci=concretestress(csi,fcuk);
    Nc=Nc+hci*A(i);
end
Ns=0;
n=length(As);
for i=1:n
    ts=fai*(y0-dsteel(i)); %�ֽ�Ӧ��
    gs=steelstress(abs(ts),steeltype);
    Ns=Ns+gs*As(i)*sign(ts);
end
N=Nc-Ns;
end
%5����ؼ��㺯��
function M=moment(fai,y0,A,h,fcuk,steeltype,As,dsteel)   
      
Mc=0;
m=length(A);
for i=1:m
    csi=fai*(h/m*(i-0.5)-y0);   %��Եÿһ�������Ļ�������Ӧ��
    hci=concretestress(csi,fcuk);
    Mc=Mc+hci*A(i)*(h/m*(i-0.5)-y0);
end
Ms=0;
n=length(As);
for i=1:n
    ts=fai*(y0-dsteel(i)); %�ֽ�Ӧ��
    gs=steelstress(abs(ts),steeltype);
    Ms=Ms+gs*As(i)*abs(y0-dsteel(i));
end
M=Mc+Ms;
end
%6����������㺯��
function [y0] = Calaxis(A,h)
%�����к��ᣬy0Ϊ�к��ᵽ����׶˵ľ���
m=length(A);
y1=0;
y2=h;
while(y2-y1>0.00000001)    
    
    N1=0;
    N2=0;
    for i=1:m
        N1=N1+A(i)*(h/m*(i-0.5)-y1);
        N2=N2+A(i)*(h/m*(i-0.5)-y2);
    end
    y0=(y1+y2)/2;
    N0=0;
    for i=1:m
        N0=N0+A(i)*(h/m*(i-0.5)-y0);
    end
    if N0==0
        break
    else if N0*N1>0
            y1=y0;
        else
            y2=y0;
        end
    end
end
end

