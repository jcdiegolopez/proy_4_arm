# Proyecto 4 - Organización de Computadoras y Assembler

## Descripción del Archivo

### startup_stm32f446retx.s

**Autores:**
- Dilary Sarahí Cruz López - 231010
- Diego José López Campos - 23242
- Jonathan Josúe Zacarías Bances - 231104

**Resumen:**
Vector de interrupciones del dispositivo STM32F446RETx para el conjunto de herramientas GCC. Este módulo realiza:
- Configuración del SP inicial
- Configuración del PC inicial == `Reset_Handler`
- Configuración de las entradas de la tabla de vectores con las direcciones de las ISR de excepciones
- Salto a la función principal en la biblioteca C (que eventualmente llama a `main()`).

---

## Licencia

**Derechos de Autor (c) 2024 STMicroelectronics. Todos los derechos reservados.**

Este software está licenciado bajo los términos que se pueden encontrar en el archivo LICENSE en el directorio raíz de este componente de software. Si no se proporciona un archivo LICENSE con este software, se proporciona TAL CUAL.

---

## Información del Proyecto

**Universidad del Valle de Guatemala**  
**Facultad de Ingeniería**  
**Departamento de Ciencias de la Computación**  
**CC3054 Organización de Computadoras y Assembler**  
**Ciclo 1 - 2024**  

### Objetivo

Diseñar y programar el funcionamiento de los puertos GPIO del STM32, para un display de 7 segmentos. Este tendrá un comportamiento de activación/desactivación que realice el despliegue secuencial de las letras A, B, C, D, E, F, G, H. El corrimiento cíclico se activará al presionar un push button A. La señal de reloj para el control del circuito tendrá un período de 1.5 segundos. El funcionamiento debe ser cíclico, es decir, al finalizar la secuencia, esta debe iniciar de nuevo desde el estado 0.

---

## Definiciones

### Habilitar el Reloj AHB1 para los Puertos A y C

```assembly
.equ    RCC_BASE,        0x40023800        // Dirección base del RCC
.equ    AHB1ENR_OFFSET,  0x30              // Desplazamiento del registro de habilitación AHB1
.equ    RCC_AHB1ENR,     (RCC_BASE + AHB1ENR_OFFSET) // Dirección del registro de habilitación AHB1 del RCC

.equ    GPIOC_BASE,      0x40020800        // Dirección base del GPIOC
.equ    GPIOA_BASE,      0x40020000        // Dirección base del GPIOA
.equ    GPIOA_EN,        (1 << 0)          // Habilitar reloj para GPIOA (establecer bit 0)
.equ    GPIOC_EN,        (1 << 2)          // Habilitar reloj para GPIOC (establecer bit 1)

```
### Configurar los Puertos A y C
```assembly
.equ    GPIOA_MODER_OFFSET, 0x00           // Desplazamiento del registro de modo de GPIOA
.equ    GPIOC_MODER_OFFSET, 0x00           // Desplazamiento del registro de modo de GPIOC
.equ    GPIOA_MODER,     (GPIOA_BASE + GPIOA_MODER_OFFSET) // Dirección del registro de modo de GPIOA
.equ    GPIOC_MODER,     (GPIOC_BASE + GPIOC_MODER_OFFSET) // Dirección del registro de modo de GPIOC
.equ    MODERPA0_OUT,    (1 << 0)          // Configurar PA0 como salida
.equ    MODERPA1_OUT,    (1 << 2)          // Configurar PA1 como salida
.equ    MODERPA4_OUT,    (1 << 8)          // Configurar PA4 como salida
.equ    MODERPA6_OUT,    (1 << 12)         // Configurar PA6 como salida
.equ    MODERPA7_OUT,    (1 << 14)         // Configurar PA7 como salida
.equ    MODERPA8_OUT,    (1 << 16)         // Configurar PA8 como salida
.equ    MODERPA9_OUT,    (1 << 18)         // Configurar PA9 como salida
.equ    MODERPC13_IN,    (0 << 26)         // Configurar PC13 como entrada
```

### Controlar los Puertos
```assembly
.equ    GPIOA_ODR_OFFSET, 0x14             // Desplazamiento del registro de datos de salida de GPIOA
.equ    GPIOC_IDR_OFFSET, 0x10             // Desplazamiento del registro de datos de entrada de GPIOC
.equ    GPIOA_ODR,       (GPIOA_BASE + GPIOA_ODR_OFFSET) // Dirección del registro de datos de salida de GPIOA
.equ    GPIOC_IDR,       (GPIOC_BASE + GPIOC_IDR_OFFSET) // Dirección del registro de datos de entrada de GPIOC

.equ    LEDPA0_ON,       (1 << 0)          // Encender PA0 (encender LED)
.equ    LEDPA1_ON,       (1 << 1)          // Encender PA1 (encender LED)
.equ    LEDPA4_ON,       (1 << 4)          // Encender PA4 (encender LED)
.equ    LEDPA6_ON,       (1 << 6)          // Encender PA6 (encender LED)
.equ    LEDPA7_ON,       (1 << 7)          // Encender PA7 (encender LED)
.equ    LEDPA8_ON,       (1 << 8)          // Encender PA8 (encender LED)
.equ    LEDPA9_ON,       (1 << 9)          // Encender PA9 (encender LED)
.equ    BUTTON_PC13,     (1 << 13)         // Máscara de bits para el botón PC13

```
