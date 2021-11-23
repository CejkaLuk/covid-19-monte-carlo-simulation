close all
clear variables
clc


%% Constants
num_days = 100;
num_humans = 100;
city_dimensions = [100; 100];
show_everyday_plot = true;
plot_paths = false;
save_as_gif = false;


%% Simulation

progress_bar = waitbar(0,'1','Name','COVID-19 simulation progress',...
                       'CreateCancelBtn','setappdata(gcbf,''cancelling'',1)');

sim_fig = figure('Name', 'COVID-19 Monte Carlo Simulation', ...
                 'NumberTitle', 'off', 'visible', 'off');

filename = "simulation_gifs/simulation_" + string(floor(posixtime(datetime))) + ".gif";

prague = city(city_dimensions, num_humans);
prague.plot_simulation(0, ...
                       plot_paths=plot_paths, ...
                       fig=sim_fig, ...
                       filename=filename, ...
                       save_as_gif=save_as_gif);

for day = 1:num_days
    waitbar(day/num_days, progress_bar, ...
            sprintf('%d/%d days', day, num_days));
    
    if getappdata(progress_bar, 'cancelling')
        break
    end

    prague.simulate_day(day, ...
                        show_plot=show_everyday_plot, ...
                        plot_paths=plot_paths, ...
                        fig=sim_fig, ...
                        filename=filename, ...
                        save_as_gif=save_as_gif);
    
end

delete(progress_bar);

prague.plot_simulation(num_days, ...
                       plot_paths=plot_paths, ...
                       fig=sim_fig);