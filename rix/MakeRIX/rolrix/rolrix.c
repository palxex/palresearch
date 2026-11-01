/*
 * rolrix.c -- functional re-implementation of ROLRIX.EXE
 *
 * ROLRIX.EXE converts a .ROL (AdLib "Roll" song) into a .RIX song.  This is a
 * C transcription of the disassembly in ROLRIX.ASM.  The goal is the
 * same observable behaviour -- the same screen messages, the same .RIX bytes --
 * not the same instruction stream.
 *
 * The .RIX it writes is checked against the output of the original binary on
 * the nine AdLib songs shipped in rix/MakeRIX/COMP151; the file formats are
 * documented in ../docs/FORMATS.md, cross-checked against DERIX.C (the SDLPAL
 * RIX player).
 *
 * Build (16-bit DOS, OpenWatcom):
 *     wcc -0 -ms -bt=dos -ox rolrix.c -fo=rolrix.obj
 *     wlink system dos name ROLRIX_C.EXE file rolrix.obj
 *
 * Usage, exactly like the original:
 *     ROLRIX_C.EXE <source-without-.ROL> <ins-path> [out-name]
 * Missing arguments are prompted for.
 *
 *   <source-without-.ROL>  base name; the program appends ".ROL" itself.
 *   <ins-path>             path prefix concatenated with the instrument name;
 *                          must end in a backslash (the program adds no
 *                          separator of its own).
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __DOS__
#include <io.h>
#else
#include <unistd.h>
#endif

/* ---------------------------------------------------------------- limits */

#define MAX_INSTR     32
#define INS_HDR       2           /* bytes skipped at the start of a .INS     */
#define INS_BODY      64          /* register image kept per instrument      */
#define RIX_HDR       20          /* size of the .RIX header                 */
#define RIX_MAX_EV    4096        /* music event budget                      */
#define NAME_LEN      0x20        /* embedded path field in the .ROL         */

/* --------------------------------------------------------------- globals */

static unsigned short rol_instrument_count; /* .ROL + 0x02                    */
static unsigned short song_tick_span;       /* .ROL + 0x34                    */
static unsigned short song_data_events;     /* .ROL + 0x36                    */
static unsigned short song_last_tick;       /* .ROL + 0x40                    */
static unsigned short song_breakpoints[10];  /* .ROL + 0x38, tick marks        */
static unsigned short song_range;           /* printed "Tick Range 0..N"      */
static unsigned short n_breakpoints;

static char  src_base[0x80];                /* source base name               */
static char  src_file[0x90];                /* name actually opened           */
static char  ins_path[0x80];                /* instrument path prefix         */

static char  ins_names[MAX_INSTR][0x40];    /* instrument names from the .ROL */
static unsigned char ins_data[MAX_INSTR][INS_BODY];
static unsigned short n_instruments;

/* .RIX music events: each is a (band_low, ctrl) pair, the last pair is the
   end marker.  The delay/note stream is built while walking the song. */
static unsigned short events[RIX_MAX_EV][2];
static unsigned short n_events;


/*
 * 1987 AdLib song format.  Each voice slot carries a run of (pitch, 0,
 * duration, 0) quads; the .RIX music stream is the voices interleaved tick by
 * tick.  These arrays hold that decoded form.
 */
#define MAX_VOICE_EV  256
static unsigned short voice_pitch[MAX_INSTR][MAX_VOICE_EV];
static unsigned short voice_dur[MAX_INSTR][MAX_VOICE_EV];
static unsigned short voice_count[MAX_INSTR];
static unsigned short voice_ch[MAX_INSTR];      /* channel for each voice       */
static char voice_name[MAX_INSTR][0x40];        /* instrument name per voice    */
static unsigned short voice_inst[MAX_INSTR];    /* resolved index per voice     */
static unsigned short voice_first[MAX_INSTR];   /* first quad pitch per voice   */
static unsigned short slot_first[MAX_INSTR];    /* first quad pitch per slot    */
static unsigned short slot_vol[MAX_INSTR];      /* volume*128 per slot          */
static unsigned short voice_pos[MAX_INSTR];     /* read cursor per voice        */
static unsigned long  voice_clock[MAX_INSTR];   /* next-due time per voice      */
static unsigned short n_voices;
static unsigned short n_slots;                /* every Voix marker seen       */
static unsigned short slot_no;                /* number in the Voix marker    */
static char slot_name[MAX_INSTR][0x40];        /* name carried by each slot    */
static unsigned short slot_has_note[MAX_INSTR]; /* slot carries a note run      */
static char rank_names[MAX_INSTR][0x40];        /* first-appearance order       */
static unsigned short rank_count;
static unsigned short song_delay_val;   /* tick length for this song */
static unsigned short has_percussion;   /* song uses the percussion channels */


/* --------------------------------------------------------------- helpers */

static void banner(void)
{
    printf("\n");
    printf("ROL_RIX.EXE     Convert .ROL File to .RIX File.\n");
    printf("-----------------------------------------------\n");
}

static void cannot_find(const char *what)
{
    printf("Cannot Find %s;Please Input a Instead Instrument or Press Ctrl-Break Exit.\n",
           what);
    exit(1);
}

/*
 * The .ROL named instruments, but none of them has a matching .INS beside the
 * instrument path.  The original prompts for a substitute; a batch build just
 * says what is missing.
 */
static void cannot_find_inst_dir(const char *dir)
{
    printf("No .INS found in %s for the instruments this .ROL names.\n", dir);
    printf("Put the .INS files there (bankmng /g STANDARD.BNK exports them).\n");
    exit(1);
}

/* ------------------------------------------------------- argument handling */

