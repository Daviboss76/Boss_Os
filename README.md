# BossOS v2.1 🚀 (Edição de Junho)

O **BossOS** é um Sistema Operacional de 16 bits desenvolvido em Assembly por **Davi R. Boss**, focado em explorar a lógica de baixo nível e arquitetura de computadores diretamente no Real Mode.

Esta atualização de junho traz a versão 2.1 do sistema, focada na expansão do terminal e melhorias estruturais, trazendo dois comandos novos.

---

## 🛠️ O que há de novo na Versão 2.1:
* **Dois Comandos Novos no Terminal:** O terminal agora conta com duas novas instruções nativas para o usuário interagir com o Kernel.
* **Aviso Importante sobre o Comando Secreto (`boss_rm`):** **NUNCA UTILIZEM ESTE COMANDO!** Ele ativa a rotina de autodestruição que apaga e corrompe o sistema operacional na memória. Use por sua própria conta e risco.
* **Nota sobre o Comando `linux`:** O portal para o Linux ainda está em estágio inicial e muito mal desenvolvido. Atualmente, ele não está funcionando muito bem e pode apresentar falhas ou mensagens de erro ao ser executado.

---

## 🖥️ Aplicativos e Recursos Integrados:
* **BossOS Terminal v2.0:** Prompt de comando interativo com suporte a `help`, `cls` e `ver`.
* **BossOS Code Editor v1.0:** Um editor de texto embutido diretamente no Kernel para escrita de códigos.
* **Calculadora Boss v1.0:** Utilitário para operações matemáticas básicas diretamente na tela do sistema.
* **BossIA (Inteligência Artificial):** Sistema de interatividade embutido para conversação básica com o usuário.
* **Monitor de Memória:** Exibe a divisão real do mapa de RAM do sistema (Núcleo, IA e Memória de Vídeo VGA).

---

## 🌐 Suporte de Rede e Internet:
* **Driver de Rede:** O Kernel possui o suporte inicial voltado para o driver de Wi-Fi e controle do hardware RTL8139.
* **BossBrowser v1.0:** O navegador web estruturado **ainda não está funcionando**, mas a pilha de requisições HTTP está em desenvolvimento ativo para que ele funcione por completo em breve.

---

## 💾 Como testar o sistema:
Você pode rodar a imagem binária `bossos.img` utilizando emuladores de PC x86, como o **Limbo PC Emulator** no Android ou o **QEMU** no computador.

