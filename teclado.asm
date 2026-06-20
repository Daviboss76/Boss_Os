; ==========================================================
; teclado.asm - Controlador de Entradas do BossOS
; ==========================================================

verificar_teclado:
    mov ah, 00h
    int 16h              ; Lê a tecla

    ; --- LOGICA DE ATALHOS (Sempre com espaço antes do comando!) ---
    cmp al, 'i'          ; Tecla 'i' para o Menu
    je .abrir_menu

    cmp al, '1'          ; Tecla '1' para o Terminal
    je .ir_terminal

    cmp al, '2'          ; Tecla '2' para o Editor
    je .ir_editor

    cmp al, '3'          ; Tecla '3' para a Calculadora
    je .ir_calculadora

    cmp al, '4'          ; Tecla '4' para a IA
    je .ir_IA

    cmp al, '5'          ; Tecla '5' para a memoria
    je .ir_jogo

    cmp al, '6'          ; Tecla '6' para o navegador
    je .ir_web

    cmp al, 's'          ; Tecla 's' para reiniciar
    je .reiniciar_sistema

    jmp .sem_tecla       ; Se não for nada, ignora

; --- DESTINOS (Estes podem ficar encostados na esquerda com ':') ---
.abrir_menu:
    call desenhar_menu_iniciar
    ret

.ir_terminal:
    call abrir_terminal_v2
    ret

.ir_editor:
    call abrir_editor
    ret

.ir_calculadora:
    call abrir_calculadora
    ret

.ir_IA:
    call abrir_IA
    ret

.ir_jogo:
    call main_cobra
    ret

.ir_web:
    call abrir_navegador
    ret

.reiniciar_sistema:
    int 19h              ; Chama a interrupção de reinicialização da BIOS
    ret

.sem_tecla:
    jmp verificar_teclado

