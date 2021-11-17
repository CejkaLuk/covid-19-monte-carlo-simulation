close all
clear variables
clc

num_days = 10;
num_humans = 10;

% Linking plots to data
% https://www.mathworks.com/help/matlab/creating_plots/making-graphs-responsive-with-data-linking.html

h1 = human([0; 0]);

sim_fig = figure('Name', 'COVID-19 Monte Carlo Simulation', ...
                 'NumberTitle', 'off');

plot(h1.position(1), h1.position(2), 'o')
hold on

plot(h1.path(1, 1:end), h1.path(2, 1:end))
hold on

 % graph properties
% axis([-10 10 -10 10])
% grid on
% xlabel('x')
% ylabel('y')
% legend('human')

pop = population(num_humans);

for k = 1:num_days
    
    for h = [pop.humans{:}]
        h.plot(sim_fig);
        h.move_to_random_position();
    end
    
    % marker plots
%     plot(t(k),y(k),'x')
%     hold on
%     plot(h1.position(1), h1.position(2), 'o')
%     hold on
%     plot(t(k),y2(k),'o')
%     hold on
    
    % line plots
%     plot(t(1:k),y(1:k))
%     hold on
%     plot(h1.path(1, 1:k), h1.path(2, 1:k))
%     hold on
%     plot(t(1:k),y2(1:k))
    
%     h1.plot(sim_fig);
    pause(0.1)
%     h1.move_to_random_position();
    
    if k ~= num_days
        clf
    end
end

% for h = [pop.humans{:}]
%     h.plot(sim_fig);
% end