#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <termios.h>

volatile sig_atomic_t stop = 0;

struct termios oldt;

void restore_terminal() {
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
}

void handle_sigint(int sig) {
    stop = 1;
}

int main() {
    signal(SIGINT, handle_sigint);

    // Get current terminal settings
    tcgetattr(STDIN_FILENO, &oldt);

    // Copy settings and disable ^C echo
    struct termios newt = oldt;
    newt.c_lflag &= ~ECHOCTL;

    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

    // Restore terminal when program exits
    atexit(restore_terminal);

    while (!stop) {
        printf("Running...\n");
        sleep(1);
    }

    printf("Closing program...\n");

    return 0;
}