classdef human < handle
    %HUMAN Class representing a human in the COVID-19 simulation.
    %   This class contains the human's current position, their path
    %   since the beginning of the simulation, their current health
    %   status, movement info, infection info, etc.
    
    properties
        path          % Path of the human
        position      % Cartesian position of the human
        health_status % Health status of the human:
                      % susceptible, infectious, recovered
        movement      % Struct storing any movement values of the human:
                      %     - base := base distance of movement
                      %     - mean := mean distance of movement
                      %     - std_var := std. variance of movement
                      %     - limits := boundaries that the human cannot cross (optional)
        infection     % Struct storing any infection values
                      %     - first_day := first day that the human is infectious
                      %     - duration := duration of the human's infectious status
                      %     - last_day := last day that the human is sick
                      %     - mean_distance := mean infectious distance
        city_bounds   % Bounds of the city that the human is located in
    end
    
    methods
        function obj = human(initial_pos, infectious_duration,  options)
            %HUMAN Constructs a human.
            
            arguments
                % [Required] Initial position of the human
                initial_pos                     (2, 1) {mustBeFloat};
                % [Required] Duration of the human's infectious status
                infectious_duration             (1, 1) {mustBeFloat};
                % [Optional] Base movement distance of the human
                options.base_movement           (1, 1) {mustBeFloat};
                % [Optional] Health status of the human
                options.health_status           (1, 1) {mustBeTextScalar} = "susceptible";
                % [Optional] Mean infectious distance in meters
                options.mean_infectious_distance (1, 1) {mustBeFloat} = 8;
                % [Optional] Limits of the human's movement - not allowed
                %            to move past these limits
                options.movement_limits         (1, 4) {mustBeFloat} = nan;
            end
            
            % Set the human's movement
            obj.movement.base = options.base_movement;
            % Constants 1/4 and 1/12 are taken from the research paper
            obj.movement.mean = 1/4 * obj.movement.base;
            obj.movement.std_var = 1/12 * obj.movement.base;
            obj.movement.limits = options.movement_limits;
            
            obj.set_position(initial_pos);
            
            obj.health_status = options.health_status;
            
            obj.infection.duration = infectious_duration;
            obj.infection.mean_distance = options.mean_infectious_distance;
        end
        
        function move_to_random_position(obj, options)
            %MOVE_TO_RANDOM_POSITION Moves the human to a new random
            % position.
            % This position can be generated using cartesian or
            % polar coordinates.
            
            arguments
                obj
                % [Optional] Move the human to a random position
                %            - By default use polar coodinates to generate 
                %              random position
                options.coords {mustBeTextScalar} = "polar";
            end
            
            if options.coords == "cartesian"
                obj.move_to_random_position_cartesian();
            elseif options.coords == "polar"
                obj.move_to_random_position_polar();
            else
                error('Error. Random coordinates can only be generated using "cartesian" or "polar" coordinate systems!')
            end
        end
        
        function move_to_random_position_polar(obj)
            %MOVE_TO_RANDOM_POSITION_POLAR Moves the human to a new random  
            % position that is first generated in polar coordinates and then
            % converted to cartesian based on the human's current position.
            % Theta is from a uniform distribution and rho is from a normal
            % distribution.
            
            rand_theta = rand() * 2*pi;
            rand_rho = normrnd(obj.movement.mean, obj.movement.std_var);
            
            [rand_x, rand_y] = pol2cart(rand_theta, rand_rho);
            
            new_pos = [obj.position(1) + rand_x; ...
                       obj.position(2) + rand_y];

            obj.set_position(new_pos);
        end
        
        function move_to_random_position_cartesian(obj)
            %MOVE_TO_RANDOM_POSITION_CARTESIAN Moves the human to a new random  
            % cartesian position that has both x and y generated from a normal 
            % distribution based on its current position.
            
            rand_x = normrnd(obj.movement.mean, obj.movement.std_var);
            rand_y = normrnd(obj.movement.mean, obj.movement.std_var);
            
            new_pos = [obj.position(1) + rand_x; ...
                       obj.position(2) + rand_y];            
            
            obj.set_position(new_pos);
        end
        
        function set_position(obj, new_pos)
            %SET_POSITION Moves the human to a new [x; y] position and
            % appends the new position to the human's path.

            arguments
                obj
                % [Required] New position of the human
                new_pos (2, 1) {mustBeFloat, mustBeNonempty};
            end
            
            % Verify that the position is correctly formatted
            assert(isequal(size(new_pos), [2 1]));
            
            % Correct the position if the human is out of bounds
            obj.position = obj.correct_pos_if_out_of_bounds(new_pos);
            
            % Append the position to the human's path
            obj.append_pos_to_path(obj.position);
        end
        
        function new_pos = correct_pos_if_out_of_bounds(obj, pos)
            %CORRECT_POST_IF_OUT_OF_BOUNDS Corrects the position if it 
            % is out of bounds.
            % Otherwise leave the position as it is.
            
            arguments
                obj
                % [Required] Position to be corrected
                pos (2, 1) {mustBeFloat, mustBeNonempty};
            end
            
            new_pos = pos;
            
            % If movement limits are not specified, they are nan -> 
            if isnan(obj.movement.limits)    
                return
            end
            
            % If movement limits are specified, make sure it is inside the
            % bounds
            new_pos = obj.keep_position_in_bounds(new_pos, obj.movement.limits);
        end
        
        function pos = keep_position_in_bounds(obj, pos, bounds)
            %KEEP_POSITION_IN_BOUNDS Keeps the position in bounds.
            % If the position is out of bounds, then it will be set
            % to the bound limits.
            
            arguments
                obj
                pos (2, 1) {mustBeFloat, mustBeNonempty};
                % [Required] Bounds of the position
                bounds (1, 4) {mustBeFloat, mustBeNonempty};
            end
            
            % Get the lower and upper x and y values
            x_lower = bounds(1);
            x_upper = bounds(2);
            y_lower = bounds(3);
            y_upper = bounds(4);
            
            % If x position is less than the lower bounds ->  correct it
            if pos(1) < x_lower
                pos(1) = x_lower;
            elseif x_upper < pos(1)
                pos(1) = x_upper;
            end
            
            if pos(2) < y_lower
                pos(2) = y_lower;
            elseif y_upper < pos(2)
                pos(2) = y_upper;
            end
        end
        
        function append_pos_to_path(obj, pos)
            %APPEND_POSITION_TO_PATH Appends the given [x; y] position
            % to the human's path.
            % It is added as the last element to the human's path.
            
            obj.path(:, end + 1) = pos;
        end
        
        function infect_susceptible_humans(obj, day, susceptible_humans)
            %INFECT_SUSCEPTIBLE_HUMANS Calculates how a given human will
            % infect susceptible humans on a given day.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
                % [Required] Array of susceptible humans
                susceptible_humans {mustBeA(susceptible_humans, 'human')};
            end
            
            % Infect susceptible humans with a probability based on the
            % distance between this human and the susceptible human
            for susceptible_human = susceptible_humans                
                infection_prob = obj.get_infection_prob_of_human(susceptible_human);
                
                if rand() <= infection_prob
                    susceptible_human.set_health_status("infectious", ...
                                                        day=day);
                end
            end                
        end
        
        function plot(obj, options)
            %PLOT Plots the human's current position and their path up to
            % this point (optional).
            
            arguments
                obj
                options.plot_paths (1, 1) {mustBeA(options.plot_paths, 'logical')} = true;
            end
            
            default_blue_color = [0 0.4470 0.7410];
            
            plot(obj.position(1), obj.position(2), 'o', ...
                 'MarkerEdgeColor', default_blue_color, ...
                 'MarkerFaceColor', obj.get_color_of_health_status())
            hold on
            
            if options.plot_paths == true
                plot(obj.path(1, :), obj.path(2, :), '-');
            end
        end
        
        function set_health_status(obj, health_status, options)
            %SET_HEALTH_STATUS Sets the health status of the human.
            % If the human is about to be infectious, we need to know the
            % day.
            
            arguments
                obj
                health_status (1, 1) {mustBeTextScalar, mustBeNonempty};
                % [Required if health_status == infectious]
                options.day (1, 1) {mustBeInteger, mustBeNonnegative};
            end

            % Check that the health status is valid
            assert(ismember(health_status, ["susceptible", "infectious", "recovered"]), ...
                   "Error! Unrecognized health status of human! Valid values are: 'susceptible', 'infectious', 'recovered'.");
            
            % If the health status to-be-set is infectious, we need the day
            if health_status == "infectious"
                mustBeNonempty(options.day);
                
                % Set the first day the human is infectious
                obj.infection.first_day = options.day;

                % Set the last day the human is infectious
                obj.infection.last_day = obj.infection.first_day + obj.infection.duration;
            end              
               
            obj.health_status = health_status;
        end
        
        function check_recovered(obj, day)
            %CHECK_RECOVERED Checks if the human is recovered from a specific day.
            % If yes, then the health status is changed.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            if day >= obj.infection.last_day
                obj.set_health_status("recovered");
            end
        end
        
        function color = get_color_of_health_status(obj)
            %GET_COLOR_OF_HEALTH_STATUS Gets the colour representing each health
            % status.
            
            switch obj.health_status
                case "susceptible"
                    color = [0 0.4470 0.7410]; % Default light blue
                case "infectious"
                    color = "red";
                otherwise
                    color = [200 200 200]/255;
            end
        end
        
        function prob = get_infection_prob_of_human(obj, human)
            %GET_INFECTION_PROB_OF_HUMAN Gets the probability that this
            % human will infect a given human.
            
            arguments
                obj
                % [Required] The human that this human will infect
                % with a certain probability
                human (1, 1) {mustBeA(human, 'human')};
            end
            
            distance = obj.get_eucledian_distance_from_human(human);
            
            % Probability of infection is from exponential distribution
            % This is the value of the integral of the PDF from distance
            % to inf
            prob = round(exp(-distance/obj.infection.mean_distance), 2);
        end
        
        function distance = get_eucledian_distance_from_human(obj, human)
            %GET_EUCLEDIAN_DISTANCE_FROM_HUMAN Gets the Eucledian distance 
            % from this human to a given human.
            
            arguments
                obj
                human (1, 1) {mustBeA(human, 'human')};
            end
            
            % This is faster than the built-in MATLAB function 'pdist'
            distance = sqrt((obj.position(1)-human.position(1))^2 + ...
                            (obj.position(2)-human.position(2))^2);
        end
    end
end