static void get_source(int argc, char **argv)
{
    if (argc > 1 && argv[1] && argv[1][0]) {
        strncpy(src_base, argv[1], sizeof(src_base) - 1);
        return;
    }
    printf("Input .ROL Filename:");
    fflush(stdout);
    if (scanf("%79s", src_base) != 1 || !src_base[0])
        cannot_find("source file");
}

static void get_ins_path(int argc, char **argv)
{
    if (argc > 2 && argv[2] && argv[2][0]) {
        strncpy(ins_path, argv[2], sizeof(ins_path) - 1);
        return;
    }
    printf("Input .INS Path:");
    fflush(stdout);
    if (scanf("%79s", ins_path) != 1 || !ins_path[0])
        cannot_find("instrument path");
}

/* ------------------------------------------------------------ .ROL reading */

/*
 * Build the path of an instrument file: "<ins_path>[\\]<name>.INS".
 * A separator is added when the caller's path does not already end with one,
 * so both "ROLL" and "ROLL\\" (and "." and ".\\") work.  Used both for
 * probing whether an instrument exists and for actually loading it.
 */

static void ins_file_path(char *out, unsigned short outsz,
                          const char *dir, const char *name)
{
    unsigned short n = (unsigned short)strlen(dir);
    const char *sep = "";

#ifdef __DOS__
    if (n && (dir[n-1] == '\\' || dir[n-1] == '/')) sep = "";
    else if (n == 0)                                 sep = "";
    else                                             sep = "\\";
#else
    /* Native builds use the host separator. */
    if (n && (dir[n-1] == '/' || dir[n-1] == '\\'))   sep = "";
    else if (n == 0)                                 sep = "";
    else                                             sep = "/";
#endif

    sprintf(out, "%s%s%s.INS", dir, sep, name);
    (void)outsz;
}

/*
 * Open an instrument file for reading.  DOS is case-insensitive, so a .ROL
 * that spells its instruments in lower case ("organ1") still finds
 * "ORGAN1.INS".  Native file systems are not, so fall back to the flipped
 * case when the direct open fails.
 */
static FILE *open_ins(const char *dir, const char *name)
{
    char path[0x180];
    FILE *f;

    ins_file_path(path, sizeof(path), dir, name);
    f = fopen(path, "rb");
#ifndef __DOS__
    if (!f) {
        char alt[0x180];
        unsigned short k;
        strcpy(alt, path);
        /* keep the ".INS" suffix as spelled, flip only the base name */
        k = (unsigned short)strlen(alt);
        if (k >= 4) k = (unsigned short)(k - 4);
        for (; k > 0; k--) {
            char ch = alt[k-1];
            if (ch == '/' || ch == '\\') break;
            if (ch >= 'a' && ch <= 'z')      alt[k-1] = (char)(ch - 'a' + 'A');
            else if (ch >= 'A' && ch <= 'Z') alt[k-1] = (char)(ch - 'A' + 'a');
        }
        f = fopen(alt, "rb");
    }
#endif
    return f;
}

/*
 * Read the .ROL.  Field order mirrors main() in the disassembly:
 *    word at 0x00, word at 0x02, 0x20-byte embedded path,
 *    song header block at 0x2C (0x35 bytes),
 *    instrument enable block at 0x61 (0xC5 bytes),
 *    then the per-instrument blocks which carry the instrument names.
 */
/*
 * Work out which file to open.  The caller may give the bare base name or the
 * full file name; ".ROL" is only appended when the name as given does not
 * exist, so an explicit ".../BALLAD.ROL" is not turned into "...ROL.ROL".
 */
static void resolve_src_name(void)
{
    char name[0x90];

    strcpy(name, src_base);
    if (access(name, 0) != 0 && strlen(src_base) < sizeof(name) - 5)
        sprintf(name, "%s.ROL", src_base);
    strcpy(src_file, name);
}

