% Simulation 2: Battery State of Charge
function simulation_2_battery_soc()

    duration_hrs = 24;
    dt_min = 1;
    steps = duration_hrs * 60;
    batt_cap_wh = 20;
    initial_soc = 100;

    solar_watts = 2.0;       
    P_rf_tx = 4.0;           
    P_mcu_active = 0.05;
    P_mcu_sleep = 0.002;
    P_sens_idle = 0.005;
    orbit_period = 95;
    sunlight_dur = 60;

    fprintf('Running Baseline...\n');
    [~, ~, ~, ~, soc_baseline, ~] = run_sim_logic(steps, dt_min, 'Baseline', initial_soc, batt_cap_wh, ...
        orbit_period, sunlight_dur, solar_watts, P_mcu_active, P_mcu_sleep, P_sens_idle, P_rf_tx);

    fprintf('Running SunSync...\n');
    [~, ~, ~, ~, soc_sunsync, ~] = run_sim_logic(steps, dt_min, 'SunSync', initial_soc, batt_cap_wh, ...
        orbit_period, sunlight_dur, solar_watts, P_mcu_active, P_mcu_sleep, P_sens_idle, P_rf_tx);

    time_min = 0:dt_min:(steps*dt_min - dt_min);

    figure('Name', 'Sim 2: Battery SoC Comparison', 'Color', 'w' , 'Position' , [50 50 1400 700]);
    plot(time_min, soc_baseline, 'r--', 'LineWidth', 1.5); hold on;
    plot(time_min, soc_sunsync, 'b-', 'LineWidth', 2);

    plot([time_min(1) time_min(end)], [30 30], 'k-.', 'LineWidth', 1.2);
    text(time_min(1), 31, 'Low Threshold', 'Color', 'k', 'FontSize', 8);
    plot([time_min(1) time_min(end)], [20 20], 'k:', 'LineWidth', 1.2);
    text(time_min(1), 21, 'Critical Threshold', 'Color', 'k', 'FontSize', 8);

    title('Battery State of Charge (24 Hours)');
    xlabel('Time (Minutes)');
    ylabel('SoC (%)');
    legend('Baseline (Fixed)', 'SunSync (Adaptive)', 'Location', 'best');
    grid on;
    ylim([0 105]);

    avg_soc_base = mean(soc_baseline);
    avg_soc_sun = mean(soc_sunsync);
    min_soc_base = min(soc_baseline);
    min_soc_sun = min(soc_sunsync);

    fprintf('\n--- Simulation 2 Results ---\n');
    fprintf('Baseline  | Avg SoC: %.1f%% | Min SoC: %.1f%%\n', avg_soc_base, min_soc_base);
    fprintf('SunSync   | Avg SoC: %.1f%% | Min SoC: %.1f%%\n', avg_soc_sun, min_soc_sun);
    fprintf('Improvement: %.1f percentage points higher avg SoC\n', avg_soc_sun - avg_soc_base);
end

function [time, p_solar, p_rf, p_total, soc, queue] = run_sim_logic(steps, dt, mode, init_soc, cap_wh, orbit_period, sunlight_dur, solar_watts, P_mcu_a, P_mcu_s, P_sens, P_rf_tx)
    time = (0:steps-1) * dt;

    soc = zeros(1, steps);
    queue = zeros(1, steps);
    p_solar = zeros(1, steps);
    p_rf = zeros(1, steps);
    p_total = zeros(1, steps);

    pass_starts = [100, 460, 820, 1180];
    pass_dur = 8;
    current_soc = init_soc;
    current_queue = 0;
    data_rate = 1;

    for t = 1:steps
        time_min = (t-1)*dt;
        is_sun = mod(time_min, orbit_period) < sunlight_dur;
        is_pass = any(time_min >= pass_starts & time_min < pass_starts + pass_dur);
        current_queue = current_queue + data_rate;

        tx_enable = false;
        mcu_active = false;
        if rand() < 0.001, tx_enable = true; end

        if strcmp(mode, 'Baseline')
            % --- EDIT: Changed to match Simulation 3 ---
            % Baseline now transmits ONLY when Ground Station is visible (Day or Night)
            if is_pass
                tx_enable = true;
            end
        else % SunSync
            % SunSync transmits only when Ground Station is visible AND Sun is shining
            if is_sun && current_soc > 30 && is_pass
                tx_enable = true;
            end
        end
        mcu_active = tx_enable;

        p_in = is_sun * solar_watts;
        p_mcu = mcu_active * P_mcu_a + (~mcu_active) * P_mcu_s;
        p_sens = P_sens;
        p_rf_now = 0;

        if tx_enable
            if current_queue > 0
                drain_amount = 10;
                current_queue = max(0, current_queue - drain_amount);
                p_rf_now = P_rf_tx;
            else
                p_rf_now = 0.1;
            end
        else
            p_rf_now = 0;
        end

        p_out = p_mcu + p_sens + p_rf_now;
        net_energy_wh = (p_in - p_out) * (dt/60);
        soc_change_pct = (net_energy_wh / cap_wh) * 100;
        current_soc = current_soc + soc_change_pct;
        if current_soc > 100, current_soc = 100; end
        if current_soc < 0, current_soc = 0; end

        soc(t) = current_soc;
        queue(t) = current_queue;
        p_solar(t) = p_in;
        p_rf(t) = p_rf_now;
        p_total(t) = p_out;
    end
end
