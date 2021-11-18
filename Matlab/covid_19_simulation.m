close all
clear variables
clc


%% Constants
num_days = 100;
num_humans = 100;
city_dimensions = [100; 100];
show_everyday_plot = true;


%% Simulation             
prague = city(city_dimensions, num_humans);

progress_bar = waitbar(0,'1','Name','COVID-19 simulation progress',...
                       'CreateCancelBtn','setappdata(gcbf,''cancelling'',1)');

sim_fig = figure('Name', 'COVID-19 Monte Carlo Simulation', ...
                 'NumberTitle', 'off');
             
for k = 1:num_days
    waitbar(k/num_days, progress_bar, ...
            sprintf('%d/%d days', k, num_days));
    
    if getappdata(progress_bar, 'cancelling')
        break
    end
    
    prague.simulate_one_day(show_plot=show_everyday_plot);
end

delete(progress_bar);

prague.plot_simulation();