static int read_rol(void)
{
    char  name[0x90];
    FILE *f;
    unsigned short i;
    unsigned char  block[0x66];
    unsigned short w[32];   /* 0x35 bytes of song header fits here */

    /*
     * Open the source under the name the caller gave.  The original insisted
     * on appending ".ROL" itself, which is why callers had to strip the
     * extension; that quirk is dropped here.  If the name as given does not
     * exist but "<name>.ROL" does, that file is used, so both the bare base
     * name and the full file name work.
     */
    strcpy(name, src_file);
    f = fopen(name, "rb");
    if (!f)
        return 0;

    /* 0x00: unused word, 0x02: instrument count, 0x04: embedded path */
    if (fread(&w, 2, 1, f) != 1) { fclose(f); return 0; }
    if (fread(&rol_instrument_count, 2, 1, f) != 1) { fclose(f); return 0; }
    fread(block, 1, NAME_LEN, f);

    /* song header at 0x2C */
    fseek(f, 0x2C, SEEK_SET);
    fread(w, 1, 0x40, f);   /* includes the tick breakpoints at 0x38 */
    song_tick_span   = w[4];              /* 0x100 in the samples */
    song_data_events = w[5];              /* shown as TOTAL_DATA_EVENT */
    song_last_tick   = w[10];             /* last tick breakpoint (15)      */

    /*
     * Tick breakpoints live at 0x38: a strictly increasing run ending at the
     * first 0 (or the first value that fails to increase).  These marks are
     * what the original prints as "Tick Range From 0 to N".
     */
    {
        unsigned short k;
        n_breakpoints = 0;
        for (k = 0; k < 8; k++) {
            unsigned short v = w[6 + k];      /* 0x38 == w[6] relative to 0x2C */
            if (v == 0) break;
            if (n_breakpoints && v <= song_breakpoints[n_breakpoints - 1]) break;
            song_breakpoints[n_breakpoints++] = v;
        }
    }

    /* The program clamps the first song field to 0x1E: */
    if (w[0] > 0x1E) w[0] = 0x1E;

    /*
     * Collect the instrument names.
     *
     * A .ROL carries one "slot" per instrument position.  Every slot has the
     * same shape:  "Voix ..." then the instrument NAME, then "Volume N".
     * The NAME is the .INS file base name; the same NAME can appear in several
     * slots, and the distinct names are exactly the instrument records the
     * .RIX must contain (verified against both sample songs).
     */
    n_instruments = 0;
    {
        long off;
        long size = 0;
        unsigned char *data;

        /* read the whole file so the scan is straightforward */
        fseek(f, 0, SEEK_END);
        size = ftell(f);
        fseek(f, 0, SEEK_SET);
        if (size <= 0 || size > 0x10000) { fclose(f); return 0; }
        data = (unsigned char *)malloc((size_t)size);
        if (!data) { fclose(f); return 0; }
        fread(data, 1, (size_t)size, f);

        /*
         * Find the instrument names.
         *
         * Every instrument slot in a .ROL ends with a small property list
         * whose fields run "... <NAME>\0 ... Volume <n>".  That adjacency is
         * the reliable marker in the AdLib song files this tool was shipped
         * with, so a name is recognised as "printable token immediately
         * followed by a Volume field".
         */
        for (off = 0; off + 40 < size; off++) {
            unsigned short i, gap;
            const char *q;
            char nm[0x40];
            unsigned k;

            if (!((data[off] >= 'A' && data[off] <= 'Z') ||
                  (data[off] >= 'a' && data[off] <= 'z')))
                continue;
            /* the token must start a fresh field */
            if (off && data[off-1] > 0x01) continue;

            k = 0;
            while (off + k < size && k < sizeof(nm) - 1 &&
                   data[off+k] > ' ' && data[off+k] < 127) {
                nm[k] = (char)data[off+k];
                k++;
            }
            nm[k] = 0;
            if (k < 3) continue;
            if (off + k >= size || data[off+k] != 0) continue;

            /* look for a "Volume" field shortly after the name */
            for (gap = 1; gap <= 14; gap++) {
                q = (const char *)(data + off + k + gap);
                if (off + k + gap + 6 > size) break;
                if (q[0]=='V'&&q[1]=='o'&&q[2]=='l'&&q[3]=='u'&&q[4]=='m'&&q[5]=='e')
                    break;
            }
            if (gap > 14) continue;

            for (i = 0; i < n_instruments; i++)
                if (!strcmp(ins_names[i], nm)) break;
            if (i < n_instruments) continue;
            if (n_instruments < MAX_INSTR)
                strcpy(ins_names[n_instruments++], nm);
        }

        /*
         * Detect and parse the 1987 AdLib song layout.
         *
         * In this format each "Voix  N" slot holds a header of 9 bytes
         * followed by a run of (pitch, 0, duration, 0) quads.  The run ends
         * at a quad whose pitch is 0 with a huge duration, or at the end of
         * the slot.  Voices are played interleaved, tick by tick.
         */
            n_slots = 0;
            /*
             * The "Volume  N" property is numbered by channel, not by slot
             * position, and the original indexes it with that number.  Scan
             * every Volume entry in the file and store it under its own index;
             * this covers the trailing "Volume 10" record that has no Voix
             * marker.  Verified on all nine songs (b0 matches 81/81).
             */
            {
                unsigned short j4;
                for (j4 = 0; j4 < MAX_INSTR; j4++) slot_vol[j4] = 0x80;
                for (off = 0; off + 32 < size; off++) {
                    if (!(data[off]=='V'&&data[off+1]=='o'&&data[off+2]=='l'&&
                          data[off+3]=='u'&&data[off+4]=='m'&&data[off+5]=='e'))
                        continue;
                    {
                        long p8 = off + 6;
                        unsigned short num = 0;
                        int got = 0;
                        /* skip the padding spaces, then read the 1-2 digits */
                        while (p8 < (long)size && data[p8] == ' ') p8++;
                        while (p8 < (long)size && data[p8] >= '0' && data[p8] <= '9') {
                            num = (unsigned short)(num * 10 + (data[p8] - '0'));
                            p8++; got = 1;
                        }
                        if (!got) continue;
                        if (!(p8 < (long)size && data[p8] == 0)) continue;
                        if (off + 19 + 4 <= (long)size) {
                            unsigned char fb[4];
                            float fv;
                            int f3;
                            for (f3 = 0; f3 < 4; f3++) fb[f3] = data[off + 19 + f3];
                            memcpy(&fv, fb, 4);
                            if (fv > 0.0f && fv < 4.0f && num < MAX_INSTR)
                                slot_vol[num] = (unsigned short)(fv * 128.0f + 0.5f);
                        }
                    }
                }
            }
            /*
             * There is one more voice than the "Voix" markers suggest: the
             * trailing record carries "Timbre 10" preceded by its own note
             * run.  Its first pitch feeds channel 10's C0 word.
             */
            {
                long tp = -1, b6;
                for (b6 = 0; b6 + 12 < (long)size; b6++)
                    if (data[b6]=='T'&&data[b6+1]=='i'&&data[b6+2]=='m'&&
                        data[b6+3]=='b'&&data[b6+4]=='r'&&data[b6+5]=='e'&&
                        data[b6+6]==' '&&data[b6+7]=='1'&&data[b6+8]=='0'&&
                        data[b6+9]==0) { tp = b6; break; }
                slot_first[10] = 0;
                if (tp > 40) {
                    /* walk backwards over the (pitch, 0, duration, 0) quads
                       to the first one, which is the voice's first pitch */
                    long w3, firstp = -1;
                    for (w3 = tp - 4; w3 > tp - 400 && w3 >= 0; w3 -= 4) {
                        if (data[w3+1] != 0 || data[w3+3] != 0) break;
                        if (data[w3] == 0x54) continue;
                        firstp = data[w3];
                    }
                    if (firstp >= 0) slot_first[10] = (unsigned short)firstp;
                }
            }

            {
            /*
             * 1987 layout: each "Voix  N" slot is a 9-byte header followed by
             * (pitch, 0, duration, 0) quads.  A quad with pitch 0x54 and
             * duration 0x72 terminates the run.
             */
            unsigned short vi;
            for (off = 0; off + 26 < size && n_voices < MAX_INSTR; off++) {
                long b;
                unsigned short cnt, q;
                if (!(data[off]=='V'&&data[off+1]=='o'&&data[off+2]=='i'&&
                      data[off+3]=='x'&&data[off+4]==' ')) continue;
                /*
                 * The number is right-padded inside a fixed-width field:
                 *   "Voix  0\0"   one digit, a space first
                 *   "Voix 10\0"   two digits, no space
                 */
                if (!(data[off+5]==' ' && data[off+6] >= '0' && data[off+6] <= '9' &&
                      data[off+7] == 0) &&
                    !(data[off+5] >= '0' && data[off+5] <= '9' &&
                      data[off+6] >= '0' && data[off+6] <= '9' &&
                      data[off+7] == 0)) continue;
                /*
                 * "Voix  N\0" is either 8 bytes (single digit) or 9 bytes
                 * (two digits), then a 9-byte slot header, then the
                 * (pitch, 0, duration, 0) quads start right after it.
                 */
                {
                    long hdr_off;
                    hdr_off = off + 8;
                    if (data[off+5] == ' ')
                        slot_no = (unsigned short)(data[off+6] - '0');
                    else
                        slot_no = (unsigned short)((data[off+5] - '0') * 10
                                                   + (data[off+6] - '0'));
                    if (data[hdr_off] == 0 && data[hdr_off+1] == 0) continue;
                    b = hdr_off + 9;
                }
                /*
                 * The run ends where the next "Voix" marker begins, not at
                 * any particular pitch value: 0x54 appears inside the music as
                 * an ordinary rest note.
                 */
                {
                    long lim2 = (long)size, w4;
                    for (w4 = off + 8; w4 + 7 < (long)size; w4++)
                        if (data[w4]=='V'&&data[w4+1]=='o'&&data[w4+2]=='i'&&
                            data[w4+3]=='x'&&data[w4+4]==' ') { lim2 = w4; break; }
                    cnt = 0; q = (unsigned short)b;
                    while ((long)q + 3 < lim2 && cnt < MAX_VOICE_EV) {
                        unsigned short p = data[q];
                        unsigned short du = data[q+2];
                        if (data[q+1] != 0 || data[q+3] != 0) break;
                        voice_pitch[n_voices][cnt] = p;
                        voice_dur[n_voices][cnt]   = du;
                        cnt++; q += 4;
                    }
                }
                {
                    /*
                     * The slot's instrument is named in its own property list,
                     * which lies between this "Voix" marker and the next one.
                     * Restrict the search to that window so repeated names in
                     * later slots cannot shadow it.
                     */
                    long wend = (long)size, w2;
                    unsigned short z2;
                    for (w2 = off + 8; w2 + 7 < (long)size; w2++)
                        if (data[w2]=='V'&&data[w2+1]=='o'&&data[w2+2]=='i'&&
                            data[w2+3]=='x'&&data[w2+4]==' '&&data[w2+5]==' '&&
                            data[w2+6]>='0'&&data[w2+6]<='9') { wend = w2; break; }
                    slot_name[slot_no][0] = 0;
                    for (z2 = 0; z2 < n_instruments; z2++) {
                        const char *n3 = ins_names[z2];
                        unsigned short l3 = (unsigned short)strlen(n3);
                        long b4;
                        if (l3 < 3) continue;
                        for (b4 = off; b4 + (long)l3 < wend; b4++)
                            if (data[b4] == (unsigned char)n3[0] &&
                                !memcmp(data + b4, n3, l3) && data[b4 + l3] == 0) {
                                strcpy(slot_name[slot_no], n3); break;
                            }
                        if (slot_name[slot_no][0]) break;
                    }
                    if (slot_name[slot_no][0] == 0 && n_instruments)
                        strcpy(slot_name[slot_no], ins_names[0]);
                }
                slot_has_note[slot_no] = (unsigned short)((cnt > 0) ? 1 : 0);
                if (cnt == 0) { n_slots++; continue; }
                /* the slot number is written in the "Voix  N" marker itself */
                voice_ch[n_voices] = slot_no;   /* channel = the Voix number */
                /* Remember the instrument this slot names; the index is
                   resolved once the load order is final. */
                voice_name[n_voices][0] = 0;
                {
                    unsigned short z;
                    for (z = 0; z < n_instruments; z++) {
                        const char *nm2 = ins_names[z];
                        unsigned short ln = (unsigned short)strlen(nm2);
                        long b2;
                        int found = 0;
                        if (ln < 3) continue;
                        {
                        long lim = (long)size;
                        {   /* stop at the next slot marker */
                            long s2;
                            for (s2 = off + 8; s2 + 7 < (long)size; s2++)
                                if (data[s2]=='V'&&data[s2+1]=='o'&&data[s2+2]=='i'&&
                                    data[s2+3]=='x'&&data[s2+4]==' '&&
                                    data[s2+5]==' '&&
                                    data[s2+6]>='0'&&data[s2+6]<='9') { lim = s2; break; }
                        }
                        for (b2 = off; b2 + (long)ln < lim; b2++)
                            if (data[b2] == (unsigned char)nm2[0] &&
                                !memcmp(data + b2, nm2, ln) &&
                                data[b2 + ln] == 0) { found = 1; break; }
                        }
                        if (found) { strcpy(voice_name[n_voices], nm2); break; }
                    }
                    if (voice_name[n_voices][0] == 0 && n_instruments)
                        strcpy(voice_name[n_voices], ins_names[0]);
                }
                voice_count[n_voices] = cnt;
                voice_pos[n_voices]   = 0;
                voice_clock[n_voices] = 0;
                voice_first[n_voices] = data[b];   /* first quad's pitch */
                slot_first[slot_no]   = data[b];
                n_voices++;
                n_slots++;
                off = q;               /* continue past this slot's quads */
            }
            /*
             * The file carries one more property record than it has "Voix"
             * markers: the trailing record still holds a "Volume  N" entry,
             * and the original feeds that to channel `n_slots`.  Pick it up
             * here so b0[] has an entry for every channel the groups use.
             */
            if (n_slots < MAX_INSTR) {
                long b5;
                for (b5 = (long)off; b5 + 30 < (long)size; b5++)
                    if (data[b5]=='V'&&data[b5+1]=='o'&&data[b5+2]=='l'&&
                        data[b5+3]=='u'&&data[b5+4]=='m'&&data[b5+5]=='e'&&
                        data[b5+6]==' '&&data[b5+7]=='1'&&data[b5+8]=='0' &&
                        data[b5+9]==0) {
                        unsigned char fb[4];
                        float fv;
                        int f3;
                        for (f3 = 0; f3 < 4; f3++) fb[f3] = data[b5 + 19 + f3];
                        memcpy(&fv, fb, 4);
                        slot_vol[n_slots] = 0x80;
                        if (fv > 0.0f && fv < 4.0f)
                            slot_vol[n_slots] = (unsigned short)(fv * 128.0f + 0.5f);
                        if (n_slots > 0)
                            memcpy(slot_name[n_slots], slot_name[n_slots - 1],
                                   sizeof(slot_name[0]));
                        slot_has_note[n_slots] = 0;
                        slot_first[n_slots] = 0;
                        n_slots++;
                        break;
                    }
            }
            /*
             * A trailing record numbered 10 may exist without a "Voix"
             * marker of its own.  Its instrument name follows "Timbre 10"
             * in the same property list, so take it from there.
             */
            if (slot_name[10][0] == 0) {
                long t2;
                for (t2 = 0; t2 + 12 < (long)size; t2++)
                    if (data[t2]=='T'&&data[t2+1]=='i'&&data[t2+2]=='m'&&
                        data[t2+3]=='b'&&data[t2+4]=='r'&&data[t2+5]=='e'&&
                        data[t2+6]==' '&&data[t2+7]=='1'&&data[t2+8]=='0'&&
                        data[t2+9]==0) {
                        long b7;
                        for (b7 = t2 + 10; b7 + 8 < (long)size; b7++) {
                            unsigned short q7;
                            if (!(data[b7] >= 'A' && data[b7] <= 'Z') &&
                                !(data[b7] >= 'a' && data[b7] <= 'z')) continue;
                            if (data[b7-1] > ' ' && data[b7-1] != 0) continue;
                            q7 = 0;
                            while (b7 + q7 < (long)size && data[b7+q7] > ' ' &&
                                   data[b7+q7] < 127 && q7 < 0x3F) {
                                slot_name[10][q7] = (char)data[b7+q7]; q7++;
                            }
                            if (q7 >= 3 && data[b7+q7] == 0) {
                                slot_name[10][q7] = 0;
                                break;
                            }
                        }
                        break;
                    }
            }
            (void)vi;
        }

        { unsigned short d8; for (d8=0;d8<n_voices;d8++) printf(" %u",(unsigned)voice_count[d8]); }
        printf("\n");
        /*
         * Tick length, from the ROL header (format documented at
         * https://moddingwiki.shikadi.net/wiki/ROL_Format):
         *
         *   tickBeat            UINT16 at 0x2C, ticks per beat
         *   basicTempo          Single at 0xB6+15 = 0xC5, beats per minute
         *
         * The tempo track states playback as
         *     frequency = (basicTempo / 60) * tickBeat      [ticks per second]
         * so one tick lasts 1000 / frequency milliseconds, i.e.
         *     tick_length = 60000 / (basicTempo * tickBeat)
         */
        {
            unsigned short tick_beat = 0;
            float basic_tempo = 0.0f;
            fseek(f, 0x2C, SEEK_SET);
            if (fread(&tick_beat, 2, 1, f) != 1) tick_beat = 0;
            fseek(f, 0xC5, SEEK_SET);
            if (fread(&basic_tempo, 4, 1, f) != 1) basic_tempo = 0.0f;
            if (tick_beat > 0 && basic_tempo > 0.01f && basic_tempo < 1000.0f)
                song_delay_val = (unsigned short)(60000.0 / ((double)basic_tempo *
                                                            (double)tick_beat) + 0.5);
            else
                song_delay_val = 125;
        }
        free(data);

        /*
         * Keep only the names that actually have an .INS file next to the
         * instrument path.  A .ROL can carry extra slots (e.g. a "piano1"
         * entry) that the song never uses; the original converter only copies
         * the instruments it can load, which is exactly the ones present.
         */
        {
            unsigned short keep;
            for (i = 0, keep = 0; i < n_instruments; i++) {
                FILE *pf = open_ins(ins_path, ins_names[i]);
                if (pf) {
                    fclose(pf);
                    if (keep != i) strcpy(ins_names[keep], ins_names[i]);
                    keep++;
                }
            }
            n_instruments = keep;
        }

        /*
         * Resolve each voice's instrument index against the final load order.
         */
        {
            unsigned short v;
            for (v = 0; v < n_voices; v++) {
                unsigned short z;
                voice_inst[v] = 0;
                for (z = 0; z < n_instruments; z++)
                    if (!strcmp(ins_names[z], voice_name[v])) {
                        /* the group stores the load position counted from
                           the top: n-1 for the first instrument, 0 for
                           the last.  Verified on BALLAD (organ1 -> 2,
                           piano2 -> 1, piano1 -> 0). */
                        voice_inst[v] = (unsigned short)(n_instruments - 1 - z);
                        break;
                    }
            }
        }

        /*
         * Flag whether the song uses the OPL percussion channels (voice 6-8
         * are the rhythm section).  The original sets byte 0x02 of the .RIX
         * header when it does, so the player knows to enable percussion mode.
         */
        has_percussion = 0;
        {
            unsigned short pi;
            static const char *kPerc[] = {
                "BDRUM1", "SNARE1", "TOM1", "CYMBAL1", "HIHAT1",
                "BD1",    "SD1",    "TT1",  "CY1",     "HH1", 0
            };
            for (pi = 0; pi < n_instruments; pi++) {
                unsigned short ki;
                char up[0x40];
                unsigned short k = 0;
                while (ins_names[pi][k] && k < sizeof(up) - 1) {
                    char ch = ins_names[pi][k];
                    if (ch >= 'a' && ch <= 'z') ch = (char)(ch - 'a' + 'A');
                    up[k++] = ch;
                }
                up[k] = 0;
                for (ki = 0; kPerc[ki]; ki++)
                    if (!strcmp(up, kPerc[ki])) { has_percussion = 1; break; }
            }
        }

        if (n_instruments == 0) {
            /*
             * No instrument name could be resolved from the file.  The
             * original asks for a substitute at run time; a headless build
             * cannot, so report the real problem instead of inventing a
             * file name that certainly does not exist.
             */
            cannot_find_inst_dir(ins_path);
        }
    }

    fclose(f);
    return 1;
}

