# SunSync-Power-Management-Space-SubSystem

AESS Sustainability Hackathon 2026 — Sustainable Electronics for Space Systems

Overview
SunSync is an intelligent power-aware telemetry scheduling subsystem designed for CubeSats operating in Low Earth Orbit (LEO). Developed by Team LU1-RC for the AESS Sustainability Hackathon 2026, the project addresses a critical challenge in small satellite missions: unnecessary battery drain caused by high-power radio transmissions during orbital eclipse periods.
Traditional CubeSat telemetry systems often transmit data whenever a Ground Station is visible, regardless of whether the spacecraft is currently in sunlight or eclipse. During eclipse phases, the spacecraft receives no solar input, forcing the battery to power all onboard systems — including energy-intensive RF transmissions. Repeated deep discharge cycles can significantly reduce battery lifespan, increase thermal stress, and ultimately shorten mission duration.
SunSync introduces a smarter store-and-forward telemetry architecture that dynamically schedules transmissions only during optimal operating conditions:


☀️ Solar power is available


🔋 Battery State of Charge (SoC) is healthy


📡 Ground Station visibility is confirmed


Instead of transmitting immediately, scientific telemetry is buffered in non-volatile memory and released during energy-efficient orbital windows. Critical housekeeping telemetry can still bypass the scheduler when necessary.
Key Features


Intelligent telemetry scheduling based on orbital power conditions


Battery-aware RF transmission control


Eclipse avoidance logic to reduce unnecessary battery stress


Store-and-forward buffering using simulated FRAM logic


MATLAB-based orbital and energy simulations


Real-time orbit visualization and subsystem behavior analysis


Comparative Baseline vs. Optimized system evaluation


Simulation Results
The repository includes multiple simulations demonstrating the effectiveness of SunSync under stress-test conditions (2W solar generation / 4W RF transmission):


Orbit Energy Model — Visualizes solar power availability during orbital sunlight/eclipses


Battery State of Charge — Shows reduced battery degradation using SunSync


RF Duty Cycle — Demonstrates optimized transmission timing


Power Consumption Comparison — Quantifies total energy savings over 24 hours


3D Orbit Visualization — Simulates satellite movement and communication windows in real time


Results show that intelligent scheduling can significantly reduce unnecessary RF activity during eclipse phases, helping preserve battery health and improve long-term mission sustainability.
Repository Structure
Simulation Results/├── Battery State of Charge.png├── Orbit Energy Model.png├── Power Consumption Comparison.png├── RF Duty Cycle.png├── Simulation Video.mp4├── result.pngcodes/├── run_all_simulations.m├── simulation_1_orbit_energy.m├── simulation_2_battery_soc.m├── simulation_3_rf_duty_cycle.m├── simulation_4_power_consumption.m├── simulation_orbit_visual.m├── Block Diagram.png├── README.md

Project Impact
SunSync demonstrates that sustainable spacecraft operation is not only about improving hardware efficiency — it is also about optimizing when systems operate. By shifting telemetry transmission windows from eclipse to sunlight periods, the subsystem can:


Reduce battery stress and deep discharge cycles


Extend spacecraft operational lifetime


Improve onboard energy efficiency


Allocate more power toward scientific payloads


Increase mission reliability for future CubeSat platforms


Future Improvements


Real-time eclipse prediction


Adaptive RF transmission rates based on signal quality


More realistic orbital mechanics and environmental modeling


Integration with embedded flight software and real hardware testing


Team
LU1-RC
AESS Sustainability Hackathon 2026
Sustainable Electronics for Space Systems
