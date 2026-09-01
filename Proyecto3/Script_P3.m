% =========================================================================
% Instituto Tecnológico de Costa Rica (ITCR)
% Escuela de Ingeniería Electrónica
% EL-5409 Laboratorio de Control Automático
% Profesor: Ing. Luis C. Rosales
%
% Proyecto Individual 3: Análisis de Estabilidad (Routh-Hurwitz) y Reubicación
% Interactiva de Polos mediante C(s)
% Estudiante: Álvarez Álvarez Lesly Mariana
% II Semestre 2026
% =========================================================================

clear; clc; close all;
fprintf('=====================================================\n');
fprintf('  ANÁLISIS DE ESTABILIDAD Y REUBICACIÓN DE POLOS\n');
fprintf('=====================================================\n\n');

%% 1. Solicitud de Entradas al Usuario
fprintf('Ingrese los polos y ceros de la planta G(s).\n');
fprintf('Ejemplo de formato: [-1 -2] o [-1+2j -1-2j] o [] si no hay.\n\n');

ceros_la = input('Ingrese el vector de ceros Z = ');
polos_la = input('Ingrese el vector de polos P = ');
k_planta = input('Ingrese la ganancia escalar K0 de la planta (por defecto 1): ');

if isempty(k_planta)
    k_planta = 1;
end

if isempty(polos_la)
    error('El sistema requiere al menos un polo en el denominador para construir la planta.');
end

k_eval = input('Ingrese un valor específico de ganancia K para la tabla de Routh (ej. 1): ');
if isempty(k_eval)
    k_eval = 1;
end

%% 2. Construcción de la Función de Transferencia G(s) en Formato Racional
poli_num = k_planta * real(poly(ceros_la));
poli_den = real(poly(polos_la));
G = tf(poli_num, poli_den);

fprintf('\n-----------------------------------------------------\n');
fprintf('1. Función de Transferencia G(s) en Formato Racional:\n');
fprintf('-----------------------------------------------------\n');
mostrar_racional(poli_num, poli_den, 'G(s)');
fprintf('Representación en objeto Control System Toolbox:\n');
disp(G);

%% 3. Construcción y Análisis con Tabla de Routh-Hurwitz
tam_num = length(poli_num);
tam_den = length(poli_den);
tam_max = max(tam_num, tam_den);

den_ajustado = [zeros(1, tam_max - tam_den), poli_den];
num_ajustado = [zeros(1, tam_max - tam_num), k_eval * poli_num];

poli_carac = den_ajustado + num_ajustado;

fprintf('--------------------------------------------------------------\n');
fprintf('2. Ecuación Característica 1 + K*G(s) = 0 para K = %.2f:\n', k_eval);
fprintf('--------------------------------------------------------------\n');
mostrar_polinomio(poli_carac, 'Q(s)');

% Construcción de la Matriz de Routh-Hurwitz
n = length(poli_carac) - 1;
num_columnas = ceil((n + 1) / 2);
matriz_routh = zeros(n + 1, num_columnas);

matriz_routh(1, 1:length(poli_carac(1:2:end))) = poli_carac(1:2:end);
matriz_routh(2, 1:length(poli_carac(2:2:end))) = poli_carac(2:2:end);

valor_epsilon = 1e-6;

for i = 3:(n + 1)
    for j = 1:(num_columnas - 1)
        pivote = matriz_routh(i - 1, 1);
        if abs(pivote) < 1e-12
            pivote = valor_epsilon;
        end
        
        numerador_val = pivote * matriz_routh(i - 2, j + 1) - matriz_routh(i - 2, 1) * matriz_routh(i - 1, j + 1);
        matriz_routh(i, j) = numerador_val / pivote;
    end
end

fprintf('\nMatriz de Routh-Hurwitz:\n');
fprintf('-----------------------------------------------------\n');
for i = 1:(n + 1)
    fprintf('s^%d \t| ', n - i + 1);
    for j = 1:num_columnas
        fprintf('%10.4f ', matriz_routh(i, j));
    end
    fprintf('\n');
end

% Evaluación de la Primera Columna
primera_columna = matriz_routh(:, 1);
cambios_signo = 0;

for i = 1:(length(primera_columna) - 1)
    if (primera_columna(i) * primera_columna(i + 1)) < 0
        cambios_signo = cambios_signo + 1;
    end
end

fprintf('\n-----------------------------------------------------\n');
fprintf('EVALUACIÓN Y JUSTIFICACIÓN DE ESTABILIDAD:\n');
fprintf('-----------------------------------------------------\n');

