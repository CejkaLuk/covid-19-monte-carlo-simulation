classdef human < handle
    %HUMAN Class representing a human in the COVID-19 simulation.
    %   This class contains the human's current position, their path
    %   since the beginning of the simulation, their current 
    %   status.
    
    properties
        path
        position % Struct: cartesian, polar
        health_status % (susceptible), (infected), (recovered/removed)
        movement % = Struct('base', 0, 'mean', 0, 'std_var', 0);
    end
    
    methods
        function obj = human(initial_pos, options)
            %HUMAN Construct a human.
            
            arguments
                initial_pos % x and y coordinates in a 2-element a column vector.
                options.base_movement (1, 1) {mustBeFloat} = 7.9; % Base length of a grid shell from paper -> used to set random
                                                                  % movement length of Human every day.
            end
            
            assert( isequal(size(initial_pos), [2 1]) );
            
            obj.position.cartesian = initial_pos;
            obj.append_pos_to_path(initial_pos)
            
            obj.movement.base = options.base_movement;
            obj.movement.mean = 1/4 * obj.movement.base;
            obj.movement.std_var = 1/12 * obj.movement.base;
            
            obj.health_status = 'susceptible';
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
            obj.position.polar = [rand_theta; rand_rho];
            
            [rand_x, rand_y] = pol2cart(rand_theta, rand_rho);
            
            new_pos = [obj.position.cartesian(1) + rand_x; ...
                       obj.position.cartesian(2) + rand_y];

            obj.move_to(new_pos);
        end
        
        function move_to_random_position_cartesian(obj)
            %MOVE_TO_RANDOM_POSITION_CARTESIAN Move the human to a new random  
            % position that has both x and y generated from a normal distribution 
            % based on its current position.
            
            rand_x = normrnd(obj.movement.mean, obj.movement.std_var);
            rand_y = normrnd(obj.movement.mean, obj.movement.std_var);
            [rand_theta, rand_rho] = cart2pol(rand_x, rand_y);
            obj.position.cartesian = [rand_theta; rand_rho];
            
            new_pos = [obj.position.cartesian(1) + rand_x; ...
                       obj.position.cartesian(2) + rand_y];            
            
            obj.move_to(new_pos);
        end
        
        function move_to(obj, pos)
            %MOVE_TO Move the human to a new [x; y] position and append
            % the new position to the human's path.
            
            assert( isa(pos, 'double') && isequal(size(pos), [2 1]) );
            
            obj.position.cartesian = pos;
            
            obj.append_pos_to_path(obj.position.cartesian);
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
            
            plot(obj.position.cartesian(1), obj.position.cartesian(2), 'o')
            hold on
            
            if options.plot_paths == true
                plot(obj.path(1, :), obj.path(2, :), '-');
            end
        end
        
        function days_walked = get_days_walked(obj)
            %GET_DAYS_WALKED Return the number of days this human has
            % been alive for.
            %  In the context of the simulation, a human walks every single
            %  day, so the number of days walked is the number of days the
            %  simulation has been running for.
            
            % The simulation starts on day 0.
            days_walked = size(obj.path, 2) - 1;
        end
    end
end

