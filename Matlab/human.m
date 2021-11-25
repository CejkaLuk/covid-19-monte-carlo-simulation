classdef human < handle
    %HUMAN Class representing a human in the COVID-19 simulation.
    %   This class contains the human's current position, their path
    %   since the beginning of the simulation, their current 
    %   status.
    
    properties
        path
        position % Assumend cartesian
        health_status % (susceptible), (infected), (recovered)
        movement % = Struct('base', 0, 'mean', 0, 'std_var', 0);
        infection % = Struct('first_day', 0, 'infectious_duration', 0, 'mean_distance', 0, 'exp_distr.lambda', 0)
        city_bounds
    end
    
    methods
        function obj = human(initial_pos, infectious_duration,  options)
            %HUMAN Construct a human.
            
            arguments
                initial_pos % x and y coordinates in a 2-element a column vector.
                infectious_duration (1, 1) {mustBeFloat};
                options.base_movement (1, 1) {mustBeFloat}; % Base length of a grid shell from paper -> used to set random
                                                            % movement length of Human every day.
                options.health_status (1, 1) {mustBeTextScalar} = "susceptible";
                options.mean_infection_distance (1, 1) {mustBeFloat} = 8; % Mean infection distance in meters.
                options.movement_limits (1, 4) {mustBeFloat} = nan;
            end
            
            obj.movement.base = options.base_movement;
            obj.movement.mean = 1/4 * obj.movement.base;
            obj.movement.std_var = 1/12 * obj.movement.base;
            obj.movement.limits = options.movement_limits;
            
            obj.set_position(initial_pos);
            
            obj.health_status = options.health_status;
            
            obj.infection.duration = infectious_duration;
            obj.infection.mean_distance = options.mean_infection_distance;
        end
        
        function move_to_random_position(obj, options)
            %MOVE_TO_RANDOM_POSITION Move the human to a new random
            % position.
            % This position can be generated using cartesian or
            % polar coordinates.
            
            arguments
                obj
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
            %MOVE_TO_RANDOM_POSITION_CARTESIAN Move the human to a new random  
            % position that is first generated in polar coordinates and then
            % converted to cartesian.
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
            %MOVE_TO_RANDOM_POSITION_CARTESIAN Move the human to a new random  
            % position that has both x and y generated from a normal distribution 
            % based on its current position.
            
            rand_x = normrnd(obj.movement.mean, obj.movement.std_var);
            rand_y = normrnd(obj.movement.mean, obj.movement.std_var);
            
            new_pos = [obj.position(1) + rand_x; ...
                       obj.position(2) + rand_y];            
            
            obj.set_position(new_pos);
        end
        
        function set_position(obj, pos)
            %SET_POSITION Move the human to a new [x; y] position and append
            % the new position to the human's path.
            
            assert( isa(pos, 'double') && isequal(size(pos), [2 1]) );
            
            obj.position = obj.correct_pos_if_out_of_bounds(pos);
            
            obj.append_pos_to_path(obj.position);
        end
        
        function new_pos = correct_pos_if_out_of_bounds(obj, pos)
            %CORRECT_POST_IF_OUT_OF_BOUNDS If the position is out of bounds
            % set for the human -> redefine position to be at bounds.
            % Otherwise leave position as is.
            
            new_pos = pos;
            
            if isnan(obj.movement.limits)    
                return
            end
            
            x_lower = obj.movement.limits(1);
            x_upper = obj.movement.limits(2);
            y_lower = obj.movement.limits(3);
            y_upper = obj.movement.limits(4);
            
            if new_pos(1) < x_lower
                new_pos(1) = x_lower;
            elseif x_upper < new_pos(1)
                new_pos(1) = x_upper;
            end
            
            if new_pos(2) < y_lower
                new_pos(2) = y_lower;
            elseif y_upper < new_pos(2)
                new_pos(2) = y_upper;
            end
        end
        
        function append_pos_to_path(obj, pos)
            %APPEND_POSITION_TO_PATH Given an [x; y] position, it is added as
            % the last element to the human's path.
            
            obj.path(:, end + 1) = pos;
        end
        
        function plot(obj, options)
            %PLOT Plot the human's current position and their path up to
            % this point.
            
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
            %SET_HEALTH_STATUS Set the health status of the human.
            % If the human is about to be infected, we need to know the
            % day.
            % The human will never be labelled as infected, if they're
            % already infected - the function in population only considers
            % susceptible humans to infect.
            
            arguments
                obj
                health_status (1, 1) {mustBeTextScalar, mustBeNonempty};
                options.day (1, 1) {mustBeInteger, mustBeNonnegative};
            end

            assert(ismember(health_status, ["susceptible", "infected", "recovered"]), ...
                   "Error! Unrecognized health status of human! Valid values are: 'susceptible', 'infected', 'recovered'.");
            if health_status == "infected"
                mustBeNonempty(options.day);
            end
            
            if health_status == "infected"
                obj.infection.first_day = options.day;
                obj.infection.last_day = obj.infection.first_day + obj.infection.duration;
            end              
               
            obj.health_status = health_status;
        end
        
        function check_recovered(obj, day)
            %CHECK_RECOVERED Check if the human is recovered on a specific day.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            if day >= obj.infection.last_day
                obj.set_health_status("recovered");
            end
        end
        
        function color = get_color_of_health_status(obj)
            %GET_COLOR_OF_HEALTH_STATUS Get colour representing each health
            % status.
            
            switch obj.health_status
                case "susceptible"
                    color = [0 0.4470 0.7410]; % Default light blue
                case "infected"
                    color = "red";
                otherwise
                    color = [200 200 200]/255;
            end
        end
        
        function prob = get_infection_prob_of_human(obj, human)
            %GET_INFECTION_PROB_OF_HUMAN Get the probability that this
            % human will infect a given human.
            
            arguments
                obj
                human (1, 1) {mustBeA(human, 'human')};
            end
            
            distance = obj.get_eucledian_distance_from_human(human);
            
            prob = round(exp(-distance/obj.infection.mean_distance), 2);
        end
        
        function distance = get_eucledian_distance_from_human(obj, human)
            %GET_EUCLEDIAN_DISTANCE_FROM_HUMAN Get the distance from this
            % human to a given human.
            
            arguments
                obj
                human (1, 1) {mustBeA(human, 'human')};
            end
            
            human_pos = human.position;
            distance = sqrt((obj.position(1)-human_pos(1))^2 + ...
                            (obj.position(2)-human_pos(2))^2);
        end
    end
end

