# 🚀 BossOS v2.3
Um sistema operacional independente de 16 bits desenvolvido puramente em **Assembly x86 (NASM)**, focado em alta eficiência, leveza e segurança ativa por software.

## 📊 Especificações Técnicas
* **Versão Atual:** v2.3
* **Arquitetura:** 16-bit Real Mode (Modo Real)
* **Linguagem:** Assembly Puro (Zero "gordura" de compiladores C/C++)
* **Tamanho Total do Sistema:** ~16,87 KB (Incrível eficiência de armazenamento!)
* **Plataforma de Desenvolvimento:** Construído e compilado diretamente no celular via **Termux**
* **Alvo de Execução:** Emuladores (como QEMU/Bochs) ou hardware compatível x86

---

## 🛡️ Diferencial do BossOS: Arquitetura de Segurança Ativa
Diferente do MS-DOS clássico, que entregava o controle total do processador para os programas e travava silenciosamente em caso de falhas, o BossOS introduz uma mentalidade moderna de proteção em um ambiente de 16 bits:

1. **Loop Principal Vigilante (`main_loop`):** O Kernel monitora constantemente o sistema enquanto ele está rodando, gerenciando o relógio, o teclado e a integridade da memória em paralelo.
2. **B.E.S. (Boss Error System):** Uma rotina de segurança integrada (`verificar_Os`) valida assinaturas críticas de memória em tempo real. Se um binário ou comando tentar corromper ou invadir o endereço do Kernel (`0x1000`), a **B.E.S.** intercepta a ação imediatamente e dispara a **Tela Vermelha da Morte**, protegendo o processador de comportamentos indefinidos.

---

## 📂 Estrutura de Arquivos do Projeto
O ecossistema do BossOS é modularizado e dividido nos seguintes componentes:

* `bootloader.asm`: O setor de boot responsável por preparar o ambiente e carregar o Kernel na RAM.
* `kernel.asm`: O núcleo do sistema operacional que gerencia o loop principal e as chamadas de funções.
* `terminal.asm`: Prompt de comando interativo para execução de utilitários e testes do sistema.
* `BES.asm`: Módulo da Tela Vermelha da Morte para tratamento de erros graves e invasões de memória.
* `calc.asm` / `editor.asm` / `relogio.asm`: Utilitários nativos (Calculadora, Editor de Texto e Relógio Visual).
* `moto_IA.asm`: Mecanismo experimental de processamento lógico de strings e respostas locais.
* `rede_rtl8139.asm` / `http_boss.asm`: Módulos de teste para simulação e estruturação de drivers de rede.
* `biblioteca.asm`: Coleção de subrotinas compartilhadas (impressão de strings, leitura de teclado, etc.).

---

## ⚙️ Como Compilar e Unir o Sistema (No Termux)
Se você deseja clonar este repositório e gerar a imagem final do sistema, certifique-se de ter o `nasm` instalado e execute os comandos:

```bash
# 1. Compilar os componentes base
nasm -f bin bootloader.asm -o bootloader.bin
nasm -f bin kernel.asm -o kernel.bin

# 2. Unir os binários na imagem de disco final
cat bootloader.bin kernel.bin > boss_os.img

