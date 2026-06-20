; ==========================================================
; video.asm - Motor de Interface do BossOS v2.3 (Nova UI)
; ==========================================================

; --- 1. Função para Desenhar o Fundo Azul ---
; Modificado: Começa na linha 1 para preservar a barra de status na linha 0
desenhar_fundo_azul:
    mov ah, 06h
    mov al, 0
    mov bh, 0x1F         ; Fundo Azul com letra branca
    mov ch, 1            ; Linha inicial mudou de 0 para 1!
    mov cl, 0
    mov dh, 22           ; Linha limite antes da barra de tarefas
    mov dl, 79
    int 10h
    
    call desenhar_barra_status ; Desenha a nova barra no topo automaticamente
    ret

; --- [NOVA FUNÇÃO] Barra de Status Superior (Linha 0) ---
desenhar_barra_status:
    ; 1. Pintar a barra no topo (Linha 0, de ponta a ponta)
    mov ah, 06h
    mov al, 0
    mov bh, 0x4F         ; Fundo Vermelho Escuro/Preto com letra branca (Destaque)
    mov ch, 0            ; Linha 0
    mov cl, 0            ; Coluna 0
    mov dh, 0            ; Linha 0
    mov dl, 79           ; Coluna 79
    int 10h

    ; 2. Escrever o Status do WhatsApp no canto esquerdo
    mov ah, 02h
    mov bh, 0
    mov dh, 0            ; Linha 0
    mov dl, 1            ; Coluna 1
    int 10h
    mov si, txt_zap
    call print_string

    ; 3. Buscar e Escrever a Data Real (Via BIOS INT 1Ah) no canto direito
    ; Retorna: CH = Século (20), CL = Ano (26), DH = Mês, DL = Dia em formato BCD
    mov ah, 04h
    int 1Ah              
    jc .sem_relogio      ; Se o hardware falhar, pula a impressão da data

    push dx              ; Salva Dia e Mês
    push cx              ; Salva Século e Ano

    ; Posicionar cursor para a data (Coluna 55 da Linha 0)
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 55
    int 10h

    ; Imprimir Dia
    pop cx
    pop dx
    push dx
    push cx
    mov al, dl
    call imprimir_bcd_byte
    
    mov al, '/'
    call imprimir_char_status

    ; Imprimir Mês
    pop cx
    pop dx
    push dx
    push cx
    mov al, dh
    call imprimir_bcd_byte

    mov al, '/'
    call imprimir_char_status

    ; Imprimir Século (20)
    pop cx
    pop dx
    push dx
    push cx
    mov al, ch
    call imprimir_bcd_byte

    ; Imprimir Ano (26)
    pop cx
    pop dx
    mov al, cl
    call imprimir_bcd_byte

.sem_relogio:
    ret

; --- Auxiliares internos da Barra de Status ---
imprimir_bcd_byte:
    ; Converte o formato BCD do chip RTC para caracteres ASCII legíveis
    push ax
    shr al, 4            ; Pega o dígito mais alto
    add al, '0'
    call imprimir_char_status
    pop ax
    and al, 0x0F         ; Pega o dígito mais baixo
    add al, '0'
    call imprimir_char_status
    ret

imprimir_char_status:
    mov ah, 0Eh          ; Teletype
    mov bh, 0
    int 10h
    ret

; --- 2. Função para a Barra de Tarefas ---
desenhar_barra_tarefas:
    mov ah, 06h
    mov al, 0
    mov bh, 0x70         ; Cinza com letra preta
    mov ch, 23           ; Linha da barra
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h

    ; Escrever [ Iniciar ]
    mov ah, 02h
    mov bh, 0
    mov dh, 23
    mov dl, 1
    int 10h
    mov si, txt_iniciar
    call print_string
    ret

; --- 3. Função para o Menu Iniciar ---
; Ajustado o CH para 11 para dar um visual melhor com a nova proporção da tela
desenhar_menu_iniciar:
    mov ah, 06h
    mov al, 0
    mov bh, 0x70         ; Menu Cinza
    mov ch, 11
    mov cl, 1
    mov dh, 22
    mov dl, 20
    int 10h

    ; Opções do Menu
    mov dh, 11
    mov dl, 2
    mov si, txt_terminal
    call imprimir_texto_menu

    mov dh, 13
    mov dl, 2
    mov si, txt_edito
    call imprimir_texto_menu

    mov dh, 15
    mov dl, 2
    mov si, txt_calc
    call imprimir_texto_menu

    mov dh, 17
    mov dl, 2
    mov si, txt_IA
    call imprimir_texto_menu

    mov dh, 19
    mov dl, 2
    mov si, txt_jogo
    call imprimir_texto_menu

    mov dh, 21
    mov dl, 2
    mov si, txt_web
    call imprimir_texto_menu
    ret

; --- 4. Função para Janelas de Aplicativos ---
; CH=Y, CL=X, DH=Alt, DL=Larg, SI=Titulo
desenhar_janela_app:
    mov ah, 06h
    mov al, 0
    mov bh, 0x70         ; Fundo da janela cinza
    int 10h

    push dx
    mov dh, ch           ; Barra de título azul
    mov ah, 06h
    mov bh, 0x1F
    int 10h
    pop dx

    mov ah, 02h
    mov bh, 0
    inc cl
    int 10h
    call print_string
    ret

; --- Funções Auxiliares ---
imprimir_texto_menu:
    mov ah, 02h
    mov bh, 0
    int 10h
    call print_string
    ret

limpar_tela_total:
    mov ah, 06h          
    mov al, 0            
    mov bh, 0x07         
    mov ch, 0            
    mov cl, 0            
    mov dh, 24           
    mov dl, 79           
    int 10h
    ret

resetar_cursor:
    mov ah, 02h          
    mov bh, 0            
    mov dh, 0            
    mov dl, 0            
    int 10h
    ret

; --- TEXTOS E NOTIFICAÇÕES ---
txt_iniciar  db "[ Iniciar ]", 0
txt_terminal db "1. Terminal", 0
txt_edito    db "2. Editor", 0       ; Corrigido o erro de grafia de "edito" para "Editor"
txt_calc     db "3. Calculadora", 0
txt_IA       db "4. BossIA", 0
txt_jogo     db "5. jogo", 0
txt_web      db "6. web", 0

; Notificação simulada do DaviZap ativa no topo do sistema
txt_zap      db "[DaviZap] Mae: A familia e importante no BossOS. (1)", 0

