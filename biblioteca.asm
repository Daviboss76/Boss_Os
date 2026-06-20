; ==========================================================
; biblioteca.asm - As Cordas Vocais do BossOS v2.3
; ==========================================================

section .text        ; Garante que tudo abaixo seja tratado como código puro

; --- Função para Imprimir Strings ---
print_string:
    pusha                ; Guarda todos os registradores para não dar erro
.loop:
    lodsb                ; Carrega a próxima letra de SI para AL
    cmp al, 0            ; É o fim da string (o número 0)?
    je .fim              ; Se sim, para de escrever
    mov ah, 0Eh          ; Função de teletype da BIOS
    mov bh, 0            ; Página de vídeo 0
    int 10h              ; Chama a interrupção de vídeo
    jmp .loop            ; Volta para pegar a próxima letra
.fim:
    popa                 ; Devolve os registradores como estavam
    ret

; --- Função para Comparar Strings ---
comparar_strings:
    push si
    push di
.comp_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .diferente
    cmp al, 0
    je .igual
    inc si
    inc di
    jmp .comp_loop
.diferente:
    pop di
    pop si
    clc
    ret
.igual:
    pop di
    pop si
    stc
    ret

; --- Função para Limpar a Tela (Padrão BossOS) ---
limpar_tela:
    pusha
    mov ax, 03h          ; Reinicia o modo de vídeo texto 80x25
    int 10h              ; BIOS faz a limpeza
    popa
    ret

; --- Função para Imprimir Números (AX) ---
imprimir_numero_ax:
    pusha
    mov cx, 0            ; Contador de dígitos
    mov bx, 10           ; Vamos dividir por 10
.dividir:
    mov dx, 0
    div bx               ; AX / 10 (Resto em DX)
    push dx              ; Guarda o resto na pilha
    inc cx
    cmp ax, 0
    jne .dividir         ; Continua até AX ser zero
.mostrar:
    pop dx
    add dl, '0'          ; Converte número para caractere ASCII
    mov al, dl
    mov ah, 0Eh          ; Teletype da BIOS
    int 10h
    loop .mostrar
    popa
    ret

; =============================================================================
; EXPANSÃO GRÁFICA PARA O BossBrowser 
; =============================================================================

; --- Função: limpar_tela_branco ---
; Deixa a tela com fundo branco/cinza claro para o Navegador
limpar_tela_branco:
    pusha
    mov ax, 0600h       ; Scroll up (limpar)
    mov bh, 0x70        ; Atributo: Fundo Cinza Claro, Letra Preta
    mov cx, 0x0000      ; Canto superior (0,0)
    mov dx, 0x184F      ; Canto inferior (24,79)
    int 10h
    popa
    ret

; --- Função: desenhar_retangulo_colorido ---
; BX = Cor/Atributo, CX = Início (Linha/Col), DX = Fim (Linha/Col)
desenhar_retangulo_colorido:
    pusha
    mov ax, 0600h       ; Função de scroll/pintar da BIOS
    ; BX já vem com a cor do código do navegador
    int 10h
    popa
    ret

; --- Função: print_string_color ---
; SI = String, BL = Cor (Atributo)
print_string_color:
    pusha
.proximo_char:
    lodsb               ; Carrega o caractere de SI em AL
    cmp al, 0           ; É o fim da string?
    je .fim
    mov ah, 09h         ; Escrita de caractere + Atributo
    mov bh, 0           ; Página de vídeo 0
    mov cx, 1           ; Escrever 1 vez
    int 10h

    ; Avançar o cursor manualmente
    call mover_cursor_frente
    jmp .proximo_char
.fim:
    popa
    ret

; --- Auxiliar: Mover Cursor para Frente ---
mover_cursor_frente:
    pusha
    mov ah, 03h         ; Pega posição atual
    mov bh, 0
    int 10h             ; Retorna em DH (linha) e DL (coluna)
    inc dl              ; Próxima coluna
    mov ah, 02h         ; Seta nova posição
    int 10h
    popa
    ret

; =============================================================================
; MÓDULO DE EXPANSÃO: TEXTO E BUFFERS (Adicionado para o BossBrowser)
; =============================================================================

; --- Função: proxima_linha ---
; Pula para a linha de baixo (CR + LF) - Essencial para ler os textos de estudo
proxima_linha:
    push ax
    mov ah, 0Eh
    mov al, 13          ; Retorno de carro
    int 10h
    mov al, 10          ; Nova linha
    int 10h
    pop ax
    ret

; --- Função: limpar_buffer ---
; DI = Endereço, CX = Tamanho
; Zera a memória para não misturar um site com o outro
limpar_buffer:
    pusha
    mov al, 0
    rep stosb           ; Preenche com zero
    popa
    ret

; --- Função: imprimir_hex_byte ---
; AL = Byte. Útil para ver o endereço MAC ou IPs da rede
imprimir_hex_byte:
    push ax
    push ax
    shr al, 4
    call .conv
    pop ax
    and al, 0x0F
    call .conv
    pop ax
    ret
.conv:
    cmp al, 10
    jl .num
    add al, 7
.num:
    add al, '0'
    mov ah, 0Eh
    int 10h
    ret

; =============================================================================
; SEÇÃO DE DADOS ISOLADA (Fica sempre no final para não misturar com o código)
; =============================================================================
section .data
    txt_navegador    db "NAVEGADOR", 0

