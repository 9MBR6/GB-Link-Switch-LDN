@ Address check, run on the Switch as a Mystery Gift buffer script (client
@ command 21) before a card or save script built from predicted addresses
@ (predict-roms.mjs) goes out. Each entry after `count` is an address and the
@ 4 bytes expected there, as a little-endian word. They are looked for at the
@ address, then 1, 2, ... bytes after and before it, up to SEARCH; the answer
@ is one byte per entry: that distance, or NOT_FOUND.
@
@ The client copies the script to gDecompressionBuffer and calls it as
@ u32 (*)(u32 *param, SaveBlock2 *, SaveBlock1 *) once CLI_LOAD_TOSS_RESPONSE
@ has set up the link: link.sendSize is at param + 0x34, link.sendBuffer at
@ param + 0x3C. The script points them at its answer, built after it in the
@ buffer, for CLI_SEND_LOADED. ARM code, position independent.

    .arm
    .text
    .global _start
    .equ SEARCH, 16
    .equ NOT_FOUND, 0x80
    .equ ANSWER, 0x400
    .equ LINK_SEND_SIZE, 0x34
    .equ LINK_SEND_BUFFER, 0x3C

@ r4 table cursor, r5 entries left, r6 answer, r7 its cursor, r8 address,
@ r9 expected bytes, r3 distance, r10 param.
_start:
    push    {r4-r10, lr}
    mov     r10, r0
    adr     r4, count
    ldr     r5, [r4], #4
    adr     r6, _start
    add     r6, r6, #ANSWER
    mov     r7, r6
entry:
    subs    r5, r5, #1
    bmi     done
    ldr     r8, [r4], #4
    ldr     r9, [r4], #4
    mov     r3, #0
look:
    mov     r2, r3
    bl      compare
    beq     found
    rsbs    r2, r3, #0
    beq     next                        @ 0 is looked at once
    bl      compare
    beq     found
next:
    add     r3, r3, #1
    cmp     r3, #SEARCH
    ble     look
    mov     r2, #NOT_FOUND
found:
    strb    r2, [r7], #1
    b       entry

@ The answer, as whole words (one at least).
done:
    sub     r0, r7, r6
    add     r0, r0, #3
    bic     r0, r0, #3
    cmp     r0, #4
    movlt   r0, #4
    strh    r0, [r10, #LINK_SEND_SIZE]
    str     r6, [r10, #LINK_SEND_BUFFER]
    mov     r0, #1
    pop     {r4-r10, lr}
    bx      lr

@ Z set when the 4 bytes at r8 + r2 are r9. Uses r0, r1 and ip.
compare:
    add     ip, r8, r2
    ldrb    r0, [ip]
    ldrb    r1, [ip, #1]
    orr     r0, r0, r1, lsl #8
    ldrb    r1, [ip, #2]
    orr     r0, r0, r1, lsl #16
    ldrb    r1, [ip, #3]
    orr     r0, r0, r1, lsl #24
    cmp     r0, r9
    bx      lr

@ The page writes the entries' count here and the entries after it.
count:
    .word   0
