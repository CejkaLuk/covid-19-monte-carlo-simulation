close all
clear variables
clc

%% Physical distance of individuals

% Use exponential distribution:

lbda = 1/8;

physical_distance_distr = @(x) lbda*exp(-lbda*x);