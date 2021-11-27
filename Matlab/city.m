classdef city < handle
    %CITY Class representing the city that will house the population.
    %   This class contains the size of the city where a population of
    %   humans will live and plot handles for humans with a specific health
    %   status.
    
    properties
        dimensions % Dimensions of the city
        population % Population class of the city
        plots      % Plot handle of humans by status struct
                   % (susceptible, infectious, recovered)
    end
    
    methods
        function obj = city(city_dimensions, pop_size, humans_stay_in_city)
            %CITY Constructs a city.
            
            arguments
                % [Required] Dimensions of the city - humans will be
                % generated inside the city and they may be banned from
                % leaving
                city_dimensions     (2, 1) {mustBeFloat, mustBePositive};
                % [Required] The size of the population
                pop_size            (1, 1) {mustBeInteger};
                % [Required] If humans should stay in the city bounds
                humans_stay_in_city (1, 1) {mustBeA(humans_stay_in_city, 'logical')};
            end
            
            % Validate city dimensions format
            assert(isequal(size(city_dimensions), [2 1]));
            
            obj.dimensions = city_dimensions;
            
            % Set a boolean value for the purpose of plotting a border
            % denoting city dimensions
            obj.plots.humans_stay_in_city = humans_stay_in_city;
            
            % Initialize the population - positions of humans in the city
            % bounds will be uniformly distributed
            obj.intialize_population_uniform_distr_pos(pop_size, ...
                                                       humans_stay_in_city);
        end
        
        function intialize_population_uniform_distr_pos(obj, pop_size, humans_stay_in_cities)
            %INITIALIZE_POPULATION_UNIFORM_DISTR_POS Initializes the
            % population of humans in this city uniformly distributed over
            % its area.
            
            % Initial value of day
            day = 1;
            
            % Initiliaze the population
            obj.population = population(pop_size);
            
            % Save the population size to a local variable to easy access
            n = obj.population.size;
            
            % Get the maximum x and y values for human movement - city
            % bounds
            x_max = obj.dimensions(1);
            y_max = obj.dimensions(2);
            
            % Generate random coordinates from 0 to city bounds
            rand_x_coords = rand(1, n)*x_max;
            rand_y_coords = rand(1, n)*y_max;
            
            % Generate infectious durations for the entire population as a
            % random variable from the Gamma distributin
            % Constant are from the researc paper
            alpha = 6;
            beta = 2/3;
            rand_infectious_durations = ceil(gamrnd(alpha, 1/beta, n, 1));
            
            % Initialize 0.5% of the population as infectious
            percent_infectious = 0.005;
            num_infectious = ceil(n*percent_infectious);
            % Get random ids to set the human with this id to be infectious
            rand_infectious_ids = randi([1, n], num_infectious, 1);
            
            % Set movement limits of humans based on input parameter
            if humans_stay_in_cities
                movement_limits = obj.get_bounds();
            else
                movement_limits = nan;
            end
            
            % Initialize humans:
            %   - starting position
            %   - infectious duration
            %   - base movement (based on max. city dimensions)
            %   - movement limits (if human can move outside of city bounds)
            for id = 1:n
                obj.population.humans{id} = human([rand_x_coords(id); ...
                                                   rand_y_coords(id)], ...
                                                  rand_infectious_durations(id), ...
                                                  base_movement   = 1/12*x_max, ...
                                                  movement_limits = movement_limits);
                
                % If the human should be initialized as infectious
                if ismember(id, rand_infectious_ids)
                    obj.population.humans{id}.set_health_status("infectious", ...
                                                                day=day);
                end
            end
            
            % Initialize arrays of susceptible, infectious and recovered humans
            obj.population.update_humans(day);

            % Initialize array of all humans in city
            obj.population.humans_by_status.all = [obj.population.humans{:}];

            % Initiliaze plots of humans by health status
            obj.initialize_plots();
        end
        
        function initialize_plots(obj)
            %INITIALIZE_PLOTS Initializes the plots as variables with a
            % dummy array and makes the plotted points invisible.
            % The data in these plots needs to be replaced and the plots
            % need to be made visible to see output.
                              
            % Declare default blue colour for susceptible humans
            default_blue_color = [0 0.4470 0.7410];

            % Create a dummy array which will be initially plotted to get
            % plot handles for quicker plotting during simulation
            dummy_array = [0; 0];
            
            % Create plot handles for humans based on their health status
            obj.plots.susceptible = plot(dummy_array(1, :), ...
                                         dummy_array(2, :), ...
                                         'o', ...
                                         'MarkerEdgeColor', default_blue_color, ...
                                         'MarkerFaceColor', default_blue_color);
            
            % Set the plot to be invisible as this plot is only
            % a dummy plot to obtain the plot handle
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
            
            % If humans should not leave the city, plot the city bounds
            if obj.plots.humans_stay_in_city
                bounds = obj.get_bounds();
                corners = [bounds(1) bounds(3) bounds(2) bounds(4)];
                rectangle('Position', corners)
            end

            % Set the axis to be the bounds of the city
            axis(obj.get_bounds())
            grid on

            xlabel('x [m]', 'Interpreter', 'latex')
            ylabel('y [m]', 'Interpreter', 'latex')
            
            set(gca,'TickLabelInterpreter','latex');
            
            hold off
        end
        
        function simulate_day(obj, day, options)
            %SIMULATE_ONE_DAY Simulates one day in the city
            
            arguments
                obj
                % [Required] Day to simulate
                day                 (1, 1) {mustBeInteger, mustBeNonnegative};
                % [Optional] Show the simulation plot for this day
                options.show_plot   (1, 1) {mustBeA(options.show_plot, 'logical')} = false;
                % [Optional] Plot the paths of humans (very slow)
                options.plot_paths  (1, 1) {mustBeA(options.plot_paths, 'logical')} = false;
                % [Optional] Save every day to the .gif file
                options.save_as_gif (1, 1) {mustBeA(options.save_as_gif, 'logical')} = false;
                % [Optional] Figure for the plot
                options.fig         (1, 1) {mustBeA(options.fig, 'matlab.ui.Figure')};
                % [Optional] File name for the .gif file
                options.filename    (1, 1) {mustBeTextScalar};
            end
            
            % Update the health status of the population for this day
            obj.population.update_health_status(day);

            % Update the arrays of susceptible, infectious and recovered humans
            obj.population.update_humans(day);
            
            % Move all humans to a random position
            for human = obj.population.humans_by_status.all
                human.move_to_random_position()
            end
            
            % If set, plot the simulation for this day
            if options.show_plot
                obj.plot_simulation(day, ...
                                    plot_paths  = options.plot_paths, ...
                                    save_as_gif = options.save_as_gif, ...
                                    fig         = options.fig, ...
                                    filename    = options.filename);
            end
        end
        
        function plot_simulation(obj, day, options)
            %PLOT_SIMULATION Plots the current city-population layout -
            % positions and paths of all humans (optional).
            
            arguments
                obj
                day                 (1, 1) {mustBeInteger, mustBeNonnegative};
                options.fig         (1, 1) = false;
                options.plot_paths  (1, 1) {mustBeA(options.plot_paths, 'logical')} = true;
                options.save_as_gif (1, 1) {mustBeA(options.save_as_gif, 'logical')} = false;
                options.filename    (1, 1) {mustBeTextScalar};
            end
            
            % If the supplied figure is a figure and not a logical 
            % with value false (default value to avoid unknown property)
            if isgraphics(options.fig, 'figure')
                figure(options.fig)
                
                if options.save_as_gif
                    save_as_gif(options.filename, options.fig, day)
                end
            end
            
            % Use path-plotting specific functions
            if ~options.plot_paths
                % Human paths are not plotted
                obj.plot_humans_fast(day);
            else
                % Human paths are plotted
                obj.plot_humans_with_paths(day);
            end
        end
        
        function plot_humans_fast(obj, day)
            %PLOT_HUMANS_FAST Plots all humans based on their status using
            % predefined plot handles.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            % Get arrays of human positions based on human health status
            susceptible_humans_positions = [obj.population.humans_by_status.susceptible.position];
            infectious_humans_positions  = [obj.population.humans_by_status.infectious.position];
            recovered_humans_positions   = [obj.population.humans_by_status.recovered.position];
            
            % Update the plot handles of human positions based on health status
            plot_by_status(obj.plots.susceptible, ...
                           susceptible_humans_positions);
            
            plot_by_status(obj.plots.infectious, ...
                           infectious_humans_positions);
            
            plot_by_status(obj.plots.recovered, ...
                           recovered_humans_positions);
            
            title(sprintf('\\textbf{Day %d}', day), 'Interpreter', 'latex')
            
            legend(sprintf("Susceptible %d", obj.population.sir_data.num_susceptible(day)), ...
                   sprintf("Infectious %d",  obj.population.sir_data.num_infectious(day)), ...
                   sprintf("Recovered %d",   obj.population.sir_data.num_recovered(day)), ...
                   'location', 'eastoutside', ...
                   'Interpreter', 'latex');
            
            drawnow
        end

        function plot_humans_with_paths(obj, day, options)
            %PLOT_HUMANS_WITH_PATHS Plots humans and their paths - given that the
            % paths are not turned off.
            % This plot is very slow.
            
            arguments
                obj
                day                (1, 1) {mustBeInteger, mustBeNonnegative};
                options.plot_paths (1, 1) {mustBeA(options.plot_paths, 'logical')} = true;
            end
            
            % Plot each human's position
            for human = obj.population.humans_by_status.all
                human.plot(plot_paths = options.plot_paths);
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
            
            title(sprintf('\\textbf{Day %d}', day), 'Interpreter', 'latex')
            
            legend(sprintf("Susceptible %d", obj.population.sir_data.num_susceptible(day)), ...
                   sprintf("Infectious %d",  obj.population.sir_data.num_infectious(day)), ...
                   sprintf("Recovered %d",   obj.population.sir_data.num_recovered(day)), ...
                   'location', 'eastoutside', ...
                   'Interpreter', 'latex');
               
            xlabel('x [m]', 'Interpreter', 'latex')
            ylabel('y [m]', 'Interpreter', 'latex')
            
            set(gca,'TickLabelInterpreter','latex');
            
            hold off
        end

        function city_bounds = get_bounds(obj)
            %GET_LIMITS Returns the bounds of the city.
            
            % x-axis from 0 to obj.dimensions(1) and 
            % y-axis from 0 to obj.dimensions(2)
            city_bounds = [0 obj.dimensions(1) 0 obj.dimensions(2)];
        end
        
        function population_density = get_population_density(obj)
            %POPULATION_DENSITY Returns population density in humans/km^2 as 
            % the population divided by the area of the city.
            
            population_density = obj.population.size / (obj.dimensions(1) * obj.dimensions(2)) * 1000000;
        end
    end
end

function save_as_gif(filename, fig, day)
    %SAVE_AS_GIF Saves the current simulated day to a gif file.
    
    arguments
        filename (1, 1) {mustBeTextScalar};
        fig (1, 1) {mustBeA(fig, 'matlab.ui.Figure')};
        day (1, 1) {mustBeInteger, mustBePositive};
    end

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

    arguments
        % [Required] Plot handle
        h_plot (1, 1) {mustBeA(h_plot, 'handle')};
        % [Required] Human positions to plot
        humans_positions {mustBeFloat};
    end
    % If there are human positions update the data
    % of the plot handle and make them visible
    if ~isempty(humans_positions)
        h_plot.Visible = 'on';
        set(h_plot, {'XData', 'YData'}, {humans_positions(1, :), ...
                                         humans_positions(2, :)});
    else
        % If the positions are empty, then no data would
        % be updated -> the last plot would remain 
        % constantly visible -> Make it invisible
        h_plot.Visible = 'off';
    end
end
