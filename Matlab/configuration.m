classdef configuration < handle
    %CONFIG Class housing the configuration for the COVID-19 simulation.
    %   This class holds values used by the simulation. It includes
    %   checking the validity of the supplied configuration and providing a
    %   default configuration is one is not supplied.
    
    properties
        num_days
        num_humans
        city_dimensions
        humans_stay_in_city
        show_everyday_plot
        plot_paths
        save_as_gif
        sim_fig
        filename
    end
    
    methods
        function obj = configuration(config)
            %CONFIG Construct an instance of this class
            %   Detailed explanation goes here
            
            arguments
                config (1, 1) {mustBeA(config, 'struct')} = struct();
            end
            
            obj.set_config(config);
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
                obj.load_default_config();
            else
                obj.load_config(config);
            end
        end
        
        function load_default_config(obj)
            %SET_DEFAULT_CONFIG Set the default configuration.
            
            sim_figure = figure('Name', 'COVID-19 Monte Carlo Simulation of a city', ...
                 'NumberTitle', 'off', 'visible', 'off');

            file_name = "simulation_" + string(floor(posixtime(datetime))) + ".gif";

            configuration = struct('num_days',            100, ...
                                   'num_humans',          2000, ...
                                   'city_dimensions',     [1000; 1000], ...
                                   'humans_stay_in_city', true, ...
                                   'show_everyday_plot',  true, ...
                                   'plot_paths',          false, ...
                                   'save_as_gif',         true, ...
                                   'sim_fig',             sim_figure, ...
                                   'filename',            file_name);
            
            obj.load_config(configuration);
        end
        
        function load_config(obj, config)
            %LOAD_CONFIG Load the given configuration having assessed its
            % validity.
            
            assert(obj.is_valid_config(config));
            
            obj.num_days = config.num_days;
            obj.num_humans = config.num_humans;
            obj.city_dimensions = config.city_dimensions;
            
            obj.humans_stay_in_city = config.humans_stay_in_city;
            obj.show_everyday_plot = config.show_everyday_plot;
            obj.plot_paths = config.plot_paths;
            obj.save_as_gif = config.save_as_gif;
            
            obj.sim_fig = config.sim_fig;
            obj.filename = config.filename;
        end
        
        function valid = is_valid_config(obj, config)
            %IS_VALID_CONFIG Check if the supplied coniguration is valid.
            
            arguments
                obj
                config (1, 1) {mustBeA(config, 'struct')}
            end
            
            valid = 0;
            obj.check_config_fieldnames(config);
            obj.check_config_values(config);
            valid = 1;
        end
        
        function check_config_fieldnames(obj, config)
            %CHECK_CONFIG_FIELDNAMES Check that the config contains the
            % correct fieldnames.
            
            arguments
                obj
                config (1, 1) {mustBeA(config, 'struct')}
            end
            
            valid_fieldnames = ["num_days"; ...
                                "num_humans"; ...
                                "city_dimensions"; ...
                                'humans_stay_in_city'; ...
                                "show_everyday_plot"; ...
                                "plot_paths"; ...
                                "save_as_gif"; ...
                                "sim_fig"; ...
                                "filename"];
                            
            config_fieldnames = string(fieldnames(config));
            
            assert(arrays_have_same_elements(config_fieldnames, valid_fieldnames), ...
                   ['Invalid configuration! The Config struct must contain', ... 
                    ' the following fields:', ...
                    ' num_days, num_humans, city_dimensions, humans_stay_in_city,', ...
                    'show_everyday_plot, plot_paths, save_as_gif, sim_fig, filename!'])
        end
        
        function check_config_values(obj, config)
            %CHECK_CONFIG_VALUES Check that the configuration values are
            % correctly defined.
            % For example, that a value which is supposed to be a scalar is 
            % not a vector, etc.
            
            arguments
                obj
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
               
            assert(isBool(config.humans_stay_in_city));
            
            assert(isBool(config.show_everyday_plot));
            
            assert(isBool(config.plot_paths));
            
            assert(isBool(config.save_as_gif));
            
            assert(isa(config.sim_fig, 'matlab.ui.Figure'));
            
            assert(isStringScalar(config.filename));
        end
    end
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
