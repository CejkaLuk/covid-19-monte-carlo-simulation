classdef human < handle
    %HUMAN Class representing a human in the COVID-19 simulation
    %   This class should contain everything from the human's current
    %   position, their entire path since the beginning of the simulation,
    %   their current status (susceptible, infected, recovered/removed).
    
    properties
        path
        position
    end
    
    methods
        function obj = human(initial_position)
            %HUMAN Construct a human.
            %   Params:
            %       - initial_position := x and y coordinates in a 2-element
            %         a column vector.
            
            assert(all(size(initial_position) == [2 1]));
            
            obj.position = initial_position;
            obj.append_position_to_path(initial_position)
        end
        
        function append_position_to_path(obj, pos)
            %ADD_POSITION_TO_PATH Given an [x; y] position, it is added as
            %the last element to the human's path.
            obj.path(:, end + 1) = pos;
        end
        
        function move_to_random_position(obj)
            %MOVE_TO_RANDOM_POSITION Move the human in a random direction from its current
            %position and add the new position to the human's path.
            obj.position(1) = obj.position(1) + normrnd(0, 1/6)*5;
            obj.position(2) = obj.position(2) + normrnd(0, 1/6)*5;
            
            obj.append_position_to_path(obj.position);
        end
        
        function move_to_position_based_on_func(obj, func)
            %MOVE_TO_RANDOM_POSITION Move the human in a random direction from its current
            %position and add the new position to the human's path.
            obj.position(1) = obj.position(1) + func()*2-1;
            obj.position(2) = obj.position(2) + func()*2-1;
            
            obj.append_position_to_path(obj.position);
        end
        
        function plot(obj, fig)
            %PLOT Plot the human's current position and their path up to
            %this point
            figure(fig);
            
            plot(obj.position(1), obj.position(2), 'o')
            hold on

            plot(obj.path(1, 1:end), obj.path(2, 1:end))
        end
    end
end

