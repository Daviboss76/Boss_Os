; ==================================================================
; BOSS ERROR SYSTEM (B.E.S.) - TELA VERMELHA DA MORTE
; ==================================================================

; ------------------------------------------------------------------
; FUNÇÃO: verificar_Os
; Chamada constantemente no main_loop do kernel para segurança.
; ------------------------------------------------------------------
verificar_Os:
    ; Verifica se o primeiro byte do Kernel (em 0x1000) foi alterado.
    mov ax, 0
    mov gs, ax
    cmp byte [gs:0x1000], 0xB8
    jne .violacao_kernel
    ret

.violacao_kernel:
    mov al, 1
    jmp boss_error_system

; ------------------------------------------------------------------
; FUNÇÃO PRINCIPAL: boss_error_system
; Entrada: AL = Código do erro
; ------------------------------------------------------------------
boss_error_system:
    cli                     ; Desliga interrupções para travar com segurança
    mov byte [codigo_erro_atual], al

    ; 1. CONFIGURA TELA VERMELHA (Modo texto 80x25, fundo vermelho, texto branco)
    mov ah, 0x06
    mov al, 0
    mov bh, 0x4F            ; 4 = Fundo Vermelho, F = Texto Branco
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 0x10

    ; 2. POSICIONA O CURSOR (Linha 2, Coluna 5)
    mov ah, 0x02
    mov bh, 0
    mov dh, 2
    mov dl, 5
    int 0x10

    ; 3. MOSTRA O CABEÇALHO DA B.E.S.
    mov si, msg_bes_titulo
    call print_string_vermelha

    ; 4. EXIBE A MENSAGEM DE ERRO MUITO GRAVE (Linha 5, Coluna 5)
    mov ah, 0x02
    mov dh, 5
    mov dl, 5
    int 0x10
    mov si, msg_bes_erro_grave  ; <--- NOME ALTERADO AQUI PARA EVITAR CONFLITO
    call print_string_vermelha

    ; 5. VERIFICA QUAL ERRO ACONTECEU (Linha 8, Coluna 5)
    mov ah, 0x02
    mov dh, 8
    mov dl, 5
    int 0x10

    mov al, [codigo_erro_atual]
    cmp al, 1
    je .erro_kernel
    cmp al, 2
    je .erro_pilha
    cmp al, 3
    je .erro_divisao
    
    mov si, msg_erro_desconhecido
    jmp .print_detalhe

.erro_kernel:
    mov si, msg_detalhe_kernel
    jmp .print_detalhe

.erro_pilha:
    mov si, msg_detalhe_pilha
    jmp .print_detalhe

.erro_divisao:
    mov si, msg_detalhe_divisao

.print_detalhe:
    call print_string_vermelha

    ; 6. INSTRUÇÃO DE REINICIALIZAÇÃO (Linha 12, Coluna 5)
    mov ah, 0x02
    mov dh, 12
    mov dl, 5
    int 0x10
    mov si, msg_reiniciar
    call print_string_vermelha

.travar_sistema:
    hlt
    jmp .travar_sistema

; ------------------------------------------------------------------
; FUNÇÃO AUXILIAR: print_string_vermelha
; Entrada: SI apontando para a string
; ------------------------------------------------------------------
print_string_vermelha:
    lodsb
    cmp al, 0
    je .fim_print
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x4F
    int 0x10
    jmp print_string_vermelha
.fim_print:
    ret

; ==================================================================
; SEÇÃO DE DADOS (STRINGS DA B.E.S.)
; ==================================================================
codigo_erro_atual     db 0

msg_bes_titulo        db "===================================================", 13, 10, "         B.E.S. - BOSS ERROR SYSTEM v1.0           ", 13, 10, "===================================================", 0

msg_bes_erro_grave    db "Erro erro muito grave mais grave vamos morre corra corra!", 0 ; <--- NOME ALTERADO AQUI TAMBÉM

msg_reiniciar         db "O sistema foi interrompido para proteger o hardware.", 13, 10, "     Pressione o botao de RESET para reiniciar.     ", 0

msg_detalhe_kernel    db "CAUSA: Tentativa de escrita no endereco de memoria do Kernel [0x1000]!", 0
msg_detalhe_pilha     db "CAUSA: Stack Overflow! A pilha do sistema estourou os limites seguros.", 0
msg_detalhe_divisao   db "CAUSA: Erro fatal de divisao matematica ou operacao invalida no app!", 0
msg_erro_desconhecido db "CAUSA: Falha critica desconhecida ou interrupcao nao tratada.", 0

