% Simulation 4: Power Consumption Comparison
function simulation_4_power_consumption()

    duration_hrs = 24;
    dt_min = 1;
    steps = duration_hrs * 60;
    batt_cap = 20;

    % --- STRESS TEST PARAMETERS ---
    solar_watts = 2.0;
    P_rf_tx = 4.0;
    P_mcu_active = 0.05;
    P_mcu_sleep = 0.002;
    P_sens_idle = 0.005;
    orbit_period = 95;
    sunlight_dur = 60;
    % -------------------------------

    fprintf('Calculating Power Consumption...\n');
    [~, ~, ~, p_tot_base, ~, ~] = run_sim_logic(steps, dt_min, 'Baseline', 100, batt_cap, ...
        orbit_period, sunlight_dur, solar_watts, P_mcu_active, P_mcu_sleep, P_sens_idle, P_rf_tx);
    [~, ~, ~, p_tot_sun, ~, ~] = run_sim_logic(steps, dt_min, 'SunSync', 100, batt_cap, ...
        orbit_period, sunlight_dur, solar_watts, P_mcu_active, P_mcu_sleep, P_sens_idle, P_rf_tx);

    time_min = 0:dt_min:(steps*dt_min - dt_min);

    hourly_bins = 0:60:1440;
    avg_p_base = zeros(1, length(hourly_bins)-1);
    avg_p_sun = zeros(1, length(hourly_bins)-1);

    for i = 1:length(hourly_bins)-1
        idx = hourly_bins(i)+1 : hourly_bins(i+1);
        avg_p_base(i) = mean(p_tot_base(idx));
        avg_p_sun(i) = mean(p_tot_sun(idx));
    end

    figure('Name', 'Sim 5: Power Consumption', 'Color', 'w' , 'Position' , [50 50 1400 700]);
    bar(hourly_bins(1:end-1)+30, [avg_p_base; avg_p_sun]', 'grouped');

    title('Average Hourly Power Consumption');
    xlabel('Time (Hours)');
    ylabel('Power Consumption (Watts)');
    legend('Baseline', 'SunSync', 'Location', 'best');
    grid on;

    total_energy_base = sum(p_tot_base) * dt_min / 60;
    total_energy_sun = sum(p_tot_sun) * dt_min / 60;

    fprintf('\n--- Simulation 4 Results ---\n');
    fprintf('Total Energy Consumed (24h):\n');
    fprintf('  Baseline: %.2f Wh\n', total_energy_base);
    fprintf('  SunSync:  %.2f Wh\n', total_energy_sun);
    fprintf('  Reduction: %.2f Wh (%.1f%%)\n', ...
        (total_energy_base - total_energy_sun), ...
        (1 - total_energy_sun/total_energy_base)*100);
end

function [time, p_solar, p_rf, p_total, soc, queue] = run_sim_logic(steps, dt, mode, init_soc, cap_wh, orbit_period, sunlight_dur, solar_watts, P_mcu_a, P_mcu_s, P_sens, P_rf_tx)
    time = (0:steps-1) * dt;

    soc = zeros(1, steps);
    queue = zeros(1, steps);
    p_solar = zeros(1, steps);
    p_rf = zeros(1, steps);
    p_total = zeros(1, steps);

    pass_starts = [100, 460, 820, 1180]; pass_dur = 8;
    cur_soc = init_soc; cur_queue = 0; data_rate = 1;

    for t = 1:steps
        tm = (t-1)*dt;
        is_sun = mod(tm, orbit_period) < sunlight_dur;
        is_pass = any(tm >= pass_starts & tm < pass_starts + pass_dur);
        cur_queue = cur_queue + data_rate;

        tx = false; mcu = false;

        if strcmp(mode, 'Baseline')
            % Updated: Baseline transmits only when GS is visible
            if is_pass
                tx = true;
            end
        else
            % SunSync transmits only when GS is visible AND Sun is shining
            if is_pass && is_sun && cur_soc > 30
                tx = true;
            end
        end
        mcu = tx;

        p_in = is_sun * solar_watts;
        p_m = mcu*P_mcu_a + (~mcu)*P_mcu_s;
        p_rf_cur = 0;
        if tx
            drain = 10; cur_queue = max(0, cur_queue - drain);
            p_rf_cur = P_rf_tx;
        else
            p_rf_cur = 0;
        end
        p_out = p_m + P_sens + p_rf_cur;
        cur_soc = cur_soc + ((p_in - p_out)*(dt/60)/cap_wh)*100;
        cur_soc = max(0, min(100, cur_soc));

        soc(t)=cur_soc; queue(t)=cur_queue; p_solar(t)=p_in; p_rf(t)=p_rf_cur; p_total(t)=p_out;
    end
end
