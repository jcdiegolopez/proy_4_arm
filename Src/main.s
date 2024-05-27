/**
 ******************************************************************************
 * @file      startup_stm32f446retx.s
 * @author    Dilary Sarahí Cruz López - 231010
 *            Diego José López Campos - 23242
 *            Jonathan Josúe Zacarías Bances - 231104
 * @brief     Vector de interrupciones del dispositivo STM32F446RETx para el
 *            conjunto de herramientas GCC.
 *            Este módulo realiza:
 *                - Configuración del SP inicial
 *                - Configuración del PC inicial == Reset_Handler
 *                - Configuración de las entradas de la tabla de vectores con
 *                  las direcciones de las ISR de excepciones
 *                - Salto a la función principal en la biblioteca C (que
 *                  eventualmente llama a main()).
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2024 STMicroelectronics.
 * Todos los derechos reservados.
 *
 * Este software está licenciado bajo los términos que se pueden encontrar en el
 * archivo LICENSE en el directorio raíz de este componente de software. Si no
 * se proporciona un archivo LICENSE con este software, se proporciona TAL CUAL.
 *
 ******************************************************************************
 *
 * Universidad del Valle de Guatemala
 * Facultad de Ingeniería
 * Departamento de Ciencias de la Computación
 * CC3054 Organización de computadoras y Assembler
 * Ciclo 1 - 2024
 * Proyecto 4
 *
 * Objetivo:
 * Diseñar y programar el funcionamiento de los puertos GPIO del STM32, para un
 * display de 7 segmentos. Este tendrá un comportamiento de activación/desactivación
 * que realice el despliegue secuencial de las letras A, B, C, D, E, F, G, H.
 * El corrimiento cíclico se activará al presionar un push button A. La señal de
 * reloj para el control del circuito tendrá un período de 1.5 segundos.
 *
 * El funcionamiento debe ser cíclico, es decir, al finalizar la secuencia, esta
 * debe iniciar de nuevo desde el estado 0.
 ******************************************************************************
 */
/*--------------------------------------------------
DEFINICIONES PARA HABILITAR EL RELOJ AHB1 PARA LOS PUERTOS A Y C
--------------------------------------------------*/
.equ    RCC_BASE,        0x40023800        // Dirección base del RCC
.equ    AHB1ENR_OFFSET,  0x30              // Desplazamiento del registro de habilitación AHB1
.equ    RCC_AHB1ENR,     (RCC_BASE + AHB1ENR_OFFSET) // Dirección del registro de habilitación AHB1 del RCC

.equ    GPIOC_BASE,      0x40020800        // Dirección base del GPIOC
.equ    GPIOA_BASE,      0x40020000        // Dirección base del GPIOA
.equ    GPIOA_EN,        (1 << 0)          // Habilitar reloj para GPIOA (establecer bit 0)
.equ    GPIOC_EN,        (1 << 2)          // Habilitar reloj para GPIOC (establecer bit 1)

/*--------------------------------------------------
DEFINICIONES PARA CONFIGURAR LOS PUERTOS A Y C
--------------------------------------------------*/
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

/*--------------------------------------------------
DEFINICIONES PARA CONTROLAR LOS PUERTOS
--------------------------------------------------*/
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

.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb
.section .text
.globl __main

