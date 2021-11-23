classdef city < handle
    %CITY Class representing the city that will house the population.
    %   This class will contain the size of the city where a population of
    %   humans will live.
    
    properties
        dimensions
        area
        population
    end
    
    methods
        function obj = city(city_dimensions, pop_size)
            %CITY Construct a city.
            %   Params:
            %       - city_dimensions := a column vector with x and y 
            %         coordinates.
            %       - pop_size := number of humans in the city.
            
            assert( isequal(size(city_dimensions), [2 1]) );
            
            obj.dimensions = city_dimensions;
            obj.area = city_dimensions(1) * city_dimensions(2);
            
            obj.intialize_population_uniform_distr_pos(pop_size);
        end
        
        function intialize_population_uniform_distr_pos(obj, pop_size)
            %INITIALIZE_POPULATION_UNIFORM_DISTR_POS Initialize the
            % population of humans in this city uniformly distributed over
            % the area of the city.
            
            obj.population = population(pop_size);
            n = obj.population.size;
            
            x_max = obj.dimensions(1);
            y_max = obj.dimensions(2);
            
            rand_x_coords = rand(1, n)*x_max;
            rand_y_coords = rand(1, n)*y_max;
            
            alpha = 6;
            beta = 2/3;
            rand_infectious_durations = ceil(gamrnd(alpha, 1/beta, n, 1));
            
            percent_infected = 0.005; % 0.5%
            num_infected = ceil(n*percent_infected);
            rand_infected_idx = randi([1, n], num_infected, 1);
            
            for i=1:n
                obj.population.humans{i} = human([rand_x_coords(i); ...
                                                  rand_y_coords(i)], ...
                                                 rand_infectious_durations(i), ...
                                                 base_movement=1/4*x_max);
                if ismember(i, rand_infected_idx)
                    obj.population.humans{i}.set_health_status("infected", ...
                                                               day=0);
                end
            end
            
            obj.population.update_humans();
        end
        
        function simulate_day(obj, day, options)
            %SIMULATE_ONE_DAY Move every single human to a new random
            % position.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
                options.show_plot (1, 1) {mustBeA(options.show_plot, 'logical')} = false;
                options.plot_paths (1, 1) {mustBeA(options.plot_paths, 'logical')} = true;
                options.fig (1, 1) = false;
                options.filename (1, 1) {mustBeTextScalar};
                options.save_as_gif (1, 1) {mustBeA(options.save_as_gif, 'logical')} = false;
            end
            
            obj.population.update_health_status(day);
            obj.population.update_humans();
            
            for human = [obj.population.humans{:}]
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
                    obj.save_as_gif(options.filename, options.fig, day)
                end
            end
            
            for human = [obj.population.humans{:}]
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
        
        function save_as_gif(obj, filename, fig, day)
            %SAVE_AS_GIF Save the current day to a gif file.

            % Capture the plot as an image 
            frame = getframe(fig); 
            im = frame2im(frame); 
            [imind, cm] = rgb2ind(im, 256); 

            % Write to the GIF File  
            if day == 0 
                imwrite(imind, cm, filename, 'gif', 'Loopcount', inf); 
            else 
                imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append'); 
            end
        end
        
        function population_density = get_population_density(obj)
            %POPULATION_DENSITY Returns population density as the
            % population divided by the area of the city.
            
            population_density = obj.population.size / obj.area * 1000000;
        end
    end
end

