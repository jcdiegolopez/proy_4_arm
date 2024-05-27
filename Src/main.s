.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

/*--------------------------------------------------
DEFINITIONS FOR AHB1 CLOCK ENABLE FOR PORT A AND PORT C
-------------------------------------------------*/
.equ    RCC_BASE,        0x40023800        // Base address for RCC
.equ    AHB1ENR_OFFSET,  0x30              // Offset for AHB1 enable register
.equ    RCC_AHB1ENR,     (RCC_BASE + AHB1ENR_OFFSET) // RCC AHB1 enable register address

.equ    GPIOC_BASE,      0x40020800        // Base address for GPIOC
.equ    GPIOA_BASE,      0x40020000        // Base address for GPIOA
.equ    GPIOA_EN,        (1 << 0)          // Enable clock for GPIOA (set bit 0)
.equ    GPIOC_EN,        (1 << 2)          // Enable clock for GPIOC (set bit 1)

/*--------------------------------------------------
DEFINITIONS FOR CONFIGURING PORTS A AND C
-------------------------------------------------*/
.equ    GPIOA_MODER_OFFSET, 0x00           // Offset for GPIOA mode register
.equ    GPIOC_MODER_OFFSET, 0x00           // Offset for GPIOC mode register
.equ    GPIOA_MODER,     (GPIOA_BASE + GPIOA_MODER_OFFSET) // GPIOA mode register address
.equ    GPIOC_MODER,     (GPIOC_BASE + GPIOC_MODER_OFFSET) // GPIOC mode register address
.equ    MODERPA0_OUT,    (1 << 0)          // Set PA0 as output
.equ    MODERPA1_OUT,    (1 << 2)          // Set PA1 as output
.equ    MODERPA4_OUT,    (1 << 8)          // Set PA4 as output
.equ    MODERPA6_OUT,    (1 << 12)         // Set PA6 as output
.equ    MODERPA7_OUT,    (1 << 14)         // Set PA7 as output
.equ    MODERPA8_OUT,    (1 << 16)         // Set PA8 as output
.equ    MODERPA9_OUT,    (1 << 18)         // Set PA9 as output
.equ    MODERPC13_IN,    (0 << 26)         // Set PC13 as input

/*--------------------------------------------------
DEFINITIONS FOR CONTROLLING PORTS
-------------------------------------------------*/
.equ    GPIOA_ODR_OFFSET, 0x14             // Offset for GPIOA output data register
.equ    GPIOC_IDR_OFFSET, 0x10             // Offset for GPIOC input data register
.equ    GPIOA_ODR,       (GPIOA_BASE + GPIOA_ODR_OFFSET) // GPIOA output data register address
.equ    GPIOC_IDR,       (GPIOC_BASE + GPIOC_IDR_OFFSET) // GPIOC input data register address

.equ    LEDPA0_ON,       (1 << 0)          // Set PA0 high (turn on LED)
.equ    LEDPA1_ON,       (1 << 1)          // Set PA1 high (turn on LED)
.equ    LEDPA4_ON,       (1 << 4)          // Set PA4 high (turn on LED)
.equ    LEDPA6_ON,       (1 << 6)          // Set PA6 high (turn on LED)
.equ    LEDPA7_ON,       (1 << 7)          // Set PA7 high (turn on LED)
.equ    LEDPA8_ON,       (1 << 8)          // Set PA8 high (turn on LED)
.equ    LEDPA9_ON,       (1 << 9)          // Set PA9 high (turn on LED)
.equ    BUTTON_PC13,     (1 << 13)         // Bit mask for PC13 button

.section .text
.globl __main

__main:
    // Enable clock access to GPIOA and GPIOC

    // Load address of RCC_AHB1ENR to r0
    ldr r0, =RCC_AHB1ENR
    // Load value at address found in r0 into r1
    ldr r1, [r0]
    // Enable clock for GPIOA and GPIOC
    orr r1, #GPIOA_EN
    orr r1, #GPIOC_EN
    // Store content in r1 at address found in r0
    str r1, [r0]

    // Set PA0, PA1, PA4, PA6, PA7, PA8, PA9 as output
    // Load address of GPIOA_MODER to r0
    ldr r0, =GPIOA_MODER
    // Load value at address found in r0 into r1
    ldr r1, [r0]
    // Set PA0 as output
    orr r1, #MODERPA0_OUT
    // Set PA1 as output
    orr r1, #MODERPA1_OUT
    // Set PA4 as output
    orr r1, #MODERPA4_OUT
    // Set PA6 as output
    orr r1, #MODERPA6_OUT
    // Set PA7 as output
    orr r1, #MODERPA7_OUT
    // Set PA8 as output
    orr r1, #MODERPA8_OUT
    // Set PA9 as output
    orr r1, #MODERPA9_OUT
    // Store content in r1 at address found in r0
    str r1, [r0]

    // Set PC13 as input
    // Load address of GPIOC_MODER to r0
    ldr r0, =GPIOC_MODER
    // Load value at address found in r0 into r1
    ldr r1, [r0]
    // Clear bits to set PC13 as input
    BIC R1, R1, #(3 << 26)
    // Store content in r1 at address found in r0
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
time_delay_1_5_seconds: .word 5000000  // Approximate delay count for 1.5 seconds
.align
.end
