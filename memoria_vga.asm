; ========================================================>
; mem_view.asm - O Visualizador de RAM do BossOS
; ========================================================>

abrir_memoria:
    pusha                   ; Salva o estado do Kernel

    call limpar_tela        ; Limpa o azul do Menu

    ; --- Cabeçalho do App ---
    mov dh, 1               ; Linha 1
    mov dl, 5               ; Coluna 5
    call ia_set_cursor      ; Define a posição do cursor

    mov si, msg_titulo_mem
    call print_string

    ; --- Mostrar RAM Total ---
    mov dh, 3
    mov dl, 2
    call ia_set_cursor

    mov si, msg_total
    call print_string

    ; Aqui chamamos a função que lê da BIOS
    int 12h                 ; AX = KB de RAM
    call imprimir_numero_ax ; Exibe o valor do registrador AX

    mov si, msg_kb_unidade
    call print_string

    ; --- MOSTRAR A DIVISÃO (O MAPA) ---
    mov dh, 6
    mov dl, 2
    call ia_set_cursor

    mov si, msg_mapa_desc
    call print_string

    ; 1. Mostrar onde está o KERNEL
    mov dh, 8
    call ia_set_cursor
    mov si, msg_setor_kernel
    call print_string

    ; 2. Mostrar onde está a IA
    mov dh, 9
    call ia_set_cursor
    mov si, msg_setor_ia
    call print_string

    ; 3. Mostrar onde está o VÍDEO
    mov dh, 10
    call ia_set_cursor
    mov si, msg_setor_video
    call print_string

    ; --- Instrução para Sair ---
    mov dh, 20
    mov dl, 5
    call ia_set_cursor
    mov si, msg_voltar
    call print_string

.esperar_tecla:
    mov ah, 00h
    int 16h                 ; Espera uma tecla da BIOS

    ; --- VERIFICA SE COMPATÍVEL COM REINICIALIZAÇÃO ---
    cmp al, 'S'
    je .reiniciar_sistema
    cmp al, 's'
    je .reiniciar_sistema

    popa                    ; Restaura o Kernel caso seja outra tecla
    ret                     ; Volta para o Menu Principal

.reiniciar_sistema:
    int 19h                 ; Interrupção de Bootstrap (Reinicia o PC)

; ========================================================>
; DADOS DO VISUALIZADOR
; ========================================================>

section .data
    msg_titulo_mem   db "--- MONITOR DE MEMORIA BossOS ---", 0
    msg_total        db "MEMORIA DETECTADA: ", 0
    msg_kb_unidade   db " KB", 0
    msg_mapa_desc    db "DIVISAO DO MAPA DE RAM:", 0

    msg_setor_kernel db "[0x1000] - NUCLEO DO SISTEMA (OCUPADO)", 0
    msg_setor_ia     db "[0x5000] - INTELIGENCIA ARTIFICIAL", 0
    msg_setor_video  db "[0xA000] - MEMORIA DE VIDEO VGA", 0

    ; Atualizado para avisar sobre a opção de reiniciar
    msg_voltar       db "Pressione qualquer tecla para voltar (ou S para reiniciar)...", 0

