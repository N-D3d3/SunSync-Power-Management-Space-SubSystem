function run_all_simulations()
    clc; clear; close all;

    fprintf('========================================\n');
    fprintf('Starting Complete Simulation Suite\n');
    fprintf('========================================\n\n');
    
    % Orbit Visualization
    fprintf('Running Orbit Visualization...\n');
    simulation_orbit_visual();

    % 1. Orbit Energy Model
    fprintf('Running Simulation 1: Orbit Energy Model...\n');
    simulation_1_orbit_energy();
    fprintf('Simulation 1 Complete.\n\n');
    pause(5); % Pause 5 seconds

    % 2. Battery State of Charge
    fprintf('Running Simulation 2: Battery SoC...\n');
    simulation_2_battery_soc();
    fprintf('Simulation 2 Complete.\n\n');
    pause(5); 

    % 3. RF Duty Cycle
    fprintf('Running Simulation 3: RF Duty Cycle...\n');
    simulation_3_rf_duty_cycle();
    fprintf('Simulation 3 Complete.\n\n');
    pause(5); 

    % 4. Power Consumption
    fprintf('Running Simulation 4: Power Consumption...\n');
    simulation_4_power_consumption();
    fprintf('Simulation 4 Complete.\n\n');
    pause(5); 
    
    close all;
    
    fprintf('\n========================================\n');
    fprintf('All Simulations Complete!\n');
    fprintf('========================================\n');
end
