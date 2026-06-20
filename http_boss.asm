; =============================================================================
; BossOS - Módulo de Protocolo HTTP (HyperText Transfer Protocol)
; Versão: 1.0 "Estudo Web"
; =============================================================================

[bits 16]

section .data
    ; --- Cabeçalhos Padrão do Protocolo ---
    http_metodo      db "GET / ", 0
    http_versao      db " HTTP/1.1", 13, 10, 0        
    http_host_label  db "Host: ", 0
    http_user_agent  db "User-Agent: BossOS/1.0 (Davi Edition)", 13, 10, 0
    http_connection  db "Connection: close", 13, 10, 13, 10, 0 

    ; --- Variáveis de Controle e Buffers Estáticos ---
    url_destino      times 128 db 0
    pacote_completo  times 512 db 0                   

    ; --- Mensagens de Sistema ---
    msg_http_gerando db "HTTP: Gerando requisicao para o servidor...", 13, 10, 0
    msg_http_pronto  db "HTTP: Pacote de dados pronto para o driver de rede.", 13, 10, 0

section .text

; -----------------------------------------------------------------------------
; FUNÇÃO: montar_requisicao_http
; -----------------------------------------------------------------------------
montar_requisicao_http:
    pusha

    mov si, msg_http_gerando
    call print_string

    ; 1. Limpar o buffer do pacote antigo
    mov di, pacote_completo
    mov al, 0
    mov cx, 512
    rep stosb                   

    ; 2. Começar a montagem: Copiar "GET / "
    mov di, pacote_completo
    mov si, http_metodo
    call .copiar_string

    ; 3. Copiar a Versão
    mov si, http_versao
    call .copiar_string

    ; 4. Adicionar o Host: "Host: "
    mov si, http_host_label
    call .copiar_string

    ; 5. Adicionar a URL que está no buffer global url_destino
    mov si, url_destino         
    call .copiar_string

    ; Adicionar quebra de linha após o Host
    mov al, 13
    stosb
    mov al, 10
    stosb

    ; 6. Adicionar User-Agent
    mov si, http_user_agent
    call .copiar_string

    ; 7. Finalizar o cabeçalho (Connection: close + Duplo Enter)
    mov si, http_connection
    call .copiar_string

    mov si, msg_http_pronto
    call print_string

    popa
    ret

; --- Subfunção Interna: Copiar String para o Buffer DI ---
.copiar_string:
.loop_copy:
    lodsb               
    cmp al, 0           
    je .done_copy
    stosb               
    jmp .loop_copy
.done_copy:
    ret

; -----------------------------------------------------------------------------
; FUNÇÃO: enviar_pedido_estudo
; -----------------------------------------------------------------------------
enviar_pedido_estudo:
    pusha

    ; Conta quantos bytes o pacote tem no total
    mov si, pacote_completo
    mov cx, 0
.contar:
    lodsb
    cmp al, 0
    je .enviar
    inc cx
    jmp .contar

.enviar:
    mov si, pacote_completo
    ; CX já está com o tamanho correto do pacote contado no loop anterior
    call enviar_pacote_rede     
    
    popa
    ret