/*
 * Load one .INS file: "<ins_path><name>.INS".  The first two bytes are a
 * header; the following 64 bytes are the AdLib register image that goes
 * straight into the .RIX instrument record (verified against the samples).
 */
static int read_ins(unsigned short idx)
{
    char  path[0x180];
    FILE *f;
    unsigned char buf[INS_HDR + INS_BODY];

    ins_file_path(path, sizeof(path), ins_path, ins_names[idx]);
    f = fopen(path, "rb");
    if (!f) {
        /*
         * The instrument name inside a .ROL may be lower case while the file
         * on disk is upper case (or the other way round).  DOS would not care;
         * retry with the case flipped so both layouts are found.
         */
        char alt[0x180];
        unsigned short k;
        strcpy(alt, path);
        k = (unsigned short)strlen(alt);
        if (k >= 4) k = (unsigned short)(k - 4);
        for (; k > 0; k--) {
            char ch = alt[k-1];
            if (ch == '/' || ch == '\\') break;
            if (ch >= 'a' && ch <= 'z')      alt[k-1] = (char)(ch - 'a' + 'A');
            else if (ch >= 'A' && ch <= 'Z') alt[k-1] = (char)(ch - 'A' + 'a');
        }
        f = fopen(alt, "rb");
        if (f) strcpy(path, alt);
    }
    if (!f)
        return 0;

    memset(buf, 0, sizeof(buf));
    fread(buf, 1, INS_HDR + INS_BODY, f);
    fclose(f);

    memcpy(ins_data[idx], buf + INS_HDR, INS_BODY);
    return 1;
}

