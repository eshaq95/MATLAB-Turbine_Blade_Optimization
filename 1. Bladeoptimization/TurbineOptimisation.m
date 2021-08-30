
%Author: Eshaq Rahmani
% Wind Turbine Optimisation 1

% This script takes input variables of maximum radius, wind speed, rotor
% rpm, number of blades, number of blade elements, generator efficiency and
% the stall angle, maximum lift coefficient and the maximum lift over drag
% ratio. 
%
% The script will then return optimal values for the attack angle, chord 
%length and which aerofoil is to be used for each element of the blade. 
%The power coefficient for these paramiters is returned as is the net 
%power of the turbine. 

%% Notes for Nathan,
% I belive this method is fundementally flawed for radii above, or 
% approaching 2m, but this will obviously be fine for our turbine
%
% To acheive a Tip Speed Ratio of more than 2 is pretty much impossible if
% our turbine is to have a power output even remotley close to the one uwe
% requires
%
% I wouldnt believe the thrust, axial moment or angular momentum numbers
% too far as they require the convergence of a to a concistent value which
% i have, as yet, struggled to implememnt. The aerofoil to be used is
% determined only by using the optimal angle of attack, as such the
% aerofoil selected will not consider the lift or drag values associated
% with it and this will obviously effect the aerofoils you choose to
% include in the design. as long as you have 5-10 different aerofoils, each
% within 2 degrees of the angle of attack of one another it should be a
% reasonable assumption to assume that the lift coefficient does not vary
% significantly from the maximum value stated on aerofoil db. 
% 
% ALL ANGLES ARE DISPLAYED AND INPUT IN DEGREES AND THE SCRIPT CONVERTS
% THEM TO RADIANS FOR CALCULATIONS
%
% The colum "Blade Angle" and "(Relative) Wind Angle" are defined from parralel to the
% blades being 0 degrees. 
%
% The "attack angle" is the angle of attack, or the angle between the
% relative wind direction and the blade angle 
% 
% "Chord Length" is obviously chord length of the aerofoil 
%
% Aerofoil used is the number of the aerofoil in the list of the aerofoil
% from the left in the matrix you define
%
% WHEN YOU DEFINE YOUR AREOFOILS YOU MUST DEFINE THEM IN IN INCREASING
% ORDER OF ATTACK




%% Clears Command Window and Stored Variables
clc 
clear
format long

%% Variable Definition

rho=1.2;             %defines the density of air in kg/m^3
RMax=0.2;            %defines the maximum radius of the blades of the turbine
RMin=0.0;           %defines the radius at which the hub starts
n=3;                 %defines the number of blades on the turbine
rpm=2500;            %defines the rpm of the rotor at analysed windpeed
windSpeed=12;        %defines the windpeed in m/s
elements=100;        %defines the number of elements in the blade to be analysed
%Aerofoil names [RAF 32, GOE 198, FX61-168, FX 63-110, FX 63-100, GOE 174, Eiffel 385, GOE 282, GOE 682, GOE 650, Eppler 433, GOE 414, HQ3.5/14, GOE 532, GOE 398, NACA 6412, Clark YM-15, Eppler 558]
attackAngle = 4*pi/180;%[3.5, 5.0, 6, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10, 10.5, 11.5, 12, 12.5, 13, 14, 14.5]*pi/180;   %defines stall angle for a variety of aerofoils
ClMax = 1.051;%[1.607, 1.597, 1.573, 1.578, 1.556, 1.559, 1.609, 1.624, 1.605, 1.591, 1.607, 1.595, 1.595, 1.620, 1.614, 1.622, 1.597, 1.605];              %defines the stall lift for the aerofoils
MaxLoverD= 1/0.004;%[84.6, 52.0, 96.3, 84.1, 80.6, 69.1, 63.1, 55.4, 65.4, 72.2, 76.8, 52.1, 63.1, 53.1, 53.8, 55.6, 69.7, 60.0];          %defines the maximum lift over drag coefficient of the aerofoils at the stall angle
cumcoeff=0;                     %Sets Power Coefficient To Zero
tipSpeed=RMax*2*pi*rpm/60;      %calculates the tip speed in m/s
TSR=tipSpeed/windSpeed;         %calculates tip speed ratio
dr=(RMax-RMin)/elements;        %calculates the change in r for each element in the blade 
maxWindSpeed = 20;              %defines the maximum wind speed the turbine will generate at 
generatorEfficiency = 1;        %defines the efficiency of the generator

