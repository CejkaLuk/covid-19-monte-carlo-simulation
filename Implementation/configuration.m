classdef configuration < handle
    %CONFIGURATION Class housing the configuration for the COVID-19 simulation.
    %   This class holds values used by the simulation. 
    %   It includes checking the validity of the supplied configuration and 
    %   providing a default configuration is one is not supplied.
    
    properties
        num_days            % Number of days the simulation will run
        num_humans          % Number of humans in the simulation
        city_dimensions     % Dimensions of the city (city bounds)
        humans_stay_in_city % If humans must stay in the city
        show_everyday_plot  % If every day should be plotted
        plot_paths          % If human paths should be plotted
        save_as_gif         % If every day of the simulation should be 
                            % added to a .gif file 
        sim_fig             % The simulation figure
        filename            % The .gif file name
    end
    
    methods
        function obj = configuration(config)
            %CONFIGURATION Constructs the configuration of the simulation.
            
            arguments
                % [Optional] Structure that contains values of the
                % configuration - empty by default
                config (1, 1) {mustBeA(config, 'struct')} = struct();
            end
            
            % Set the configuration
            obj.set_config(config);
        end
        
        function set_config(obj, config)
            %SET_CONFIG Sets the configuration of the simulation.
            % If there is not configuration supplied -> set default
            % configuration specified in set_default_config().
            
            arguments
                obj
                % [Required] Configuration to be set
                config (1, 1) {mustBeA(config, 'struct')};
            end
            
            % If the input configuration is empty (no configuration struct
            % was given to the constructor) -> Load the default
            % configuration
            if isempty(fieldnames(config))
                obj.load_default_config();
            else
                % Load the input configuration
                obj.load_config(config);
            end
        end
        
        function load_default_config(obj)
            %SET_DEFAULT_CONFIG Sets the default configuration.
            
            % Set the figure
            sim_figure = figure('Name', 'COVID-19 Monte Carlo Simulation of humans in a city', ...
                                'NumberTitle', 'off', 'visible', 'off');
            
            % Set the filename of the output .gif file
            file_name = "simulation_" + string(floor(posixtime(datetime))) + ".gif";
            
            % Create default configuration -> a struct with default values 
            % from the research paper
            config = struct('num_days',            100, ...
                            'num_humans',          2000, ...
                            'city_dimensions',     [1000; 1000], ...
                            'humans_stay_in_city', true, ...
                            'show_everyday_plot',  true, ...
                            'plot_paths',          false, ...
                            'save_as_gif',         true, ...
                            'sim_fig',             sim_figure, ...
                            'filename',            file_name);
            
            % Load the data from the default config struct
            obj.load_config(config);
        end
        
        function load_config(obj, config)
            %LOAD_CONFIG Loads the given configuration having assessed its
            % validity.
            
            arguments
                obj
                % [Required] Configuration to be set
                config (1, 1) {mustBeA(config, 'struct')};
            end
            
            % Check that the input config struct is valid
            assert(obj.is_valid_config(config));
            
            % Load all the data from the input config struct
            obj.num_days        = config.num_days;
            obj.num_humans      = config.num_humans;
            obj.city_dimensions = config.city_dimensions;
            
            obj.humans_stay_in_city = config.humans_stay_in_city;
            obj.show_everyday_plot  = config.show_everyday_plot;
            obj.plot_paths          = config.plot_paths;
            obj.save_as_gif         = config.save_as_gif;
            
            % Alter the size of the figure, so that the legend doesn't
            % squash the main plot
            pos = get(gcf, 'Position');
            config.sim_fig.Position = [pos(1) pos(2) pos(3)*1.3 pos(4)];
            
            obj.sim_fig  = config.sim_fig;
            obj.filename = config.filename;
        end
        
        function valid = is_valid_config(obj, config)
            %IS_VALID_CONFIG Checks if the supplied coniguration is valid.
            
            arguments
                obj
                % [Required] Configuration to be set
                config (1, 1) {mustBeA(config, 'struct')};
            end
            
            % By default, the config is not valid
            valid = 0;
            
            % The following functions will throw an error if the
            % configuration is not valid
            obj.check_fieldnames(config);
            obj.check_values(config);
            
            % All checks passed, config is valid
            valid = 1;
        end
        
        function check_fieldnames(obj, config)
            %CHECK_CONFIG_FIELDNAMES Checks that the config contains the
            % correct fieldnames.
            
            arguments
                obj
                % [Required] Configuration to be set
                config (1, 1) {mustBeA(config, 'struct')}
            end
            
            % Declare valid field names.
            valid_fieldnames = ["num_days"; ...
                                "num_humans"; ...
                                "city_dimensions"; ...
                                "humans_stay_in_city"; ...
                                "show_everyday_plot"; ...
                                "plot_paths"; ...
                                "save_as_gif"; ...
                                "sim_fig"; ...
                                "filename"];
            
            % Get field names of the input configuration
            config_fieldnames = string(fieldnames(config));
            
            % Check that fieldnames are valid
            assert(arrays_have_same_elements(config_fieldnames, valid_fieldnames), ...
                   ['Invalid configuration! The Config struct must contain', ... 
                    ' the following fields:', ...
                    ' num_days, num_humans, city_dimensions, humans_stay_in_city,', ...
                    ' show_everyday_plot, plot_paths, save_as_gif, sim_fig, filename!'])
        end
        
        function check_values(obj, config)
            %CHECK_CONFIG_VALUES Checks that the configuration values are
            % correctly defined.
            % For example, that a value which is supposed to be a scalar is 
            % not a vector, etc.
            
            arguments
                obj
                % [Required] Configuration to be set
                config (1, 1) {mustBeA(config, 'struct')}
            end
            
            % Helper functions
            is_integer = @(x) floor(x) == x;
            is_bool = @(x) islogical(x) && isscalar(x);
            
            % Check that the number of days is a non-negative scalar integer
            assert(is_integer(config.num_days) && ...
                   isscalar(config.num_days) && ...
                   config.num_days >= 0);
            
            % Check that the number of humans is a positive scalar integer
            assert(is_integer(config.num_humans) && ...
                   isscalar(config.num_humans) && ...
                   config.num_humans > 0);
            
            % Check that the city dimensions are a 2x1 positive double
            assert(isa(config.city_dimensions, 'double') && ...
                   isequal(size(config.city_dimensions), [2 1]) && ...
                   all(config.city_dimensions(:) > 0));
            
            % Check that given boolean settings are booleans
            assert(is_bool(config.humans_stay_in_city));
            
            assert(is_bool(config.show_everyday_plot));
            
            assert(is_bool(config.plot_paths));
            
            assert(is_bool(config.save_as_gif));
            
            % Check that the given figure is a figure
            assert(isa(config.sim_fig, 'matlab.ui.Figure'));
            
            % Check that the file name for the .gif file is a scalar
            % string
            assert(isStringScalar(config.filename));
        end
        
        function print(obj)
            %PRINT Prints the configuration.
            
            fprintf("\nCOVID-19 simulation coniguration: \n\n");
            fprintf("  Number of days:\t\t\t\t  %d\n", obj.num_days);
            fprintf("  Number of humans:\t\t\t\t  %d\n", obj.num_humans);
            fprintf("  City dimension:\t\t\t\t  %d x %d\n", obj.city_dimensions(1), ...
                                                            obj.city_dimensions(2));
            fprintf("  Humans stay in city:\t\t\t  %s\n", mat2str(obj.humans_stay_in_city));
            fprintf("  Show plot of every day:\t\t  %s\n", mat2str(obj.show_everyday_plot));
            fprintf("  Plot paths of humans:\t\t\t  %s\n", mat2str(obj.plot_paths));
            fprintf("  Save simulation as a .gif file: %s\n", mat2str(obj.save_as_gif));
        end
    end
end


function correct = arrays_have_same_elements(arr1, arr2)
    %ARRAYS_HAVE_SAME_ELEMENTS Validates whether two arrays
    % contain the same elements.

    % If the size of the intersection is the same as one of the input
    % arrays -> the elements are the same
    if all(size(intersect(arr1, arr2)) == size(arr1)) || ...
       all(size(intersect(arr1, arr2)) == size(arr2))
        correct = 1;
    else
        correct = 0;
    end
end
