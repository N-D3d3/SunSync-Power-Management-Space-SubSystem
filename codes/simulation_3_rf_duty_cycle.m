% Simulation 3: RF Duty Cycle
function simulation_3_rf_duty_cycle()

    duration_hrs = 24;
    dt_min = 1;
    steps = duration_hrs * 60;
    batt_cap = 20;

    solar_watts = 2.0;
    P_rf_tx = 4.0;
    P_mcu_active = 0.05;
    P_mcu_sleep = 0.002;
    P_sens_idle = 0.005;
    orbit_period = 95;
    sunlight_dur = 60;

    fprintf('Running RF Analysis...\n');
    [~, ~, rf_base, ~, ~, ~] = run_sim_logic(steps, dt_min, 'Baseline', 100, batt_cap, ...
        orbit_period, sunlight_dur, solar_watts, P_mcu_active, P_mcu_sleep, P_sens_idle, P_rf_tx);
    [~, ~, rf_sun, ~, ~, ~] = run_sim_logic(steps, dt_min, 'SunSync', 100, batt_cap, ...
        orbit_period, sunlight_dur, solar_watts, P_mcu_active, P_mcu_sleep, P_sens_idle, P_rf_tx);

    time_min = 0:dt_min:(steps*dt_min - dt_min);

    figure('Name', 'Sim 3: RF Duty Cycle', 'Color', 'w' , 'Position' , [50 50 1400 700]);

    subplot(2,1,1);
    area(time_min, rf_base, 'FaceColor', [1 0.4 0.4]);
    title('Baseline: RF Power Usage (GS Triggered)');
    ylabel('RF Power (W)');
    ylim([0 5]); grid on;

    subplot(2,1,2);
    area(time_min, rf_sun, 'FaceColor', [0.4 0.6 1]);
    title('SunSync: RF Power Usage (Smart Scheduling)');
    xlabel('Time (Minutes)'); ylabel('RF Power (W)');
    ylim([0 5]); grid on;

    active_time_base = sum(rf_base > 0.1) * dt_min;
    active_time_sun = sum(rf_sun > 0.1) * dt_min;

    rf_energy_base = sum(rf_base) * dt_min / 60;
    rf_energy_sun = sum(rf_sun) * dt_min / 60;

    fprintf('\n--- Simulation 3 Results ---\n');
    fprintf('Metric           | Baseline | SunSync\n');
    fprintf('-----------------|----------|--------\n');
    fprintf('RF Active Time   | %6.1f m | %6.1f m\n', active_time_base, active_time_sun);
    fprintf('RF Energy Consum | %6.2f Wh| %6.2f Wh\n', rf_energy_base, rf_energy_sun);
    fprintf('Energy Savings   |   N/A    | %6.1f %%\n', (1 - rf_energy_sun/rf_energy_base)*100);
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
            if is_pass
                tx = true;
            end
        else
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
