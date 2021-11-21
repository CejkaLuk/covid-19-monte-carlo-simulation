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
            
            for i=1:n
                obj.population.humans{i} = human([rand_x_coords(i); ...
                                                  rand_y_coords(i)]);
            end
        end
        
        function simulate_one_day(obj, options)
            %SIMULATE_ONE_DAY Move every single human to a new random
            % position and if set, plot the position and paths of all
            % humans.
            arguments
                obj
                options.show_plot (1, 1) {mustBeA(options.show_plot, 'logical')} = false;
                options.fig (1, 1) = false;
            end
            
            for human = [obj.population.humans{:}]
                human.move_to_random_position()
            end
            
            if options.show_plot == true
                obj.plot_simulation(fig=options.fig);
            end
        end
        
        function plot_simulation(obj, options)
            %PLOT_SIMULATION Plot the current city-population layout -
            % positions and paths of all humans.
            arguments
                obj
                options.fig (1, 1) = false;
                options.plot_paths (1, 1) {mustBeA(options.plot_paths, 'logical')} = true
            end
            
            if isgraphics(options.fig,'figure')
                figure(options.fig)
            end
            
            for human = [obj.population.humans{:}]
                human.plot(plot_paths=options.plot_paths);
            end

            obj.set_plot_configuration();
        end
        
        function set_plot_configuration(obj)
            %SET_PLOT_CONFIGURATION Sets the configuration of the plot.
            
            axis(obj.get_bounds())
            grid on
            
            day = obj.population.humans{1}.get_days_walked();
            
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
            
            population_density = obj.population.size / obj.area;
        end
    end
end

