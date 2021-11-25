classdef population < handle
    %POPULATION Class representing all humans in the simulation.
    %   This class will contain a set number of humans.
    
    properties
        humans
        humans_by_status
        size
        sir_data
    end
    
    methods
        function obj = population(num_humans)
            %POPULATION Construct a population.
            
            arguments
                num_humans (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            obj.size = num_humans;
        end        
        
        function update_humans(obj, day)
            %UPDATE_HUMANS Update the lists of humans by health status.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBePositive};
            end
            
            obj.humans_by_status.susceptible = obj.get_susceptible_humans();
            obj.humans_by_status.infectious = obj.get_infectious_humans();
            obj.humans_by_status.recovered = obj.get_recovered_humans();
            
            obj.sir_data.num_susceptible(day) = length(obj.humans_by_status.susceptible);
            obj.sir_data.num_infectious(day) = length(obj.humans_by_status.infectious);
            obj.sir_data.num_recovered(day) = length(obj.humans_by_status.recovered);
        end
        
        function update_health_status(obj, day)
            %UPDATE_HEALTH_STATUS Update the health status of the entire
            % population on a given day.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end

            obj.update_infectious(day);
            obj.update_recovered(day);
        end
        
        function update_infectious(obj, day)
            %UPDATE_INFECTIOUS Update the infectious portion of the population.
            % In other words, update how the current infectious will infect
            % the susceptible.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            for human = obj.humans_by_status.infectious
                human.infect_susceptible_humans(day, obj.humans_by_status.susceptible);
            end
        end
        
        function update_recovered(obj, day)
            %UPDATE_RECOVERED Update the recovered portion of the population.
            % In other words, update which of the infectious are recovered on
            % a given day.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            for human = obj.humans_by_status.infectious
                human.check_recovered(day);
            end
        end
        
        function infectious_humans = get_infectious_humans(obj)
            %GET_INFECTIOUS_HUMANS Return portion of humans that are
            % infectious.
            
            infectious_humans = obj.get_humans_with_health_status("infectious");
        end
        
        function susceptible_humans = get_susceptible_humans(obj)
            %GET_SUSCEPTIBLE_HUMANS Return portion of humans that are
            % susceptible.
            
            susceptible_humans = obj.get_humans_with_health_status("susceptible");
        end
        
        function recovered_humans = get_recovered_humans(obj)
            %GET_RECOVERED_HUMANS Return portion of humans that are
            % infectious.
            
            recovered_humans = obj.get_humans_with_health_status("recovered");
        end
        
        function humans = get_humans_with_health_status(obj, health_status)
            %GET_HUMANS_WITH_HEALTH_STATUS Return humans with a specific
            % health status
            
            humans_arr = [obj.humans{:}];
            indices = arrayfun(@(h) h.health_status == health_status, humans_arr);
            humans = vertcat(humans_arr(indices));
        end
    end
end

