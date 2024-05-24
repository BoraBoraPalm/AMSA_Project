%% Data loading
close all;
clear all;
 
% Add NIfTI Toolbox to the MATLAB path
addpath('E:\FH Kärnten\Semester 2\AMIA\Project data\MIA_SS24_Project_Task1_220424\MIA_SS24_Project_Task1_220424\NIfTI_20140122');
 
% Load the NIfTI files
main_path = "E:\FH Kärnten\Semester 2\AMIA\Project data\MIA_SS24_Project_Task1_220424\MIA_SS24_Project_Task1_220424";
magnitude = niftiread(main_path+'\data\swi\magnitude.nii');
phase_unw = niftiread(main_path+'\data\swi\phase_unw.nii');
mask = niftiread(main_path+'\data\swi\mask.nii');
 
% Extract the data from the NIfTI structures
mag_data = magnitude;
phase_data = phase_unw;
mask_data = mask;
 
% Convert data to double precision
mag_data = double(mag_data);
phase_data = double(phase_data);
mask_data = double(mask_data);
 
 
%% Generating an SWI image [7 POINTS]
 
% [i] Apply the mask to the unwrapped phase image [OK]
masked_phase_data = phase_data .* mask_data;

% [ii] High-pass filter the phase data using unsharp masking [OK]
% Create a Gaussian high-pass filter
sigma = 2; % Standard deviation for Gaussian filter
hsize = 5; % Size of the filter
gaussian_low_pass = fspecial('gaussian', hsize, sigma);

% To get get the high-pass: Apply the low-pass filter and subtract it from the original to get high-pass
low_passed_phase_data = imfilter(masked_phase_data, gaussian_low_pass, 'replicate'); % TODO: Why replicate? In lecture we used 'conv'
high_passed_phase_data = masked_phase_data - low_passed_phase_data;
 
 
% [iii] Generate an SWI mask following the specified function [OK]
swi_mask = zeros(size(high_passed_phase_data));
swi_mask(high_passed_phase_data < 0) = 1; 
swi_mask(high_passed_phase_data >= 0 & high_passed_phase_data <= 1) = 1 - high_passed_phase_data(high_passed_phase_data >= 0 & high_passed_phase_data <= 1);
 
 
% [iv] Define the number of times to multiply (n) and generate the SWI image
n = 4; % n enhances the susceptibility contrast
swi_image = mag_data .* (swi_mask .^ n);
 
 
 
%% [v] Generate a minimum intensity projection SWI image 

min_ip_swi_image=swi_image;
 
% Generate the MinIP SWI image using 10 slices (Ms Bachrata said it to another group)
start_slice = 40;
end_slice = 55; % 50
 
min_ip_swi_image = min(min_ip_swi_image(:, :, start_slice:end_slice), [], 3);
 
 
%% Plotting the results
figure;
 
% Magnitude Image
subplot(1, 3, 1);
imshow(mag_data(:, :, round(end/2)), []);
title('Magnitude');
 
% SWI Image
subplot(1, 3, 2);
imshow(swi_image(:, :, round(end/2)), []);
title('SWI');
 
% MinIP SWI Image
subplot(1, 3, 3);
imshow(min_ip_swi_image, []);
title('MinIP');