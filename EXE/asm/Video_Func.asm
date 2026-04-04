seg012:00C2 ; =============== S U B R O U T I N E =======================================
seg012:00C2
seg012:00C2 ; Attributes: bp-based frame
seg012:00C2
seg012:00C2 proc            Video_Func far          ; CODE XREF: real_entry+AF4↑P
seg012:00C2                                         ; release_resources_exit+ED↑P
seg012:00C2
seg012:00C2 arg_0           = dword ptr  6
seg012:00C2
seg012:00C2                 push    bp
seg012:00C3
seg012:00C3 loc_286A3:
seg012:00C3                 mov     bp, sp
seg012:00C5                 push    ds
seg012:00C6
seg012:00C6 loc_286A6:
seg012:00C6                 push    si
seg012:00C7
seg012:00C7 loc_286A7:
seg012:00C7                 lds     si, [bp+arg_0]
seg012:00CA
seg012:00CA loc_286AA:
seg012:00CA                 lodsw
seg012:00CB
seg012:00CB loc_286AB:                              ; - VIDEO -
seg012:00CB                 int     10h
seg012:00CD                 pop     si
seg012:00CE
seg012:00CE loc_286AE:
seg012:00CE                 pop     ds
seg012:00CF                 pop     bp
seg012:00D0                 retf    4
seg012:00D0 endp            Video_Func
