% =========================================================================
% Instituto Tecnológico de Costa Rica (ITCR)
% Escuela de Ingeniería Electrónica
% EL-5409 Laboratorio de Control Automático
% Profesor: Ing. Luis C. Rosales
%
% Proyecto Individual 1: Simulación Paramétrica de un Motor de CD
% Estudiante: Álvarez Álvarez Lesly Mariana
% II Semestre 2026
% =========================================================================

clear; clc; close all;

disp('======================================================');
disp('   SIMULACIÓN PARAMÉTRICA DE UN MOTOR DE CD - G(s)    ');
disp('======================================================');

%% 1. ENTRADA Y VALIDACIÓN DE PARÁMETROS
param_ok = false;

while ~param_ok
    fprintf('\nIngrese los parámetros físicos del motor:\n');
    Kt = input('1. Constante de par Kt [N·m/A]: ');
    Ra = input('2. Resistencia de armadura Ra [Ohm]: ');
    b  = input('3. Coeficiente de fricción b [N·m·s/rad]: ');
    Kb = input('4. Constante de fuerza electromotriz Kb [V·s/rad]: ');
    J  = input('5. Momento de inercia J [kg·m^2]: ');
    
    % Validación 1: Verificar que los datos no estén vacíos
    if isempty(Kt) || isempty(Ra) || isempty(b) || isempty(Kb) || isempty(J)
        disp('--> ERROR: Todos los parámetros deben ser ingresados. Intente nuevamente.');
    % Validación 2: Verificar que todos los valores sean mayores que cero
    elseif Kt <= 0 || Ra <= 0 || b <= 0 || Kb <= 0 || J <= 0
        disp('--> ERROR: Todos los valores deben ser estrictamente positivos (> 0). Intente nuevamente.');
    else
        denominador = Ra * b + Kt * Kb;
        if denominador <= 0
            disp('--> ERROR: La combinación de parámetros produce una división por cero. Intente nuevamente.');
        else
            param_ok = true;
        end
    end
    disp('------------------------------------------------------');
end

%% 2. CÁLCULO DE COEFICIENTES (KM y tau)
KM = Kt / (Ra * b + Kt * Kb);
tau = (Ra * J) / (Ra * b + Kt * Kb);

fprintf('\n======================================================\n');
fprintf('                RESULTADOS CALCULADOS                 \n');
fprintf('======================================================\n');
fprintf('  * Ganancia General (KM):        %0.4f rad/(V·s)\n', KM);
fprintf('  * Constante de Tiempo (tau):     %0.4f s\n', tau);
fprintf('======================================================\n\n');

%% 3. DEFINICIÓN DE LA FUNCIÓN DE TRANSFERENCIA Y SIMULACIÓN
% G(s) = KM / (tau*s + 1)
G = tf(KM, [tau, 1]);

% Vector de tiempo de simulación (hasta 6*tau para mostrar estado estacionario)
t = linspace(0, 6*tau, 1000);
[y, t] = step(G, t);

% Cálculo de puntos clave requeridos:
y_final = KM;                        % Valor final esperado (t = infinity)
t_1tau = 1 * tau;                    % Tiempo t = 1*tau
y_1tau = KM * (1 - exp(-1));         % Valor de la respuesta en t = 1*tau (~63.2% del valor final)
t_5tau = 5 * tau;                    % Tiempo t = 5*tau
y_5tau = KM * (1 - exp(-5));         % Valor de la respuesta en t = 5*tau (~99.3% del valor final)
ts_2 = -tau * log(0.02);             % Tiempo de asentamiento al 2% (ts ≈ 3.912 * tau)
y_ts_2 = 0.98 * KM;                  % Valor al 98% de la respuesta
ess = abs(1 - y_final);              % Error de estado estacionario ante escalón unitario

%% 4. GRAFICACIÓN Y VISUALIZACIÓN DE REQUERIMIENTOS
figure('Name', 'Respuesta al Escalón - Motor de CD', 'NumberTitle', 'off');
plot(t, y, 'b-', 'LineWidth', 2, 'DisplayName', 'Respuesta y(t)');
hold on; grid on;

% a) Valor final esperado (línea horizontal)
plot([0, max(t)], [y_final, y_final], 'k--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Valor Final Esperado (KM = %.4f)', y_final));

% Punto en t = 1*tau
plot(t_1tau, y_1tau, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
    'DisplayName', sprintf('t = 1\\tau (%.2f s, y = %.4f)', t_1tau, y_1tau));

% Punto en t = 5*tau
plot(t_5tau, y_5tau, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', 'k', ...
    'DisplayName', sprintf('t = 5\\tau (%.2f s, y = %.4f)', t_5tau, y_5tau));

% b) Entrada escalón unitario para visualizar el Error de Estado Estacionario (ess)
plot([0, max(t)], [1, 1], 'g--', 'LineWidth', 1.2, ...
    'DisplayName', 'Entrada Escalón Unitario r(t) = 1');

% d) Tiempo de asentamiento (criterio del 2%)
plot(ts_2, y_ts_2, 'm^', 'MarkerSize', 8, 'MarkerFaceColor', 'm', ...
    'DisplayName', sprintf('Tiempo de Asentamiento 2%% (ts = %.2f s)', ts_2));

% Formato del gráfico
title('Respuesta del Motor de CD al Escalón Unitario', 'FontSize', 12);
xlabel('Tiempo t [s]', 'FontSize', 11);
ylabel('Velocidad angular y(t) [rad/s]', 'FontSize', 11);
legend('Location', 'southeast', 'FontSize', 9);

% Cuadro con datos cuantitativos en la gráfica
str_info = {
    sprintf('\\bfParámetros Calculados:\\rm');
    sprintf('K_M = %.4f rad/(V·s)', KM);
    sprintf('\\tau = %.4f s', tau);
    sprintf('e_{ss} = |1 - K_M| = %.4f', ess)
};
annotation('textbox', [0.15, 0.62, 0.28, 0.22], 'String', str_info, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'w', 'EdgeColor', 'k');

disp('--> Simulación completada. Gráfico generado con éxito.');