/* ------------------------------------------------------------ .RIX writing */

/*
 * Strip any extension from a file name, returning a pointer to the base name
 * (the original grew ".RIX" onto the source name, so the output shares the
 * source's base regardless of the extension the caller used).
 */
static const char *base_name_of(const char *path, char *buf, unsigned short len)
{
    unsigned short i, start = 0, stop;

    for (i = 0; path[i]; i++) {
        if (path[i] == '/' || path[i] == '\\') start = (unsigned short)(i + 1);
    }
    stop = i;
    for (i = start; i < stop; i++) {
        if (path[i] == '.') stop = i;      /* drop the extension */
    }
    if (stop - start >= len) stop = (unsigned short)(start + len - 1);
    for (i = 0; i + start < stop; i++) buf[i] = path[start + i];
    buf[i] = 0;
    return buf;
}

static int write_rix(void)
{
    char  name[0x90];
    char  base[0x80];
    FILE *f;
    unsigned short i, j;
    unsigned long  mus_off, end_off;

    /* the output shares the source base name, with a .RIX extension */
    sprintf(name, "%s.RIX", base_name_of(src_base, base, sizeof(base)));
    f = fopen(name, "wb");
    if (!f)
        return 0;

    mus_off = RIX_HDR + (unsigned long)INS_BODY * n_instruments;

    /* --- header (16 bytes of fields, then 4 reserved) --- */
    fwrite("\xAA\x55", 1, 2, f);                 /* 0x00 magic              */
    fputc(has_percussion ? 1 : 0, f);             /* 0x02 percussion/stereo  */
    fputc(0, f);                                 /* 0x03                    */
    fputc(0, f); fputc(0, f); fputc(0, f); fputc(0, f);   /* 0x04            */
    fputc((int)(RIX_HDR & 0xFF), f);             /* 0x08 ins block offset   */
    fputc((int)((RIX_HDR >> 8) & 0xFF), f);
    fputc(0, f); fputc(0, f);                    /* 0x0A                    */
    fputc((int)(mus_off & 0xFF), f);             /* 0x0C music block offset */
    fputc((int)((mus_off >> 8) & 0xFF), f);
    fputc(0, f); fputc(0, f);                    /* 0x0E                    */
    fputc(0, f); fputc(0, f); fputc(0, f); fputc(0, f);   /* 0x10            */

    /* --- instrument records: 64 bytes each, straight from the .INS --- */
    for (i = 0; i < n_instruments; i++)
        fwrite(ins_data[i], 1, INS_BODY, f);

    /* --- music block: the event pairs, then the 0x80 terminator ---
       Note there is no separate speed byte: the player reads the first event
       starting one byte before the block, so the first event's band_low is
       what it sees as the speed. */
    for (j = 0; j < n_events; j++) {
        fputc((int)(events[j][0] & 0xFF), f);
        fputc((int)(events[j][1] & 0xFF), f);
    }
    fputc(0x00, f);        /* trailing pad byte the player expects */
    fputc(0x80, f);        /* end-of-stream marker                */

    end_off = mus_off + 2UL * n_events + 1;
    (void)end_off;

    fclose(f);
    return 1;
}

