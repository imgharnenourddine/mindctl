#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

#define MAX_AGENTS 10
#define MAX_PATH   256

// ── Structure pour un agent ───────────────────────────────
typedef struct {
    char agent[MAX_PATH];
    char parametre[MAX_PATH];
    int  pid;
    int  status;
} Agent;

// ── Construire le chemin du script ────────────────────────
void construire_chemin(char *dest, const char *agent) {
    char *home = getenv("HOME");
    if (home == NULL) home = "/root";
    snprintf(dest, MAX_PATH, "%s/mindctl/agents/%s.sh", home, agent);
}

// ── Lancer un agent via fork ──────────────────────────────
pid_t lancer_agent(const char *agent, const char *parametre) {
    char chemin[MAX_PATH];
    construire_chemin(chemin, agent);

    pid_t pid = fork();

    if (pid < 0) {
        // Erreur fork
        fprintf(stderr, "[fork_agent] Erreur : impossible de créer le processus fils pour %s\n", agent);
        return -1;

    } else if (pid == 0) {
        // Processus fils — exécuter l'agent
        printf("[fork_agent] Fils PID %d — lancement de %s\n", getpid(), agent);
        execl("/bin/bash", "bash", chemin, parametre, NULL);

        // Si execl échoue
        fprintf(stderr, "[fork_agent] Erreur : impossible de lancer %s\n", chemin);
        exit(1);

    } else {
        // Processus père — retourner le PID du fils
        printf("[fork_agent] Père PID %d — fils créé PID %d pour %s\n",
               getpid(), pid, agent);
        return pid;
    }
}

// ── Programme principal ───────────────────────────────────
int main(int argc, char *argv[]) {

    if (argc < 3) {
        fprintf(stderr, "Usage : fork_agent <agent> <parametre>\n");
        fprintf(stderr, "Exemple : fork_agent depguard ./monprojet\n");
        return 1;
    }

    // Vérifier si plusieurs agents séparés par virgule
    // Ex : fork_agent "cleaner,analyzer,insight" "./monprojet"
    char agents_str[MAX_PATH];
    strncpy(agents_str, argv[1], MAX_PATH - 1);

    char *parametre = argv[2];
    Agent agents[MAX_AGENTS];
    int nb_agents = 0;

    // Découper les agents séparés par virgule
    char *token = strtok(agents_str, ",");
    while (token != NULL && nb_agents < MAX_AGENTS) {
        strncpy(agents[nb_agents].agent, token, MAX_PATH - 1);
        strncpy(agents[nb_agents].parametre, parametre, MAX_PATH - 1);
        agents[nb_agents].pid = -1;
        agents[nb_agents].status = -1;
        nb_agents++;
        token = strtok(NULL, ",");
    }

    printf("[fork_agent] Lancement de %d agent(s) en parallèle...\n", nb_agents);

    // Lancer tous les agents en fork
    for (int i = 0; i < nb_agents; i++) {
        agents[i].pid = lancer_agent(agents[i].agent, agents[i].parametre);
        if (agents[i].pid < 0) {
            fprintf(stderr, "[fork_agent] Échec lancement : %s\n", agents[i].agent);
        }
    }

    // Attendre la fin de tous les fils
    printf("[fork_agent] Attente de la fin des processus fils...\n");

    int succes = 0;
    int echec  = 0;

    for (int i = 0; i < nb_agents; i++) {
        if (agents[i].pid > 0) {
            int wstatus;
            waitpid(agents[i].pid, &wstatus, 0);

            if (WIFEXITED(wstatus)) {
                agents[i].status = WEXITSTATUS(wstatus);
                if (agents[i].status == 0) {
                    printf("[fork_agent] ✅ %s — terminé avec succès (PID %d)\n",
                           agents[i].agent, agents[i].pid);
                    succes++;
                } else {
                    printf("[fork_agent] ❌ %s — erreur code %d (PID %d)\n",
                           agents[i].agent, agents[i].status, agents[i].pid);
                    echec++;
                }
            }
        }
    }

    printf("\n[fork_agent] ── Résumé ──\n");
    printf("[fork_agent] %d agent(s) réussi(s)\n", succes);
    printf("[fork_agent] %d agent(s) échoué(s)\n", echec);

    return (echec > 0) ? 1 : 0;
}
