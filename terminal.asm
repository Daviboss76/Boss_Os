; ==================================================================
; terminal_v2.asm - O Cérebro Organizado do BossOS v2.0
; ==================================================================

; --- VARIÁVEIS E BUFFERS ---
buffer_cmd       times 32 db 0      ; Buffer para o comando digitado
pos_buffer       dw 0               ; Contador de letras no buffer

; --- INICIALIZAÇÃO DO TERMINAL ---
abrir_terminal_v2:
    call limpar_tela_total
    call resetar_cursor

    mov si, msg_header_v2
    call print_string

    ; Cai direto no prompt principal
    jmp novo_prompt

; --- O LAÇO PRINCIPAL (PROMPT) ---
novo_prompt:
    call pular_linha                ; Dá um espaço limpo na tela

    mov si, prompt_v2
    call print_string

    mov word [pos_buffer], 0        ; Reseta o contador do buffer

loop_leitura:
    mov ah, 00h
    int 16h                         ; Lê a tecla do teclado

    cmp al, 13                      ; ENTER?
    je processar_comando

    cmp al, 8                       ; BACKSPACE?
    je apagar_letra

    ; Exibe a letra na tela e guarda no buffer
    mov ah, 0Eh
    int 10h

    mov bx, [pos_buffer]
    mov [buffer_cmd + bx], al
    inc word [pos_buffer]
    jmp loop_leitura

apagar_letra:
    ; Lógica simples de backspace para não travar o teclado
    jmp loop_leitura

; --- PROCESSAMENTO E COMPARAÇÃO ---
processar_comando:
    call pular_linha

    ; Finaliza a string do buffer com zero (null-terminator)
    mov bx, [pos_buffer]
    mov byte [buffer_cmd + bx], 0

    ; 1. Comando "cls"
    mov si, buffer_cmd
    mov di, cmd_cls
    call comparar_strings
    je exec_cls

    ; 2. Comando "ver"
    mov si, buffer_cmd
    mov di, cmd_ver
    call comparar_strings
    je exec_ver

    ; 3. Comando "help"
    mov si, buffer_cmd
    mov di, cmd_help
    call comparar_strings
    je exec_help

    ; 4. Comando "boss_rm"
    mov si, buffer_cmd
    mov di, cmd_boss_rm
    call comparar_strings
    je exec_boss_rm

    ; 5. Comando "linux" (O Portal)
    mov si, buffer_cmd
    mov di, cmd_linux
    call comparar_strings
    je exec_linux

    ; 6. Comando "sai"
    mov si, buffer_cmd
    mov di, cmd_sai
    call comparar_strings
    je exec_sai

    ; 7. Comando "teste_bes"
    mov si, buffer_cmd              ; CORRIGIDO: mudado de cmd_buffer para buffer_cmd
    mov di, cmd_teste_bes
    call comparar_strings
    je exec_forcar_erro_kernel      ; CORRIGIDO: apontando para o rótulo correto

    ; Se não for nenhum comando conhecido:
    mov si, msg_erro_v2
    call print_string
    jmp novo_prompt

; --- EXECUÇÃO DOS COMANDOS ---

exec_cls:
    call limpar_tela_total
    call resetar_cursor
    jmp novo_prompt

exec_ver:
    mov si, msg_versao_info
    call print_string
    jmp novo_prompt

exec_help:
    mov si, msg_ajuda
    call print_string
    jmp novo_prompt

exec_boss_rm:
    mov si, msg_erro_grave          ; Alerta dramático
    call print_string

    ; Pausa de 3 segundos (Suspense)
    mov ah, 0x86
    mov cx, 0x002D
    mov dx, 0xC6C0
    int 0x15

    ; Destruição do Setor 1 (Bootloader)
    mov ah, 0x03        ; Função de escrita da BIOS
    mov al, 1           ; 1 setor
    mov ch, 0           ; Trilha 0
    mov cl, 1           ; Setor 1
    mov dh, 0           ; Cabeça 0
    mov bx, buffer_vazio
    int 0x13

    ; Reboot físico
    jmp 0xFFFF:0x0000

exec_linux:
    mov si, msg_portal
    call print_string

    ; Reseta o sistema de disco
    mov ah, 0x00
    int 0x13

    ; BIOS lê o setor do Linux e joga na RAM
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2           ; Setor 2
    mov dh, 0
    mov bx, 0x7C00
    int 0x13

    ; Checagem de segurança (Se deu erro, vai para o aviso)
    jc erro_portal

    ; Atravessa o portal! Passe livre para o Linux
    jmp 0x0000:0x7C00

erro_portal:
    mov si, msg_erro_portal
    call print_string
    jmp novo_prompt                 ; Volta para o terminal em segurança!

exec_sai:
    int 0x19
    ret

exec_forcar_erro_kernel:             ; CORRIGIDO: Rótulo padronizado e global
    mov ax, 0
    mov gs, ax
    mov byte [gs:0x1000], 0x00      ; Corrompe o primeiro byte do Kernel de propósito!
    ret                             ; O loop principal capturará a falha na próxima volta!

; --- SUBROTINAS AUXILIARES ---

pular_linha:
    mov ah, 0Eh
    mov al, 13                      ; Retorno de carro
    int 10h
    mov al, 10                      ; Nova linha
    int 10h
    ret

; --- DADOS, STRINGS E MENSAGENS ---
cmd_cls          db "cls", 0
cmd_ver          db "ver", 0
cmd_help         db "help", 0
cmd_boss_rm      db "boss_rm", 0
cmd_linux        db "linux", 0
cmd_sai          db "sai", 0
cmd_teste_bes    db "teste_bes", 0

msg_header_v2    db "BossOS Terminal v2.0 - Digite 'help'", 13, 10, 0
prompt_v2        db "Boss@Davi> ", 0
msg_erro_v2      db "Comando invalido!", 13, 10, 0
msg_versao_info  db "BossOS v2.0 - Desenvolvido por Davi R. Boss", 13, 10, 0
msg_ajuda        db "Comandos disponiveis:", 13, 10
                 db "  help    - Mostra esta lista de comandos", 13, 10
                 db "  cls     - Limpa a tela do terminal", 13, 10
                 db "  ver     - Mostra os dados do criador", 13, 10
                 db "  linux   - Abre o portal para o Linux", 13, 10
                 db "  boss_rm - ERRO GRAVE! Autodestruicao", 13, 10
                 db "  sai     - Sai do terminal!", 13, 10, 0

msg_erro_grave   db "Erro erro muito grave mais grave vamos morre corra corra salves quem pude", 13, 10, 0
msg_portal       db "encontrado linux aguande", 13, 10, 0
msg_erro_portal  db "erro nao encontrei o linux", 13, 10, 0

buffer_vazio     times 512 db 0   ; Bloco de zeros para apagar o disco

