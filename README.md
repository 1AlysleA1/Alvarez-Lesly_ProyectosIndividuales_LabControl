# EL-5409 Laboratorio de Control Automático

**Instituto Tecnológico de Costa Rica (ITCR)**  
**Escuela de Ingeniería Electrónica**  
**II Semestre 2026**  

* **Estudiante:** Álvarez Álvarez Lesly Mariana  
* **Carné:** 2021120228   
* **Profesor:** Ing. Luis C. Rosales  

---

## Descripción del Repositorio
Este repositorio contiene los scripts de simulación y código desarrollado para los proyectos individuales del curso de Laboratorio de Control Automático.

---

## Proyectos

### Proyecto Individual 1: Simulación de Motor de CD (1.er Orden)
* **Archivo:** `proyecto1.m`
* **Descripción:** Simulación paramétrica de un motor de CD definido por la función de transferencia $G(s) = \frac{K_M}{\tau s + 1}$. Valida los datos de entrada ($K_T, R_a, b, K_b, J$), calcula $K_M$ y $\tau$, e imprime la gráfica de respuesta al escalón mostrando $t=\tau$, tiempo de asentamiento y valor final.
* **Uso:**
  1. Abrir MATLAB.
  2. Ejecutar en la consola:
     ```matlab
     proyecto1
     ```
  3. Ingresar los parámetros solicitados.

### Proyecto Individual 2: Tabla de Routh-Hurwitz y Root Locus
* **Archivo:** `proyecto2.m`
* **Descripción:** Simulación paramétrica que solicita la ubicación de polos, ceros y la ganancia de lazo abierto de $G(s)$. Construye la ecuación característica $1 + KG(s) = 0$, genera la matriz de Routh-Hurwitz para evaluar la estabilidad del sistema (con su respectiva justificación) y grafica el Lugar Geométrico de las Raíces (Root Locus) resaltando los polos y ceros.
* **Uso:**
  1. Abrir MATLAB.
  2. Ejecutar en la consola:
     ```matlab
     proyecto2
     ```
  3. Ingresar los vectores de ceros (ej. `[]`), polos (ej. `[0 -1 -5]`), la ganancia $K_0$ de la planta y la ganancia $K$ a evaluar según los mensajes en pantalla.

3. Ingresar los vectores de ceros (ej. `[]`), polos (ej. `[0 -1 -5]`), la ganancia $K_0$ de la planta y la ganancia $K$ a evaluar según los mensajes en pantalla.

### Proyecto Individual 3: Análisis de Estabilidad y Reubicación Interactiva de Polos
* **Archivo:** `proyecto3.m`
* **Descripción:** Script interactivo compatible con MATLAB que construye la función de transferencia $G(s)$ en formato racional a partir de sus vectores de polos, ceros y ganancia $K_0$. Genera la matriz de Routh-Hurwitz con su evaluación formal de estabilidad y ofrece una interfaz gráfica interactiva en el plano $s$ para reubicar, agregar o eliminar polos (identificados individualmente como $P_n$) mediante selección por clic. Finalmente, calcula el compensador dinámico $C(s)$, muestra el Root Locus del sistema compensado y compara la respuesta al escalón en lazo cerrado entre el sistema original y el compensado.
* **Uso:**
  1. Abrir MATLAB.
  2. Ejecutar en la consola:
     ```matlab
     proyecto3
     ```
  3. Ingresar el vector de ceros $Z$ (ej. `[]`), el vector de polos $P$ (ej. `[-1 -2 -5]`) y las ganancias solicitadas.
  4. Utilizar el menú interactivo de la consola en conjunto con la ventana gráfica para hacer clic y manipular los polos $P_n$ según los requerimientos de diseño.
