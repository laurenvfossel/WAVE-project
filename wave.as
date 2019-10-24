Wave Source:
;;; (c) 2019 Erica Barrett and Lauren Fossel
;;; -*- mode: asm; compile-command: "wia wave2.s" -*-
        .requ   ir,r2
        .requ   dest,r3
        .requ   lsrc,r4
        .requ   rsrc,r5
        .requ   ccode,r10
        lea     warm,r0
        trap    $SysOverlay
        jmp     loop
never:  add     $1, wpc
        jmp     loop
setbits:
        mov     ccr, ccode
;r2 is instruction register
;r3 is destination register
;r4 is left source register
;r5 is right source register
;condition code bits register
set2:
test    $0x10000000, ir
je      loop
shl     $28, ccode
and     $0xFFFFFF,wpc
or      ccode,wpc
                wpc,r1
        mov     warm(r1),ir
cond:   mov
        shr     $29, r8
; --------------------TOP OF INSTRUCTION LOOP---------
;move first instr into ir
loop:   mov
        and     $0xFFFFFF, r1
condtable:
        .data
        .data
equal:  mov
        shr
        mov
always, never, equal, nequal
lessthan, lesseq, greateq, greater
wpc, ccode
$28, ccode
ccode, ccr
always
$1, wpc
nequal: mov
        shr
        mov
wpc, ccode
$28, ccode
ccode, ccr
lesseq: mov
        shr
        mov
wpc, ccode
$28, ccode
ccode, ccr
        ir, r8
mov     condtable(r8),rip
je
add
jmp     loop
jne     always
add     $1, wpc
jmp     loop
        jle     always
        add     $1, wpc
        jmp     loop
lessthan:
        mov     wpc, ccode
        shr     $28, ccode
        mov     ccode, ccr
        jl      always
        add     $1, wpc
        jmp     loop
greater:
        mov     wpc, ccode
        shr     $28, ccode
        mov     ccode, ccr
        jg      always
        add     $1, wpc
        jmp     loop
greateq:
        mov     wpc, ccode
shr     $28, ccode
;getting conditional stuff
;r8 has cond stuff
        mov     ccode, ccr
        jge     always
        add     $1, wpc
        jmp     loop
always:
opcode: ;; getting opcode
        mov     ir, r8
        shr     $23,r8
        and     $0x1F,r8
        test    $0x8000000,ir
        jne     op1
op0:    ;; getting mode bits
        mov     ir, r7
        and     $0x7000, r7
        shr     $12, r7
        mov     modejmp(r7),rip ;jump to mode jump table
        ;; after this, r5 has right source
op1:    test    $0x4000000,ir
        jne     branch
        mov     ir, r7
        and     $0x7000, r7
        shr     $12, r7
        mov     mode2(r7),rip
;getting second bit of opcode
;mask for mode bits
mode2:  .data   sobr, sobr, sobr, sobr
        .data   imsh, halt, halt, halt
sobr:   mov
        and     $0x3FFF,rsrc
        shl     $18,rsrc
        sar     $18,rsrc
        jmp     after
branch: test    $0x1000000, ir
        jne     blfw
after:
ir, rsrc
;r8 has opcode
;if first bit of opcode is 1, then other mode stuff
;mask for mode bits
;signed offset from base register
and     $0xF0FFFFFF, wpc
and     $0xFFFFFFF, ir
add     ir,wpc  ;add displacement to warm program counter
jmp     loop
imme:   mov
        and     $0x1FF,rsrc
ir, rsrc
mov     ir, r6
shr     $9, r6
and     $0x1F, r6
shl     r6, rsrc
;get value to be shifted
;get exp
;; getting dest register
mov     ir, dest
shr     $19, dest
and     $0xF,dest
add     $1, wpc
mov     fasttable(r8),rip
fasttable:
        .data left, left, left, left, left, left, left, left
        .data left, left, left, move, mvinv, sfti, left, left
        .data left, left, left, left, left, left, left, left
        .data left, left, left, left, left, left, left, left
left:
;; getting left source register
sub     $1, wpc
mov     ir,r12
shr     $15,r12
and $0xF,r12

mov
regsh:  mov
        and
        mov
        mov
        shr
        and
        mov
        mov
