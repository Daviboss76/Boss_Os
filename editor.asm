; ==========================================>
; editor.asm - IDE de Desenvolvimento do BossOS
; ==========================================>

abrir_editor:
    mov bh, 0x1E         ; Cor: Fundo Azul
    call limpar_tela_total
    call resetar_cursor

    mov si, msg_editor_topo
    call print_string

    mov si, msg_editor_instrucao
    call print_string

    ; Loop de escrita do Editor
    jmp loop_editor

loop_editor:
    mov ah, 00h          ; Ler tecla
    int 16h

    cmp al, 27           ; ESC para sair
    je voltar_desktop_editor

    ; === NOVA LOGICA: Se digitar 'S' ou 's', reinicia o sistema ===
    cmp al, 'S'
    je reiniciar_sistema
    cmp al, 's'
    je reiniciar_sistema

    ; Mostrar letra na tela
    mov ah, 0Eh          
    mov bh, 0
    int 10h

    ; === NOVA LOGICA: Quebra de linha automatica ===
    ; Pega a posicao atual do cursor usando a INT 10h / AH=03h
    mov ah, 03h
    mov bh, 0
    int 10h              ; Retorna a coluna em DL e a linha em DH

    cmp dl, 0            ; Se DL voltou para 0, a propria BIOS ja quebrou a linha (depende do emulador)
    je loop_editor
    
    cmp dl, 79           ; Chegou no limite da linha (coluna 79)?
    jne loop_editor      ; Se nao chegou, continua no loop

quebrar_linha_auto:
    mov ah, 0Eh
    mov al, 0Dh          ; Carriage Return (Volta para o inicio da linha)
    int 10h
    mov al, 0Ah          ; Line Feed (Pula para a linha de baixo)
    int 10h
    jmp loop_editor

reiniciar_sistema:
    int 0x19             ; Chama a interrupcao de Boot da BIOS para reiniciar

voltar_desktop_editor:
    call desenhar_fundo_azul
    call desenhar_barra_tarefas
    ret

; --- Textos ---
msg_editor_topo      db "--- BossOS Code Editor v1.0 ---", 13, 10, 0
msg_editor_instrucao db "Digite seu codigo abaixo (ESC para sair ou S para reiniciar):", 13, 10, 0

