close all
clear variables
clc


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