shopjmp(r7),rip ;jump to shop table
mov     wregs(r12),lsrc ;r4 has left source
add     $1, wpc
mov     opjmp(r8),rip
imsh:   mov
        and     $0x3F, r6
        mov     ir, r14
        shr     $6,r14
;move ir into r7
;get low 6 bits = shift count, in r6
regprod:
        mov     ir, r6
        and     $0xF, r6
        mov     wregs(r6),r6
        mov     ir, rsrc
        shr     $6, r5
        and     $0xF, r5
        mov     wregs(r5),r5
        mul     r6,rsrc
        jmp     after
;low 4 bits = src 3
;r6 has value from src reg 3
;next 4 = src 2
;r5 has value from src reg 2
;multiply r5*r6, result in r5
ir, r6
and
mov
mov     ir, r7
shr     $10,r7          ;r7 has shop
and     $0x3,r7         ;2 low bits = shop
$0xF,r14
wregs(r14),rsrc ;r5 has src 2
;next 4 bits, src reg 2
ir,r6
$0xF, r6
wregs(r6),r6
ir, rsrc
$6, rsrc
$0xF, rsrc
wregs(rsrc),rsrc        ;r5 has value from src 2
ir, r7
;get low 4 bits = shift reg
;r6 has value in wregister
;next 4 bits are src reg 2
shr     $10,r7
and     $0x3,r7         ;next 2 bits are shop
mov     shopjmp(r7),rip ;jump to shop table to shift
modejmp:
        .data   imme, imme, imme, imme
        .data   imsh, regsh, regprod, halt
        ;; assuming shift amount is in r6, value to be shifted in r5
lsl:    shl     r6,rsrc
        mov     ir, dest
        shr     $19, dest
        and     $0xF,dest
        mov     ir,r12
        shr     $15,r12
        and     $0xF,r12
        mov     wregs(r12),lsrc
        add     $1, wpc
        mov     opjmp(r8),rip
lsr:    shr     r6,rsrc
        jmp     after
asr:    sar     r6,rsrc
        jmp     after
ror:    mov     rsrc,r7         ;right source already in r5
        shr     r6,r7
        sub     $32,r6
        mul     $-1,r6
        shl     r6,rsrc
        or      r7, rsrc
        jmp     after
shopjmp:
        .data   lsl,lsr,asr,ror

plusc:  test    $0x20000000,wpc
        je      plus
fuma: plus:
add $1,lsrc
add     rsrc, lsrc
mov     lsrc,wregs(dest)
jmp     setbits
;if carry bit is 1
;fused mul/add, mul already done, just need to add
comp:   sub     rsrc,lsrc
        mov     ccr, ccode
        shl     $28, ccode
        and     $0xFFFFFF,wpc
        or      ccode,wpc
        jmp     loop
minus:  sub     rsrc,lsrc
        mov     lsrc,wregs(dest)
        jmp     setbits
exor:   xor     rsrc,lsrc
        mov     lsrc,wregs(dest)
        jmp     setbits
bitor:  or      rsrc,lsrc
        mov     lsrc,wregs(dest)
        jmp     setbits
tstbit: and
        mov
        shl
rsrc,lsrc
ccr, ccode
$28, ccode
        and     $0xFFFFFF,wpc
        or      ccode,wpc
        jmp     loop
bitand: and     rsrc,lsrc
        mov     lsrc,wregs(dest)
        jmp     setbits
times:  mul     rsrc,lsrc
        mov     lsrc,wregs(dest)
        jmp     setbits
divi:   div     rsrc,lsrc
        mov     lsrc,wregs(dest)
        jmp     setbits
mvinv:  xor     $-1,rsrc        ;negate rsrc, then regular move
move:   cmp     $14,r14
        je      linkreg
mv:     mov     rsrc,wregs(dest)
mv2:    add     $0, wregs(dest)
        mov     ccr, ccode
        test    $0x10000000, ir
        je      loop
        shl     $28, ccode
        and     $0xFFFFFF,wpc
        or      ccode,wpc
        mov     wpc,r1
        and     $0xFFFFFF, r1
        mov     warm(r1),ir
        mov     ir, r8
        shr     $29, r8
        mov     condtable(r8),rip
