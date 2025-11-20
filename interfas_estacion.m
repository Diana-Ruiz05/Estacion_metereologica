function EstacionConfort_GUI
    % GUI de estación de confort - ESP32 (WiFi UDP + UART)
    % Métricas: Temperatura, Altura, Luminosidad, Presencia
    % MATLAB R2025a o superior
    
    %% Colores exactos del tema Python
    colores.fondo = [0.051 0.067 0.090];        % #0D1117
    colores.panel = [0.051 0.067 0.090];        % #0D1117
    colores.texto = [0.902 0.929 0.953];        % #E6EDF3
    colores.acento = [0.345 0.651 1.000];       % #58A6FF
    colores.temperatura = [1.000 0.482 0.447];  % #FF7B72
    colores.velocidad = [0.824 0.659 1.000];    % #D2A8FF
    colores.altura = [0.494 0.906 0.529];       % #7EE787
    colores.luminosidad = [0.941 0.859 0.310];  % #F0DB4F
    
    %% Ventana principal - 850x500
    fig = uifigure('Name','Estación Meteorológica ESP32',...
        'Position',[100 100 850 500],...
        'Color',colores.fondo);
    
    % Grid principal
    gl = uigridlayout(fig,[3,3]);
    gl.RowHeight = {80, 350, 'fit'};
    gl.ColumnWidth = {350, 320, 250};
    gl.Padding = [10 10 10 10];
    gl.RowSpacing = 15;
    gl.ColumnSpacing = 15;
    gl.BackgroundColor = colores.fondo;
    
    %% ========== BARRA SUPERIOR - Controles de conexión ==========
    conexionPanel = uipanel(gl,'BorderType','none',...
        'BackgroundColor',colores.fondo);
    conexionPanel.Layout.Row = 1;
    conexionPanel.Layout.Column = [1 3];
    
    conGrid = uigridlayout(conexionPanel,[2,4]);
    conGrid.RowHeight = {35, 35};
    conGrid.ColumnWidth = {'1x', 120, 120, 120};
    conGrid.BackgroundColor = colores.fondo;
    conGrid.Padding = [10 0 10 0];
    conGrid.ColumnSpacing = 10;
    conGrid.RowSpacing = 5;
    
    % Fila 1: Modo WiFi (UDP)
    uilabel(conGrid,'Text','📡 WiFi UDP:',...
        'FontSize',12,'FontColor',colores.texto,...
        'HorizontalAlignment','right');
    
    lblPuertoUDP = uilabel(conGrid,'Text','Puerto: 5005',...
        'FontSize',11,'FontColor',colores.acento,...
        'FontWeight','bold');
    
    btnConectarWiFi = uibutton(conGrid,'Text','Conectar WiFi',...
        'FontSize',11,'FontWeight','bold',...
        'BackgroundColor',colores.acento,...
        'FontColor',colores.texto);
    
    lblEstadoWiFi = uilabel(conGrid,'Text','Desconectado',...
        'FontSize',11,'FontColor',colores.luminosidad,...
        'FontWeight','bold');
    
    % Fila 2: Modo UART (Serial)
    uilabel(conGrid,'Text','🔌 UART Serial:',...
        'FontSize',12,'FontColor',colores.texto,...
        'HorizontalAlignment','right');
    
    % Dropdown para seleccionar puerto COM
    ddPuertoCOM = uidropdown(conGrid,...
        'Items',{'COM1','COM2','COM3','COM4','COM5','COM6','COM7','COM8'},...
        'Value','COM7',...
        'FontSize',11,...
        'BackgroundColor',[0.2 0.2 0.25],...
        'FontColor',colores.texto);
    
    btnConectarUART = uibutton(conGrid,'Text','Conectar UART',...
        'FontSize',11,'FontWeight','bold',...
        'BackgroundColor',colores.velocidad,...
        'FontColor',colores.texto);
    
    lblEstadoUART = uilabel(conGrid,'Text','Desconectado',...
        'FontSize',11,'FontColor',colores.luminosidad,...
        'FontWeight','bold');
    
    %% ========== PANEL IZQUIERDO: TEMPERATURA (gráfica) ==========
    tempPanel = uipanel(gl,'BorderType','none',...
        'BackgroundColor',colores.panel);
    tempPanel.Layout.Row = 2;
    tempPanel.Layout.Column = 1;
    
    tempGrid = uigridlayout(tempPanel,[4,1]);
    tempGrid.RowHeight = {40, 80, '1x', 20};
    tempGrid.BackgroundColor = colores.panel;
    tempGrid.Padding = [10 10 10 10];
    tempGrid.RowSpacing = 5;
    
    uilabel(tempGrid,'Text','TEMPERATURA',...
        'FontSize',16,'FontWeight','bold',...
        'FontColor',colores.texto,...
        'HorizontalAlignment','center');
    
    lblTemp = uilabel(tempGrid,'Text','25.7 °C',...
        'FontSize',48,'FontWeight','bold',...
        'FontColor',colores.temperatura,...
        'HorizontalAlignment','center');
    
    % Gráfica de temperatura
    axTemp = uiaxes(tempGrid);
    axTemp.BackgroundColor = colores.panel;
    axTemp.XColor = colores.texto;
    axTemp.YColor = colores.temperatura;
    axTemp.GridColor = [0.3 0.3 0.3];
    axTemp.GridAlpha = 0.3;
    axTemp.XLabel.String = 'Tiempo (min)';
    axTemp.YLabel.String = 'Temperatura (°C)';
    axTemp.XLabel.Color = colores.texto;
    axTemp.YLabel.Color = colores.temperatura;
    axTemp.FontSize = 9;
    grid(axTemp,'on');
    
    histTemp = ones(1,60) * 25.7;
    lineTemp = plot(axTemp, 60:-1:1, histTemp,...
        'Color',colores.temperatura,'LineWidth',2,...
        'Marker','o','MarkerSize',3,...
        'MarkerFaceColor',colores.temperatura);
    xlim(axTemp,[0 60]);
    ylim(axTemp,[20 30]);
    
    uilabel(tempGrid,'Text','Últimos 60 minutos',...
        'FontSize',9,'FontColor',colores.texto,...
        'HorizontalAlignment','center');
    
    %% ========== PANEL CENTRO: ALTURA (altímetro circular) ==========
    alturaPanel = uipanel(gl,'BorderType','none',...
        'BackgroundColor',colores.panel);
    alturaPanel.Layout.Row = 2;
    alturaPanel.Layout.Column = 2;
    
    alturaGrid = uigridlayout(alturaPanel,[2,1]);
    alturaGrid.RowHeight = {40, '1x'};
    alturaGrid.BackgroundColor = colores.panel;
    alturaGrid.Padding = [10 10 10 10];
    
    uilabel(alturaGrid,'Text','ALTURA',...
        'FontSize',16,'FontWeight','bold',...
        'FontColor',colores.texto,...
        'HorizontalAlignment','center');
    
    % Panel para el altímetro
    altPanel = uipanel(alturaGrid,'BorderType','none',...
        'BackgroundColor',colores.panel);
    
    altGrid = uigridlayout(altPanel,[3,1]);
    altGrid.RowHeight = {'1x', 60, 30};
    altGrid.BackgroundColor = colores.panel;
    
    % Gauge circular (0-3000 msnm)
    gaugeAltura = uigauge(altGrid,'circular',...
        'Limits',[0 3000],'Value',2600,...
        'BackgroundColor',colores.panel,...
        'FontColor',colores.texto,...
        'ScaleColors',colores.altura,...
        'MajorTicks',[0 500 1000 1500 2000 2500 3000],...
        'ScaleColorLimits',[0 1000; 1000 2000; 2000 3000],...
        'ScaleColors',[0.494 0.906 0.529; 0.345 0.651 1.000; 1.000 0.482 0.447]);
    
    % Valor numérico
    lblAltura = uilabel(altGrid,'Text','2600 msnm',...
        'FontSize',32,'FontWeight','bold',...
        'FontColor',colores.altura,...
        'HorizontalAlignment','center');
    
    % Etiqueta
    uilabel(altGrid,'Text','metros sobre nivel del mar',...
        'FontSize',10,'FontColor',colores.texto,...
        'FontWeight','bold',...
        'HorizontalAlignment','center');
    
    %% ========== PANEL DERECHO: LUMINOSIDAD ==========
    derechoPanel = uipanel(gl,'BorderType','none',...
        'BackgroundColor',colores.panel);
    derechoPanel.Layout.Row = 2;
    derechoPanel.Layout.Column = 3;
    
    derechoGrid = uigridlayout(derechoPanel,[1,1]);
    derechoGrid.BackgroundColor = colores.panel;
    derechoGrid.Padding = [10 20 10 20];
    
    %% --- LUMINOSIDAD ---
    luxPanel = uipanel(derechoGrid,'BorderType','none',...
        'BackgroundColor',colores.panel);
    
    luxGrid = uigridlayout(luxPanel,[5,1]);
    luxGrid.RowHeight = {30, 80, 60, 30, 'fit'};
    luxGrid.BackgroundColor = colores.panel;
    luxGrid.RowSpacing = 10;
    
    uilabel(luxGrid,'Text','LUMINOSIDAD',...
        'FontSize',16,'FontWeight','bold',...
        'FontColor',colores.texto,...
        'HorizontalAlignment','center');
    
    lblLux = uilabel(luxGrid,'Text','65 %',...
        'FontSize',48,'FontWeight','bold',...
        'FontColor',colores.luminosidad,...
        'HorizontalAlignment','center');
    
    % Barra de progreso
    gaugeLux = uigauge(luxGrid,'linear',...
        'Limits',[0 100],'Value',65,...
        'BackgroundColor',[0.086 0.106 0.133],...
        'FontColor',colores.texto,...
        'ScaleColors',colores.luminosidad,...
        'MajorTicks',[0 25 50 75 100]);
    
    % Etiquetas de rango lux
    luxLabelsGrid = uigridlayout(luxGrid,[1,2]);
    luxLabelsGrid.ColumnWidth = {'1x','1x'};
    luxLabelsGrid.BackgroundColor = colores.panel;
    luxLabelsGrid.Padding = [0 0 0 0];
    
    uilabel(luxLabelsGrid,'Text','0 lux',...
        'FontSize',9,'FontColor',colores.texto,...
        'HorizontalAlignment','left');
    uilabel(luxLabelsGrid,'Text','1000 lux',...
        'FontSize',9,'FontColor',colores.texto,...
        'HorizontalAlignment','right');
    
    % Alarma de luz
    lblAlarmaLuz = uilabel(luxGrid,'Text','',...
        'FontSize',11,'FontWeight','bold',...
        'FontColor',[1 0.3 0.3],...
        'HorizontalAlignment','center');
    
    %% ========== PANEL INFERIOR ==========
    infPanel = uipanel(gl,'BorderType','none',...
        'BackgroundColor',colores.panel);
    infPanel.Layout.Row = 3;
    infPanel.Layout.Column = [1 3];
    
    infGrid = uigridlayout(infPanel,[1,4]);
    infGrid.ColumnWidth = {'1x','1x','1x','1x'};
    infGrid.BackgroundColor = colores.panel;
    infGrid.Padding = [20 10 20 10];
    infGrid.ColumnSpacing = 15;
    
    % Velocidad del viento
    vientoSubGrid = uigridlayout(infGrid,[1,2]);
    vientoSubGrid.ColumnWidth = {'fit','1x'};
    vientoSubGrid.BackgroundColor = colores.panel;
    vientoSubGrid.Padding = [0 0 0 0];
    vientoSubGrid.ColumnSpacing = 10;
    
    uilabel(vientoSubGrid,'Text','💨 VIENTO:',...
        'FontSize',12,'FontWeight','bold',...
        'FontColor',colores.texto);
    lblViento = uilabel(vientoSubGrid,'Text','-- km/h',...
        'FontSize',12,'FontWeight','bold',...
        'FontColor',colores.velocidad);
    
    % Estado general
    lblEstadoGeneral = uilabel(infGrid,'Text','Sistema iniciado',...
        'FontSize',12,'FontWeight','bold',...
        'FontColor',colores.luminosidad,...
        'HorizontalAlignment','center');
    
    % Botón Guardar
    btnGuardar = uibutton(infGrid,'Text','💾 Guardar',...
        'FontSize',12,...
        'BackgroundColor',colores.acento,...
        'FontColor',colores.texto);
    
    % Botón Limpiar
    btnLimpiar = uibutton(infGrid,'Text','🧹 Limpiar',...
        'FontSize',12,...
        'BackgroundColor',colores.luminosidad,...
        'FontColor',[0 0 0]);
    
    %% Variables de comunicación
    udpObj = [];
    serialObj = [];
    timerUDP = [];
    timerUART = [];
    conectadoWiFi = false;
    conectadoUART = false;
    maxLuxCalibrado = 15000.0;
    
    %% Actualizar lista de puertos COM disponibles
    actualizarPuertosCOM();
    
    function actualizarPuertosCOM()
        try
            puertos = serialportlist("available");
            if isempty(puertos)
                puertos = ["COM1","COM2","COM3","COM4","COM5","COM6","COM7"];
            end
            ddPuertoCOM.Items = puertos;
            if ~isempty(puertos)
                ddPuertoCOM.Value = puertos(1);
            end
        catch
            ddPuertoCOM.Items = ["COM1","COM2","COM3","COM4","COM5","COM6","COM7"];
            ddPuertoCOM.Value = "COM7";
        end
    end
    
    %% ========== CONEXIÓN WiFi UDP ==========
    function toggleWiFi()
        if ~conectadoWiFi
            conectarWiFi();
        else
            desconectarWiFi();
        end
    end
    
    btnConectarWiFi.ButtonPushedFcn = @(~,~) toggleWiFi();
    
    function conectarWiFi()
        try
            lblEstadoWiFi.Text = 'Conectando...';
            lblEstadoWiFi.FontColor = colores.luminosidad;
            drawnow;
            
            localPort = 5005;
            udpObj = udpport("datagram","IPV4","LocalPort",localPort);
            configureCallback(udpObj,"off");
            
            lblEstadoWiFi.Text = '✅ Conectado';
            lblEstadoWiFi.FontColor = colores.altura;
            btnConectarWiFi.Text = 'Desconectar WiFi';
            btnConectarWiFi.BackgroundColor = [0.9 0.3 0.3];
            conectadoWiFi = true;
            
            timerUDP = timer('ExecutionMode','fixedSpacing','Period',0.5,...
                'TimerFcn',@leerSocketUDP);
            start(timerUDP);
            
        catch ME
            lblEstadoWiFi.Text = '❌ Error';
            lblEstadoWiFi.FontColor = colores.temperatura;
            lblEstadoGeneral.Text = sprintf('Error WiFi: %s', ME.message);
        end
    end
    
    function leerSocketUDP(~, ~)
        try
            if udpObj.NumDatagramsAvailable > 0
                pkt = read(udpObj, udpObj.NumDatagramsAvailable, "uint8");
                
                for k = 1:numel(pkt)
                    rawData = pkt(k).Data;
                    
                    if isnumeric(rawData)
                        data = native2unicode(rawData, 'UTF-8');
                    else
                        data = char(rawData);
                    end
                    
                    data = strtrim(data);
                    procesarDatosJSON(data, 'WiFi');
                end
            end
        catch readErr
            lblEstadoGeneral.Text = '⚠️ Error lectura WiFi';
            lblEstadoGeneral.FontColor = colores.temperatura;
        end
    end
    
    function desconectarWiFi()
        try
            if ~isempty(timerUDP) && isvalid(timerUDP)
                stop(timerUDP);
                delete(timerUDP);
            end
            if ~isempty(udpObj)
                clear udpObj;
            end
            lblEstadoWiFi.Text = 'Desconectado';
            lblEstadoWiFi.FontColor = colores.luminosidad;
            btnConectarWiFi.Text = 'Conectar WiFi';
            btnConectarWiFi.BackgroundColor = colores.acento;
            conectadoWiFi = false;
        catch
        end
    end
    
    %% ========== CONEXIÓN UART Serial ==========
    function toggleUART()
        if ~conectadoUART
            conectarUART();
        else
            desconectarUART();
        end
    end
    
    btnConectarUART.ButtonPushedFcn = @(~,~) toggleUART();
    
    function conectarUART()
        try
            lblEstadoUART.Text = 'Conectando...';
            lblEstadoUART.FontColor = colores.luminosidad;
            drawnow;
            
            puerto = ddPuertoCOM.Value;
            serialObj = serialport(puerto, 9600);
            configureTerminator(serialObj,"LF");
            
            lblEstadoUART.Text = '✅ Conectado';
            lblEstadoUART.FontColor = colores.altura;
            btnConectarUART.Text = 'Desconectar UART';
            btnConectarUART.BackgroundColor = [0.9 0.3 0.3];
            conectadoUART = true;
            
            timerUART = timer('ExecutionMode','fixedSpacing','Period',0.5,...
                'TimerFcn',@leerUART);
            start(timerUART);
            
        catch ME
            lblEstadoUART.Text = '❌ Error';
            lblEstadoUART.FontColor = colores.temperatura;
            lblEstadoGeneral.Text = sprintf('Error UART: %s', ME.message);
        end
    end
    
    function leerUART(~, ~)
        try
            if serialObj.NumBytesAvailable > 0
                data = readline(serialObj);
                data = strtrim(data);
                procesarDatosJSON(data, 'UART');
            end
        catch readErr
            lblEstadoGeneral.Text = '⚠️ Error lectura UART';
            lblEstadoGeneral.FontColor = colores.temperatura;
        end
    end
    
    function desconectarUART()
        try
            if ~isempty(timerUART) && isvalid(timerUART)
                stop(timerUART);
                delete(timerUART);
            end
            if ~isempty(serialObj)
                delete(serialObj);
                clear serialObj;
            end
            lblEstadoUART.Text = 'Desconectado';
            lblEstadoUART.FontColor = colores.luminosidad;
            btnConectarUART.Text = 'Conectar UART';
            btnConectarUART.BackgroundColor = colores.velocidad;
            conectadoUART = false;
        catch
        end
    end
    
    %% ========== PROCESAR DATOS JSON ==========
    function procesarDatosJSON(data, origen)
        try
            % Mostrar datos crudos para debugging
            disp(['==============================']);
            disp(['Datos recibidos [' origen ']: ' data]);
            
            d = jsondecode(data);
            
            % Mostrar estructura completa del JSON
            disp('Campos del JSON:');
            disp(d);
            
            % TEMPERATURA
            if isfield(d, 'temperatura')
                temp = d.temperatura;
                disp(['  - Temperatura: ' num2str(temp) ' °C']);
                lblTemp.Text = sprintf('%.1f °C', temp);
                histTemp = [histTemp(2:end), temp];
                lineTemp.YData = histTemp;
                minTemp = min(histTemp);
                maxTemp = max(histTemp);
                rango = max(1, maxTemp - minTemp);
                ylim(axTemp, [minTemp - 0.1*rango, maxTemp + 0.1*rango]);
            else
                disp('  - Temperatura: NO ENCONTRADA');
            end
            
            % ALTURA (viene en el campo "humedad" del JSON actual)
            if isfield(d, 'humedad')
                altura = d.humedad;
                disp(['  - Altura (humedad): ' num2str(altura) ' msnm']);
                lblAltura.Text = sprintf('%.0f msnm', altura);
                gaugeAltura.Value = min(3000, max(0, altura));
            elseif isfield(d, 'altura')
                altura = d.altura;
                disp(['  - Altura: ' num2str(altura) ' msnm']);
                lblAltura.Text = sprintf('%.0f msnm', altura);
                gaugeAltura.Value = min(3000, max(0, altura));
            else
                disp('  - Altura: NO ENCONTRADA');
            end
            
            % LUMINOSIDAD
            if isfield(d, 'luz')
                luzLux = d.luz;
                disp(['  - Luz: ' num2str(luzLux) ' lux']);
                luzPorcentaje = min(100, max(0, (luzLux / maxLuxCalibrado) * 100));
                lblLux.Text = sprintf('%.0f %%', luzPorcentaje);
                gaugeLux.Value = luzPorcentaje;
                
                % ALARMA de luz baja
                if luzLux < 10
                    lblAlarmaLuz.Text = '⚠️ LUZ BAJA';
                    lblEstadoGeneral.Text = sprintf('⚠️ ALARMA: Luz %.1f lux [%s]', luzLux, origen);
                    lblEstadoGeneral.FontColor = colores.temperatura;
                    lblLux.FontColor = colores.temperatura;
                else
                    lblAlarmaLuz.Text = '';
                    lblEstadoGeneral.Text = sprintf('✅ Datos OK [%s]', origen);
                    lblEstadoGeneral.FontColor = colores.altura;
                    lblLux.FontColor = colores.luminosidad;
                end
            else
                disp('  - Luz: NO ENCONTRADA');
            end
            
            % VELOCIDAD DEL VIENTO (buscando en presencia o viento)
            if isfield(d, 'presencia')
                velocidad = d.presencia;
                disp(['  - Velocidad (presencia): ' num2str(velocidad) ' km/h']);
                lblViento.Text = sprintf('%.1f km/h', velocidad);
                
                % Cambiar color según velocidad
                if velocidad < 10
                    lblViento.FontColor = colores.altura; % Verde - viento suave
                elseif velocidad < 40
                    lblViento.FontColor = colores.luminosidad; % Amarillo - viento moderado
                else
                    lblViento.FontColor = colores.temperatura; % Rojo - viento fuerte
                end
            elseif isfield(d, 'viento')
                velocidad = d.viento;
                disp(['  - Velocidad (viento): ' num2str(velocidad) ' km/h']);
                lblViento.Text = sprintf('%.1f km/h', velocidad);
                
                if velocidad < 10
                    lblViento.FontColor = colores.altura;
                elseif velocidad < 40
                    lblViento.FontColor = colores.luminosidad;
                else
                    lblViento.FontColor = colores.temperatura;
                end
            elseif isfield(d, 'velocidad')
                velocidad = d.velocidad;
                disp(['  - Velocidad: ' num2str(velocidad) ' km/h']);
                lblViento.Text = sprintf('%.1f km/h', velocidad);
                
                if velocidad < 10
                    lblViento.FontColor = colores.altura;
                elseif velocidad < 40
                    lblViento.FontColor = colores.luminosidad;
                else
                    lblViento.FontColor = colores.temperatura;
                end
            else
                disp('  - Velocidad: NO ENCONTRADA (buscado en: presencia, viento, velocidad)');
            end
            
            disp(['==============================']);
            
        catch jsonErr
            disp(['ERROR procesando JSON: ' jsonErr.message]);
            disp(['Datos problemáticos: ' data]);
            lblEstadoGeneral.Text = sprintf('⚠️ Error JSON [%s]: %s', origen, jsonErr.message);
            lblEstadoGeneral.FontColor = colores.luminosidad;
        end
    end
    
    %% ========== FUNCIONES DE BOTONES ==========
    function guardarLectura()
        try
            timestamp = datetime('now','Format','yyyy-MM-dd HH:mm:ss');
            data = sprintf('[%s] %s, %s, %s, viento=%s',...
                timestamp, lblTemp.Text, lblAltura.Text, lblLux.Text, lblViento.Text);
            writelines(data,'registro_datos.txt','WriteMode','append');
            lblEstadoGeneral.Text = '💾 Lectura guardada';
            lblEstadoGeneral.FontColor = colores.altura;
        catch
            lblEstadoGeneral.Text = '❌ Error al guardar';
            lblEstadoGeneral.FontColor = colores.temperatura;
        end
    end
    
    btnGuardar.ButtonPushedFcn = @(~,~) guardarLectura();
    
    function limpiarAlarmas()
        lblAlarmaLuz.Text = '';
        lblEstadoGeneral.Text = '✅ Alarmas limpiadas';
        lblEstadoGeneral.FontColor = colores.altura;
        lblLux.FontColor = colores.luminosidad;
    end
    
    btnLimpiar.ButtonPushedFcn = @(~,~) limpiarAlarmas();
    
    %% ========== CERRAR GUI ==========
    fig.CloseRequestFcn = @(~,~) onClose();
    function onClose()
        desconectarWiFi();
        desconectarUART();
        delete(fig);
    end
end