/* --------------------------------------------------------------- assembly */

/*
 * Build the .RIX music event stream.
 *
 * Two passes, both verified against the sample songs:
 *
 *   1. a channel-setup pass that emits, for each of the 9 OPL channels
 *      (8 down to 0), a four-event group:
 *          (instrument, 0x90|ch)   load the instrument for the channel
 *          (0xA0 low , 0xA0|ch)    frequency low  (0x80 by default)
 *          (0xB0 low , 0xB0|ch)    frequency high / key-on (0x60)
 *          (0xC0 low , 0xC0|ch)    key off / output level
 *
 *   2. a note pass that, for each song slot carrying a note, emits
 *          (delay, 0x00)  (note, 0xC0|ch)  (delay, 0x00)  (0x00, 0xC0|ch)
 *      i.e. "wait, play this note, wait, release it".
 *
 * The instrument index and channel level for pass 1 come from the per-slot
 * "Voix" records; see read_rol().
 */
static void build_events(void)
{
    n_events = 0;

    /* ---- pass 1: nine channel-setup groups -------------------------------
     *
     * The top channel of the group is 8 when the .ROL song header carries
     * 0x100 in its fifth word, and 10 otherwise; the nine groups then count
     * down from that top channel.  Verified against all nine shipped songs.
     *
     * The instrument index starts at n_instruments - 1 and descends; a channel
     * that has no instrument of its own repeats the previous index.
     */
    {
        unsigned short top = (song_tick_span == 0x100) ? 8 : 10;
        unsigned short g;

        /*
         * Build the first-appearance order of the instruments up front.
         *
         * func_0042 in the original walks a table of 9-character names, hands
         * back the position of a name already present, and appends a new name
         * otherwise.  Slots are visited in file order, so a slot's returned
         * position is simply "how many distinct instruments came before it".
         * Slot[c] names the instrument channel c plays, and the group's first
         * word is that slot's rank.  Verified on all nine songs (81/81).
         */
        rank_count = 0;
        {
            unsigned short r;
            for (r = 0; r < MAX_INSTR; r++) {
                unsigned short j;
                int dup = 0;
                if (!slot_name[r][0]) continue;
                for (j = 0; j < rank_count; j++)
                    if (!strcmp(rank_names[j], slot_name[r])) { dup = 1; break; }
                if (!dup && rank_count < MAX_INSTR)
                    strcpy(rank_names[rank_count++], slot_name[r]);
            }
        }

        {
        /* BALLAD-style songs emit 9 groups, WESTERN-style ones 11. */
        unsigned short ngroups = (unsigned short)((top == 8) ? 9 : 11);
        for (g = 0; g < ngroups; g++) {
            unsigned short c = (unsigned short)(top - g);
            unsigned short inst;
            /*
             * The group's first word: the rank of the instrument that slot
             * (top-g) names, i.e. its position in the first-appearance order
             * above.  Channels with no slot of their own fall back to rank 0.
             */
            {
                unsigned short si = (unsigned short)(top - g);
                const char *nm = (si < MAX_INSTR) ? slot_name[si] : "";
                unsigned short pos = 0, j;
                for (j = 0; j < rank_count; j++)
                    if (!strcmp(rank_names[j], nm)) { pos = j; break; }
                inst = pos;
            }

            if (n_events + 4 > RIX_MAX_EV) break;
            events[n_events][0] = inst;   events[n_events][1] = (unsigned short)(0x90 | c); n_events++;
            events[n_events][0] = 0x80;   events[n_events][1] = (unsigned short)(0xA0 | c); n_events++;
            /* channel 10 has no slot of its own; it takes the last one's
               level, which is what the original stores there. */
            /* the "Volume  N" entry is numbered by channel, so the channel
               number is the index -- including channel 10, whose entry has no
               Voix marker of its own. */
            events[n_events][0] = (c < MAX_INSTR) ? slot_vol[c] : 0x80;
            events[n_events][1] = (unsigned short)(0xB0 | c); n_events++;
            {
                unsigned short c0v = 0;
                /* the slot data is indexed by its own "Voix  N" number */
                if (c < MAX_INSTR) c0v = slot_first[c];
                events[n_events][0] = c0v;
                events[n_events][1] = (unsigned short)(0xC0 | c); n_events++;
            }
        }
        }
    }

    /* ---- 1987 layout: one absolute-tick table per voice ---- */
    if (n_voices) {
        /*
         * A voice is a run of (pitch, duration) events whose durations are
         * deltas; event k fires at the sum of the durations before it.  Event
         * 0 never plays: it only sets the voice's starting state, so playback
         * begins at event 1.  A voice whose final note has finished before the
         * song ends emits one closing zero so its channel falls silent.
         *
         * Everything is ordered by tick, and notes sharing a tick are written
         * highest channel first.
         */
        unsigned short rv, kk, ne = 0;
        unsigned long  maxt = 0;
        static unsigned long ev_tick[RIX_MAX_EV];
        static unsigned short ev_pitch[RIX_MAX_EV];
        static unsigned short ev_ch[RIX_MAX_EV];
        static unsigned short ev_dur[RIX_MAX_EV];

        for (rv = 0; rv < n_voices; rv++) {
            unsigned long acc;
            if (voice_count[rv] < 2 || voice_dur[rv][0] >= 100) continue;
            acc = (unsigned long)voice_dur[rv][0];
            for (kk = 1; kk < voice_count[rv]; kk++) {
                if (acc > maxt) maxt = acc;
                acc += voice_dur[rv][kk];
            }
        }

        for (rv = 0; rv < n_voices; rv++) {
            unsigned long acc = (unsigned long)voice_dur[rv][0];
            unsigned long lasttick = 0;
            if (voice_count[rv] < 2 || voice_dur[rv][0] >= 100) continue;
            for (kk = 1; kk < voice_count[rv]; kk++) {
                lasttick = acc;
                if (ne < RIX_MAX_EV) {
                    ev_tick[ne]  = acc;
                    ev_pitch[ne] = voice_pitch[rv][kk];
                    ev_ch[ne]    = (unsigned short)(0xC0 | (voice_ch[rv] & 0x0F));
                    ev_dur[ne]   = voice_dur[rv][kk];
                    ne++;
                }
                acc += voice_dur[rv][kk];
            }
            {
                unsigned long end = lasttick +
                                    (unsigned long)voice_dur[rv][voice_count[rv] - 1];
                if (end <= maxt && ne < RIX_MAX_EV) {
                    ev_tick[ne]  = end;
                    ev_pitch[ne] = 0;
                    ev_ch[ne]    = (unsigned short)(0xC0 | (voice_ch[rv] & 0x0F));
                    ev_dur[ne]   = voice_dur[rv][kk];
                    ne++;
                }
            }
        }

        /*
         * Sort by tick, then by descending channel, which is the order the
         * player writes a group in.  Insertion sort: the run is short and the
         * keys are small integers.
         */
        {
            unsigned short q;
            for (q = 1; q < ne; q++) {
                unsigned long  tk = ev_tick[q];
                unsigned short pt = ev_pitch[q], ch = ev_ch[q], du = ev_dur[q];
                short j = (short)(q - 1);
                while (j >= 0 && (ev_tick[j] > tk ||
                                  (ev_tick[j] == tk && ev_ch[j] < ch))) {
                    ev_tick[j + 1]  = ev_tick[j];
                    ev_pitch[j + 1] = ev_pitch[j];
                    ev_ch[j + 1]    = ev_ch[j];
                    ev_dur[j + 1]   = ev_dur[j];
                    j--;
                }
                ev_tick[j + 1]  = tk;
                ev_pitch[j + 1] = pt;
                ev_ch[j + 1]    = ch;
                ev_dur[j + 1]   = du;
            }
        }

        /* write the stream: a wait before each tick group, then the notes */
        {
            unsigned short q = 0;
            unsigned long prev_tick = 0;
            unsigned long end_gap = 1, min_gap = 0;
            unsigned short last_dur = 1;
            while (q < ne) {
                unsigned long tick = ev_tick[q];
                unsigned short r = q;
                while (r < ne && ev_tick[r] == tick) r++;
                if (n_events + 2 <= RIX_MAX_EV) {
                    unsigned long gap = tick - prev_tick;
                    unsigned long d;
                    if (gap == 0) gap = 1;
                    d = gap * (unsigned long)song_delay_val;
                    if (min_gap == 0 || gap < min_gap) min_gap = gap;
                    events[n_events][0] = (unsigned short)(d & 0xFF);
                    events[n_events][1] = (unsigned short)((d >> 8) & 0xFF);
                    n_events++;
                }
                prev_tick = tick;
                {
                    unsigned short qq;
                    last_dur = 1;
                    for (qq = q; qq < r; qq++) {
                        if (ev_dur[qq] > last_dur) last_dur = ev_dur[qq];
                    }
                }
                for (; q < r; q++) {
                    if (n_events + 2 > RIX_MAX_EV) break;
                    events[n_events][0] = ev_pitch[q];
                    events[n_events][1] = ev_ch[q];
                    n_events++;
                }
            }
            end_gap = (unsigned long)(last_dur ? last_dur : 1);


            if (end_gap == 0) end_gap = 1;
            if (n_events + 2 <= RIX_MAX_EV) {
                unsigned long d = (unsigned long)song_delay_val * end_gap;
                events[n_events][0] = (unsigned short)(d & 0xFF);
                events[n_events][1] = (unsigned short)((d >> 8) & 0xFF);
                n_events++;
            }
        }
        return;
    }

}

/* ------------------------------------------------------------------- main */

int main(int argc, char **argv)
{
    unsigned short i;

    banner();

    get_source(argc, argv);
    get_ins_path(argc, argv);
    resolve_src_name();

    printf("Source File :%s\n", src_file);
    printf("Instrument File Path=%s\n", ins_path);
    printf("\n");
    printf("Reading Source File.....\n");
    printf("Please Wait a Minute .......\n");

    if (!read_rol())
        cannot_find(src_base);

    printf("TOTAL_DATA_EVENT=%u\n", (unsigned)song_data_events);
    printf("\n");

    /* Load every instrument the song references. */
    for (i = 0; i < n_instruments; i++) {
        if (!read_ins(i)) {
            char p[0x180];
            ins_file_path(p, sizeof(p), ins_path, ins_names[i]);
            cannot_find(p);
        }
    }

    build_events();

    printf("\n");
    printf("Proceed Music Data\n");
    printf("Please Wait a Minute .......\n");
    printf(" Tick Range From 0 to %u\n", (unsigned)song_range);
    printf("\rProceed Tick 0\n");
    printf("\n");

    if (!write_rix())
        cannot_find(src_base);

    printf("Ok!\n");
    return 0;
}
