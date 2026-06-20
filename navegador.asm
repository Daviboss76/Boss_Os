; =============================================================================
; BossOS - Interface Gráfica de Texto (BossBrowser)
; Versão: 1.0 "Conectividade Boss"
; =============================================================================

[bits 16]

section .data
    msg_btn_voltar   db "[<] [>] [R]", 0
    msg_url_exemplo  db "www.google.com.br", 0
    msg_status_rede  db "BossBrowser v1.0 - Conectado via RTL8139", 0

section .text

; -----------------------------------------------------------------------------
; FUNÇÃO: abrir_navegador
; -----------------------------------------------------------------------------
abrir_navegador:
    pusha
    call limpar_tela_branco      

    ; 1. Desenhar a Barra de Cima (Cinza Escuro)
    mov bh, 0x88                
    mov cx, 0x0000              
    mov dx, 0x014F              
    call desenhar_retangulo_colorido

    ; 2. Desenhar a Barra de Endereço (Branca)
    mov bh, 0xF0                
    mov cx, 0x000A              
    mov dx, 0x0046              
    call desenhar_retangulo_colorido

    ; 3. Colocar os Textos Fixos
    mov dh, 0                   
    mov dl, 1                   
    call ia_set_cursor
    mov si, msg_btn_voltar
    call print_string_color     

    mov dl, 12
    call ia_set_cursor
    mov si, msg_url_exemplo     
    call print_string

    ; 4. Linha de Status (Lá embaixo)
    mov bh, 0x1F                
    mov cx, 0x1800              
    mov dx, 0x184F              
    call desenhar_retangulo_colorido

    mov dh, 24
    mov dl, 1
    call ia_set_cursor
    mov si, msg_status_rede
    call print_string

.loop_navegador:
    ; Verifica constantemente se a internet mandou resposta de pacotes
    call checar_recebimento     

    ; Verifica se o usuário apertou uma tecla sem travar a tela
    mov ah, 01h
    int 16h
    jz .loop_navegador          ; Se não apertou nada, continua rodando e checando a rede

    ; Se tem tecla pressionada, captura ela
    mov ah, 00h
    int 16h                     
    cmp al, 27                  ; Tecla ESC sai do navegador
    je .sair
    cmp al, 13                  ; Tecla ENTER dispara a requisição HTTP!
    je .disparar_requisicao

    jmp .loop_navegador

.disparar_requisicao:
    ; Copia o texto de "msg_url_exemplo" para dentro do buffer "url_destino" do http_boss
    mov si, msg_url_exemplo
    mov di, url_destino
.copiar_url:
    lodsb
    stosb
    cmp al, 0
    jnz .copiar_url

    ; Executa a montagem e o disparo através do driver de rede
    call montar_requisicao_http
    call enviar_pedido_estudo
    jmp .loop_navegador

.sair:
    popa
    ret

