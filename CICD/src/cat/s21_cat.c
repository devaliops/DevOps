#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct options {
  int b;
  int e;
  int n;
  int s;
  int t;
  int v;
} opts;

void parser(int argc, char *argv[], opts *options) {
  int opt;
  int option_index;
  static struct option long_options[] = {{"number-nonblank", 0, 0, 'b'},
                                         {"number", 0, 0, 'n'},
                                         {"squeeze-blank", 0, 0, 's'},
                                         {0, 0, 0, 0}};
  while ((opt = getopt_long(argc, argv, "+benstvTE", long_options,
                            &option_index)) != -1) {
    switch (opt) {
      case 'b':
        options->b = 1;
        break;
      case 'e':
        options->e = 1;
        options->v = 1;
        break;
      case 't':
        options->t = 1;
        options->v = 1;
        break;
      case 'n':
        options->n = 1;
        break;
      case 's':
        options->s = 1;
        break;
      case 'v':
        options->v = 1;
        break;
      case 'T':
        options->b = 1;
        break;
      case 'E':
        options->b = 1;
        break;
      default:
        printf("%d", opt);
    }
  }
}

void reader(char *argv[], opts *options) {
  while (argv[optind]) {
    FILE *f = fopen(argv[optind], "r");
    if (f) {
      int cur;
      int str_count = 0;
      int empty_count = 1;
      int counter = 0;
      int ecount = 0;
      int *Ecount = &ecount;
      char arr[4096];
      int i = 0;
      int Scount = 0;
      while ((arr[i] = fgetc(f)) != EOF) {
        cur = arr[i];
        if (arr[i] == '\n') {
          empty_count++;
        } else
          empty_count = 0;
        if ((options->b == 0) && (options->t == 0) && (options->s == 0) &&
            (options->e == 0) && (options->v == 0) && (options->n == 0)) {
          if (arr[i] == '\n') {
            arr[i] = '\0';
            printf("%s\n", arr);
            i = 0;
          } else
            i++;
        } else {
          if (options->b == 1) {
            if (counter == 0) {
              if (empty_count == 0) {
                printf("%6d\t", ++str_count);
              }
              counter = 1;
            }
          }
          if (options->n == 1) {
            if (counter == 0) {
              if ((empty_count >= 3) && ((options->s))) {
                Scount++;
                if (Scount != 2) {
                  ++str_count;
                  printf("%6d\t", str_count);
                }
              } else {
                printf("%6d\t", ++str_count);
              }
              counter = 1;
            }
          }
          if (options->s == 1) {
            if ((arr[i] == '\n') && (empty_count >= 3)) {
              if (options->b == 1) {
                printf("%6d\t", ++str_count);
              }
              while (arr[i] == '\n') {
                arr[i] = fgetc(f);
              }
            }
            counter = 1;
          }
          if (options->v == 1) {
            counter = 1;
            *Ecount = 1;
            if (((cur >= 0) && (cur < 32)) && ((cur != 10) && (cur != 9))) {
              arr[i] = '^';
              i++;
              if (arr[i - 1] == '^') {
                arr[i] = cur + 64;
              }
            }
            if (cur == 127) {
              arr[i] = '^';
              i++;
              if (arr[i - 1] == '^') {
                arr[i] = cur - 64;
              }
            }
            if (((cur >= -128) && (cur < 0))) {
              arr[i] = 'M';
              i++;
              arr[i] = '-';
              i++;
              arr[i] = '^';
              i++;
              if (arr[i - 1] == '^') {
                arr[i] = cur + 192;
              }
              if ((cur >= -96) && (cur < 0)) {
                i--;
                if (arr[i - 1] == '-') {
                  arr[i] = cur + 128;
                }
              }
              if (cur == -1) {
                arr[i] = '^';
                i++;
                if (arr[i - 1] == '^') {
                  arr[i] = cur + 129;
                }
              }
            }
          }
          if (options->e == 1) {
            counter = 1;
            if (arr[i] == '\n') {
              arr[i] = '$';
              i++;
              arr[i] = '\n';
            }
          }
          if (options->t == 1) {
            counter = 1;
            if (arr[i] == '\t') {
              arr[i] = '^';
              i++;
              arr[i] = 'I';
            }
          }
          if (counter == 1) {
            if (arr[i] == '\n') {
              arr[i] = '\0';
              printf("%s\n", arr);
              i = 0;
              counter = 0;
            } else
              i++;
          }
        }
      }
      if ((empty_count >= 3) && (options->s)) {
      } else {
        arr[i] = '\0';
        printf("%s", arr);
      }
    } else {
      fprintf(stderr, "No such file or directory\n");
    }

    optind++;
  }
}

int main(int argc, char *argv[]) {
  opts options = {0};
  parser(argc, argv, &options);
  reader(argv, &options);

  return 0;
}
