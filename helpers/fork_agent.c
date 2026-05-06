#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#define MAX_TABLES 128

int main(int argc, char *argv[]) {
    if (argc < 4) {
        printf("usage: %s agent ctx tables...\n", argv[0]);
        return 1;
    }

    char *agent = argv[1];
    char *ctx   = argv[2];
    int nb      = argc - 3;

    if (nb > MAX_TABLES) {
        fprintf(stderr, "[fork_agent] Trop de tables (max %d)\n", MAX_TABLES);
        return 1;
    }

    pid_t pids[MAX_TABLES];

    /* Etape 1 : fork() tous les fils sans attendre */
    for (int i = 0; i < nb; i++) {
        pids[i] = fork();

        if (pids[i] < 0) {
            perror("fork");
            return 1;
        }

        if (pids[i] == 0) {
            /* Fils : executer le script et quitter */
            execlp("bash", "bash", agent, argv[i + 3], ctx, NULL);
            exit(1);
        }
    }

    /* Etape 2 : attendre tous les fils APRES les avoir tous lances */
    int ok = 0, fail = 0;
    for (int i = 0; i < nb; i++) {
        int st;
        waitpid(pids[i], &st, 0);
        if (WIFEXITED(st) && WEXITSTATUS(st) == 0)
            ok++;
        else
            fail++;
    }

    printf("RESULT: %d OK / %d FAIL\n", ok, fail);
    return (fail > 0) ? 1 : 0;
}
