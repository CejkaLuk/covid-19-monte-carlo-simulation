classdef population < handle
    %POPULATION Class representing all humans in the simulation.
    %   This class will contain a set number of humans.
    
    properties
        humans
        size
    end
    
    methods
        function obj = population(num_humans)
            %POPULATION Construct a population.
            %   Params:
            %       - num_humans := number of humans in the population.
            
            obj.size = num_humans;
        end
    end
end

