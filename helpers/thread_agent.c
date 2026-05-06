#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>

#define MAX_TABLES 128

typedef struct {
    char agent[256];
    char table[256];
    char ctx[256];
    int  result;
} Task;

/* Mutex pour proteger les ecritures dans les logs */
static pthread_mutex_t log_mutex = PTHREAD_MUTEX_INITIALIZER;

void *run(void *arg) {
    Task *t = (Task *)arg;
    char cmd[768];

    snprintf(cmd, sizeof(cmd), "bash %s %s %s", t->agent, t->table, t->ctx);

    pthread_mutex_lock(&log_mutex);
    printf("[thread_agent] lancement table: %s\n", t->table);
    pthread_mutex_unlock(&log_mutex);

    /* system() est thread-safe, pas besoin de fork() ici */
    int ret = system(cmd);
    t->result = (ret == 0) ? 0 : 1;

    pthread_mutex_lock(&log_mutex);
    if (t->result == 0)
        printf("[thread_agent] OK: %s\n", t->table);
    else
        fprintf(stderr, "[thread_agent] FAIL: %s\n", t->table);
    pthread_mutex_unlock(&log_mutex);

    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc < 4) {
        printf("usage: %s agent ctx tables...\n", argv[0]);
        return 1;
    }

    char *agent = argv[1];
    char *ctx   = argv[2];
    int n       = argc - 3;

    if (n > MAX_TABLES) {
        fprintf(stderr, "[thread_agent] Trop de tables (max %d)\n", MAX_TABLES);
        return 1;
    }

    pthread_t th[MAX_TABLES];
    Task      t[MAX_TABLES];

    for (int i = 0; i < n; i++) {
        strcpy(t[i].agent, agent);
        strcpy(t[i].ctx,   ctx);
        strcpy(t[i].table, argv[i + 3]);
        t[i].result = 1;

        pthread_create(&th[i], NULL, run, &t[i]);
    }

    for (int i = 0; i < n; i++)
        pthread_join(th[i], NULL);

    int ok = 0, fail = 0;
    for (int i = 0; i < n; i++)
        t[i].result ? fail++ : ok++;

    printf("RESULT: %d OK / %d FAIL\n", ok, fail);

    pthread_mutex_destroy(&log_mutex);
    return (fail > 0) ? 1 : 0;
}
