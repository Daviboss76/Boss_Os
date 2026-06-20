; =============================================================================
; BossOS - Módulo Web Parser (Limpador de HTML)
; Versão: 1.0 "Foco nos Estudos"
; =============================================================================

[bits 16]

section .data
    ; --- Estados do Filtro ---
    dentro_da_tag    db 0         

    ; --- Cores de Estudo ---
    cor_texto_estudo db 0x70      ; Cinza claro com letra preta
    cor_titulo       db 0x71      ; Cinza claro com azul

    msg_parser_init  db "PARSER: Formatando conteudo para leitura...", 13, 10, 0
    msg_fim_pagina   db 13, 10, "--- Fim da Pagina ---", 13, 10, 0

section .text

; -----------------------------------------------------------------------------
; FUNÇÃO: processar_html_recebido
; -----------------------------------------------------------------------------
processar_html_recebido:
    pusha

    mov byte [dentro_da_tag], 0   
    call limpar_tela_branco      

.loop_leitura:
    lodsb                       
    cmp al, 0                   ; Fim do buffer do site
    je .finalizar

    ; --- Lógica do Filtro de Tags ---
    cmp al, '<'                 
    je .abriu_tag

    cmp al, '>'                 
    je .fechou_tag

    ; Se não estamos dentro de uma tag, imprimimos o caractere
    cmp byte [dentro_da_tag], 0
    je .imprimir_caractere

    jmp .loop_leitura           

.abriu_tag:
    mov byte [dentro_da_tag], 1
    jmp .loop_leitura

.fechou_tag:
    mov byte [dentro_da_tag], 0
    jmp .loop_leitura

.imprimir_caractere:
    cmp al, 10                  ; Newline (\n)
    je .nova_linha
    cmp al, 13                  ; Carriage Return (\r)
    je .loop_leitura

    mov ah, 0Eh                 ; Modo Teletype da BIOS
    mov bh, 0                   
    int 10h
    jmp .loop_leitura

.nova_linha:
    mov ah, 0Eh
    mov al, 13
    int 10h
    mov al, 10
    int 10h
    jmp .loop_leitura

.finalizar:
    call proxima_linha
    mov si, msg_fim_pagina
    call print_string

    popa
    ret

