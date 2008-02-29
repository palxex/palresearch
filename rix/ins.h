/*  Operator  structure  */ 
typedef  struct  { 
      int    ksl; 
      int    freqMult; 
      int    feedBack;                            /*  used  by  operator  0  only  */ 
      int    attack; 
      int    sustLevel; 
      int    sustain; 
      int    decay; 
      int    release; 
      int    output; 
      int    am; 
      int    vib; 
      int    ksr; 
      int    fm;                                        /*  used  by  operator  0  only  */ 
}  Operator; 
 
 
/*  Timbre  structure  (old  .INS  file  structure)  */ 
typedef  struct  { 
      char            mode;                          /*  0=melodic,  1=percussive  */ 
      char            percVoice;                /*  if  mode=1,  voice  number  to  be  used  */ 
      Operator    op0; 
      Operator    op1; 
      int              wave0;                        /*  waveform  for  operator  0  */ 
      int              wave1;                        /*  waveform  for  operator  1  */ 
}  Timbre; 
