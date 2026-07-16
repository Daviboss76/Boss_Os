// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

// Agora o programa padrão que o init vai abrir é a nossa TUI!
char *argv[] = { "tui", 0 };

int
main(void)
{
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  dup(0);  // stderr

  // ==========================================
  // 1. O NOSSO BLUE BOOT SPLASH
  // ==========================================
  // Define fundo azul, texto branco brilhante, limpa a tela e vai pro topo
  write(1, "\033[44m\033[37;1m\033[2J\033[H", 16);
  
  // Posiciona o cursor no centro e escreve o nome do sistema
  write(1, "\033[12;33H", 8);
  write(1, "B O S S - O S", 13);
  
  // Desenha uma linha decorativa embaixo
  write(1, "\033[13;31H", 8);
  write(1, "=================", 17);

  // Espera 2 segundos para o usuário ver o Boot Splash
  sleep(200); 

  // Restaura as cores padrão e limpa a tela para a TUI entrar limpa
  write(1, "\033[0m\033[2J\033[H", 11);
  // ==========================================

  // 2. LOOP INFINITO DE INICIALIZAÇÃO
  for(;;){
    printf(1, "BOSS-OS: Iniciando a Interface Grafica...\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
      // Executa a TUI diretamente!
      exec("tui", argv);
      printf(1, "init: falha ao iniciar a interface TUI\n");
      exit();
    }
    // Espera a TUI fechar. Se ela fechar (Opção 5), o loop reinicia ela.
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  }
}

