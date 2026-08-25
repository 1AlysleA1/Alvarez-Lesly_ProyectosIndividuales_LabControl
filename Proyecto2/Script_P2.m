% =========================================================================
% Instituto Tecnológico de Costa Rica (ITCR)
% Escuela de Ingeniería Electrónica
% EL-5409 Laboratorio de Control Automático
% Profesor: Ing. Luis C. Rosales
%
% Proyecto Individual 2: Tabla de Routh-Hurwitz y Root Locus
% Estudiante: Álvarez Álvarez Lesly Mariana
% II Semestre 2026
% =========================================================================

clear; clc; close all;

fprintf('=====================================================\n');
fprintf('  ANÁLISIS DE ESTABILIDAD: ROUTH-HURWITZ Y ROOT LOCUS\n');
fprintf('=====================================================\n\n');

%% 1. Solicitud de entradas al usuario
fprintf('Ingrese los polos y ceros de la planta G(s).\n');
fprintf('Ejemplo de formato: [-1 -2] o [-1+2j -1-2j] o [] si no hay.\n\n');

ceros_la = input('Ingrese el vector de ceros de lazo abierto Z = ');
polos_la = input('Ingrese el vector de polos de lazo abierto P = ');
k_planta = input('Ingrese la ganancia escalar K0 de la planta (por defecto 1): ');

if isempty(k_planta)
    k_planta = 1;
end

%% 2. Construcción de la Función de Transferencia G(s)
% Expansión polinomial a partir de las raíces
poli_num = poly(ceros_la);
poli_den = poly(polos_la);

% Ajuste con la ganancia K0 de la planta
poli_num = k_planta * poli_num;

% Creación del objeto de función de transferencia
G = tf(poli_num, poli_den);

fprintf('\n-----------------------------------------------------\n');
fprintf('Función de Transferencia en Lazo Abierto G(s):\n');
fprintf('-----------------------------------------------------\n');
disp(G);

%% 3. Construcción de la Ecuación Característica
% Ecuación de lazo cerrado: 1 + K*G(s) = 0 => D(s) + K*N(s) = 0
k_eval = input('Ingrese un valor específico de ganancia K para la tabla de Routh (ej. 1): ');

if isempty(k_eval)
    k_eval = 1;
end

% Ajuste dinámico de dimensiones para poder sumar denominador y numerador
tam_num = length(poli_num);
tam_den = length(poli_den);
tam_max = max(tam_num, tam_den);

den_ajustado = [zeros(1, tam_max - tam_den), poli_den];
num_ajustado = [zeros(1, tam_max - tam_num), k_eval * poli_num];

poli_carac = den_ajustado + num_ajustado;

fprintf('\n-----------------------------------------------------\n');
fprintf('Ecuación Característica 1 + K*G(s) = 0 para K = %.2f:\n', k_eval);
fprintf('-----------------------------------------------------\n');

grado_polinomio = length(poli_carac) - 1;
texto_polinomio = 'Q(s) = ';

for i = 1:length(poli_carac)
    potencia = grado_polinomio - (i - 1);
    val = poli_carac(i);
    if potencia > 0
        texto_polinomio = [texto_polinomio, sprintf('%+.4g*s^%d ', val, potencia)];
    else
        texto_polinomio = [texto_polinomio, sprintf('%+.4g ', val)];
    end
end
fprintf('%s = 0\n', texto_polinomio);

%% 4. Construcción de la Matriz de Routh-Hurwitz
n = length(poli_carac) - 1; % Grado del polinomio
num_columnas = ceil((n + 1) / 2);
matriz_routh = zeros(n + 1, num_columnas);

% Rellenado de las dos primeras filas
matriz_routh(1, 1:length(poli_carac(1:2:end))) = poli_carac(1:2:end);
matriz_routh(2, 1:length(poli_carac(2:2:end))) = poli_carac(2:2:end);

% Cálculo recursivo de las filas restantes
valor_epsilon = 1e-6; % Tolerancia para evitar división entre cero

for i = 3:(n + 1)
    for j = 1:(num_columnas - 1)
        % Elemento pivote de la fila anterior
        pivote = matriz_routh(i - 1, 1);
        if abs(pivote) < 1e-12
            pivote = valor_epsilon;
        end
        
        numerador_val = pivote * matriz_routh(i - 2, j + 1) - matriz_routh(i - 2, 1) * matriz_routh(i - 1, j + 1);
        matriz_routh(i, j) = numerador_val / pivote;
    end
end

fprintf('\n-----------------------------------------------------\n');
fprintf('Matriz de Routh-Hurwitz:\n');
fprintf('-----------------------------------------------------\n');

for i = 1:(n + 1)
    fprintf('s^%d \t| ', n - i + 1);
    for j = 1:num_columnas
        fprintf('%10.4f ', matriz_routh(i, j));
    end
    fprintf('\n');
end

%% 5. Análisis de Estabilidad
primera_columna = matriz_routh(:, 1);
cambios_signo = 0;

for i = 1:(length(primera_columna) - 1)
    if (primera_columna(i) * primera_columna(i + 1)) < 0
        cambios_signo = cambios_signo + 1;
    end
end

fprintf('\n-----------------------------------------------------\n');
fprintf('JUSTIFICACIÓN Y EVALUACIÓN DE ESTABILIDAD:\n');
fprintf('-----------------------------------------------------\n');

if cambios_signo == 0 && all(primera_columna > 0)
    fprintf('ESTADO: EL SISTEMA ES ESTABLE (para K = %.2f)\n\n', k_eval);
    fprintf('Explicación:\n');
    fprintf('- Todos los valores de la primera columna de la tabla son positivos.\n');
    fprintf('- No existe ningún cambio de signo entre los elementos de esa columna.\n');
    fprintf('- Según el criterio de Routh-Hurwitz, esto garantiza que TODOS los polos\n');
    fprintf('  en lazo cerrado están en el semiplano izquierdo (estabilidad).\n');
else
    fprintf('ESTADO: EL SISTEMA ES INESTABLE (para K = %.2f)\n\n', k_eval);
    fprintf('Explicación:\n');
    fprintf('- Se detectaron %d cambio(s) de signo en la primera columna de la tabla.\n', cambios_signo);
    fprintf('- Según el criterio de Routh-Hurwitz, la cantidad de cambios de signo es igual\n');
    fprintf('  al número de polos inestables.\n');
    fprintf('- Por lo tanto, el sistema tiene %d polo(s) en el semiplano derecho del plano s.\n', cambios_signo);
end

%% 6. Generación del Gráfico del Lugar Geométrico de las Raíces (Root Locus)
figure('Name', 'Lugar Geométrico de las Raíces', 'NumberTitle', 'off');
rlocus(G);
hold on;

% Resaltar polos y ceros de lazo abierto
if ~isempty(polos_la)
    plot(real(polos_la), imag(polos_la), 'rx', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'Polos L.A.');
end

if ~isempty(ceros_la)
    plot(real(ceros_la), imag(ceros_la), 'bo', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Ceros L.A.');
end

grid on;
title('Lugar Geométrico de las Raíces (Root Locus)', 'FontSize', 12);
xlabel('Eje Real (\sigma)', 'FontSize', 10);
ylabel('Eje Imaginario (j\omega)', 'FontSize', 10);
legend('Location', 'best');
hold off;

fprintf('\nGráfico de Root Locus generado exitosamente.\n');
