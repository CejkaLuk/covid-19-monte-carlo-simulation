close all
clear variables
clc


%% Constants
num_days = 100;
num_humans = 2000;
city_dimensions = [1000; 1000];
show_everyday_plot = true;
plot_paths = false;
save_as_gif = true;


%% Simulation

sim_fig = figure('Name', 'COVID-19 Monte Carlo Simulation of a city', ...
                 'NumberTitle', 'off', 'visible', 'off');

filename = "simulation_gifs/simulation_" + string(floor(posixtime(datetime))) + ".gif";

prague = city(city_dimensions, num_humans);
prague.plot_simulation(0, ...
                       plot_paths=plot_paths, ...
                       fig=sim_fig, ...
                       filename=filename, ...
                       save_as_gif=save_as_gif);

for day = 1:num_days
    prague.simulate_day(day, ...
                        show_plot=show_everyday_plot, ...
                        plot_paths=plot_paths, ...
                        fig=sim_fig, ...
                        filename=filename, ...
                        save_as_gif=save_as_gif);
    
end

prague.plot_simulation(num_days, ...
                       plot_paths=plot_paths, ...
                       fig=sim_fig);