__main:
    // Habilitar acceso al reloj para GPIOA y GPIOC

    // Cargar la dirección de RCC_AHB1ENR en r0
    ldr r0, =RCC_AHB1ENR
    // Cargar el valor en la dirección encontrada en r0 en r1
    ldr r1, [r0]
    // Habilitar reloj para GPIOA y GPIOC
    orr r1, #GPIOA_EN
    orr r1, #GPIOC_EN
    // Almacenar el contenido en r1 en la dirección encontrada en r0
    str r1, [r0]

    // Configurar PA0, PA1, PA4, PA6, PA7, PA8, PA9 como salida
    // Cargar la dirección de GPIOA_MODER en r0
    ldr r0, =GPIOA_MODER
    // Cargar el valor en la dirección encontrada en r0 en r1
    ldr r1, [r0]
    // Configurar PA0 como salida
    orr r1, #MODERPA0_OUT
    // Configurar PA1 como salida
    orr r1, #MODERPA1_OUT
    // Configurar PA4 como salida
    orr r1, #MODERPA4_OUT
    // Configurar PA6 como salida
    orr r1, #MODERPA6_OUT
    // Configurar PA7 como salida
    orr r1, #MODERPA7_OUT
    // Configurar PA8 como salida
    orr r1, #MODERPA8_OUT
    // Configurar PA9 como salida
    orr r1, #MODERPA9_OUT
    // Almacenar el contenido en r1 en la dirección encontrada en r0
    str r1, [r0]

    // Configurar PC13 como entrada
    // Cargar la dirección de GPIOC_MODER en r0
    ldr r0, =GPIOC_MODER
    // Cargar el valor en la dirección encontrada en r0 en r1
    ldr r1, [r0]
    // Borrar bits para configurar PC13 como entrada
    BIC R1, R1, #(3 << 26)
    // Almacenar el contenido en r1 en la dirección encontrada en r0
    str r1, [r0]
   // bl check_button
    b off



//check_button:
  //  ldr r0, =GPIOC_IDR
  //  ldr r1, [r0]
  //  tst r1, #BUTTON_PC13
  //  beq check_button


start_cycle:
    bl display_A
    bl delay_1_5_seconds

    bl display_B
    bl delay_1_5_seconds

    bl display_C
    bl delay_1_5_seconds

    bl display_D
    bl delay_1_5_seconds

    bl display_E
    bl delay_1_5_seconds

    bl display_F
    bl delay_1_5_seconds

    bl display_G
    bl delay_1_5_seconds

    bl display_H
    bl delay_1_5_seconds

    b start_cycle

display_A:
    ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA8_ON
    str r1, [r0]
    bx lr

display_B:
    ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA4_ON | LEDPA6_ON
    str r1, [r0]
    bx lr

display_C:
    ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA0_ON |LEDPA6_ON | LEDPA9_ON
    str r1, [r0]
    bx lr

display_D:
    ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA1_ON | LEDPA4_ON
    str r1, [r0]
    bx lr

display_E:
    ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA6_ON | LEDPA9_ON
    str r1, [r0]
    bx lr

display_F:
    ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA6_ON | LEDPA8_ON | LEDPA9_ON
    str r1, [r0]
    bx lr

display_G:
    ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA7_ON
    str r1, [r0]
    bx lr

display_H:
    ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA4_ON | LEDPA8_ON
    str r1, [r0]
    bx lr

delay_1_5_seconds:
    mov r6, lr
    ldr r3, =time_delay_1_5_seconds
    ldr r5, [r3]
    bl delay_loop
    bx r6

delay_loop:
    subs r5, r5, #1
    cmp r5, #0
    bne delay_loop
    bx lr

read_button:
    // Leer el estado de PC13
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]
    LSR R1, R1, #13 // Desplazar el bit 13 a la posición menos significativa
    ANDS R1, R1, #1 // Enmascarar todos los bits excepto el menos significativo

    // Aquí puedes realizar alguna acción dependiendo del estado del botón
    // R1 será 0 si el botón está presionado y 1 si no lo está
	CMP R1,0
	BEQ start_cycle
    // Loop infinito
    B read_button

 off:
 	ldr r0, =GPIOA_ODR
    ldr r1, =LEDPA0_ON | LEDPA1_ON |LEDPA4_ON |LEDPA6_ON |LEDPA7_ON |LEDPA8_ON |LEDPA9_ON
    str r1, [r0]
    b read_button


.section .data
time_delay_1_5_seconds: .word 5000000  // Conteo aproximado de retraso para 1.5 segundos
.align
.end
