#define _CRT_SECURE_NO_WARNINGS
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INPOUT32_DYN_IMPLEMENTATION
#include "inpout32_dyn.h"

typedef struct RwImage {
    unsigned short base_port;
    unsigned char values[256];
    unsigned char present[256];
} RwImage;

static int parse_u8(const char *text, int *out)
{
    char *end = NULL;
    long v;

    if (text == NULL || out == NULL) return 0;
    v = strtol(text, &end, 0);
    if (end == text || *end != '\0') return 0;
    if (v < 0 || v > 255) return 0;
    *out = (int)v;
    return 1;
}

static int parse_rw_file(const char *path, RwImage *out)
{
    FILE *fp = NULL;
    long size;
    char *buf = NULL;
    char *start_tag;
    char *p;

    if (path == NULL || out == NULL) return 0;
    memset(out, 0, sizeof(*out));

    fp = fopen(path, "rb");
    if (fp == NULL)
    {
        fprintf(stderr, "Cannot open file: %s\n", path);
        return 0;
    }

    if (fseek(fp, 0, SEEK_END) != 0)
    {
        fclose(fp);
        fprintf(stderr, "Seek failed: %s\n", path);
        return 0;
    }
    size = ftell(fp);
    if (size < 0)
    {
        fclose(fp);
        fprintf(stderr, "Tell failed: %s\n", path);
        return 0;
    }
    if (fseek(fp, 0, SEEK_SET) != 0)
    {
        fclose(fp);
        fprintf(stderr, "Seek failed: %s\n", path);
        return 0;
    }

    buf = (char *)malloc((size_t)size + 1);
    if (buf == NULL)
    {
        fclose(fp);
        fprintf(stderr, "Out of memory.\n");
        return 0;
    }

    if (fread(buf, 1, (size_t)size, fp) != (size_t)size)
    {
        free(buf);
        fclose(fp);
        fprintf(stderr, "Read failed: %s\n", path);
        return 0;
    }
    buf[size] = '\0';
    fclose(fp);

    start_tag = strstr(buf, "Start");
    if (start_tag == NULL)
    {
        free(buf);
        fprintf(stderr, "Missing Start field in rw file.\n");
        return 0;
    }

    p = start_tag + 5;
    while (*p != '\0' && isspace((unsigned char)*p)) ++p;
    if (!isxdigit((unsigned char)p[0]))
    {
        free(buf);
        fprintf(stderr, "Invalid Start field in rw file.\n");
        return 0;
    }

    {
        char *end = NULL;
        unsigned long base = strtoul(p, &end, 16);
        if (end == p || base > 0xFFFFUL)
        {
            free(buf);
            fprintf(stderr, "Invalid base port in Start field.\n");
            return 0;
        }
        out->base_port = (unsigned short)base;
    }

    p = buf;
    while (*p != '\0')
    {
        unsigned int off, val;
        int n;

        if (!isxdigit((unsigned char)p[0]) || !isxdigit((unsigned char)p[1]) || p[2] != '=')
        {
            ++p;
            continue;
        }

        n = sscanf(p, "%2X=%2X", &off, &val);
        if (n == 2 && off <= 0xFFU && val <= 0xFFU)
        {
            out->values[off] = (unsigned char)val;
            out->present[off] = 1;
            p += 5;
            continue;
        }
        ++p;
    }

    free(buf);
    return 1;
}

static const char *inpout_err_name(int code)
{
    switch (code)
    {
    case INPOUT32_DYN_OK: return "OK";
    case INPOUT32_DYN_ERR_DLL_NOT_FOUND: return "DLL_NOT_FOUND";
    case INPOUT32_DYN_ERR_PROC_MISSING: return "PROC_MISSING";
    case INPOUT32_DYN_ERR_DRIVER_NOT_LOADED: return "DRIVER_NOT_LOADED";
    case INPOUT32_DYN_ERR_WRITE_FAILED: return "WRITE_FAILED";
    case INPOUT32_DYN_ERR_READ_FAILED: return "READ_FAILED";
    default: return "UNKNOWN";
    }
}

int main(int argc, char **argv)
{
    RwImage img;
    int start_off;
    int end_off;
    int sleep_ms;
    int pass;
    int i;
    int wrote = 0;

    if (argc != 5)
    {
        fprintf(stderr, "Usage: %s <rw_file> <start_offset 0-255> <end_offset 0-255> <sleep_ms>\n", argv[0]);
        return 1;
    }

    if (!parse_u8(argv[2], &start_off) || !parse_u8(argv[3], &end_off))
    {
        fprintf(stderr, "Offsets must be integers in [0,255].\n");
        return 1;
    }

    {
        char *end = NULL;
        long v = strtol(argv[4], &end, 0);
        if (end == argv[4] || *end != '\0' || v < 0)
        {
            fprintf(stderr, "sleep_ms must be a non-negative integer.\n");
            return 1;
        }
        sleep_ms = (int)v;
    }
    if (start_off > end_off)
    {
        fprintf(stderr, "start_offset must be <= end_offset.\n");
        return 1;
    }

    if (!parse_rw_file(argv[1], &img))
        return 1;

    for (pass = 0; pass < 2; ++pass)
    {
        if (pass == 1)
        {
            printf("Sleeping %d ms...\n", sleep_ms);
            Sleep((DWORD)sleep_ms);
        }
        printf("Pass %d:\n", pass + 1);
        for (i = start_off; i <= end_off; ++i)
        {
            short port;
            short value;

            if (!img.present[i])
            {
                fprintf(stderr, "Missing value for offset %02X in rw file.\n", i);
                return 2;
            }

            port = (short)(img.base_port + (unsigned short)i);
            value = (short)img.values[i];

            if (!inpout32_dyn_write_port(port, value))
            {
                int err = inpout32_dyn_get_last_error();
                fprintf(stderr, "Write failed at port %04X (offset %02X), err=%d (%s).\n",
                    (unsigned int)((unsigned short)port), i, err, inpout_err_name(err));
                return 3;
            }

            printf("OUT %04X <- %02X\n", (unsigned int)((unsigned short)port), img.values[i]);
            ++wrote;
        }
    }

    printf("Done. base=%04X wrote=%d offsets=%02X..%02X\n",
        img.base_port, wrote, start_off, end_off);
    return 0;
}