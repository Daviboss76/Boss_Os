; =====================================================================
; BOSS OS v2.3 - UTILITÁRIO DE ENTRETENIMENTO: JOGO DA COBRINHA (SNAKE)
; =====================================================================

macro_bloco_cobra equ 0xDB   ; Caractere '█' para deixar a cobra bem grossa!
macro_comida      equ 0x2A   ; Caractere '*' para a comida

section .text
main_cobra:
    call inicializar_video
    call gerar_comida

.game_loop:
    call ler_teclado
    call atualizar_posicao
    call verificar_colisao
    call desenhar_jogo
    call delay_frames
    jmp .game_loop

; --- SUBROTINAS ---

inicializar_video:
    ; Limpa a tela e define modo texto 80x25
    mov ax, 0x0003
    int 0x10
    
    ; Posição inicial da cabeça da cobra (X=40, Y=12 - Centro da tela)
    mov byte [cobra_x], 40
    mov byte [cobra_y], 12
    mov byte [direcao], 'D'  ; Começa indo para a direita
    mov word [tamanho], 3    ; Tamanho inicial da cobra
    ret

ler_teclado:
    ; Verifica se tem tecla no buffer sem travar o jogo (Não-bloqueante)
    mov ah, 0x01
    int 0x16
    jz .sem_tecla            ; Se nenhuma tecla foi pressionada, continua andando

    ; Lê a tecla real
    mov ah, 0x00
    int 0x16

    ; Filtra os controles W, S, A, D (Maiúsculas e Minúsculas)
    cmp al, 'w'
    je .ir_cima
    cmp al, 'W'
    je .ir_cima
    cmp al, 's'
    je .ir_baixo
    cmp al, 'S'
    je .ir_baixo
    cmp al, 'a'
    je .ir_esquerda
    cmp al, 'A'
    je .ir_esquerda
    cmp al, 'd'
    je .ir_direita
    cmp al, 'D'
    je .ir_direita
    cmp al, 27              ; Tecla ESC para sair do jogo
    je .sair_jogo
    ret

.ir_cima:
    cmp byte [direcao], 'S' ; Impede a cobra de voltar para trás e se engolir
    je .sem_tecla
    mov byte [direcao], 'W'
    ret
.ir_baixo:
    cmp byte [direcao], 'W'
    je .sem_tecla
    mov byte [direcao], 'S'
    ret
.ir_esquerda:
    cmp byte [direcao], 'D'
    je .sem_tecla
    mov byte [direcao], 'A'
    ret
.ir_direita:
    cmp byte [direcao], 'A'
    je .sem_tecla
    mov byte [direcao], 'D'
    ret
.sem_tecla:
    ret

.sair_jogo:
    ; Retorna ao terminal do BossOS (Ajuste conforme seu Kernel)
    int 0x20                

atualizar_posicao:
    ; Atualiza o corpo da cobra (Move cada segmento para a posição do anterior)
    mov cx, [tamanho]
    dec cx
    mov si, cx
    shl si, 1               ; Multiplica por 2 (cada coordenada é X e Y)

.mover_corpo:
    cmp si, 0
    je .mover_cabeca
    mov ax, [corpo_cobra + si - 2]
    mov [corpo_cobra + si], ax
    sub si, 2
    loop .mover_corpo

.mover_cabeca:
    ; Salva a posição antiga da cabeça no início do array do corpo
    mov al, [cobra_x]
    mov ah, [cobra_y]
    mov [corpo_cobra], ax

    ; Move a cabeça com base na direção atual
    cmp byte [direcao], 'W'
    je .move_cima
    cmp byte [direcao], 'S'
    je .move_baixo
    cmp byte [direcao], 'A'
    je .move_esquerda
    cmp byte [direcao], 'D'
    je .move_direita
    ret

.move_cima:
    dec byte [cobra_y]
    ret
.move_baixo:
    inc byte [cobra_y]
    ret
.move_esquerda:
    dec byte [cobra_x]
    ret
.move_direita:
    inc byte [cobra_x]
    ret

verificar_colisao:
    ; 1. Colisão com as paredes da tela (80x25)
    cmp byte [cobra_x], 0
    jl .morreu
    cmp byte [cobra_x], 80
    jge .morreu
    cmp byte [cobra_y], 0
    jl .morreu
    cmp byte [cobra_y], 25
    jge .morreu

    ; 2. Colisão com a Comida
    mov al, [cobra_x]
    cmp al, [comida_x]
    jne .fim_colisao
    mov al, [cobra_y]
    cmp al, [comida_y]
    jne .fim_colisao

    ; Se colidiu com a comida: cresce e gera nova comida
    inc word [tamanho]
    call gerar_comida
    ret

.morreu:
    ; Se bater na parede, o jogo chama o seu Boss Error System!
    jmp 0x1000              ; Endereço da sua BES (ou chame sua rotina de erro)

.fim_colisao:
    ret

gerar_comida:
    ; Gera posições "aleatórias" usando o contador do clock do sistema (INT 1Ah)
    mov ah, 0x00
    int 0x1A                ; Retorna os ticks em DX
    
    ; Limita o X entre 1 e 78
    mov ax, dx
    xor dx, dx
    mov cx, 77
    div cx
    inc dl
    mov [comida_x], dl

    ; Limita o Y entre 1 e 23
    mov ax, ax ; pega o resto anterior para variar mais
    xor dx, dx
    mov cx, 22
    div cx
    inc dl
    mov [comida_y], dl
    ret

desenhar_jogo:
    ; Limpa a tela redesenhando o fundo de forma rápida
    mov ax, 0x0600
    mov bh, 0x07            ; Fundo preto, letra branca
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10

    ; 1. Desenha a Comida
    mov ah, 0x02
    mov bh, 0
    mov dl, [comida_x]
    mov dh, [comida_y]
    int 0x10

    mov ah, 0x0A
    mov al, macro_comida
    mov cx, 1
    int 0x10

    ; 2. Desenha a Cabeça da Cobra (█ Verde brilhante para destacar)
    mov ah, 0x02
    mov bh, 0
    mov dl, [cobra_x]
    mov dh, [cobra_y]
    int 0x10

    mov ah, 0x09
    mov al, macro_bloco_cobra
    mov bl, 0x0A            ; Cor: Verde Claro
    mov cx, 1
    int 0x10

    ; 3. Desenha o resto do Corpo
    mov cx, [tamanho]
    dec cx
    mov si, 0
.desenha_corpo_loop:
    push cx
    mov dx, [corpo_cobra + si] ; Carrega X e Y do segmento
    
    ; Move cursor para a posição do segmento do corpo
    mov ah, 0x02
    mov bh, 0
    int 0x10

    ; Printa o bloco grosso da cobra
    mov ah, 0x09
    mov al, macro_bloco_cobra
    mov bl, 0x02            ; Cor: Verde Escuro para o corpo
    mov cx, 1
    int 0x10

    add si, 2
    pop cx
    loop .desenha_corpo_loop
    ret

delay_frames:
    ; Cria um atraso controlado para o jogo não rodar na velocidade da luz
    mov cx, 0x0001
    mov dx, 0x86A0          ; ~100.000 microssegundos de delay
    mov ah, 0x86
    int 0x15
    ret

section .data
cobra_x     db 0
cobra_y     db 0
comida_x    db 0
comida_y    db 0
direcao     db 'D'
tamanho     dw 3

section .bss
; Array para guardar até 200 coordenadas do corpo da cobra (X e Y somam 2 bytes por pedaço)
corpo_cobra resw 200

