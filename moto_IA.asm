; ========================================================>
; moto_IA.asm - IA BossOS (Versão Corrigida)
; ========================================================>

abrir_IA:
    pusha

.reiniciar_interface:
    call ia_limpar_tela

    mov dh, 2               ; Linha 2
    mov dl, 2               ; Coluna 2
    call ia_set_cursor

    mov si, msg_ia_banner
    call print_string

    mov dh, 4
    mov dl, 2
    call ia_set_cursor

    mov si, msg_hello
    call print_string

eliza_loop:
    ; --- Limpar linha do Prompt antes de ler ---
    call limpar_linha_prompt

    mov dh, 10
    mov dl, 2
    call ia_set_cursor

    mov si, msg_prompt
    call print_string

    ; --- LER TECLADO ---
    mov di, input_buffer
    call ia_ler_string

    ; Se a string estiver vazia (só apertou enter), ignora
    cmp byte [input_buffer], 0
    je eliza_loop

    ; --- MOTOR DE BUSCA DE PALAVRAS-CHAVE ---
    
    ; 1. Procura por "MAE" ou "FAMILIA"
    mov si, input_buffer
    mov di, key_mae
    call buscar_sub_string
    jc .responder_familia

    mov si, input_buffer
    mov di, key_familia
    call buscar_sub_string
    jc .responder_familia

    ; 2. Procura por "OS" ou "SISTEMA" ou "BOSSOS"
    mov si, input_buffer
    mov di, key_os
    call buscar_sub_string
    jc .responder_os

    ; 3. Procura por "REINICIAR" ou "BOOT"
    mov si, input_buffer
    mov di, key_reset
    call buscar_sub_string
    jc ia_reiniciar_sistema

    ; 4. Procura por "AJUDA" ou "COMMAND"
    mov si, input_buffer
    mov di, key_ajuda
    call buscar_sub_string
    jc .responder_ajuda

    ; Resposta padrão caso não entenda nenhuma palavra-chave
    mov si, resp_default
    call ia_print_resp
    jmp eliza_loop

.responder_familia:
    mov si, resp_familia
    call ia_print_resp
    jmp eliza_loop

.responder_os:
    mov si, resp_os
    call ia_print_resp
    jmp eliza_loop

.responder_ajuda:
    mov si, resp_ajuda
    call ia_print_resp
    jmp eliza_loop


; ========================================================>
; FUNÇÕES DE SUPORTE E LÓGICA
; ========================================================>

ia_reiniciar_sistema:
    int 19h                 ; Interrupção de Bootstrap (Reinicia o PC)

ia_limpar_tela:
    mov ax, 03h             ; Reinicia o modo de vídeo (limpa tudo)
    int 10h
    ret

ia_set_cursor:
    mov ah, 02h             ; Mover cursor
    mov bh, 0
    int 10h
    ret

ia_print_resp:
    ; Primeiro limpa a área da resposta antiga
    mov dh, 12
    mov dl, 2
    call ia_set_cursor
    mov si, msg_limpar_linha
    call print_string

    ; Exibe a nova resposta
    mov dh, 12
    mov dl, 2
    call ia_set_cursor
    call print_string
    ret

limpar_linha_prompt:
    mov dh, 10
    mov dl, 2
    call ia_set_cursor
    mov si, msg_limpar_linha
    call print_string
    ret

ia_ler_string:
    xor cx, cx              ; Contador de caracteres
    .loop_leitura:
        mov ah, 00h
        int 16h             ; Lê tecla

        ; Verifica se apertou 'S' ou 's' para reiniciar instantaneamente
        cmp al, 'S'
        je ia_reiniciar_sistema
        cmp al, 's'
        je ia_reiniciar_sistema

        cmp al, 0Dh         ; É ENTER?
        je .fim_leitura

        cmp al, 08h         ; É Backspace?
        je .handle_backspace

        cmp cx, 60          ; Limite do buffer para não estourar
        jge .loop_leitura

        ; Converte para MAIÚSCULO para facilitar a comparação depois
        cmp al, 'a'
        jb .salvar
        cmp al, 'z'
        ja .salvar
        sub al, 32          ; Transforma minúscula em maiúscula

    .salvar:
        mov [di], al        ; Salva no buffer
        inc di
        inc cx
        mov ah, 0Eh         ; Eco na tela
        int 10h
        jmp .loop_leitura

    .handle_backspace:
        cmp cx, 0
        je .loop_leitura    ; Se não tem nada escrito, ignora
        dec di
        dec cx
        mov byte [di], 0
        ; Apaga o caractere visualmente na tela
        mov ah, 0Eh
        mov al, 08h
        int 10h
        mov al, ' '
        int 10h
        mov al, 08h
        int 10h
        jmp .loop_leitura

    .fim_leitura:
        mov byte [di], 0    ; Finaliza a string
        ret


; --- Função: buscar_sub_string ---
; Procura a palavra-chave (DI) dentro da frase digitada (SI)
; Retorno: Carry Flag (JC) setado se encontrar, limpo se não encontrar
buscar_sub_string:
    push si
    push di
.proxima_letra_frase:
    mov al, [si]
    cmp al, 0
    je .nao_encontrou      ; Fim da frase digitada
    
    push si                 ; Salva a posição atual da frase
.comparar_loop:
    mov al, [si]
    mov bl, [di]
    cmp bl, 0               ; Se a palavra-chave terminou, encontramos!
    je .encontrou
    cmp al, bl
    jne .falhou_match
    inc si
    inc di
    jmp .comparar_loop

.falhou_match:
    pop si                  ; Restaura a posição da frase
    pop di                  ; Restaura o início da palavra-chave
    push di
    inc si                  ; Avança uma letra na frase principal
    jmp .proxima_letra_frase

.encontrou:
    pop si                  ; Desempilha lixo
    pop di
    pop si
    stc                     ; Seta carry flag (Encontrou!)
    ret

.nao_encontrou:
    pop di
    pop si
    clc                     ; Limpa carry flag (Não encontrou)
    ret


; ========================================================>
; DADOS DA IA
; ========================================================>

section .data
    msg_ia_banner     db "--- BOSS INTELLIGENCE SYSTEM v1.5 ---", 0
    msg_hello         db "IA: Ola! O sistema cognitivo do BossOS esta ativo. Pergunte algo.", 0
    msg_prompt        db "DIGITE: ", 0
    msg_limpar_linha  db "                                                                           ", 0

    ; Palavras-chave (Sempre em letras maiúsculas por causa do filtro de leitura)
    key_mae           db "MAE", 0
    key_familia       db "FAMILIA", 0
    key_os            db "OS", 0
    key_reset         db "REINICIAR", 0
    key_ajuda         db "AJUDA", 0

    ; Respostas da IA
    resp_familia      db "IA: A familia e a base mais importante de tudo, ate no BossOS.", 0
    resp_os           db "IA: O BossOS e um sistema incrivel feito em Assembly puro!", 0
    resp_ajuda        db "IA: Posso conversar sobre o sistema, familia ou reiniciar se pedir.", 0
    resp_default      db "IA: Entendi a sua pergunta. O processamento logico faz sentido.", 0

    input_buffer      times 64 db 0

