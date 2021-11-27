classdef data < handle
    %DATA Class holding the data of a simulation.
    %   This class serves as a handle for data that is recorded during the
    %   simulation.
    
    properties
        dnc % Daily New cases
        R_e % Effective reproductive number struct
            % (raw, filtered, moving average)
    end
    
    methods
        function obj = data(num_days)
            %DATA Contructs an empty instance of data.
            %   The data will be occupied via the process function.
            
            arguments
                % [Required] Number of days in the simulation
                num_days (1, 1) {mustBeInteger, mustBePositive};
            end
            
            % Pre-allocate Daily New Cases
            obj.dnc = zeros([1, num_days]);
            
            % Pre-allocate different effective reproductive number
            % variables:
            %   - raw := Pure R_e data obtained from research paper
            %            formula
            %   - filtered := Filtered according to the research paper
            %                 (digital filtering)
            %   - moving_avg := Moving average of R_e
            obj.R_e.raw        = nan([1, num_days]);
            obj.R_e.filtered   = nan([1, num_days]);
            obj.R_e.moving_avg = nan([1, num_days]);
        end
        
        function process(obj, input_city)
           %PROCESS_DATA Processes data from city in simulation run.
            
            arguments
                obj
                % [Required] The input city - for data access
                input_city (1, 1) {mustBeA(input_city, 'city')};
            end
            
            % Get arrays of humans that are or were infectious
            final_infectious = input_city.population.humans_by_status.infectious;
            final_recovered  = input_city.population.humans_by_status.recovered;
            
            % Get SIR data (Susceptible, Infectious, Recovered) from the
            % population
            sir_data = input_city.population.sir_data;
            
            % Extract Daily New Cases from the humans that are or were
            % infectious
            obj.extract_dnc(final_infectious, final_recovered);
            
            % Extract effective reproductive numbers from the SIR data
            obj.extract_R_e(sir_data);
        end
        
        function set_dnc(obj, day, dnc)
            %SET_DNC Sets daily new cases for a specified day.
            
            arguments
                obj
                % [Required] Day on which to set DNC
                day (1, 1) {mustBeInteger, mustBePositive};
                % [Required] Value of DNC
                dnc (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            obj.dnc(day) = dnc;
        end
        
        function dnc = get_dnc(obj, day)
            %GET_DNC Gets daily new cases in a speficie day.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBePositive};
            end
            
            dnc = obj.dnc(day);
        end
        
        function extract_dnc(obj, infectious, recovered)
            %GATHER_DNC Gathers DNC over all humans who were sick (i.e. recovered or infectious).
            
            arguments
                obj
                % [Required] Array of infectious humans at the end of the
                % simulation
                infectious {mustBeA(infectious, 'human')};
                % [Required] Array of recovered humans at the end of the
                % simulation
                recovered  {mustBeA(recovered, 'human')};
            end
            
            % For each human that is or was infectious get their first
            % day of being infected and use it as an index for incrementing
            % the number of new cases on that day.
            for human = [infectious, recovered]
                day     = human.infection.first_day;
                num_dnc = obj.get_dnc(day);
                obj.set_dnc(day, num_dnc + 1);
            end
        end
        
        function extract_R_e(obj, sir_data)
            %GATHER_R_E Gathers R_e over all days and sets its filtered values.
            
            arguments
                obj
                % [Required] SIR data of the entire simulation
                sir_data
            end
            
            % Formula of effective reproductive number according
            % to research paper
            % Towards the end, when there are no new cases, this formula
            % will divide by 0, so the data of R_e is not available for the
            % entire period of te simulation
            % R_e = 1 + ln(I_t_i/I_t_{i-1})
            c = 1;
            for day=2:length(sir_data.num_infectious)
                obj.R_e.raw(day) = 1 + log(sir_data.num_infectious(day)/ ...
                                           sir_data.num_infectious(day - 1))^(1/c);
            end
            
            % According to research paper - digital filtering of R_e
            windowSize = 4; 
            b = (1/windowSize) * ones(1, windowSize);
            obj.R_e.filtered = filter(b, 1, obj.R_e.raw(:));
            
            % 13-Day moving average of R_e
            days_moving = 13;
            obj.R_e.moving_avg = movmean(obj.R_e.filtered, days_moving);
        end

        function plot_dnc(obj)
            %PLOT_DNC Plots Daily New Cases in its own figure.
            
            dnc_fig = figure('Name', 'Daily New Cases (DNC)', ...
                             'NumberTitle', 'off', 'visible', 'off');
            figure(dnc_fig)
            
            plot(obj.dnc, '-o')
            
            title('Daily new cases (DNC) development in MC simulation', ...
                  'interpreter', 'latex')
            
            legend('Daily new cases (DNC)', 'interpreter', 'latex')
            
            xlabel('Time [day]', 'interpreter', 'latex')
            ylabel('Number of new cases per day', 'interpreter', 'latex')
        end
        
        function plot_R_e(obj)
            %PLOT_R_E Plots daily effective reproductive number (R_e) in its
            % own figure.
            
            % Declare dark-green color for plot of 13-day moving average
            dark_green = [62 150 81]/255;
            
            R_e_fig = figure('Name', 'Effective reproductive number (R_e)', ...
                             'NumberTitle', 'off', 'visible', 'off');
            figure(R_e_fig)
            hold on
            
            % Plot the digitally-filtered effective reproductive number
            plot(obj.R_e.filtered, '-o red')
            
            % Plot the base R_0 value
            yline(1, '-- red')
            
            % Plot the 13-Day moving average
            plot(obj.R_e.moving_avg, '-', ...
                 'Color', dark_green, ...
                 'LineWidth', 1.5)
            
            title('Effective reproductive number ($$R_e$$) development in MC simulation', ...
                  'interpreter', 'latex')
            
            legend('Effective reproductive number $$R_e$$', ...
                   'Threshold level $$R_e(0) = R_0 = 1$$', ...
                   '13-Day Moving Average of $$R_e$$', ...
                   'interpreter', 'latex')
            
            xlabel('Time [day]', 'interpreter', 'latex')
            ylabel('Daily $$R_e$$', 'interpreter', 'latex')
        end
        
        function plot_all(obj)
            %PLOT_ALL Plots data from simulation run.
            
            obj.plot_dnc();
            obj.plot_R_e();
        end
    end
end

