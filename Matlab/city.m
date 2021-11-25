classdef city < handle
    %CITY Class representing the city that will house the population.
    %   This class will contain the size of the city where a population of
    %   humans will live.
    
    properties
        dimensions
        area
        population
        plots
    end
    
    methods
        function obj = city(city_dimensions, pop_size, humans_stay_in_city)
            %CITY Construct a city.
            %   Params:
            %       - city_dimensions := a column vector with x and y 
            %         coordinates.
            %       - pop_size := number of humans in the city.
            
            assert( isequal(size(city_dimensions), [2 1]) );
            
            obj.dimensions = city_dimensions;
            obj.area = city_dimensions(1) * city_dimensions(2);
            
            obj.plots.humans_stay_in_city = humans_stay_in_city;
            
            obj.intialize_population_uniform_distr_pos(pop_size, ...
                                                       humans_stay_in_city);
        end
        
        function intialize_population_uniform_distr_pos(obj, pop_size, humans_stay_in_cities)
            %INITIALIZE_POPULATION_UNIFORM_DISTR_POS Initialize the
            % population of humans in this city uniformly distributed over
            % the area of the city.
            
            day = 1;
            
            obj.population = population(pop_size);
            n = obj.population.size;
            
            x_max = obj.dimensions(1);
            y_max = obj.dimensions(2);
            
            rand_x_coords = rand(1, n)*x_max;
            rand_y_coords = rand(1, n)*y_max;
            
            alpha = 6;
            beta = 2/3;
            rand_infectious_durations = ceil(gamrnd(alpha, 1/beta, n, 1));
            
            percent_infectious = 0.005; % 0.5%
            num_infectious = ceil(n*percent_infectious);
            rand_infectious_idx = randi([1, n], num_infectious, 1);
            
            if humans_stay_in_cities
                movement_limits = obj.get_bounds();
            else
                movement_limits = nan;
            end
            
            for i=1:n
                obj.population.humans{i} = human([rand_x_coords(i); ...
                                                  rand_y_coords(i)], ...
                                                 rand_infectious_durations(i), ...
                                                 base_movement=1/12*x_max, ...
                                                 movement_limits=movement_limits);
                if ismember(i, rand_infectious_idx)
                    obj.population.humans{i}.set_health_status("infectious", ...
                                                               day=day);
                end
            end
            
            obj.population.update_humans(day);
            obj.population.humans_by_status.all = [obj.population.humans{:}];
            obj.initialize_plots();
        end
        
        function initialize_plots(obj)
            %INITIALIZE_PLOTS Initialize the plots as variables with a
            % dummy array and make the plotted points invisible.
            % The data in these plots needs to be replaced and the plots
            % needs to be made visible to see output.
                                   
            default_blue_color = [0 0.4470 0.7410];
            dummy_array = [0; 0];
            
            obj.plots.susceptible = plot(dummy_array(1, :), ...
                                         dummy_array(2, :), ...
                                         'o', ...
                                         'MarkerEdgeColor', default_blue_color, ...
                                         'MarkerFaceColor', default_blue_color);
            obj.plots.susceptible.Visible = 'off';
            
            hold on
            
            obj.plots.infectious = plot(dummy_array(1, :), ...
                                        dummy_array(2, :), ...
                                        'o', ...
                                        'MarkerEdgeColor', default_blue_color, ...
                                        'MarkerFaceColor', "red");
            obj.plots.infectious.Visible = 'off';

            obj.plots.recovered = plot(dummy_array(1, :), ...
                                       dummy_array(2, :), ...
                                       'o', ...
                                       'MarkerEdgeColor', default_blue_color, ...
                                       'MarkerFaceColor', [200 200 200]/255);
            obj.plots.recovered.Visible = 'off';
            
            if obj.plots.humans_stay_in_city
                bounds = obj.get_bounds();
                corners = [bounds(1) bounds(3) bounds(2) bounds(4)];
                rectangle('Position', corners)
            end

            axis(obj.get_bounds())
            grid on

            xlabel('x [m]', 'Interpreter', 'latex')
            ylabel('y [m]', 'Interpreter', 'latex')
            hold off
        end
        
        function simulate_day(obj, day, options)
            %SIMULATE_ONE_DAY Move every single human to a new random
            % position.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
                options.show_plot (1, 1) {mustBeA(options.show_plot, 'logical')} = false;
                options.plot_paths (1, 1) {mustBeA(options.plot_paths, 'logical')} = false;
                options.fig (1, 1) {mustBeA(options.fig, 'matlab.ui.Figure')};
                options.filename (1, 1) {mustBeTextScalar};
                options.save_as_gif (1, 1) {mustBeA(options.save_as_gif, 'logical')} = false;
            end
            
            obj.population.update_health_status(day);
            obj.population.update_humans(day);
            
            for human = obj.population.humans_by_status.all
                human.move_to_random_position()
            end
            
            if options.show_plot == true
                obj.plot_simulation(day, ...
                                    plot_paths=options.plot_paths, ...
                                    fig=options.fig, ...
                                    filename=options.filename, ...
                                    save_as_gif=options.save_as_gif);
            end
        end
        
        function plot_simulation(obj, day, options)
            %PLOT_SIMULATION Plot the current city-population layout -
            % positions and paths of all humans.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
                options.fig (1, 1) = false;
                options.plot_paths (1, 1) {mustBeA(options.plot_paths, 'logical')} = true;
                options.filename (1, 1) {mustBeTextScalar};
                options.save_as_gif (1, 1) {mustBeA(options.save_as_gif, 'logical')} = false;
            end
            
            if isgraphics(options.fig, 'figure')
                figure(options.fig)
                
                if options.save_as_gif
                    save_as_gif(options.filename, options.fig, day)
                end
            end
            
            if ~options.plot_paths
                obj.plot_humans_fast(day);
            else
                obj.plot_humans_with_paths(day);
            end
        end
        
        function plot_humans_fast(obj, day)
            %PLOT_HUMANS_FAST Plot all humans based on their status using
            % predefined plot handles.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            susceptible_humans_positions = [obj.population.humans_by_status.susceptible.position];
            infectious_humans_positions = [obj.population.humans_by_status.infectious.position];
            recovered_humans_positions = [obj.population.humans_by_status.recovered.position];
            
            plot_by_status(obj.plots.susceptible, ...
                           susceptible_humans_positions);
            
            plot_by_status(obj.plots.infectious, ...
                           infectious_humans_positions);
            
            plot_by_status(obj.plots.recovered, ...
                           recovered_humans_positions);
            
            title(sprintf('Simulation of humans in city: Day %d', day), 'Interpreter', 'latex')
            
            drawnow
        end

        function plot_humans_with_paths(obj, day, options)
            %PLOT_HUMANS_WITH_PATHS Plot humans and their paths - given that the
            % paths are not turned off.
            % This plot is very slow.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
                options.plot_paths (1, 1) {mustBeA(options.plot_paths, 'logical')} = true;
            end
            
            for human = obj.population.humans_by_status.all
                human.plot(plot_paths=options.plot_paths);
            end

            obj.set_plot_configuration(day);
        end
        
        function set_plot_configuration(obj, day)
            %SET_PLOT_CONFIGURATION Sets the configuration of the plot.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            axis(obj.get_bounds())
            grid on
            
            title(sprintf('Day %d', day))
            xlabel('x')
            ylabel('y')
            
            pause(0.1)
            hold off
        end

        function city_bounds = get_bounds(obj)
            %GET_LIMITS Return the bounds of the city.
            %  Info:
            %       - x-axis from 0 to obj.dimensions(1)
            %       - y-axis from 0 to obj.dimensions(2)
            
            city_bounds = [0 obj.dimensions(1) 0 obj.dimensions(2)];
        end
        
        function population_density = get_population_density(obj)
            %POPULATION_DENSITY Returns population density as the
            % population divided by the area of the city.
            
            population_density = obj.population.size / obj.area * 1000000;
        end
    end
end

function save_as_gif(filename, fig, day)
    %SAVE_AS_GIF Save the current day to a gif file.

    % Capture the plot as an image 
    frame = getframe(fig); 
    im = frame2im(frame); 
    [imind, cm] = rgb2ind(im, 256); 

    % Write to the GIF File  
    if day == 1 
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf); 
    else 
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append'); 
    end
end

function plot_by_status(h_plot, humans_positions)
    if ~isempty(humans_positions)
        h_plot.Visible = 'on';
        set(h_plot, {'XData', 'YData'}, {humans_positions(1, :), ...
                                         humans_positions(2, :)});
    else
        h_plot.Visible = 'off';
    end
end
