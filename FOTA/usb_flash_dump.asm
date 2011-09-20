include 'inc/settings.inc'		; user dependend settings

START
	bl	enable_fota_output


	adr	r0, DloadCmdUSBRead     ; register our handler
	bl	DloadPacketHandler


	mov	r1, #1
	ldr	r0, [pagetable]
	bl	MemMMUCacheEnable

	bl	__PfsNandInit
	bl	__PfsMassInit

	bl	dloadmode

	NORETURN                        ; endless loop


; r0 = g_Hdlc + 13
DloadCmdUSBRead:
	stmfd	sp!, {lr}
 	sub	sp, sp, #8

	ldrb    r1, [r0]
	cmp     r1, #1                  ; read command
	bne     @f

	; clear variables
	mov	r1, #0
	str	r1, [sp]
	str	r1, [sp, #4]

	; address
	ldrb	r1, [r0,#1]
	strb	r1, [sp, #0]
	ldrb	r1, [r0,#2]
	strb	r1, [sp, #1]
	ldrb	r1, [r0,#3]
	strb	r1, [sp, #2]
	ldrb	r1, [r0,#4]
	strb	r1, [sp, #3]

	; length
	ldrb	r1, [r0,#5]
	strb	r1, [sp, #4]
	ldrb	r1, [r0,#6]
	strb	r1, [sp, #5]

	ldr	r2, [sp, #4]            ; length
	ldr	r1, [sp]                ; address
	ldr	r0, [dump_buf]
	bl	Flash_Read_Data

	ldr	r1, [sp, #4]            ; length
	ldr	r0, [dump_buf]
	bl	DloadTransmite

	@@:
	add	sp, sp, #8
	ldmfd	sp!, {pc}

	align 4

	pagetable                       dw gMMUL1PageTable
	dump_buf                        dw 0x44000000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FUNCTIONS

DEFAULT_VARIABLES
DEFAULT_STRINGS_ADDR
DEFAULT_STRINGS

END