%% Determining Angles of Each Section

for i=1:elements 
r(i)=RMin+(dr*(i-0.5));                                           %calculates the average radius of the element being optimised
elementSpeed(i)=r(i)*pi*rpm/30;                                   %calculates the relative speed of the wind onto the element being analysed 
speedRatio(i)=((TSR*r(i))/RMax);                                  %calculates the relative tip speed ratio of the element being analysed
WindAngle(i)=atan(windSpeed/elementSpeed(i));                     %calculates the relative wind angle from horizontal
OptimalPhi(i) = (2/3)*atan(1/speedRatio(i));                      %calculates the optimal relative wind angle from horizontal
optimalAngleElement(i)=OptimalPhi(i)-attackAngle(1);              %calculates the optimal angle of the element from horizontal
optimalAttackAngle(i)= OptimalPhi(i)-optimalAngleElement(i);      %calculates the angle of attack of the blade required
end

%% Deteremining the Best Aerofoil to use for each section

for i=1:(length(ClMax))           %A for loop to define the intermediate values of the aerofoil angles 
    if i==1
        ave(i)=-Inf;
        ave((length(ClMax))+1)=+Inf;
    else
        ave(i)=[attackAngle(i)+attackAngle(i-1)]/2;
    end
end
I=discretize(optimalAttackAngle,ave);   %Returns an array I of the index values for the best aerofoil to use for each section

%% Dimension Calculation for Crossection

for i=1:elements
elementTipLossFactor(i)= (2/pi)*acos(exp((-(n/2)*(1-(r(i)/RMax)))/((r(i)/RMax)*sin(OptimalPhi(i)))));        %calculates the tip loss factor for element being analysed
chordLength(i)= ((8*pi*r(i)*elementTipLossFactor(i)*sin(OptimalPhi(i)))/(n*ClMax(I(i))))...                    %calculates the optimal chord length for the element being analysed
                *(cos(OptimalPhi(i))-(speedRatio(i)*sin(OptimalPhi(i))))...                               
                /(sin(OptimalPhi(i))+(speedRatio(i)*cos(OptimalPhi(i))));
solidity(i) = (n*chordLength(i))/(2*pi*r(i));                                                                %calculates the solidity of the element being analysed
a(i)=1/((1+(4*elementTipLossFactor(i)*sin(OptimalPhi(i))*sin(OptimalPhi(i)))/(solidity(i)*ClMax(I(i))*cos(OptimalPhi(i)))));    %calculates the axial induction factor
aDash(i)=1/((4*elementTipLossFactor(i)*cos(OptimalPhi(i))/(solidity(i)*ClMax(I(i))))-1);                     %calculates the angular induction factor
end 

%% calculates the thrust coefficient of each part of the blade

% for i=1:1
% counter=0;
% 
for i=1:elements
CTr(i)=(solidity(i)*(1-a(i))^2)...
    *(ClMax(I(i))*cos(OptimalPhi(i))+((ClMax(I(i))/MaxLoverD(I(i)))*sin(OptimalPhi(i))))...
    /((sin(OptimalPhi(i)))^2);
end
%
% % Fixing a
% 
% for i=1:elements
% aold(i)=a(i);
%   
% if CTr(i)<0.96% && CTr(i)>0.88
%         a(i) = (1/elementTipLossFactor(i))*[0.143+sqrt((0.0203-0.6427*(0.88-CTr(i))))]; 
% elseif CTr(i)>0.96
%         a(i)=1/((1+(4*elementTipLossFactor(i)*sin(OptimalPhi(i)))/(solidity(i)*ClMax(I(i))*cos(OptimalPhi(i)))));
% end
% 
% if abs(a(i)-aold(i))<0. 01
% %          counter=counter+1;
%    
% end 
% 
% % if counter >elements
% %     break
% % end
% end
% end

for i=1:elements
   if (CTr(i))<0 || (CTr(i)^2)<0
    CTr(i)=0
   end 
end

%% A for loop to calculate the power coefficeint of each element and the blade in total

for i=1:elements
if i==1
PowerCoeff(i)= ((8*(speedRatio(i)))/(TSR^2))*elementTipLossFactor(i)*(sin(OptimalPhi(i)))*(sin(OptimalPhi(i)))...     %calculates the power coefficient for the first element in the blade
               *((cos(OptimalPhi(i)))-speedRatio(i)*sin(OptimalPhi(i)))...
               *(((sin(OptimalPhi(i)))+speedRatio(i)*cos(OptimalPhi(i))))...
               *(1-((1/MaxLoverD(I(i)))*cot(OptimalPhi(i))))*speedRatio(i)^2;
