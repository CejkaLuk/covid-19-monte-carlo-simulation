classdef population < handle
    %POPULATION Class representing all humans in the simulation.
    %   This class will contain a set number of humans.
    
    properties
        humans
        humans_by_status
        size
    end
    
    methods
        function obj = population(num_humans)
            %POPULATION Construct a population.
            
            arguments
                num_humans (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            obj.size = num_humans;
        end        
        
        function update_humans(obj)
            %UPDATE_HUMANS Update the lists of humans by health status.
            
            obj.humans_by_status.susceptible = obj.get_susceptible_humans();
            obj.humans_by_status.infected = obj.get_infected_humans();
            obj.humans_by_status.recovered = obj.get_recovered_humans();
        end
        
        function update_health_status(obj, day)
            %UPDATE_HEALTH_STATUS Update the health status of the entire
            % population on a given day.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end

            obj.update_infected(day);

            obj.update_recovered(day);
        end
        
        function update_infected(obj, day)
            %UPDATE_INFECTED Update the infected portion of the population.
            % In other words, update how the current infected will infect
            % the susceptible.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            for human = obj.humans_by_status.infected
                obj.infect_susceptible_humans(day, human);
            end
        end
        
        function update_recovered(obj, day)
            %UPDATE_RECOVERED Update the recovered portion of the population.
            % In other words, update which of the infected are recovered on
            % a given day.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            for human = obj.humans_by_status.infected
                human.check_recovered(day);
            end
        end
        
        function infect_susceptible_humans(obj, day, human)
            %INFECT_SUSCEPTIBLE_HUMANS Calculate how a given human will
            % infect susceptible humans on a given day.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBeNonnegative};
                human (1, 1) {mustBeA(human, 'human')};
            end
            
            for susceptible_human = obj.humans_by_status.susceptible                
                infection_prob = human.get_infection_prob_of_human(susceptible_human);
                
                if rand() <= infection_prob
                    susceptible_human.set_health_status("infected", ...
                                                        day=day);
                end
            end                
        end
        
        function infected_humans = get_infected_humans(obj)
            %GET_INFECTED_HUMANS Return portion of humans that are
            % infected.
            
            infected_humans = obj.get_humans_with_health_status("infected");
        end
        
        function susceptible_humans = get_susceptible_humans(obj)
            %GET_SUSCEPTIBLE_HUMANS Return portion of humans that are
            % susceptible.
            
            susceptible_humans = obj.get_humans_with_health_status("susceptible");
        end
        
        function recovered_humans = get_recovered_humans(obj)
            %GET_RECOVERED_HUMANS Return portion of humans that are
            % infected.
            
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

