; ==========================================================
; calc.asm - Calculadora Avançada do BossOS (v2.0)
; ==========================================================

abrir_calculadora:
    call limpar_tela_total
    call resetar_cursor

    mov si, msg_calc_boas_vindas
    call print_string

    ; 1. Pega o primeiro número (Resultado vai para CX)
    mov si, msg_pedir_n1
    call print_string
    call ler_numero_multidigito
    mov bx, cx           ; Guarda N1 em BX

    call pular_linha

    ; 2. Pega a operação
    mov si, msg_operacao
    call print_string
    mov ah, 00h
    int 16h              ; Lê '+', '-', '*', '/', ou 'S'
    
    cmp al, 'S'          ; Verifica se o usuário quer sair/reiniciar
    je .reiniciar_sistema
    cmp al, 's'
    je .reiniciar_sistema

    mov cl, al           ; Guarda a operação em CL
    mov ah, 0Eh
    int 10h              ; Mostra o sinal na tela

    call pular_linha

    ; 3. Pega o segundo número (Resultado vai para CX)
    mov si, msg_pedir_n2
    call print_string
    push bx              ; Salva N1 na pilha temporariamente
    call ler_numero_multidigito
    mov dx, cx           ; Guarda N2 em DX
    pop bx               ; Recupera N1 em BX

    call pular_linha

    ; 4. Lógica de Operações (Suporta 16-bit: Dezenas, Centenas, Milhares)
    cmp cl, '+'
    je .fazer_soma
    cmp cl, '-'
    je .fazer_sub
    cmp cl, '*'
    je .fazer_mult
    cmp cl, '/'
    je .fazer_div
    jmp .erro

.fazer_soma:
    add bx, dx           ; BX = N1 + N2
    mov ax, bx           ; Move o resultado para AX
    jmp .mostrar_res

.fazer_sub:
    sub bx, dx           ; BX = N1 - N2
    mov ax, bx           ; Move o resultado para AX
    jmp .mostrar_res

.fazer_mult:
    mov ax, bx           ; AX = N1
    mul dx               ; AX = AX * DX (Resultado em DX:AX, considerando até 65535)
    jmp .mostrar_res

.fazer_div:
    cmp dx, 0            ; Evita divisão por zero
    je .erro_div
    mov ax, bx           ; AX = N1
    xor dx, dx           ; Limpa DX para a divisão de 16 bits
    div dx               ; AX = AX / DX (Quociente em AX)
    jmp .mostrar_res

.mostrar_res:
    push ax              ; Salva o resultado
    mov si, msg_resultado
    call print_string
    pop ax               ; Restaura o resultado para exibição

    call exibir_numero_16bit
    jmp .fim

.erro_div:
    mov si, msg_erro_div0
    call print_string
    jmp .fim

.erro:
    mov si, msg_erro_calc
    call print_string

.fim:
    mov si, msg_sair_calc
    call print_string
    mov ah, 00h
    int 16h
    
    cmp al, 'S'          ; Verifica se quer reiniciar no fim também
    je .reiniciar_sistema
    cmp al, 's'
    je .reiniciar_sistema

    call desenhar_fundo_azul
    call desenhar_barra_tarefas
    ret

.reiniciar_sistema:
    int 19h              ; Interrupção de Bootstrap (Reinicia o PC/SO)


; ==========================================================
; FUNÇÕES AUXILIARES DE ENTRADA E SAÍDA
; ==========================================================

; --- Lê um número com múltiplos dígitos (Ex: 2500) ---
; Retorno: Número convertido em CX
ler_numero_multidigito:
    xor cx, cx           ; Inicializa CX com 0 (acumulador do número)

.loop_leitura:
    mov ah, 00h
    int 16h              ; Captura tecla

    cmp al, 'S'          ; Verifica reinicialização rápida
    je abrir_calculadora.reiniciar_sistema
    cmp al, 's'
    je abrir_calculadora.reiniciar_sistema

    cmp al, 13           ; Tecla Enter (Fim do número)
    je .fim_leitura

    cmp al, '0'          ; Ignora se for menor que ASCII '0'
    jb .loop_leitura
    cmp al, '9'          ; Ignora se for maior que ASCII '9'
    ja .loop_leitura

    ; Exibe o caractere válido digitado
    mov ah, 0Eh
    int 10h

    ; Converte o caractere para valor e adiciona ao acumulador: CX = (CX * 10) + (AL - '0')
    sub al, '0'
    xor ah, ah
    push ax              ; Salva o dígito atual

    mov ax, cx
    mov bx, 10
    mul bx               ; AX = CX * 10
    mov cx, ax

    pop ax               ; Recupera o dígito
    add cx, ax           ; Adiciona ao total
    jmp .loop_leitura

.fim_leitura:
    ret


; --- Converte um número de 16 bits para string e exibe ---
; Entrada: AX = Número a ser exibido
exibir_numero_16bit:
    xor cx, cx           ; Contador de dígitos empilhados
    mov bx, 10           ; Divisor fixa em 10

.empilhar_digitos:
    xor dx, dx           ; Limpa DX para a divisão
    div bx               ; AX = AX / 10, resto em DX
    push dx              ; Salva o resto (dígito) na pilha
    inc cx               ; Incrementa contador de dígitos
    cmp ax, 0
    jne .empilhar_digitos

.desempilhar_e_mostrar:
    pop dx               ; Recupera o dígito (começa pelo mais significativo)
    add dl, '0'          ; Converte para ASCII
    mov al, dl
    mov ah, 0Eh
    int 10h              ; Printa o dígito
    loop .desempilhar_e_mostrar
    ret


; ==========================================================
; MENSAGENS E VARIÁVEIS
; ==========================================================
msg_calc_boas_vindas db "--- CALCULADORA BOSS v2.0 ---", 13, 10, "Pressione 'S' a qualquer momento para reiniciar.", 13, 10, 0
msg_pedir_n1         db "Numero 1 (0-65535): ", 0
msg_pedir_n2         db "Numero 2 (0-65535): ", 0
msg_operacao         db "Operacao (+, -, *, /): ", 0
msg_resultado        db "Resultado: ", 0
msg_erro_calc        db "Operacao invalida!", 0
msg_erro_div0        db "Erro: Divisao por zero!", 0
msg_sair_calc        db 13, 10, "Pressione qualquer tecla para sair (ou S para reiniciar)...", 0

