function est_im = cf_reinhard(source,target)
%CF_REINHARD computes Reinhard's image colour transfer
%
%   CF_REINHARD(SOURCE,TARGET) returns the colour transfered source
%   image SOURCE according to the target image TARGET.
%

%   Copyright 2015 Han Gong <gong@fedoraproject.org>, University of East
%   Anglia.

%   References:
% Erik Reinhard, Michael Ashikhmin, Bruce Gooch and Peter Shirley, 
% 'Color Transfer between Images', IEEE CG&A special issue on Appliedi
% Perception, Vol 21, No 5, pp 34-41, September - October 2001

[x,y,z] = size(source);
img_s = reshape(im2double(source),[],3);
img_t = reshape(im2double(target),[],3);

a = [0.3811 0.5783 0.0402;0.1967 0.7244 0.0782;0.0241 0.1288 0.8444];
b = [1/sqrt(3) 0 0;0 1/sqrt(6) 0;0 0 1/sqrt(2)];
c = [1 1 1;1 1 -2;1 -1 0];
b2 = [sqrt(3)/3 0 0;0 sqrt(6)/6 0;0 0 sqrt(2)/2];
c2 = [1 1 1;1 1 -1;1 -2 0];

disp('=============================================================================');
mean_s = mean(img_s,1);
std_s = std(img_s,0,1);
mean_t = mean(img_t,1);
std_t = std(img_t,0,1);
str = sprintf('Init format\n\tsource\n\t%f %f\n\t%f %f\n\t%f %f\n\ttarget\n\t%f %f\n\t%f %f\n\t%f %f\n', mean_s(1), std_s(1), mean_s(2), std_s(2), mean_s(3), std_s(3), mean_t(1), std_t(1), mean_t(2), std_t(2), mean_t(3), std_t(3));
disp(str);

img_s = max(img_s,1/255);
img_t = max(img_t,1/255);

% convert to LMS space
% ' transpose array
LMS_s = a*img_s';
LMS_t = a*img_t'; 

mean_s = mean(LMS_s,2);
std_s = std(LMS_s,0,2);
mean_t = mean(LMS_t,2);
std_t = std(LMS_t,0,2);
str = sprintf('In LMS format\n\tsource\n\t%f %f\n\t%f %f\n\t%f %f\n\ttarget\n\t%f %f\n\t%f %f\n\t%f %f\n', mean_s(1), std_s(1), mean_s(2), std_s(2), mean_s(3), std_s(3), mean_t(1), std_t(1), mean_t(2), std_t(2), mean_t(3), std_t(3));
disp(str);


% take the log of LMS
LMS_s = log10(LMS_s);
LMS_t = log10(LMS_t);

mean_s = mean(LMS_s,2);
std_s = std(LMS_s,0,2);
mean_t = mean(LMS_t,2);
std_t = std(LMS_t,0,2);
str = sprintf('After log10\n\tsource\n\t%f %f\n\t%f %f\n\t%f %f\n\ttarget\n\t%f %f\n\t%f %f\n\t%f %f\n', mean_s(1), std_s(1), mean_s(2), std_s(2), mean_s(3), std_s(3), mean_t(1), std_t(1), mean_t(2), std_t(2), mean_t(3), std_t(3));
disp(str);

% convert to lab space
lab_s = b*c*LMS_s;
lab_t = b*c*LMS_t;

% compute mean and std
mean_s = mean(lab_s,2);
std_s = std(lab_s,0,2);
mean_t = mean(lab_t,2);
std_t = std(lab_t,0,2);
str = sprintf('Final(in lab) \n\tsource\n\t%f %f\n\t%f %f\n\t%f %f\n\ttarget\n\t%f %f\n\t%f %f\n\t%f %f\n', mean_s(1), std_s(1), mean_s(2), std_s(2), mean_s(3), std_s(3), mean_t(1), std_t(1), mean_t(2), std_t(2), mean_t(3), std_t(3));
disp(str);

res_lab = zeros(3,x*y);

sf = std_t./std_s;

for ch = 1:3 % for each channel, apply the statistical alignment
    res_lab(ch,:) = (lab_s(ch,:) - mean_s(ch))*sf(ch) + mean_t(ch);
end

% convert back to LMS
LMS_res=c2*b2*res_lab;
for ch = 1:3
    LMS_res(ch,:) = 10.^LMS_res(ch,:);
end

% convert back to RGB
est_im = ([4.4679 -3.5873 0.1193;-1.2186 2.3809 -0.1624;0.0497 -0.2439 1.2045]*LMS_res)';
est_im = min(est_im, 1.0);
est_im = max(est_im, 1/255);
est_im = reshape(est_im,size(source)); % reshape the image