linkreg:
        cmp     $15, dest
        jne     mv
        and     $0xF0000000, wregs(dest)
        and     $0xFFFFFF, rsrc
        or      rsrc, wregs(dest)
        jmp     mv2
sfti:   mov     wr0,r0
        trap    rsrc
        mov     r0,wr0
        add     $0, r0
        mov     ccr, ccode
;move first instr into ir
;getting conditional stuff
;r8 has cond stuff

        test    $0x10000000, ir
        je      loop
        shl     $28, ccode
        and     $0xFFFFFF,wpc
        or      ccode,wpc
        mov     wpc,r1
        and     $0xFFFFFF, r1
        mov     warm(r1),ir
        mov     ir, r8
        shr     $29, r8
        mov     condtable(r8),rip
loadm:  and     $0xFFFF, rsrc
        mov     wregs(dest),r13
ldm0:   test    $1, rsrc
        je      ldm1
        mov     warm(r13),wr0
        add     $1, r13
ldm1:   and     $0xFFFFFF,r13
        test    $2,rsrc
        je      ldm2
        mov     warm(r13),wr1
        add     $1, r13
ldm2:   and     $0xFFFFFF,r13
        test    $4,rsrc
        je      ldm3
        mov     warm(r13),wr2
        add     $1, r13
ldm3:   and     $0xFFFFFF,r13
        test    $8,rsrc
        je      ldm4
        mov     warm(r13),wr3
        add     $1,r13
ldm4:   and     $0xFFFFFF,r13
        test    $16,rsrc
        je      ldm5
        mov     warm(r13),wr4
        add     $1, r13
ldm5:   and     $0xFFFFFF,r13
        test    $32,rsrc
        je      ldm6
        mov     warm(r13),wr5
        add     $1, r13
ldm6:   and     $0xFFFFFF,r13
        test    $64,rsrc
        je      ldm7
        mov     warm(r13),wr6
        add     $1, r13
ldm7:   and     $0xFFFFFF,r13
        test    $128,rsrc
        je      ldm8
        mov     warm(r13),wr7
        add     $1, r13
ldm8:   and     $0xFFFFFF,r13
        test    $256,rsrc
        je      ldm9
        mov     warm(r13),wr8
        add     $1, r13
ldm9:   and     $0xFFFFFF,r13
        test    $512,rsrc
        je      ldm10
        mov     warm(r13),wr9
        add     $1, r13
ldm10:  and     $0xFFFFFF,r13
        test    $1024,rsrc
je ldm11

        mov     warm(r13),wr10
        add     $1, r13
ldm11:  and     $0xFFFFFF,r13
        test    $2048,rsrc
        je      ldm12
        mov     warm(r13),wr11
        add     $1, r13
ldm12:  and     $0xFFFFFF,r13
        test    $4096,rsrc
        je      ldm13
        mov     warm(r13),wr12
        add     $1, r13
ldm13:  and     $0xFFFFFF,r13
        test    $8192,rsrc
        je      ldm14
        mov     warm(r13),wr13
        add     $1, r13
ldm14:  and     $0xFFFFFF,r13
        test    $16384,rsrc
        je      ldm15
        mov     warm(r13),wr14
        add
ldm15:  and
        mov
$1, r13
$0xFFFFFF,r13
r13, wregs(dest)
        test    $32768,rsrc
        je      loop
        mov     warm(r13),wr15
        add     $0,wr15
        mov     ccr, ccode
        add     $1, wregs(dest)
        jmp     set2
strm:   mov     wregs(dest),r13
stm15:  shl     $16, rsrc
        jge     stm14
        sub     $1, r13
        and     $0xFFFFFF, r13
        mov     wr15,warm(r13)
stm14:  shl     $1, rsrc
        jge     stm13
        sub     $1, r13
        and     $0xFFFFFF,r13
        mov     wr14,warm(r13)
stm13:  shl     $1, rsrc
        jge     stm12
        sub     $1, r13
        and     $0xFFFFFF,r13
        mov     wr13,warm(r13)
stm12:  shl     $1, rsrc
        jge     stm11
        sub     $1, r13
        and     $0xFFFFFF,r13
        mov     wr12,warm(r13)