if cambios_signo == 0 && all(primera_columna > 0)
    fprintf('ESTADO: EL SISTEMA ES ESTABLE (para K = %.2f)\n\n', k_eval);
    fprintf('Explicación:\n');
    fprintf('- Todos los coeficientes de la primera columna son estrictamente positivos.\n');
    fprintf('- No existen cambios de signo, garantizando que todos los polos de lazo\n');
    fprintf('  cerrado se ubican en el semiplano izquierdo del plano s.\n');
else
    fprintf('ESTADO: EL SISTEMA ES INESTABLE (para K = %.2f)\n\n', k_eval);
    fprintf('Explicación:\n');
    fprintf('- Se detectaron %d cambio(s) de signo en la primera columna.\n', cambios_signo);
    fprintf('- Según Routh-Hurwitz, el número de cambios de signo equivale a la cantidad\n');
    fprintf('  de polos inestables en el semiplano derecho del plano s (%d polo(s)).\n', cambios_signo);
end

%% 4. Bucle Interactivo de Edición y Reubicación de Polos (P#)
polos_deseados = polos_la(:);
fig_inter = figure('Name', 'Edición Interactiva de Polos', 'NumberTitle', 'off');

continuar_edicion = true;

while continuar_edicion
    clf(fig_inter);
    [r_locus, ~] = rlocus(G);
    plot(real(r_locus)', imag(r_locus)', 'b:', 'LineWidth', 1);
    hold on; grid on;
    
    if ~isempty(ceros_la)
        plot(real(ceros_la), imag(ceros_la), 'bo', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Ceros Planta');
    end
    
    for idx = 1:length(polos_deseados)
        p_val = polos_deseados(idx);
        plot(real(p_val), imag(p_val), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
        text(real(p_val) + 0.15, imag(p_val) + 0.15, sprintf('P%d', idx), ...
            'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    end
    
    title('Selección Interactiva de Polos ');
    xlabel('Eje Real (\sigma)');
    ylabel('Eje Imaginario (j\omega)');
    legend('Root Locus G(s)', 'Location', 'best');
    drawnow;
    
    fprintf('\n=====================================================\n');
    fprintf('ESTADO ACTUAL DE POLOS EN EL PLANO s:\n');
    for idx = 1:length(polos_deseados)
        if abs(imag(polos_deseados(idx))) < 1e-4
            fprintf('  P%d: %.4f\n', idx, real(polos_deseados(idx)));
        else
            fprintf('  P%d: %.4f %+.4fj\n', idx, real(polos_deseados(idx)), imag(polos_deseados(idx)));
        end
    end
    fprintf('=====================================================\n');
    fprintf('Menú de Opciones:\n');
    fprintf('  1) Seleccionar un polo (P#) por número y reubicarlo mediante clic\n');
    fprintf('  2) Agregar un nuevo polo mediante clic\n');
    fprintf('  3) Eliminar un polo (P#)\n');
    fprintf('  4) Proceder a generar la nueva función de transferencia compensada\n');
    
    opcion = input('Seleccione una opción (1-4): ');
    
    switch opcion
        case 1
            if isempty(polos_deseados)
                fprintf('\n[ADVERTENCIA] No hay polos registrados para modificar.\n');
                continue;
            end
            num_polo = input(sprintf('Ingrese el número del polo a modificar (1 a %d): ', length(polos_deseados)));
            
            if num_polo >= 1 && num_polo <= length(polos_deseados)
                fprintf('--> Haga clic en el gráfico para la NUEVA posición del polo P%d...\n', num_polo);
                [x_new, y_new] = ginput(1);
                old_p = polos_deseados(num_polo);
                
                conj_idx = find(abs(polos_deseados - conj(old_p)) < 1e-3 & (1:length(polos_deseados))' ~= num_polo, 1);
                
                if abs(y_new) > 1e-3
                    polos_deseados(num_polo) = complex(x_new, abs(y_new));
                    if ~isempty(conj_idx)
                        polos_deseados(conj_idx) = complex(x_new, -abs(y_new));
                        fprintf('\n[INFORMACIÓN] Se reubicó P%d y se actualizó automáticamente su conjugado P%d.\n', num_polo, conj_idx);
                    else
                        polos_deseados = [polos_deseados; complex(x_new, -abs(y_new))];
                        fprintf('\n[INFORMACIÓN] P%d pasó a complejo. Se agregó su pareja conjugada P%d para mantener coeficientes reales.\n', num_polo, length(polos_deseados));
                    end
                else
                    polos_deseados(num_polo) = x_new;
                    if ~isempty(conj_idx)
                        polos_deseados(conj_idx) = x_new;
                        fprintf('\n[INFORMACIÓN] P%d se movió al eje real. Su par P%d también se ajustó al eje real.\n', num_polo, conj_idx);
                    else
                        fprintf('\n[INFORMACIÓN] Polo P%d reubicado en el eje real (%.4f).\n', num_polo, x_new);
                    end
                end
            else
                fprintf('\n[ERROR] Número de polo inválido.\n');
            end
            
        case 2
            fprintf('--> Haga clic en el gráfico para agregar un NUEVO polo...\n');
            [x_new, y_new] = ginput(1);
            if abs(y_new) > 1e-3
                polos_deseados = [polos_deseados; complex(x_new, abs(y_new)); complex(x_new, -abs(y_new))];
                fprintf('\n[INFORMACIÓN] Se agregaron 2 polos complejos conjugados (%.4f ± %.4fj).\n', x_new, abs(y_new));
            else
                polos_deseados = [polos_deseados; x_new];
                fprintf('\n[INFORMACIÓN] Se agregó 1 polo real en %.4f.\n', x_new);
            end
            
        case 3
            if isempty(polos_deseados)
                fprintf('\n[ADVERTENCIA] No existen polos para eliminar.\n');
                continue;
            end
            num_polo = input(sprintf('Ingrese el número del polo a eliminar (1 a %d): ', length(polos_deseados)));
            if num_polo >= 1 && num_polo <= length(polos_deseados)
                target_p = polos_deseados(num_polo);
                conj_idx = find(abs(polos_deseados - conj(target_p)) < 1e-3 & (1:length(polos_deseados))' ~= num_polo, 1);
                
                if ~isempty(conj_idx) && abs(imag(target_p)) > 1e-3
                    idx_elim = sort([num_polo, conj_idx], 'descend');
                    polos_deseados(idx_elim) = [];
                    fprintf('\n[AVISO DE SEGURIDAD] Se eliminó P%d y AUTOMÁTICAMENTE su conjugado P%d para prevenir coeficientes imaginarios.\n', num_polo, conj_idx);
                else
                    polos_deseados(num_polo) = [];
                    fprintf('\n[INFORMACIÓN] Se eliminó el polo real P%d correctamente.\n', num_polo);
                end
            else
                fprintf('\n[ERROR] Número de polo fuera de rango.\n');
            end
            
        case 4
            if isempty(polos_deseados)
                fprintf('\n[ERROR GRAVE] Se requiere al menos un polo para construir el sistema.\n');
                continue;
            end
            
            huerfanos = 0;
            idx_ch = 1;
            while idx_ch <= length(polos_deseados)
                p_tmp = polos_deseados(idx_ch);
                if abs(imag(p_tmp)) > 1e-3
                    has_conj = any(abs(polos_deseados - conj(p_tmp)) < 1e-3 & (1:length(polos_deseados))' ~= idx_ch);
                    if ~has_conj
                        polos_deseados = [polos_deseados; conj(p_tmp)];
                        huerfanos = huerfanos + 1;
                    end
                end
                idx_ch = idx_ch + 1;
            end
            
            if huerfanos > 0
                fprintf('\n[AVISO DE SISTEMA] Se corrigieron %d polo(s) complejos huérfanos agregando sus parejas conjugadas.\n', huerfanos);
            end
            
            confirmacion = input('\n¿Desea proceder a calcular el compensador y analizar la respuesta? (s/n): ', 's');
            if strcmpi(confirmacion, 's') || strcmpi(confirmacion, 'si') || strcmpi(confirmacion, 'y')
                continuar_edicion = false;
            end
            
        otherwise
            fprintf('\n[ERROR] Opción no válida.\n');
    end
end

%% 5. Generación del Compensador C(s) y Ecuación Característica Compensada
poli_den_comp = real(poly(polos_deseados));

tam_num_c = length(poli_num);
tam_den_c = length(poli_den_comp);
tam_max_c = max(tam_num_c, tam_den_c);

den_pad_c = [zeros(1, tam_max_c - tam_den_c), poli_den_comp];
num_pad_c = [zeros(1, tam_max_c - tam_num_c), poli_num];

poli_carac_comp = den_pad_c + num_pad_c;

fprintf('\n-----------------------------------------------------\n');
fprintf('3. Ecuación Característica del Sistema Compensado:\n');
fprintf('-----------------------------------------------------\n');
mostrar_polinomio(poli_carac_comp, 'Q_comp(s)');

% Compensador C(s) = D_planta(s) / D_deseado(s)
poly_num_c = real(poly(polos_la));
poly_den_c = real(poly(polos_deseados));
C = tf(poly_num_c, poly_den_c);

fprintf('\n-----------------------------------------------------\n');
fprintf('4. Función de Transferencia del Compensador C(s) (En formato Racional):\n');
fprintf('-------------------------------------------------------,--\n');
mostrar_racional(poly_num_c, poly_den_c, 'C(s)');
fprintf('Representación en objeto Control System Toolbox:\n');
disp(C);

G_comp = C * G;

%% 6. Gráficas Finales (Root Locus Compensado y Respuesta Temporal)
figure('Name', 'Root Locus del Sistema Compensado', 'NumberTitle', 'off');
[r_locus_comp, ~] = rlocus(G_comp);
plot(real(r_locus_comp)', imag(r_locus_comp)', 'm-', 'LineWidth', 1.2);
hold on; grid on;

if ~isempty(ceros_la)
    plot(real(ceros_la), imag(ceros_la), 'bo', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Ceros Planta');
end

plot(real(polos_deseados), imag(polos_deseados), 'rx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Polos Nuevos');

for idx = 1:length(polos_deseados)
    p_val = polos_deseados(idx);
    text(real(p_val) + 0.15, imag(p_val) + 0.15, sprintf('P%d', idx), 'FontSize', 10, 'FontWeight', 'bold');
end

title('Lugar Geométrico de las Raíces - Sistema Compensado Final');
xlabel('Eje Real (\sigma)');
ylabel('Eje Imaginario (j\omega)');
legend('Location', 'best');

% Respuesta al Escalón en Lazo Cerrado
G_lc_orig = feedback(G, 1);
G_lc_comp = feedback(G_comp, 1);

figure('Name', 'Comparación de Respuesta al Escalón', 'NumberTitle', 'off');
step(G_lc_orig, 'b--', G_lc_comp, 'r-');
grid on;
title('Respuesta al Escalón: Sistema Original vs. Sistema Compensado');
legend('Lazo Cerrado Original', 'Lazo Cerrado Compensado', 'Location', 'best');
xlabel('Tiempo (s)');
ylabel('Amplitud');

%% =========================================================================
% FUNCIONES AUXILIARES DE FORMATO :v
% =========================================================================

function mostrar_racional(num, den, nombre, 
    % Imprime la función de transferencia en forma de fracción racional ASCII
    str_num = poly2str_custom(num);
    str_den = poly2str_custom(den);
    max_len = max(length(str_num), length(str_den));
    
    pad_num = floor((max_len - length(str_num)) / 2);
    pad_den = floor((max_len - length(str_den)) / 2);
    
    prefix = sprintf('%s = ', nombre);
    espacios_prefijo = repmat(' ', 1, length(prefix));
    
    fprintf('\n%s%s%s\n', prefix, repmat(' ', 1, pad_num), str_num);
    fprintf('%s%s\n', espacios_prefijo, repmat('-', 1, max_len));
    fprintf('%s%s%s\n\n', espacios_prefijo, repmat(' ', 1, pad_den), str_den);
end

function str = poly2str_custom(coefs)
    % Convierte un vector de coeficientes polinomiales a cadena en formato de potencias descendentes
    grado = length(coefs) - 1;
    str = '';
    primer_termino = true;
    
    for i = 1:length(coefs)
        pot = grado - (i - 1);
        val = coefs(i);
        
        if abs(val) > 1e-6
            if primer_termino
                if val < 0
                    str = sprintf('-%.4g', abs(val));
                else
                    str = sprintf('%.4g', val);
                end
                primer_termino = false;
            else
                if val < 0
                    str = [str, sprintf(' - %.4g', abs(val))];
                else
                    str = [str, sprintf(' + %.4g', val)];
                end
            end
            
            if pot > 1
                str = [str, sprintf('s^%d', pot)];
            elseif pot == 1
                str = [str, 's'];
            end
        end
    end
    
    if isempty(str)
        str = '0';
    end
end

function mostrar_polinomio(coeficientes, nombre)
    % Formatea polinomialmente ecuaciones características tipo Q(s) = 0
    grado = length(coeficientes) - 1;
    str = [nombre, ' = '];
    for i = 1:length(coeficientes)
        pot = grado - (i - 1);
        val = coeficientes(i);
        if abs(val) > 1e-6
            if pot > 1
                str = [str, sprintf('%+.4g*s^%d ', val, pot)];
            elseif pot == 1
                str = [str, sprintf('%+.4g*s ', val)];
            else
                str = [str, sprintf('%+.4g ', val)];
            end
        end
    end
    fprintf('%s = 0\n', str);
end
