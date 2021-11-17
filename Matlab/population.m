classdef population < handle
    %POPULATION Collection of all humans.
    %   This class will contain a set number of humans.
    
    properties
        humans
        size
    end
    
    methods
        function obj = population(num_humans)
            %POPULATION Create an array of num_humans human classes that
            %start on certain coordinates
            %   First iteration: humans will be spread out equally
            
            obj.size = num_humans;
            
            for i=1:num_humans
                obj.humans{i} = human([i*sin(i); i*cos(i)]);
            end
        end
    end
end

