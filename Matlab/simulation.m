classdef simulation < handle
    %SIMULATION Class representing the entire simulation.
    %   This class will be the driver for the city class and will
    %   contain the configuration from the simulation.
    %   Additionally, it will contain and analyze all data needed for
    %   resulting plots, such as Daily New Cases (DNC) and the effective
    %   reproductive number (R_e).
    
    properties
        config % Configuration class of simulation 
        data   % Data class of simulation
        city   % City to simulate
    end
    
    methods
        function obj = simulation(options)
            %SIMULATION Constructs a simulation object.
            
            arguments
                % [Optional] Configuration of the simulation
                options.config (1, 1) {mustBeA(options.config, 'struct')} = struct();
            end
            
            % Initiliaze the simulation's configuration
            obj.config = configuration(options.config);
            
            % Initialize the data of the simulation
            obj.data = data(obj.config.num_days);
        end
        
        function print_config(obj)
            %PRINT_CONFIG Prints the simulation's coniguration in the
            % command window.
            
            obj.config.print();
        end
        
        function run(obj)
            %RUN Runs the simulation.
            
            % Initialize the city
            obj.city = city(obj.config.city_dimensions,...
                            obj.config.num_humans, ...
                            obj.config.humans_stay_in_city);
            
            % Plot the initial state of the city
            obj.city.plot_simulation(1, ...
                                     plot_paths  = obj.config.plot_paths, ...
                                     fig         = obj.config.sim_fig, ...
                                     filename    = obj.config.filename, ...
                                     save_as_gif = obj.config.save_as_gif);
            
            % Simulate the spread of COVID-19 in the city
            for day = 2:obj.config.num_days
                obj.city.simulate_day(day, ...
                                      show_plot   = obj.config.show_everyday_plot, ...
                                      plot_paths  = obj.config.plot_paths, ...
                                      fig         = obj.config.sim_fig, ...
                                      filename    = obj.config.filename, ...
                                      save_as_gif = obj.config.save_as_gif);
            end
            
            % Plot the last day of the simulation
            % (in case every day is not plotted by user choice)
            obj.city.plot_simulation(obj.config.num_days, ...
                                     plot_paths = obj.config.plot_paths, ...
                                     fig        = obj.config.sim_fig);
        end
        
        function process_data(obj)
            %PROCESS_DATA Processes the data of the simulation
            
            obj.data.process(obj.city);
        end
        
        function visualize_data(obj)
            %VISUALIZE_DATA Visualizes the data of the simulation
            
            obj.data.plot_all();
        end
    end
end