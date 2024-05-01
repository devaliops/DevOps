#define _GNU_SOURCE
#include <getopt.h>
#include <locale.h>
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
  int opt = 0;
  int no_match = 1;
  char mas_e[1024] = {};
  int not_compiled = 1;
  int eflag = 0, iflag = 0, vflag = 0, cflag = 0, lflag = 0, nflag = 0,
      hflag = 0, sflag = 0, fflag = 0;
  FILE *f = NULL;
  int status = 228;
  regex_t re;
  char *line = NULL;
  char string[1024] = {};
  size_t len = 0;
  char *pattern = NULL;
  char patternf[1024] = {};
  char buffer = ' ';

  while (-1 != (opt = getopt_long(argc, argv, "e:ivclnhsf", NULL, NULL))) {
    switch (opt) {
      case 'e':
        strcat(mas_e, optarg);
        strcat(mas_e, "|");

        eflag = 0;
        eflag++;
        break;
      case 'i':
        iflag++;
        break;
      case 'v':
        vflag++;
        break;
      case 'c':
        cflag++;
        break;
      case 'l':
        lflag++;
        break;
      case 'n':
        nflag++;
        break;
      case 'f':
        fflag++;
        break;
      case 'h':
        hflag++;
        break;
      case 's':
        sflag++;
        break;
      default:
        exit(1);
        break;
    }
  }

  int yes = 0;
  int yesl = 0;
  int i = 1;
  if ((eflag || fflag)) {
    i = 0;
  }
  if (eflag) {
    mas_e[strlen(mas_e) - 1] = '\0';
    pattern = mas_e;
  }

  for (; i + optind < argc; i++) {
    if (fflag && i == 0) {
      f = fopen(argv[optind], "r");
      if (!f) {
        fprintf(stderr, "%s : %s : No such file or directory\n", argv[0],
                argv[i + optind]);
        break;
      }
    }
    if (!fflag || (fflag && i != 0)) {
      f = fopen(argv[optind + i], "r");
    }

    if (f) {
      int index = 0;
      if (!eflag && !fflag) {
        pattern = argv[optind];
      }
      if (fflag && i == 0) {
        fseek(f, 0, 0);
        while (fgets(string, 1024, f)) {
          if (string[strlen(string) - 1] == '\n' && string[0] != '\n') {
            string[strlen(string) - 1] = '\0';
          }
          strcat(patternf, string);
          strcat(patternf, "|");
        }

        patternf[strlen(patternf) - 1] = '\0';

        fclose(f);
        pattern = patternf;
        continue;
      }

      if (iflag) {
        if ((status = regcomp(&re, pattern, REG_ICASE)) != 0) {
          not_compiled = 0;
        }
      } else {
        if ((status = regcomp(&re, pattern, REG_EXTENDED)) != 0) {
          not_compiled = 0;
        }
      }
      fseek(f, 0, 0);  //считывание с файла//

      while (getline(&line, &len, f) != EOF && not_compiled) {
        if (nflag) {
          index++;
        }

        status = regexec(&re, line, 0, NULL, 0);

        if (status == 0 && lflag) {
          no_match = 0;
          yesl = 1;
          if (cflag) {
            yes++;
          }
        }
        if (lflag && vflag && status != 0) {
          yesl++;
        }
        if (!lflag) {
          if (status == 0 && !vflag) {
            no_match = 0;
            buffer = line[strlen(line) - 1];
            if (cflag) {
              yes++;
            }

            if (((!cflag && status == 0) &&
                 ((optind == argc - 1 && eflag && !cflag) ||
                  (optind + 1 == argc - 1 && !eflag && !cflag))) ||
                hflag) {
              if (nflag) {
                printf("%d:", index);
              }
              if (!cflag) {
                printf("%s", line);
              }

            } else {
              if (nflag && !cflag) {
                printf("%s:%d:%s", argv[optind + i], index, line);
              }
              if (!cflag && !nflag) {
                printf("%s:%s", argv[optind + i], line);
              }
            }
          } else {
            if (vflag && status != 0) {
              if (cflag) {
                yes++;
              }

              no_match = 0;
              if (!cflag && ((optind == argc - 1 && eflag) ||
                             (optind + 1 == argc - 1 && !eflag) || hflag)) {
                if (nflag) {
                  printf("%d:", index);
                }
                printf("%s", line);

              } else {
                if (nflag) {
                  printf("%s:%d:%s", argv[optind + i], index, line);
                }
                if (!cflag && !nflag) {
                  printf("%s:%s", argv[optind + i], line);
                }
              }
              buffer = line[strlen(line) - 1];
            }
          }
        }
      }

      if (cflag) {
        if ((optind + 1 == argc - 1 && !eflag) ||
            (optind == argc - 1 && eflag) || hflag) {
          if (lflag && yesl != 0) {
            printf("1\n");
          }
          if (lflag && yesl == 0) {
            printf("0\n");
          }
          if (!lflag) {
            printf("%d\n", yes);
          }
        } else {
          if (lflag && yesl != 0) {
            printf("%s:1\n", argv[optind + i]);
          }
          if (lflag && yesl == 0) {
            printf("%s:0\n", argv[optind + i]);
          }
          if (!lflag) {
            printf("%s:%d\n", argv[optind + i], yes);
          }
        }
      }
      if (lflag && yesl != 0) {
        printf("%s\n", argv[optind + i]);
      }

      yesl = 0;

      fclose(f);
      yes = 0;

    } else if (!sflag) {
      fprintf(stderr, "%s : %s : No such file or directory\n", argv[0],
              argv[i + optind]);
    }
    if (status != 228) {
      regfree(&re);
    }
  }

  if (buffer != '\n' && !no_match && !lflag && !cflag) {
    printf("\n");
  }
  if (line) {
    free(line);
  }

  return 0;
}
