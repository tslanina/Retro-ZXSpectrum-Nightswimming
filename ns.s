    ; Nightswimming
    ;
    ; 256 bytes intro for ZX Spectrum by Tomasz Slanina ( dox/joker )
    ; 2nd place in intro zx spectrum compo @ Xenium 2k22


    org $a000

    ; format: data, n 
    db $0,$c0
    db %01000101,12 
    db %00001111,2
    db %01001111,10

    ; format: ay reg no, data
    db 7,%11000111
    db 8,16
    db 12,63
    db 13,%1110

    ; format address
    dw $5800+32*6+22+32+32+32
    dw $5800+32*6+22+31
    dw $5800+32*6+22
    dw $5800+32*6+22+31+32
    
    ; stars addr
    dw $4000

start:
    di    
    ld sp,$a000
    ld de,$4000 

    ; starts from $4000 and fills  n*32 bytes with data  (first, clear screen, and later set attributes)

.next_data:    
    pop hl
    ld a,l
    ld b,h
    cp 7 ; first ay reg
    jr z,.noise

.fill_2:    
    ld c,32

.fill_1:
    ld [de],a
    inc de
    dec c
    jr nz, .fill_1
    djnz .fill_2
    jr .next_data

    ; make AY noise

.noise:
    ld d,4

.noi:  
    ld bc,255*256+253
    out (c),l
    ld b,191
    out (c),h
    pop hl
    dec d
    jr nz,.noi

    ;crescent
    ld a,l;%01110111
    ld b,4
.cr:
    
    ld [hl],a
    inc l
    ld [hl],a
    pop hl
    djnz .cr

    ; draw stars, hl = $4000 (last pop)
    ld d,l ; d=0
    ld e,$f
    ld b,e

.stars_0:
    ld [hl],b;%001100
    rrc e
    add hl,de
    djnz .stars_0

    ; calculate line addresses
    ld de, $805a ; 5a reused below
    ld hl,$4880 ; 4f60
    ld b,e; reused here

.lineloop:
    ld a,l
    ld [de],a
    inc de
    ld a,h
    ld [de],a
    inc de
    inc h
    ld a,h
    and $07
    jr nz,.skip_calc
    out [254],a ; border
    ld a,l
    sub $e0
    ld l,a
    sbc a,a
    and $F8
    add a,h
    ld h,a

.skip_calc:
    djnz .lineloop

.mainloop:
    ld sp,$a000
    ld hl,$c000+62*256 +64 ; last and last-1 lines of linear buffer
    ld de,$c000+63*256 +64 
    ld b,e

.scale:
    push bc
    push hl
    push de

    ld a,i
    add a, h
    and 31
    inc a
    ld i,a
    ld c,a
 
    ;scale right paret

.w0:    
    ld b,c

.w1:    
    ld a,[hl]
    inc l
    ld [de],a
    inc e
    djnz .w1

    ld [de],a
    inc e
   
    bit 7,e ; bounds check
    jr z,.w0
  
    pop de
    pop hl

    push hl
    push de

    ;scale left part

.w01:   
    ld b,c

.w11:    
    ld a,[hl]
    dec l
    ld [de],a
    dec e
    djnz .w11

    ld [de],a
    dec e

    bit 7,e ; bounds check
    jr z,.w01

    pop de
    pop hl
    pop bc
    dec h
    dec d
    djnz .scale

    ld de,$c000 ; linear buffer
    
    ld h,e;//$a0
    ld b,h;128

.fill_l:
    ld a,r
    ld l,a
    ld a, [hl]
    and %11 ;noisy-random ;)
    ld [de],a
    inc e
    djnz .fill_l
    
    push bc
    ld h, $c8
    inc iyh
    ld a,iyh
    bit 5,a
    jr z,.change_dir
    cpl

.change_dir:    
    and 31
    add a,48
    ld l,a

    ;draw trace

    ld b,7
    ld a,b

.trace_fill:    
    ld [hl],a
    inc l
    ld [hl],a
    inc h
    djnz .trace_fill

    ld sp,$805a+8
    ld c,48  ; num of water lines
    push de
    pop hl

    ; calculate c2p

.chunk:
    pop de
    pop de ; every 2nd line

    ;c2p
    ld b,32 ; width

.draw:
    ld a,[hl]
    add a,a
    add a,a
    inc l
    or [hl]
    add a,a
    add a,a
    inc l
    or [hl]
    add a,a
    add a,a
    inc l
    or [hl]
    inc l
    ld [de],a
    inc e
    djnz .draw
    inc h
    res 7,l
    dec c
    jr nz,.chunk
    jp .mainloop

end start