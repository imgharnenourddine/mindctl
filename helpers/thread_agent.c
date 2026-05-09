#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#define MAX_AGENTS  50
#define MAX_PATH    256

// ── Structure passée à chaque thread ─────────────────────
typedef struct {
    char   agent[MAX_PATH];
    char   parametre[MAX_PATH];
    int    index;
    int    resultat;
} TacheAgent;

// ── Mutex pour protéger les affichages ───────────────────
pthread_mutex_t mutex_affichage = PTHREAD_MUTEX_INITIALIZER;

// ── Construire le chemin du script ────────────────────────
void construire_chemin(char *dest, const char *agent) {
    char *home = getenv("HOME");
    if (home == NULL) home = "/root";
    snprintf(dest, MAX_PATH, "%s/mindctl/agents/%s.sh", home, agent);
}

// ── Fonction exécutée par chaque thread ──────────────────
void *executer_agent(void *arg) {
    TacheAgent *tache = (TacheAgent *)arg;

    char chemin[MAX_PATH];
    construire_chemin(chemin, tache->agent);

    // Construire la commande
    char commande[MAX_PATH * 3];
    snprintf(commande, sizeof(commande),
             "bash %s %s", chemin, tache->parametre);

    // Affichage protégé par mutex
    pthread_mutex_lock(&mutex_affichage);
    printf("[thread_agent] Thread %d — lancement de %s\n",
           tache->index, tache->agent);
    pthread_mutex_unlock(&mutex_affichage);

    // Exécuter l'agent
    int ret = system(commande);
    tache->resultat = WEXITSTATUS(ret);

    // Affichage du résultat protégé par mutex
    pthread_mutex_lock(&mutex_affichage);
    if (tache->resultat == 0) {
        printf("[thread_agent] ✅ Thread %d — %s terminé avec succès\n",
               tache->index, tache->agent);
    } else {
        printf("[thread_agent] ❌ Thread %d — %s erreur code %d\n",
               tache->index, tache->agent, tache->resultat);
    }
    pthread_mutex_unlock(&mutex_affichage);

    return NULL;
}

// ── Programme principal ───────────────────────────────────
int main(int argc, char *argv[]) {

    if (argc < 3) {
        fprintf(stderr, "Usage : thread_agent <agent(s)> <parametre>\n");
        fprintf(stderr, "Exemple : thread_agent cleaner,analyzer,insight ./monprojet\n");
        return 1;
    }

    char agents_str[MAX_PATH];
    strncpy(agents_str, argv[1], MAX_PATH - 1);
    char *parametre = argv[2];

    TacheAgent taches[MAX_AGENTS];
    pthread_t  threads[MAX_AGENTS];
    int nb_agents = 0;

    // Découper les agents séparés par virgule
    char *token = strtok(agents_str, ",");
    while (token != NULL && nb_agents < MAX_AGENTS) {
        strncpy(taches[nb_agents].agent, token, MAX_PATH - 1);
        strncpy(taches[nb_agents].parametre, parametre, MAX_PATH - 1);
        taches[nb_agents].index    = nb_agents;
        taches[nb_agents].resultat = -1;
        nb_agents++;
        token = strtok(NULL, ",");
    }

    printf("[thread_agent] Lancement de %d thread(s) en parallèle...\n", nb_agents);

    // Créer tous les threads
    for (int i = 0; i < nb_agents; i++) {
        int ret = pthread_create(&threads[i], NULL,
                                 executer_agent, &taches[i]);
        if (ret != 0) {
            fprintf(stderr, "[thread_agent] Erreur création thread %d\n", i);
        }
    }

    // Attendre la fin de tous les threads
    printf("[thread_agent] Attente de la fin des threads...\n");

    int succes = 0;
    int echec  = 0;

    for (int i = 0; i < nb_agents; i++) {
        pthread_join(threads[i], NULL);
        if (taches[i].resultat == 0) succes++;
        else echec++;
    }

    // Détruire le mutex
    pthread_mutex_destroy(&mutex_affichage);

    printf("\n[thread_agent] ── Résumé ──\n");
    printf("[thread_agent] %d thread(s) réussi(s)\n", succes);
    printf("[thread_agent] %d thread(s) échoué(s)\n", echec);

    return (echec > 0) ? 1 : 0;
}
