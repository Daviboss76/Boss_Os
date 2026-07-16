#include "types.h"
#include "stat.h"
#include "user.h"

// Códigos de cor e posicionamento ANSI
#define CLS          "\033[2J\033[H"
#define RESET        "\033[0m"
#define TEXT_WHITE   "\033[37;1m"
#define BG_BLUE      "\033[44m"
#define BG_CYAN      "\033[46m"
#define TEXT_YELLOW  "\033[33;1m"
#define GOTO(l,c)    printf(1, "\033[%d;%dH", (l), (c))

// Desenha as bordas da tela (80 colunas x 25 linhas)
void desenhar_moldura() {
  int i;

  // Define o fundo azul e texto branco para a tela inteira
  printf(1, BG_BLUE TEXT_WHITE CLS);

  // Linha superior
  GOTO(1, 1);
  printf(1, "┌");
  for(i = 2; i < 80; i++) printf(1, "─");
  printf(1, "┐");

  // Linhas laterais
  for(i = 2; i < 25; i++) {
    GOTO(i, 1);  printf(1, "│");
    GOTO(i, 80); printf(1, "│");
  }

  // Linha inferior
  GOTO(25, 1);
  printf(1, "└");
  for(i = 2; i < 80; i++) printf(1, "─");
  printf(1, "┘");
}

void desenhar_menu() {
  desenhar_moldura();

  // Cabeçalho Centralizado
  GOTO(2, 33);
  printf(1, TEXT_YELLOW "BOSS-OS INTERFACE" TEXT_WHITE);
  GOTO(3, 2);
  for(int i = 2; i < 80; i++) printf(1, "═");

  // Caixa de diálogo do menu (Adicionada a nova opção e ajustado o tamanho)
  GOTO(6, 20);  printf(1, "┌────────────────────────────────────────┐");
  GOTO(7, 20);  printf(1, "│          Selecione uma opcao:          │");
  GOTO(8, 20);  printf(1, "├────────────────────────────────────────┤");
  GOTO(9, 20);  printf(1, "│  " TEXT_YELLOW "[1]" TEXT_WHITE " Abrir o Terminal (Shell)          │");
  GOTO(10, 20); printf(1, "│  " TEXT_YELLOW "[2]" TEXT_WHITE " Informacoes de Hardware           │");
  GOTO(11, 20); printf(1, "│  " TEXT_YELLOW "[3]" TEXT_WHITE " Listar Arquivos no Disco (ls)     │");
  GOTO(12, 20); printf(1, "│  " TEXT_YELLOW "[4]" TEXT_WHITE " Executar um Programa do Sistema   │");
  GOTO(13, 20); printf(1, "│  " TEXT_YELLOW "[5]" TEXT_WHITE " Sair e voltar ao Boot Splash      │");
  GOTO(14, 20); printf(1, "└────────────────────────────────────────┘");

  // Barra de status embaixo
  GOTO(24, 2);
  printf(1, BG_CYAN TEXT_WHITE " Atalhos: Pressione 1, 2, 3, 4 ou 5 no seu teclado.                    " BG_BLUE);

  // Posiciona o cursor de entrada de dados
  GOTO(16, 30);
  printf(1, "Digite sua opcao: ");
}

int main(void) {
  char buf[16];
  int rodando = 1;

  while(rodando) {
    desenhar_menu();

    // Lê a tecla digitada pelo usuário (espera o Enter)
    memset(buf, 0, sizeof(buf));
    gets(buf, sizeof(buf));

    // Executa a ação dependendo do número digitado
    if(buf[0] == '1') {
      printf(1, CLS RESET);
      // Cria um processo filho e roda o shell
      int pid = fork();
      if(pid == 0) {
        char *argv[] = { "sh", 0 };
        exec("sh", argv);
        exit();
      }
      wait(); // Espera você sair do Shell (com o comando exit) para voltar ao menu!
    }
    else if(buf[0] == '2') {
      printf(1, CLS RESET);
      printf(1, "=== BOSS-OS HARDWARE INFO ===\n\n");
      printf(1, "Processador: Intel Core i3 (x86 Emulated)\n");
      printf(1, "Memoria RAM: 8GB (DDR3 Configured)\n");
      printf(1, "Armazenamento: 128GB SSD (Virtual IDE Drive)\n");
      printf(1, "Kernel Base: xv6-public Unix\n\n");
      printf(1, "Pressione ENTER para voltar ao menu...");
      gets(buf, sizeof(buf));
    }
    else if(buf[0] == '3') {
      printf(1, CLS RESET);
      printf(1, "=== ARQUIVOS NO DISCO ===\n\n");
      int pid = fork();
      if(pid == 0) {
        char *argv[] = { "ls", 0 };
        exec("ls", argv);
        exit();
      }
      wait();
      printf(1, "\nPressione ENTER para voltar ao menu...");
      gets(buf, sizeof(buf));
    }
    else if(buf[0] == '4') {
      printf(1, CLS RESET);
      printf(1, "=== EXECUTAR PROGRAMA ===\n\n");
      printf(1, "Digite o nome do programa (ex: wc, grep, echo, hello): ");

      char prog_name[32];
      memset(prog_name, 0, sizeof(prog_name));
      gets(prog_name, sizeof(prog_name));

      // Limpa o '\n' que o gets() coloca no final do texto
      int len = strlen(prog_name);
      if(len > 0 && prog_name[len-1] == '\n') {
        prog_name[len-1] = '\0';
      }

      printf(1, "\nIniciando %s...\n\n", prog_name);

      // A mágica do fork + exec acontecendo:
      int pid = fork();
      if(pid == 0) {
        char *prog_argv[] = { prog_name, 0 };
        exec(prog_name, prog_argv);

        // Se o exec falhar (programa não existe), ele avisa e fecha o processo filho
        printf(1, "Erro: Nao foi possivel rodar o programa '%s'\n", prog_name);
        exit();
      }
      wait(); // Espera o programa terminar para voltar ao menu

      printf(1, "\nPrograma finalizado. Pressione ENTER para voltar ao menu...");
      gets(buf, sizeof(buf));
    }
    else if(buf[0] == '5') {
      rodando = 0; // Sai do loop e encerra a TUI
    }
  }

  // Restaura as cores originais ao sair
  printf(1, CLS RESET);
  exit();
}

