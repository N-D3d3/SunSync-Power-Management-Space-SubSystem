% Simulation 1: Orbit Energy Model
function simulation_1_orbit_energy()

    % Simulation Parameters
    duration_min = 24 * 60; 
    dt = 0.1;               
    time = 0:dt:duration_min;
    orbit_period = 95;      
    sunlight_dur = 60;      
    solar_gen = 2;        
    
    num_steps = length(time);
    solar_power = zeros(1, num_steps);
    eclipse_line = zeros(1, num_steps); 
    
    for i = 1:num_steps
        t_orbit = mod(time(i), orbit_period);
        noise = (rand - 0.5) * 0.1; % Realistic power fluctuation
        
        if t_orbit < sunlight_dur
            solar_power(i) = solar_gen + noise;
            eclipse_line(i) = 3.5; 
        else
            solar_power(i) = 0;
            eclipse_line(i) = 0;   
        end
    end
    
    cumulative_energy = cumsum(solar_power) * dt / 60; 

    % Visualization
    figure('Name', 'Sim 1: Orbit Energy Model', 'Color', 'w', 'Position' , [50 50 1400 700]);
    
    yyaxis left
    area(time, solar_power, 'FaceColor', [1 0.8 0.2], 'EdgeColor', 'none', 'DisplayName', 'Sunlight Phase (Panels: 2W)');
    hold on;
    plot(time, eclipse_line, 'k:', 'LineWidth', 1.5, 'DisplayName', 'Eclipse Phase');
    
    ylabel('Solar Power (W)');
    ylim([0 4]);
    title('Orbital Solar Energy Cycle');
    xlabel('Time (minutes)');
    
    yyaxis right
    plot(time, cumulative_energy, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Cumulative Energy');
    ylabel('Cumulative Energy (Wh)');
    ylim([0 max(cumulative_energy)*1.1]);
    
    legend('Location', 'best');
    grid on;
    
    text(duration_min/2, max(cumulative_energy)*1.02, ...
        {'Note: Solar Panels generate 2 Watts', 'Battery Drain: Excluded (Pure Generation)'}, ...
        'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 5);
end
