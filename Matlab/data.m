classdef data < handle
    %DATA Class holding the data of a simulation
    %   This class serves as a handle for data that is acquire during the
    %   simulation.
    
    properties
        dnc
        R_e
    end
    
    methods
        function obj = data(num_days)
            %DATA Contruct an empty instance of data.
            %   The data will be occupied via the process function.
            
            arguments
                num_days (1, 1) {mustBeInteger, mustBePositive};
            end
            
            obj.dnc = zeros([1, num_days]);
            obj.R_e.raw = nan([1, num_days]);
            obj.R_e.filtered = nan([1, num_days]);
            obj.R_e.moving_avg = nan([1, num_days]);
        end
        
        function process(obj, input_city)
           %PROCESS_DATA Process data from simulation run.
            
            arguments
                obj
                input_city (1, 1) {mustBeA(input_city, 'city')};
            end
            
            final_infectious = input_city.population.humans_by_status.infectious;
            final_recovered = input_city.population.humans_by_status.recovered;
            sir_data = input_city.population.sir_data;
            
            obj.extract_dnc(final_infectious, final_recovered);
            obj.extract_R_e(sir_data);
        end
        
        function set_dnc(obj, day, dnc)
            %SET_DNC Setter for daily new cases.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBePositive};
                dnc (1, 1) {mustBeInteger, mustBeNonnegative};
            end
            
            obj.dnc(day) = dnc;
        end
        
        function dnc = get_dnc(obj, day)
            %GET_DNC Getter for daily new cases.
            
            arguments
                obj
                day (1, 1) {mustBeInteger, mustBePositive};
            end
            
            dnc = obj.dnc(day);
        end
        
        function extract_dnc(obj, infectious, recovered)
            %GATHER_DNC Gather DNC over all humans who were sick (i.e. recovered or infectious).
            
            for human = [infectious, recovered]
                day = human.infection.first_day;
                old_val = obj.dnc(day);
                obj.set_dnc(day, old_val + 1);
%                 obj.dnc(day) = old_val + 1;
            end
        end
        
        function extract_R_e(obj, sir_data)
            %GATHER_R_E Gather R_e, it's data over all days.
            % Towards the end, when there are no new cases, this formula
            % will divide by 0, so the data of R_e is not available for the
            % entire period of te simulation.
            
            c = 1;
            for day=2:length(sir_data.num_infectious)
                obj.R_e.raw(day) = 1 + log(sir_data.num_infectious(day)/...
                                           sir_data.num_infectious(day - 1))^(1/c);
            end
            
            % According to paper results - digital filtering
            windowSize = 4; 
            b = (1/windowSize) * ones(1, windowSize);
            obj.R_e.filtered = filter(b, 1, obj.R_e.raw(:));
            
            days_moving = 13;
            obj.R_e.moving_avg = movmean(obj.R_e.filtered, days_moving);
        end

        function plot_dnc(obj)
            %PLOT_DNC Plot daily new cases in its own figure.
            
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
            %PLOT_R_E Plot daily effective reproductive number (R_e) in its
            % own figure.
            
            default_blue_color = [0 0.4470 0.7410];
            dark_green = [62 150 81]/255;
            R_e_fig = figure('Name', 'Effective reproductive number (R_e)', ...
                             'NumberTitle', 'off', 'visible', 'off');
            figure(R_e_fig)
            hold on
            
            plot(obj.R_e.filtered, '-o red')
            yline(1, '-- red')
            
            plot(obj.R_e.moving_avg, '-', ...
                 'Color', dark_green, ...
                 'LineWidth', 1.5)
            
            % According to paper - error bars correspond to moving average
            % values.
%             errorbar(obj.R_e.moving_avg, obj.R_e.moving_avg/10, ...
%                      'Color', default_blue_color)
            
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
            %PLOT_ALL Plot data from simulation run.
            
            obj.plot_dnc();
            obj.plot_R_e();
        end
    end
end