elseif i>1
PowerCoeff(i)= ((8*(speedRatio(i)-speedRatio(i-1)))/(TSR^2))*elementTipLossFactor(i)*(sin(OptimalPhi(i)))*(sin(OptimalPhi(i)))...   %calculates the power coefficent for every other element 
               *((cos(OptimalPhi(i)))-speedRatio(i)*sin(OptimalPhi(i)))...
               *(((sin(OptimalPhi(i)))+speedRatio(i)*cos(OptimalPhi(i))))...
               *(1-((1/MaxLoverD(I(i)))*cot(OptimalPhi(i))))*speedRatio(i)^2;
end
cumcoeff=cumcoeff+PowerCoeff(i);     %adds the power coefficent for the elemnt being analysed to the total
end

%% calculates power, thrust and angular moment (will be fine if the value for a calculated is fixed)

Power=.5*1.2*pi*(RMax^2-RMin^2)*cumcoeff*windSpeed^3*generatorEfficiency;      %calculates the total power produced by the turbine
for i=1:elements
    
    dT(i) = 4*elementTipLossFactor(i)*a(i)*(1-a(i))*0.5*rho*2*pi*dr*windSpeed^2;
    dTorque(i)=4*elementTipLossFactor(i)*aDash(i)*(1-a(i))*0.5*windSpeed*(pi*rpm/30)*(r(i)^2)*2*pi*dr;
    reynolds(i)=rho*(sqrt(elementSpeed(i)^2+windSpeed^2))*chordLength(i)/(1.81*10^-5)
end 

%% Returns Results to User

fprintf('Element    Radius(m)   Optimal Element Angle   Attack Angle    AerofoilUsed   Optimal Phi    Wind Angle   Chord Length(m)   Solidity   AngularIF   AxialIF       CTr\n')
for i=1:elements
    fprintf('   %4d     %8.4f             %11.4f       %8.4f      %10d      %8.4f      %8.4f          %8.4f   %8.4f    %8.4f  %8.4f   %8.4f   %.15f\n'...%-------------------------------------------------------------------------------\n'
        , i, r(i), optimalAngleElement(i)*180/pi, optimalAttackAngle(i)*180/pi, I(i), OptimalPhi(i)*180/pi, WindAngle(i)*180/pi, chordLength(i), solidity(i), aDash(i), a(i), CTr(i), PowerCoeff(i))
end

fprintf('\nThe power coefficient was found to be %.3f for a tip speed ratio of %.3f and the power output is %.2fW\nThe total thrust %8.4fN\nThe torque is %8.4fNm\n\n', cumcoeff, TSR, Power, sum(dT), sum(dTorque));

%% Graphs The Results
% Calculates and plots the twist distribution 
figure (1)
plot(r/RMax,optimalAngleElement*180/pi)
xlim([0 1])
title('Twist Distribution Vs Radius')
xlabel('Radius/MaxRadius')
ylabel('Relative Twist')

%Calculates and plots the Chord Length Distribution 
figure (2)
plot(r/RMax, chordLength)
xlim([0 1])
title('Chord Length Vs Radius')
xlabel('Radius/MaxRadius')
ylabel('Chord Length')

%calculates and plots the thrust coefficient 
figure (3)
plot(r/RMax,CTr)
xlim([0 1])
title ('Thrust Coefficient Vs Radius')
xlabel('Radius/MaxRadius')
ylabel('Thrust Coefficient')

%plots power output against windsped
figure (4)
syms x
fplot((.5*1.2*pi*RMax^2*cumcoeff*x^3*generatorEfficiency), [0 maxWindSpeed])
title ('Power Vs Windspeed')
xlabel('Wind Speed (m/s)')
ylabel('Power (W)')

figure (5)
plot(r/RMax,dT)
xlim([0 1])
title ('Element Thrust Vs Radius')
xlabel('Radius/MaxRadius')
ylabel('Axial Moment')

figure (6)
plot(r/RMax, dTorque)
xlim([0 1])
title ('Element Torque Vs Radius')
xlabel('Radius/MaxRadius')
ylabel('Angular Momentum')
