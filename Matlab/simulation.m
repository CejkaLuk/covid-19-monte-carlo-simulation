classdef simulation < handle
    %SIMULATION Class representing the entire simulation.
    %   This class will be the driver for the city class and will
    %   contain the settings from the simulation.
    %   Additionally, it will contain and analyze all data needed for
    %   resulting plots, such as Daily New Cases (DNC) and the effective
    %   reproductive number.
    
    properties
        config
        data
        city
    end
    
    methods
        function obj = simulation(options)
            %SIMULATION Construct a simulation object.
            
            arguments
                options.config (1, 1) {mustBeA(options.config, 'struct')} = struct();
            end
            
            obj.config = configuration(options.config);
            obj.data = data(obj.config.num_days);
        end
        
        function run(obj)
            %RUN Driver function for the entire simulation.
            % First, create a city, then plot Day 1 (no movement, or anything, just
            % the base layout).
            % Then run the simulation based on some config parameters.
            
            cfg = obj.config;
            
            obj.city = city(cfg.city_dimensions,...
                            cfg.num_humans, ...
                            cfg.humans_stay_in_city);
                        
            obj.city.plot_simulation(1, ...
                                     plot_paths=cfg.plot_paths, ...
                                     fig=cfg.sim_fig, ...
                                     filename=cfg.filename, ...
                                     save_as_gif=cfg.save_as_gif);

            for day = 2:cfg.num_days
                obj.city.simulate_day(day, ...
                                      show_plot=cfg.show_everyday_plot, ...
                                      plot_paths=cfg.plot_paths, ...
                                      fig=cfg.sim_fig, ...
                                      filename=cfg.filename, ...
                                      save_as_gif=cfg.save_as_gif);
            end

            obj.city.plot_simulation(cfg.num_days, ...
                                     plot_paths=cfg.plot_paths, ...
                                     fig=cfg.sim_fig);
            
%             obj.process_data()
        end
        
        function process_data(obj)
            obj.data.process(obj.city);
        end
        
        function visualize_data(obj)
            obj.data.plot_all();
        end
    end
end