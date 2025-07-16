#include "FFIrandom.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

/*
    Copied this code off StackOverflow since it should roughly output values
    between [DBL_MIN..DBL_MAX] with equal possibilities.
*/

static char buf[100];

double randDouble()
{
    srand((unsigned) time(NULL));
    union {
        double d;
        unsigned char uc[sizeof(double)];
    } u;
    do {
        for (unsigned i = 0; i < sizeof u.uc; i++)
        {
            u.uc[i] = (unsigned char)rand();
        }
    } while (!isfinite(u.d));
    return u.d;
}

/*
    Generalized the code above to avoid being stuck outputting between
    [0..RAND_MAX].
*/
int randInt()
{
    srand((unsigned) time(NULL));
    union {
        int v;
        unsigned char uc[sizeof(int)];
    } u;
    for (unsigned i = 0; i < sizeof(u.uc); i++)
        u.uc[i] = (unsigned char) rand();
    return u.v;
}
float randFloat() {
    srand((unsigned) time(NULL));
    union {
        float f;
        unsigned char uc[sizeof(float)];
    } u;
    do {
        for (unsigned i = 0; i < sizeof(u.uc); i++)
            u.uc[i] = (unsigned char) rand();
    } while (!isfinite(u.f));
    return u.f;
}

char* xorCipher(char* str, int key) {
    // We can probably use C's lack of type enforcement to treat `key` like a byte array here.
    char* keyBytes = (char*) &key;
    size_t len = strlen(str);
    // Handle the last few bytes separately if our input length isn't divisible by 4.
    int diff = len % 4;
    int firstlen = len - diff;
    for (int i = 0; i < firstlen; i += 4) {
        int j = i + 1;
        int k = i + 2;
        int l = i + 3;
        buf[i] = str[i] ^ keyBytes[3];
        buf[j] = str[j] ^ keyBytes[2];
        buf[k] = str[k] ^ keyBytes[1];
        buf[l] = str[l] ^ keyBytes[0];
    }
    if (diff) {
        for (int i = 0; i < diff; i++) {
            buf[firstlen + i] = str[firstlen + i] ^ keyBytes[diff - i];
        }
    }
    buf[len] = '\0';
    return buf;
}