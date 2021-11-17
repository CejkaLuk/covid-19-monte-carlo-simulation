classdef city < handle
    %CITY Class containing the city that will house the population.
    %   This class will contain the size of the city where a population of
    %   humans will live.
    
    properties
        dimensions
        area
        population
    end
    
    methods
        function obj = city(city_dimensions, pop_size)
            %CITY Construct a city class of a given size with a population
            %of a given size.
            %   Params:
            %       - city_dimensiosn := a column vector with x and y 
            %         coordinates.
            %       - pop_size := # of humans in the city.
            
            assert(all(size(city_dimensions) == [2 1]));
            
            obj.dimensions = city_dimensions;
            obj.area = city_dimensions(1) * city_dimensions(2);
            obj.population = population(pop_size);
        end
        
        function population_density = get_population_density(obj)
            %POPULATION_DENSITY Returns population density as the
            %population divided by the area of the city.
            population_density = obj.population.size / obj.area;
        end
    end
end

