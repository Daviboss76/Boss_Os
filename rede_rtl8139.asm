; =============================================================================
; BossOS - Driver Monolítico de Rede (Realtek RTL8139)
; Versão: 1.0 "Conectividade Total"
; Description: Gerenciamento completo de Hardware, RX e TX.
; =============================================================================

[bits 16]

section .data
    ; --- Configurações de Hardware ---
    rtl_io_base      dw 0xC000    ; Porta Base I/O padrão do Limbo

    ; --- Buffers de Memória ---
    align 4
    buffer_rx_rede   times 8192 + 16 db 0

    align 4
    buffer_tx_rede   times 2048 db 0

    ; --- Mensagens de Log do Sistema ---
    msg_rede_init    db "REDE: Inicializando controlador RTL8139...", 13, 10, 0
    msg_rede_ready   db "REDE: Dispositivo pronto para transmissao.", 13, 10, 0
    msg_rede_err     db "REDE: Falha ao resetar o hardware!", 13, 10, 0
    msg_send_ok      db "REDE: Pacote enviado com sucesso.", 13, 10, 0
    msg_recv_ok      db "REDE: Pacote recebido na memoria! Processando...", 13, 10, 0

section .text

; ---------------- -------------------------------------------------------------
; FUNÇÃO: inicializar_driver_rede
; -----------------------------------------------------------------------------
inicializar_driver_rede:
    pusha

    mov si, msg_rede_init
    call print_string

    ; 1. LIGAR O CHIP (Wake up)
    mov dx, [rtl_io_base]
    add dx, 0x52                ; Offset para Config 1
    mov al, 0x00
    out dx, al

    ; 2. COMANDO DE RESET
    mov dx, [rtl_io_base]
    add dx, 0x37                ; Command Register
    mov al, 0x10
    out dx, al

.check_reset:
    in al, dx
    test al, 0x10               ; Verifica se o bit 4 (Reset) limpou
    jnz .check_reset            ; Enquanto estiver 1, a placa esta reiniciando

    ; 3. CONFIGURAR O ENDEREÇO DO BUFFER DE RECEPÇÃO (RX)
    mov dx, [rtl_io_base]
    add dx, 0x30                ; RBSTART
    mov eax, buffer_rx_rede     
    out dx, eax

    ; 4. CONFIGURAR INTERRUPÇÕES
    mov dx, [rtl_io_base]
    add dx, 0x3C                ; IMR
    mov ax, 0x0005              ; ROK + TOK
    out dx, ax

    ; 5. CONFIGURAR REGRAS DE RECEPÇÃO (RCR)
    mov dx, [rtl_io_base]
    add dx, 0x44                ; RCR
    mov eax, 0x0000000F         ; AB + AM + APM + AAP (Modo Promiscuo)
    out dx, eax

    ; 6. ATIVAR TRANSMISSOR E RECEPTOR
    mov dx, [rtl_io_base]
    add dx, 0x37                ; Command Register
    mov al, 0x0C                ; Bits RE e TE
    out dx, al

    mov si, msg_rede_ready
    call print_string

    popa
    ret

; -----------------------------------------------------------------------------
; FUNÇÃO: enviar_pacote_rede
; -----------------------------------------------------------------------------
enviar_pacote_rede:
    pusha

    ; 1. Copiar dados do SI para o buffer_tx_rede
    mov di, buffer_tx_rede
    rep movsb                   ; Copia CX bytes

    ; 2. Informar a placa o endereço físico do TX
    mov dx, [rtl_io_base]
    add dx, 0x20                ; TSAD0
    mov eax, buffer_tx_rede
    out dx, eax

    ; 3. Iniciar a transmissão informando o tamanho
    mov dx, [rtl_io_base]
    add dx, 0x10                ; TSD0
    mov ax, cx                  ; Tamanho do pacote em bytes
    and ax, 0x1FFF              ; Garante que não passe de 8KB
    out dx, ax                  

.wait_tx:
    in ax, dx
    test ax, 0x8000             ; Verifica se o bit OWN mudou para 1
    jz .wait_tx

    mov si, msg_send_ok
    call print_string

    popa
    ret

; -----------------------------------------------------------------------------
; FUNÇÃO: checar_recebimento
; -----------------------------------------------------------------------------
checar_recebimento:
    pusha

    mov dx, [rtl_io_base]
    add dx, 0x37                ; Command Register
    in al, dx
    test al, 0x01               ; Verifica o bit BUFE (Buffer Empty)
    jnz .sem_dados              ; Se estiver vazio, sai fora

    ; Se chegou aqui, tem pacote!
    mov si, msg_recv_ok
    call print_string

    ; PONTE DIRETA: Envia o buffer de rede para o limpador de HTML processar!
    mov si, buffer_rx_rede
    call processar_html_recebido

.sem_dados:
    popa
    ret

