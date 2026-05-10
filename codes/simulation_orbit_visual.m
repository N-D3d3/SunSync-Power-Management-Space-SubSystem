function simulation_orbit_visual()
    % --- SPEED SETTINGS ---
    speedup = 5;  % Increase this number to make it faster (e.g., 5 = 5x faster)
    pause_time = 0.001; % Very small pause
    % -----------------------

    Re = 6371; alt = 500; R_orbit = Re + alt; 
    
    SunDist = R_orbit * 6;   % Distance
    SunRad = Re * 2.0;       % Size
    inc = deg2rad(98);       % Orbit Inclination

    figure('Color','k', 'Position',[50 50 1400 700]);
    axis equal; hold on; grid on; view(45,30);
    
    % --- EARTH SETUP ---
    try
        load('topo.mat'); 
        if exist('topo','var')
            [lon, lat] = meshgrid(linspace(-180, 180, 360), linspace(90, -90, 180));
            phi = lat * pi/180; theta = lon * pi/180;
            Xe = Re .* cos(phi) .* cos(theta);
            Ye = Re .* cos(phi) .* sin(theta);
            Ze = Re .* sin(phi);
            C = double(topo);
            has_texture = true;
        else
            has_texture = false;
        end
    catch
        has_texture = false;
    end

    if ~has_texture
        [Xe, Ye, Ze] = sphere(50);
        Xe = Xe*Re; Ye = Ye*Re; Ze = Ze*Re;
    end
    
    if has_texture
        cmap = [0 0 0.5;    % Deep Ocean
                0 0.2 0.6;  % Ocean
                0 0.5 0.2;  % Land
                0.5 0.5 0.2; % Desert/Highland
                0.8 0.8 0.8]; % Snow
        colormap(cmap);
        h_earth = surf(Xe, Ye, Ze, C, 'FaceColor','texturemap','EdgeColor','none');
    else
        h_earth = surf(Xe, Ye, Ze, 'FaceColor', [0.1 0.3 0.8], 'EdgeColor','none');
    end
    
    set(gcf,'Renderer','opengl');
    shading interp; material dull; lighting gouraud;

    % --- SUN (Yellow with Texture) ---
    [Xs1, Ys1, Zs1] = sphere(50);
    surf(Xs1*SunRad*1.3 + SunDist, Ys1*SunRad*1.3, Zs1*SunRad*1.3, ...
        'FaceColor',[1 0.5 0], 'EdgeColor','none','FaceAlpha',0.15, 'FaceLighting','none');
    
    [Xs2, Ys2, Zs2] = sphere(100);
    noise = rand(100); 
    C_sun = zeros(100,100,3);
    C_sun(:,:,1) = 1.0;                    
    C_sun(:,:,2) = 0.4 + (noise * 0.6);    
    C_sun(:,:,3) = 0.0;                    
    surf(Xs2*SunRad + SunDist, Ys2*SunRad, Zs2*SunRad, C_sun, ...
        'FaceColor','texturemap','EdgeColor','none','SpecularStrength',1,'DiffuseStrength',0.8);
    
    text(SunDist+SunRad+1000,0,0,' SUN','Color',[1 1 0],'FontSize',20,'FontWeight','bold');
    light('Position',[SunDist 0 0],'Style','infinite');
    light('Position',[0 0 10],'Style','infinite','Color',[0.1 0.1 0.1]);

    % --- ORBIT PATH ---
    theta_points = linspace(0,2*pi,200);
    x_path_line = R_orbit*cos(theta_points); 
    y_path_line = R_orbit*sin(theta_points)*cos(inc); 
    z_path_line = R_orbit*sin(theta_points)*sin(inc);
    plot3(x_path_line, y_path_line, z_path_line,'w--','LineWidth',1.5);

    % --- GROUND STATION ---
    gs_lon = -15; 
    gx = Re*cosd(0)*cosd(gs_lon);
    gy = Re*cosd(0)*sind(gs_lon);
    gz = Re*sind(0);
    gs_marker = scatter3(gx,gy,gz,150,'gx','LineWidth',4);
    gs_text = text(gx,gy,gz+1000,'GS','Color','g','FontWeight','bold','FontSize',12);

    % --- SATELLITE ---
    sat_trail_x = zeros(1,20);
    sat_trail_y = zeros(1,20);
    sat_trail_z = zeros(1,20);
    h_trail = line(sat_trail_x, sat_trail_y, sat_trail_z, 'Color','y', 'LineWidth',1);
    
    sat = scatter3(x_path_line(1),y_path_line(1),z_path_line(1),200,'y','filled','MarkerEdgeColor','k','LineWidth',1.5);
    
    link_line = line(nan,nan,nan,'Color','g','LineWidth',2,'LineStyle','-.');
    status_text = text(0,Re*1.8,Re*1.8,'','Color','w','FontSize',14,'FontWeight','bold');

    % --- SHADOW ---
    [Xc,Yc,Zc]=cylinder([Re Re],50);
    Xc = Xc*6*Re - 3.5*Re;
    surf(Xc,Yc*Re,Zc*Re,'FaceColor','k','FaceAlpha',0.2,'EdgeColor','none','HandleVisibility','off');

    axis off;
    xlim([-SunDist*0.4, SunDist*1.1]); ylim([-Re*2.5,Re*2.5]); zlim([-Re*2.5,Re*2.5]);

    rot_speed = 24/200;
    rot = 0;
    % --- ANIMATION LOOP ---
    for i = 1:3000
        idx = mod(i-1,200)+1;
        theta_curr = linspace(0,2*pi,200);
        th_now = theta_curr(idx);
        
        % Always calculate position (Physics)
        sx = R_orbit*cos(th_now); 
        sy = R_orbit*sin(th_now)*cos(inc); 
        sz = R_orbit*sin(th_now)*sin(inc);
        
        % Always calculate rotation
        rot = rot + rot_speed;
        rad_rot = deg2rad(rot);
        
        Xe_n = Xe*cos(rad_rot) - Ye*sin(rad_rot); 
        Ye_n = Xe*sin(rad_rot) + Ye*cos(rad_rot);
        
        gs_new_x = gx*cos(rad_rot) - gy*sin(rad_rot);
        gs_new_y = gx*sin(rad_rot) + gy*cos(rad_rot);

        % --- SPEEDUP: Only update graphics every N frames ---
        if mod(i, speedup) == 0
            set(h_earth, 'XData', Xe_n, 'YData', Ye_n, 'ZData', Ze);
            set(gs_marker, 'XData', gs_new_x, 'YData', gs_new_y, 'ZData', gz);
            set(gs_text, 'Position', [gs_new_x, gs_new_y, gz+1000]);
            
            set(sat, 'XData', sx, 'YData', sy, 'ZData', sz);
            
            sat_trail_x = [sat_trail_x(2:end), sx];
            sat_trail_y = [sat_trail_y(2:end), sy];
            sat_trail_z = [sat_trail_z(2:end), sz];
            set(h_trail, 'XData', sat_trail_x, 'YData', sat_trail_y, 'ZData', sat_trail_z);
            
            is_eclipse = (sx<0) && (sqrt(sy^2+sz^2)<Re);
            
            v_sat = [sx sy sz]/norm([sx sy sz]);
            v_gs = [gs_new_x gs_new_y gz]/norm([gs_new_x gs_new_y gz]);
            is_visible = dot(v_sat, v_gs) > 0.8;

            if is_eclipse
                set(sat, 'MarkerFaceColor', 'r'); st = 'ECLIPSE'; col = 'r';
                set(h_trail, 'Color', 'r');
            else
                set(sat, 'MarkerFaceColor', 'y'); st = 'SUNLIGHT'; col = 'y';
                set(h_trail, 'Color', 'y');
            end
            
            if is_visible
                set(link_line, 'XData', [sx gs_new_x], 'YData', [sy gs_new_y], 'ZData', [sz gz]);
                st = [st ' | LINK ACTIVE'];
            else
                set(link_line, 'XData', nan, 'YData', nan, 'ZData', nan);
            end
            
            set(status_text, 'String', st, 'Color', col);
            drawnow limitrate;
        end
        
        pause(pause_time);
    end
end
