close all
clear variables
clc


%% COVID-19 simulation program
% Author:     Bc. Lukáš Čejka
% University: Czech Technical University in Prague
% Faculty:    Faculty of Nuclear Sciences and Physical Engineering
% Subject:    Method Monte Carlo (MMC)
% Reference research paper: https://doi.org/10.1016/j.meegid.2021.104896
% Information:
%   This program was created as part of an assessment task that aimed to
%   reproduce results from the above-mentioned research paper. The authors
%   in the paper used the Monte Carlo method to simulate spread of the
%   COVID-19 virus in an area over time. In order to create a realistic 
%   simulation, the authors proposed the use of various distributions: 
%   Normal, Exponential, Gamma.
%   Alongside with this program a paper was written (but not published)
%   that aims to explain the theory behind the simulation, its
%   implementation and compare results with that of the original research
%   paper.



%% Configuration (optional)
sim_fig = figure('Name', 'COVID-19 Monte Carlo Simulation of humans in a city', ...
                 'NumberTitle', 'off', ...
                 'visible', 'off');

filename = "simulation_" + string(floor(posixtime(datetime))) + ".gif";

config = struct('num_days',            100, ...
                'num_humans',          2000, ...
                'city_dimensions',     [1000; 1000], ...
                'humans_stay_in_city', true, ...
                'show_everyday_plot',  true, ...
                'plot_paths',          false, ...
                'save_as_gif',         true, ...
                'sim_fig',             sim_fig, ...
                'filename',            filename);

%% Simulation
% Create a simulation with a given configuration (optional)
sim = simulation(config=config);

% Print the configuration
sim.print_config();

% Run the simulation
sim.run();

%% Post-processing
% Process the data of the simulation
sim.process_data();

% Display the data of the simulation
sim.visualize_data();