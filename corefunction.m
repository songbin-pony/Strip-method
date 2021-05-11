function mfai=calmfai(b,h,t,w,a,fcuk,fc,ec,sigmaq,es)

% b��h��t��wΪT�ͽ�����״����λΪmm��aΪ�ֽ��������λΪmm2��fcukΪ��������ѹǿ�ȱ�׼ֵ,��λΪMpa�� fcΪ���������Ŀ�ѹǿ�ȣ�������ǿ�ȣ�,��λΪMPa�� ecΪ����������ģ��,��λΪN/mm2�� sigmaqΪ�ֽ�����Ӧ��,��λΪMPa�� esΪ�ֽ��ģ��,��λΪN/mm2

tic %��������ʱ�俪ʼ

clc %����

global stripinfo rebara H B Q F Fcuk Ec Es barstrain;

rebara=a;

H=h;Q=sigmaq;Ec=ec;B=b;Es=es;F=fc;Fcuk=fcuk;

stripinfo(1,1)=0; %����������Ϣ��stripinfo(,1)Ϊ����λ�ã���y��

%stripinfo(,2)Ϊ�������

for i=1:50

stripinfo(i+1,1)=stripinfo(i,1)+b/50;

stripinfo(i,2)=w*b/50;

end

for i=50:fix(h*50/b)

stripinfo(i+1,1)=stripinfo(i,1)+b/50;

stripinfo(i,2)=t*b/50;

end

curfai=0;

deltfai=0.0001; %�Ƕ�����

for i=1:10000

disp('step')

disp(i)

curcent(i)=calcentroid(curfai,H); %����������

fai(i)=curfai;

moment(i)=calmoment(curcent(i),curfai); %�������

maxstrain=curfai*curcent(i)*1e-3; %�������ѹӦ��

if maxstrain>=0.0033

disp('concrete failure') %��ѹ���������ﵽ����ѹӦ�䣬�ƻ�

break

end

limbarstrain=Q*5/Es; %�ֽ����Ӧ��

if barstrain>limbarstrain

disp('reforced bar failure') %�ֽ�ﵽ������Ӧ�����ƻ�

break

end

curfai=curfai+deltfai; %�Ƕ�����

end

plot(fai,moment); %��ͼ

xlabel('�ա�1e3'),ylabel('M(N)');

hold on;

grid on;

toc %��������ʱ�����

function curcent=calcentroid(fai,h) %�ö��ַ�����������λ�ú���

y0=0;y2=h; %���ڴ��乹�����������ڽ����ڣ����½�ȡ���½���

y1=(y0+y2)/2;

while abs(y2-y0)/h>1e-5 %�����ᾫ��

f0=calaxialforce(y0,fai); %��������

f1=calaxialforce(y1,fai);

f2=calaxialforce(y2,fai);

if f0*f1>=0 & f1*f2<=0

y0=y1;

y1=(y0+y2)/2;

end

if f0*f1<=0 & f1*f2>=0

y2=y1;

y1=(y0+y2)/2;

end

end

curcent=(y0+y2)/2;

function axialforce=calaxialforce(y,fai) %������������

global stripinfo rebara B H Ec barstrain stripforce;

conforce=0;

for i=1:fix(H*50/B)

stripstrain(i)=(y-stripinfo(i,1))*fai*1e-3; %��������Ӧ��

if stripstrain(i)<=-0.0001

break

end

if stripstrain(i)>=0

stripstress=calstress(stripstrain(i)); %��������Ӧ��

end

if stripstrain(i)<0&stripstrain(i)>=-0.0001

stripstress=stripstrain(i)*Ec;

end

stripforce(i)=stripstress*stripinfo(i,2);

conforce=stripforce(i)+conforce;%�������������е���

end

barstrain=fai*(H-y-20)*1e-3; %�ֽ�Ӧ�䣬��������Ϊ20mm

rebarstress=calrebarstress(barstrain); %�ֽ�Ӧ��

axialforce=conforce-rebara*rebarstress; %������

function stress=calstress(strain) %���ݻ�����������ϵ���������ѹӦ������

global F Fcuk;

if Fcuk>=50

n=2-1/60*(Fcuk-50);

else Fcuk=50;n=2;

end

ypsl=0.002+0.5*(Fcuk-50)*1e-5;

if strain<=ypsl

stress=F*(1-(1-strain/ypsl)^n);

end

if strain>ypsl

stress=F;

end

function calrebarstress=calrebarstress(barsrtain) %����ֽ�Ӧ��

global Es Q;

calrebarstress=barsrtain*Es;

if calrebarstress>Q

calrebarstress=Es/100*(barsrtain-Q/Es)+Q;

end

function moment=calmoment(y,fai) %������غ���

conmoment=0;

global stripinfo H rebara B stripforce Ec;

for i=1:fix(y*50/B)

conmoment=conmoment+stripforce(i)*(y-stripinfo(i,1));

end

tenmoment=0;

for i=fix(y*50/B):fix(H*50/B)

tenstrain=(stripinfo(i,1)-y)*fai*1e-3;

if tenstrain>0.0001

break

end

tenstress=tenstrain*Ec;

tenmoment=tenmoment-stripforce(i)*(stripinfo(i,1)-y);

%�������������ṩ���

end

barstrain=fai*(H-y-20)*1e-3;

barmoment=rebara*calrebarstress(barstrain)*(H-y-20); %�ֽ��ṩ���

moment=conmoment+barmoment+tenmoment;