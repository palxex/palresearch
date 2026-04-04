seg000:0FAB ; =============== S U B R O U T I N E =======================================
seg000:0FAB
seg000:0FAB
seg000:0FAB proc            process_Menu near       ; CODE XREF: real_entry:open_menu↑p
seg000:0FAB                 mov     [ds:money_text], 15h
seg000:0FB1                 mov     [ds:money_x], 0
seg000:0FB7                 mov     [ds:money_y], 0
seg000:0FBD                 mov     [ds:money_mask], 0FFFFh
seg000:0FC3                 push    offset money_text ; a_x
seg000:0FC6                 push    offset money_x  ; a_y
seg000:0FC9                 push    offset money_y  ; a_num
seg000:0FCC                 push    offset RPG_money ; a_shadow
seg000:0FCF                 push    offset money_mask ; int
seg000:0FD2                 call    show_current_money
seg000:0FD7                 mov     [ds:mainmenu_x], 3
seg000:0FDD                 mov     [ds:mainmenu_y], 25h ; '%'
seg000:0FE3                 mov     [ds:mainmenu_begin], 3
seg000:0FE9                 mov     [ds:mainmenu_words], 2
seg000:0FEF
seg000:0FEF loc_FEF:
seg000:0FEF                 mov     [ds:mainmenu_subs], 4
seg000:0FF5                 push    offset par_0
seg000:0FF8                 push    offset mainmenu_x
seg000:0FFB                 push    offset mainmenu_y
seg000:0FFE
seg000:0FFE loc_FFE:
seg000:0FFE                 push    offset mainmenu_begin
seg000:1001                 push    offset mainmenu_words
seg000:1004                 push    offset mainmenu_subs
seg000:1007                 call    menu_loop
seg000:100C                 mov     [ds:tmpvar_menu_selected], ax
seg000:100F                 mov     ax, [ds:tmpvar_menu_selected]
seg000:1012                 mov     [ds:global_var_menu_selected], ax
seg000:1015                 mov     bx, [ds:global_var_menu_selected]
seg000:1019                 inc     bx
seg000:101A                 call    B$OGSA
seg000:101A ; ---------------------------------------------------------------------------
seg000:101F                 db 4
seg000:1020                 dw offset menu_Status
seg000:1022                 dw offset menu_Magic
seg000:1024                 dw offset menu_Inventory
seg000:1026                 dw offset menu_System
seg000:1028 ; ---------------------------------------------------------------------------
seg000:1028                 call    produce_one_screen_map
seg000:102D                 retn
seg000:102D endp            process_Menu