stm11:  shl     $1, rsrc
        jge     stm10
        sub     $1, r13
        and     $0xFFFFFF,r13
        mov     wr11,warm(r13)
stm10:  shl     $1, rsrc
        jge     stm9
stm9:
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr10,warm(r13)
shl     $1, rsrc
jge     stm8
sub     $1, r13
and     $0xFFFFFF,r13

stm8:
stm7:
stm6:
stm5:
stm4:
stm3:
stm2:
stm1:
mov     wr9,warm(r13)
shl     $1, rsrc
jge     stm7
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr8,warm(r13)
shl     $1, rsrc
jge     stm6
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr7,warm(r13)
shl     $1, rsrc
jge     stm5
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr6,warm(r13)
shl     $1, rsrc
jge     stm4
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr5,warm(r13)
shl     $1, rsrc
jge     stm3
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr4,warm(r13)
shl     $1, rsrc
jge     stm2
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr3,warm(r13)
shl     $1, rsrc
jge     stm1
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr2,warm(r13)
shl     $1, rsrc
jge     stm0
sub     $1, r13
and     $0xFFFFFF,r13
mov     wr1,warm(r13)
stm0:   mov     r13, wregs(dest)
        shl     $1, rsrc
        jge     loop
        sub     $1, r13
        and     $0xFFFFFF,r13
        mov     wr0,warm(r13)
        mov     r13, wregs(dest)
        jmp     loop
loadr:  add     lsrc,rsrc
        and     $0xFFFFFF,rsrc
        mov     warm(rsrc),wregs(dest)
        add     $0, wregs(dest)
        jmp     setbits
strr:   add     lsrc,rsrc
        and     $0xFFFFFF,rsrc
popr:
mov     wregs(dest),warm(rsrc)
add     $0, wregs(dest)
jmp     setbits
test    $0x2000, rsrc
je      poprpos
add     lsrc,rsrc
and     $0xFFFFFF,rsrc
mov     warm(rsrc),wregs(dest)
mov     rsrc,wregs(r12)
add     $0, wregs(dest)

        jmp     setbits
poprpos:
        and     $0xFFFFFF,lsrc
        mov     warm(lsrc),wregs(dest)
        lea     0(rsrc,lsrc),wregs(r12)
        add     $0, wregs(dest)
        jmp     setbits
pushr:  test    $0x2000, rsrc
        je      pushrpos
        add     lsrc,rsrc
        and     $0xFFFFFF,rsrc
        mov     wregs(dest),warm(rsrc)
        mov     rsrc,wregs(r12)
        add     $0, wregs(dest)
        jmp     setbits
pushrpos:
        and     $0xFFFFFF,lsrc
        mov     wregs(dest),warm(lsrc)
        lea     0(lsrc,rsrc),wregs(r12)
        add     $0, wregs(dest)
        jmp     setbits
fadr:   lea     0(lsrc,rsrc),wregs(dest)
        and     $0xFFFFFF,wregs(dest)
jmp setbits
        ;; displacement in r5/rsrc
blfw:
blbw:   add     $1, r1
mov r1,wlr
bfw:
bbw: and
halt:
        $0xF0FFFFFF, wpc
and     $0xFFFFFFF, ir
add     ir,wpc  ;add displacement to warm program counter
jmp     loop
trap    $SysHalt
opjmp:  .data   plus,plusc,minus,comp,exor,bitor,bitand
        .data   tstbit,times,fuma,divi,move,mvinv,sfti
        .data   loadm,strm,loadr,strr,popr,pushr,fadr
        .data   halt,halt,halt,bfw,bbw,blfw,blbw
;;; DON’T WRITE ANY CODE BELOW THIS LINE
wregs:
wr0: .data 0
wr1: .data 0
wr2: .data 0
wr3: .data 0
wr4: .data 0
wr5: .data 0
wr6: .data 0
wr7: .data 0
wr8: .data 0
wr9: .data 0
wr10: .data 0
wr11: .data 0
wr12: .data 0
wsp:
wr13:   .data 0x00ffffff
wlr:
wr14:   .data 0
wpc:
wr15: .data 0

warm:
