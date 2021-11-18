classdef human < handle
    %HUMAN Class representing a human in the COVID-19 simulation.
    %   This class contains the human's current position, their path
    %   since the beginning of the simulation, their current 
    %   status.
    
    properties
        path
        position
        health_status % (Susceptible), (Infected), (Recovered/Removed)
    end
    
    methods
        function obj = human(initial_pos)
            %HUMAN Construct a human.
            %   Params:
            %       - initial_position := x and y coordinates in a 2-element
            %         a column vector.
            
            assert( isequal(size(initial_pos), [2 1]) );
            
            obj.position = initial_pos;
            obj.append_pos_to_path(initial_pos)
            
            obj.health_status = 'Susceptible';
        end
        
        function move_to_random_position(obj)
            %MOVE_TO_RANDOM_POSITION Move the human to a new random position 
            % based on its current position.
            
            random_pos = [obj.position(1) + normrnd(0, 1/12)*5; ...
                          obj.position(2) + normrnd(0, 1/12)*5];
            
            obj.move_to(random_pos);
        end
        
        function move_to(obj, pos)
            %MOVE_TO Move the human to a new [x; y] position and append
            % the new position to the human's path.
            
            assert( isa(pos, 'double') && isequal(size(pos), [2 1]) );
            
            obj.position = pos;
            
            obj.append_pos_to_path(obj.position);
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
                options.plot_paths (1, 1) = true
            end
            
            plot(obj.position(1), obj.position(2), 'o')
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

