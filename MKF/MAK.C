#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <sys/utime.h>
#define MAXSUB 500

extern int _days[];
time_t __cdecl __loctotime_t (int yr,int mo,int dy,int hr,int mn,int sc,int dstflag )
{
        int tmpdays;
        long tmptim;
		int timezone;

        if ( ((long)(yr -= 1900) < 70L) || ((long)yr > 138L) )
                return (time_t)(-1);

        tmpdays = dy + _days[mo - 1];
        if ( !(yr & 3) && (mo > 2) )
                tmpdays++;
		
		/*俺们是东八区滴*/
		timezone=-8;

        tmptim = /* 365 days for each year */
                 (((long)yr - 70L) * 365L
                 /* one day for each elapsed leap year */
                 + (long)((yr - 1) >> 2) - 17L
                 /* number of elapsed days in yr */
                 + tmpdays)
                 /* convert to hours and add in hr */
                 * 24L + hr + timezone;

        tmptim = /* convert to minutes and add in mn */
                 (tmptim * 60L + mn)
                 /* convert to seconds and add in sec */
                 * 60L + sc;

        return(tmptim);
}

void usage()
{
	printf("Usage:mak sam*.ext"); 
}
main(int c,char* v[])
{
	int i,im;
	char name[12];char a[5];char mkf[12];char ext[5];
	FILE* fpsrc;FILE* fpdst;
	char* pre;
	void* buf;long t,loc=0,loct;
	struct _utimbuf utb;
	if(c!=2) {usage();exit(1);}
	pre=strrchr(v[1],'.');
	strcat(ext,pre);
	pre=strrchr(v[1],'*');	*pre='\0';
	pre=v[1];
	for(i=0;i<MAXSUB;i++)
	{
		strcpy(name,pre);
		strcat(name,(const char*)itoa(i,a,10));
		strcat(name,ext);
		if((fpsrc=fopen(name,"rb"))==NULL)
		{
			//fclose(fpsrc);
			break;
		}
		fclose(fpsrc);
	}
	im=i;
	strcpy(mkf,pre);
	strcat(mkf,".mkf");
	fpdst=fopen(mkf,"wb+");
	for(i=0;i<im;i++)
	{
		strcpy(name,pre);
		strcat(name,(const char*)itoa(i,a,10));
		strcat(name,ext);
		if((fpsrc=fopen(name,"rb"))==NULL) {printf("Open Error %s",name);exit(0);}
		fseek(fpsrc,0,SEEK_END);
		loct=ftell(fpsrc);
		t=im*4+loc;
		loc=loc+loct;
		fclose(fpsrc);
		fseek(fpdst,4*i,SEEK_SET);
		fwrite(&t,4,1,fpdst);
	}
	loc=0;
	for(i=0;i<im-1;i++)
	{
        strcpy(name,pre);
		strcat(name,(const char*)itoa(i,a,10));
		strcat(name,ext);
		if((fpsrc=fopen(name,"rb"))==NULL) {printf("Open Error %s",name);exit(-1);}
		fseek(fpsrc,0,SEEK_END);
		loct=ftell(fpsrc);
		fseek(fpsrc,0,SEEK_SET);
		buf=(void*)malloc(loct);
		fread(buf,loct,1,fpsrc);
		t=im*4+loc;
		loc+=loct;
		fclose(fpsrc);
		fseek(fpdst,t,SEEK_SET);
		fwrite(buf,loct,1,fpdst);
		free(buf);
	}
	fclose(fpdst);

	utb.actime=utb.modtime=__loctotime_t(1995,12,20,0,0,0,0);
	_utime(mkf,&utb);
}
