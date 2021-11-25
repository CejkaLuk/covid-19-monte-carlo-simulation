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
            
            obj.set_config(options.config);
            
            obj.data.dnc = zeros([1, obj.config.num_days]);
            obj.data.R_e = nan([1, obj.config.num_days]);
        end
        
        function set_config(obj, config)
            %SET_CONFIG Set the configuration of the simulation.
            % If there is not configuration supplied -> set default
            % configuration specified in set_default_config().
            
            arguments
                obj
                config (1, 1) {mustBeA(config, 'struct')};
            end
            
            if isempty(fieldnames(config))
                obj.set_default_config();
            else
                assert(simulation.is_valid_config(config))
                obj.config = config;
            end
        end
        
        function set_default_config(obj)
            %SET_DEFAULT_CONFIG Set the default configuration.
            
            sim_fig = figure('Name', 'COVID-19 Monte Carlo Simulation of a city', ...
                 'NumberTitle', 'off', 'visible', 'off');

            filename = "simulation_" + string(floor(posixtime(datetime))) + ".gif";
            obj.config = struct('num_days', 100, ...
                                'num_humans', 2000, ...
                                'city_dimensions', [1000; 1000], ...
                                'show_everyday_plot', true, ...
                                'plot_paths', false, ...
                                'save_as_gif', true, ...
                                'sim_fig', sim_fig, ...
                                'filename', filename);
        end
        
        function set_dnc(obj, day, dnc)
            %SET_DNC Setter for daily new cases.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBePositive};
                dnc (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            obj.data.dnc(day) = dnc;
        end
        
        function dnc = get_dnc(obj, day)
            %GET_DNC Getter for daily new cases.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBePositive};
            end
            
            dnc = obj.data.dnc(day);
        end
        
        function run(obj)
            %RUN Driver function for the entire simulation.
            % First, create a city, then plot Day 1 (no movement, or anything, just
            % the base layout).
            % Then run the simulation based on some config parameters.
            
            cfg = obj.config;
            
            obj.city = city(cfg.city_dimensions,...
                            cfg.num_humans);
                        
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
        end
        
        function process_data(obj)
            %PROCESS_DATA Process data from simulation run.
            
            obj.gather_dnc();
            obj.gather_R_e();
        end
        
        function display_data(obj)
            %DISPLAY_DATA Display/plot data from simulation run.
            
            obj.plot_dnc();
            obj.plot_R_e();
        end
        
        function gather_dnc(obj)
            %GATHER_DNC Gather DNC over all humans who were sick (i.e. recovered or infected).
            
            for human = [obj.city.population.humans_by_status.recovered ...
                         obj.city.population.humans_by_status.infected]
                day = human.infection.first_day;
                old_val = obj.get_dnc(day);
                obj.set_dnc(day, old_val + 1);
            end
        end
        
        function gather_R_e(obj)
            %GATHER_R_E Gather R_e data over all days.
            % Towards the end, when there are no new cases, this formula
            % will divide by 0, so the data of R_e is not available for the
            % entire period of te simulation.
            
            c = 1;
            for day=2:obj.config.num_days
                obj.data.R_e(day) = 1 + log(obj.city.population.sir_data.num_infected(day)/...
                                      obj.city.population.sir_data.num_infected(day-1))^(1/c);
            end
        end

        function plot_dnc(obj)
            %PLOT_DNC Plot daily new cases in its own figure.
            
            dnc_fig = figure('Name', 'Daily New Cases (DNC)', ...
                             'NumberTitle', 'off', 'visible', 'off');
            figure(dnc_fig)
            plot(obj.data.dnc(:), '-o')
            
            title('Daily new cases (DNC) development in MC simulation', ...
                  'interpreter', 'latex')
              
            legend('Daily new cases (DNC)', 'interpreter', 'latex')
            
            xlabel('Time [day]', 'interpreter', 'latex')
            ylabel('Number of new cases per day', 'interpreter', 'latex')
        end
        
        function plot_R_e(obj)
            %PLOT_R_E Plot daily effective reproductive number (R_e)
            
            R_e_fig = figure('Name', 'Effective reproductive number (R_e)', ...
                             'NumberTitle', 'off', 'visible', 'off');
            figure(R_e_fig)
            hold on
            
            plot(obj.data.R_e(:), '-o red')
            yline(1, '-- red', 'LineWidth', 2)
            
            title('Effective reproductive number ($$R_e$$) development in MC simulation', ...
                  'interpreter', 'latex')
            legend('Effective reproductive number $$R_e$$', ...
                   'Threshold level $$R_e(0) = R_0 = 1$$', ...
                   'interpreter', 'latex')
            
            xlabel('Time [day]', 'interpreter', 'latex')
            ylabel('Daily $$R_e$$', 'interpreter', 'latex')
        end
    end
    
    methods(Static)
        
        function valid = is_valid_config(config)
            %IS_VALID_CONFIG Check if the supplied coniguration is valid.
            
            arguments
                config (1, 1) {mustBeA(config, 'struct')}
            end
            
            simulation.check_config_fieldnames(config);
            simulation.check_config_values(config);
            valid = 1;
        end
        
        function check_config_fieldnames(config)
            %CHECK_CONFIG_FIELDNAMES Check that the config contains the
            % correct fieldnames.
            
            arguments
                config (1, 1) {mustBeA(config, 'struct')}
            end
            
            valid_fieldnames = ["num_days"; ...
                                "num_humans"; ...
                                "city_dimensions"; ...
                                "show_everyday_plot"; ...
                                "plot_paths"; ...
                                "save_as_gif"; ...
                                "sim_fig"; ...
                                "filename"];
            config_fieldnames = string(fieldnames(config));
            assert(simulation.arrays_have_same_elements(config_fieldnames, valid_fieldnames), ...
                   ['Invalid configuration! The Config struct must contain', ... 
                    ' the following fields:', ...
                    ' num_days, num_humans, city_dimensions, show_everyday_plot,', ...
                    'plot_paths, save_as_gif, sim_fig, filename!'])
        end
        
        function correct = arrays_have_same_elements(arr1, arr2)
            %ARRAYS_HAVE_SAME_ELEMENTS Disregarding size of arrays,
            % validate whether they contain the same elements.
            
            if all(size(intersect(arr1, arr2)) == size(arr1)) || ...
               all(size(intersect(arr1, arr2)) == size(arr2))
                correct = 1;
            else
                correct = 0;
            end
        end
        
        function check_config_values(config)
            %CHECK_CONFIG_VALUES Check that the configuration values are
            % correctly defined.
            % For example, that a value which is supposed to be a scalar is 
            % not a vector, etc.
            
            arguments
                config (1, 1) {mustBeA(config, 'struct')}
            end

            isInteger = @(x) floor(x) == x;
            isBool = @(x) islogical(x) && isscalar(x);
            
            assert(isInteger(config.num_days) && ...
                   isscalar(config.num_days) && ...
                   config.num_days >= 0);
               
            assert(isInteger(config.num_humans) && ...
                   isscalar(config.num_humans) && ...
                   config.num_humans > 0);
               
            assert(isa(config.city_dimensions, 'double') && ...
                   isequal(size(config.city_dimensions), [2 1]) && ...
                   all(config.city_dimensions(:) > 0));
            
            assert(isBool(config.show_everyday_plot));
            
            assert(isBool(config.plot_paths));
            
            assert(isBool(config.save_as_gif));
            
            assert(isa(config.sim_fig, 'matlab.ui.Figure'));
            
            assert(isStringScalar(config.filename));
        end
    end
end

