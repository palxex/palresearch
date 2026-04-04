// 注意：这是“严格翻译版伪代码”，不是整理优化版。
// 1) 保留了很多全局变量写法
// 2) 保留了黑盒函数调用
// 3) 某些数组索引写法故意贴近汇编访问习惯

void real_entry()
{
    // ------------------------------------------------------------
    // [A] 建立运行时栈
    // ------------------------------------------------------------
    B$SSTK(1, 0x1800, 0);

    // ------------------------------------------------------------
    // [B] DIM 所有动态数组
    // ------------------------------------------------------------
    B$DDIM(ref DDIM_palette,                               ndtyp:0x101, cbelem:2,  ub:0x05FF, lb:0);
    B$DDIM(ref DDIM_SB_buf,                                ndtyp:0x101, cbelem:4,  ub:0x0007, lb:0);
    B$DDIM(ref DDIM_NPC_mgo_decoded_pack,                  ndtyp:0x101, cbelem:2,  ub:0x7FFE, lb:0);
    B$DDIM(ref DDIM_buf_glb_gop_or_FADEmap,                ndtyp:0x101, cbelem:2,  ub:0x7FFE, lb:0);
    B$DDIM(ref DDIM_buf_glb_map,                           ndtyp:0x101, cbelem:2,  ub:0x7FFE, lb:0);
    B$DDIM(ref DDIM_screen_buf,                            ndtyp:0x101, cbelem:2,  ub:0x7FFE, lb:0);
    B$DDIM(ref DDIM_buf_glb_1_redraw,                      ndtyp:0x101, cbelem:2,  ub:0x55EF, lb:0);
    B$DDIM(ref DDIM_role_mgo_decoded_pack_or_battle_ico,  ndtyp:0x101, cbelem:2,  ub:0x3907, lb:0);
    B$DDIM(ref DDIM_wor16_asc,                             ndtyp:0x101, cbelem:2,  ub:0x0A27, lb:0);
    B$DDIM(ref DDIM_buf_wor16_fon_buf,                     ndtyp:0x101, cbelem:2,  ub:0x0350, lb:0);
    B$DDIM(ref DDIM_word_dat,                              ndtyp:0x101, cbelem:0x0A, ub:0x0257, lb:0);
    B$DDIM(ref DDIM_data_C_dialog_wait_icon,               ndtyp:0x101, cbelem:2,  ub:0x0095, lb:0);
    B$DDIM(ref DDIM_sth_about_battle_row_10,               ndtyp:0x101, cbelem:0x0A, ub:0x000B, lb:0);
    B$DDIM(ref DDIM_sss_1_scene_def,                       ndtyp:0x101, cbelem:8,  ub:0x012C, lb:1);
    B$DDIM(ref DDIM_buf_SETUP_DAT,                         ndtyp:0x101, cbelem:2,  ub:0x0009, lb:0);
    B$DDIM(ref DDIM_keybuf,                                ndtyp:0x101, cbelem:2,  ub:0x006C, lb:0);

    B$DDIM(ref DDIM_data_6_uplevel_theurgy,                ndtyp:0x102, cbelem:4,  dims:[0..0x13, 0..4]);
    B$DDIM(ref DDIM_data_0_shop,                           ndtyp:0x102, cbelem:2,  dims:[0..0x14, 0..8]);

    B$DDIM(ref DDIM_x_off_fff0_fff0_10_10,                 ndtyp:0x101, cbelem:2,  ub:4, lb:0);
    B$DDIM(ref DDIM_y_off_8_fff8_fff8_8,                   ndtyp:0x101, cbelem:2,  ub:4, lb:0);
    B$DDIM(ref DDIM_x_block_off_ffff_ffff_1_1,             ndtyp:0x101, cbelem:2,  ub:4, lb:0);
    B$DDIM(ref DDIM_y_block_off_1_ffff_ffff_1,             ndtyp:0x101, cbelem:2,  ub:4, lb:0);

    B$DDIM(ref DDIM_battletime_role_HP_MP,                 ndtyp:0x101, cbelem:4,  ub:4, lb:0);
    B$DDIM(ref DDIM_battletime_enemy_HP,                   ndtyp:0x101, cbelem:2,  ub:4, lb:0);
    B$DDIM(ref DDIM_RPG_team_positions,                    ndtyp:0x101, cbelem:0x0A, ub:4, lb:0);
    B$DDIM(ref DDIM_RPG_team_trace,                        ndtyp:0x101, cbelem:6,  ub:4, lb:0);
    B$DDIM(ref DDIM_buf_common_short,                      ndtyp:0x101, cbelem:2,  ub:0x00FF, lb:0);
    B$DDIM(ref DDIM_fadegap_031524,                        ndtyp:0x101, cbelem:2,  ub:5, lb:0);
    B$DDIM(ref DDIM_buf_common,                            ndtyp:0x101, cbelem:2,  ub:0x0063, lb:0);
    B$DDIM(ref DDIM_vs_id_table,                           ndtyp:0x101, cbelem:2,  ub:9, lb:0);
    B$DDIM(ref DDIM_posXs,                                 ndtyp:0x101, cbelem:2,  ub:0x0F, lb:0);
    B$DDIM(ref DDIM_posYs,                                 ndtyp:0x101, cbelem:2,  ub:0x0F, lb:0);
    B$DDIM(ref DDIM_role_attack_table,                     ndtyp:0x101, cbelem:0x0A, ub:7, lb:0);
    B$DDIM(ref DDIM_battle_enemy_data_etc,                 ndtyp:0x101, cbelem:0x1E, ub:4, lb:0);
    B$DDIM(ref DDIM_thisbattle_role_data_etc,              ndtyp:0x101, cbelem:0x18, ub:9, lb:0);

    B$DDIM(ref DDIM_theurgy_pos_X,                         ndtyp:0x101, cbelem:2,  ub:5, lb:1);
    B$DDIM(ref DDIM_theurgy_pos_Y,                         ndtyp:0x101, cbelem:2,  ub:5, lb:1);
    B$DDIM(ref DDIM_summon_effect,                         ndtyp:0x101, cbelem:2,  ub:5, lb:1);

    B$DDIM(ref DDIM_2FAA0,                                 ndtyp:0x101, cbelem:2,  ub:4, lb:0);
    B$DDIM(ref DDIM_2FACE,                                 ndtyp:0x101, cbelem:2,  ub:4, lb:0);

    B$DDIM(ref DDIM_instrum_icon_x_offs,                   ndtyp:0x101, cbelem:2,  ub:4, lb:0);
    B$DDIM(ref DDIM_instrum_icon_y_offs,                   ndtyp:0x101, cbelem:2,  ub:4, lb:0);

    B$DDIM(ref DDIM_thisbattle_enemy_data,                 ndtyp:0x101, cbelem:0x46, ub:4, lb:0);

    B$DDIM(ref DDIM_data_D_enemy_position,                 ndtyp:0x102, cbelem:4,  dims:[0..4, 0..4]);
    B$DDIM(ref DDIM_role_status,                           ndtyp:0x102, cbelem:2,  dims:[0..0x0F, 0..4]);
    B$DDIM(ref DDIM_enemy_status,                          ndtyp:0x102, cbelem:2,  dims:[0..0x0F, 0..4]);
    B$DDIM(ref DDIM_role_poison_stack,                     ndtyp:0x102, cbelem:4,  dims:[0..0x0F, 0..4]);
    B$DDIM(ref DDIM_enemy_poison_stack,                    ndtyp:0x102, cbelem:4,  dims:[0..0x0F, 0..4]);

    B$DDIM(ref DDIM_sss_2_object_defination,               ndtyp:0x101, cbelem:0x0C, ub:0x0257, lb:0);
    B$DDIM(ref DDIM_items,                                 ndtyp:0x101, cbelem:6,  ub:0x00FF, lb:0);
    B$DDIM(ref DDIM_role_parts_attr,                       ndtyp:0x103, cbelem:2,  dims:[0..0x1E, 0x11..0x11, 0x0B..5, 0]);
    B$DDIM(ref DDIM_data_3_our_data,                       ndtyp:0x102, cbelem:2,  dims:[0..0x4A, 0..5]);
    B$DDIM(ref DDIM_RPG_kinds_of_exps,                     ndtyp:0x102, cbelem:8,  dims:[0..7, 0..5]);
    B$DDIM(ref DDIM_evt_obj_curr_scene,                    ndtyp:0x101, cbelem:0x20, ub:0x0A0, lb:0);
    B$DDIM(ref DDIM_data_B_unknown,                        ndtyp:0x101, cbelem:4,  ub:9, lb:0);
    B$DDIM(ref DDIM_buf_index,                             ndtyp:0x101, cbelem:4,  ub:0x1F, lb:0);
    B$DDIM(ref DDIM_theurgy_data,                          ndtyp:0x101, cbelem:0x20, ub:0, lb:0);
    B$DDIM(ref DDIM_21043_enemy_sequence,                 ndtyp:0x101, cbelem:2,  ub:4, lb:0);

    // ------------------------------------------------------------
    // [C] 用当前时间做 RANDOMIZE
    // ------------------------------------------------------------
    {
        double timeAsDouble = B$TIMR();   // 运行时返回“今日已过秒数”
        B$RNZP(timeAsDouble);
    }

    // ------------------------------------------------------------
    // [D] 读取 setup.dat
    // （你之前说这几大块先不细讲；这里我只严格保留流程）
    // ------------------------------------------------------------
    filename_to_open = "SETUP.DAT";
    buf_setup_dat = DDIM_buf_SETUP_DAT.header.segment;
    ReadFile_toseg(filename_to_open, ref buf_setup_dat);

    // ------------------------------------------------------------
    // [E] 检查 CD-ROM
    // ------------------------------------------------------------
    Print("CHECK_CD_ROM");
    CDROM_func0_checking = 0;
    CDROM_functions(ref CDriver, ref CDROM_func0_checking);

    if (this_step_frame + 1 < 0)
    {
        PrintLine("NotFound");
        RuntimeEnd();
    }

    CDROM_func5_GetTracks = 5;
    CDROM_functions(ref CD_tracks, ref CDROM_func5_GetTracks);

    // 原汇编这里直接跳过了“tracks 不够则退出”的分支，仍保留原控制流
    goto CDROM_Ready;

ModifyEXE_eliminated_CheckTracks:
    PrintLine("NotReady");
    RuntimeEnd();

CDROM_Ready:
    BSTR_CDriver = Chr(CDriver + 'A') + ":";
    Print("in");
    PrintLine(BSTR_CDriver);
    BSTR_fan = BSTR_CDriver + BSTR_CDriver;

    // setup.dat[8] bit2 -> 是否允许 CD 音乐
    if ((ReadWord(DDIM_buf_SETUP_DAT, 8) & 4) != 0)
        mask_use_CD = -1;
    else
        mask_use_CD = 0;

    // setup.dat[0x12] != 0 -> 强制最小安装，不用 CD
    if (ReadWord(DDIM_buf_SETUP_DAT, 0x12) != 0)
    {
        BSTR_CDriver_If_min_inst = BSTR_CDriver;
        mask_use_CD = 0;
    }
    else
    {
        BSTR_CDriver_If_min_inst = "";
    }

    // ------------------------------------------------------------
    // [F] 检查常规内存 / XMS
    // ------------------------------------------------------------
    free_bytes = FREE(-1);
    Print("Free");
    Print(free_bytes);
    PrintLine("bytes");

    if (free_bytes < 0x1000)
    {
        Beep();
        PrintLine("ErrorFreeMemoryIsNotEnough570K");
        RuntimeEnd();
    }

    XMS_Init(ref XMS_Driver_Present);
    if (XMS_Driver_Present == 0)
    {
        PrintLine("XMSNotFound");
        RuntimeEnd();
    }

    XMS_Query_Amount(ref XMS_Memory_Amount);
    Print("XMS=");
    Print(XMS_Memory_Amount);
    PrintLine("k");

    if (XMS_Memory_Amount < 0x33E)
    {
        PrintLine("ErrorXmsIsNotEnough");
        RuntimeEnd();
    }

    Xms_alloc_and_Load_sfx_music();
    replace_timer_interrupt();
    replace_keyboard_interrupt();

    // ------------------------------------------------------------
    // [G] 根据 setup.dat 初始化音乐模式 / MIDI / SFX
    // ------------------------------------------------------------
    music_mode = ReadWord(DDIM_buf_SETUP_DAT, 8) & 3;
    alloc_bytes = 0x05DB;
    midi_port = 0;

    // music_mode == 1 时，先走一轮 setup_RIX? 初始化探测/准备。
    // 这里不擅自把它命名成“播放”或“启用 FM”，因为 setup_RIX? 内部仍保持黑盒。
    if (music_mode == 1)
    {
        rixInitArg0 = 0;      // 原汇编里由局部变量提供
        rixInitArg1 = 0xFF;   // 原汇编里由局部变量提供

        setup_RIX?(ref CD_tracks, ref rixInitArg0, ref rixInitArg1);

        if (free_bytes > 0x2800)
        {
            alloc_bytes = 0x13EB;
            PrintLine("FM_OK");
        }
        else
        {
            music_mode = 0;
        }
    }


    B$DDIM(ref DDIM_buf_MPU401, ndtyp:0x101, cbelem:2, ub:alloc_bytes, lb:0);

    free_bytes = FREE(-1);

    if ((music_mode & 2) != 0)
        midi_port = ReadWord(DDIM_buf_SETUP_DAT, 0x10);

    if (midi_port != 0)
    {
        BSTR_MPU401 = "MPU401.DRV";
        mpu401drv_seg = DDIM_buf_MPU401.header.segment;
        ReadFile_toseg(BSTR_MPU401, ref mpu401drv_seg);

        mpu401_offset = 0x100;
        setup_MIDI?(ref midi_port, DDIM_buf_MPU401.dataPointer, ref mpu401_offset);

        ptr_6 = 6;
        ptr_1 = 1;
        setup_MIDI?(ref CD_tracks, ref ptr_1, ref ptr_6);

        MIDI_parm2 = 3;
        MIDI_parm1 = 80;
        setup_MIDI?(ref CD_tracks, ref MIDI_parm1, ref MIDI_parm2);

        PrintLine("Midi_OK");
    }

    if (music_mode == 0)
        use_cd = 0 | mask_use_CD;
    else
        use_cd = -1 | mask_use_CD;

    sfx_result = 0;

    // setup.dat[0x0A] != 0 且 setup.dat[8] bit0 != 0 -> 尝试 SB 音效
    if (ReadWord(DDIM_buf_SETUP_DAT, 0x0A) != 0 &&
        ((ReadWord(DDIM_buf_SETUP_DAT, 8) & 1) != 0))
    {
        sfx_func_id_4 = 4;
        sfx_func?(ref sfx_func_id_4, PtrInSetup(0x0C)); // IRQ

        sfx_func_id_5 = 5;
        sfx_func?(ref sfx_func_id_5, PtrInSetup(0x0E)); // I/O port

        sfx_func_id_0 = 0;
        sfx_func?(ref sfx_result, ref sfx_func_id_0);

        if (sfx_result != 0)
        {
            flag_has_sfx = -1;
            PrintLine("Voice_OK");
        }
    }

    // 把最终 music_mode 写回 setup.dat[8]
    WriteWord(DDIM_buf_SETUP_DAT, 8, music_mode);

    // ------------------------------------------------------------
    // [H] 打开一批核心文件
    // ------------------------------------------------------------
    B$OPEN("M.MSG", channel:1, cbRecord:-1, ModeAccessLock:0x20);

    RNG_MKF = BSTR_CDriver_If_min_inst + "RNG.MKF";
    RNG_MKF.file_handle = 0;
    Open_File(RNG_MKF, ref RNG_MKF.file_handle);
    rng_mkf_fp = RNG_MKF.pointee.file_handle;

    MGO_MKF = BSTR_CDriver_If_min_inst + "MGO.MKF";
    MGO_MKF.file_handle = 0;
    Open_File(MGO_MKF, ref MGO_MKF.file_handle);
    mgo_mkf_fp = MGO_MKF.pointee.file_handle;

    F_MKF = BSTR_CDriver_If_min_inst + "F.MKF";
    F_MKF.file_handle = ???;   // 原汇编直接塞 offset byte_2F380
    Open_File(F_MKF, ref F_MKF.file_handle);
    f_mkf_fp = F_MKF.pointee.file_handle;

    ABC_MKF = BSTR_CDriver_If_min_inst + "ABC.MKF";
    ABC_MKF.file_handle = 0;
    Open_File(ABC_MKF, ref ABC_MKF.file_handle);
    abc_mkf_fp = ABC_MKF.pointee.file_handle;

    Load_system_files();

    // ------------------------------------------------------------
    // [I] 若干全局表初始化
    // ------------------------------------------------------------
    DDIM_21043_enemy_sequence[0] = 2;
    DDIM_21043_enemy_sequence[1] = 1;
    DDIM_21043_enemy_sequence[2] = 0;
    DDIM_21043_enemy_sequence[3] = 4;
    DDIM_21043_enemy_sequence[4] = 3;

    DDIM_instrum_icon_x_offs[0] = 0x1C;
    DDIM_instrum_icon_y_offs[0] = 0x8C;
    DDIM_instrum_icon_x_offs[1] = 0x00;
    DDIM_instrum_icon_y_offs[1] = 0x9B;
    DDIM_instrum_icon_x_offs[2] = 0x37;
    DDIM_instrum_icon_y_offs[2] = 0x9B;
    DDIM_instrum_icon_x_offs[3] = 0x1B;
    DDIM_instrum_icon_y_offs[3] = 0xAA;

    DDIM_fadegap_031524[0] = 0;
    DDIM_fadegap_031524[1] = 3;
    DDIM_fadegap_031524[2] = 1;
    DDIM_fadegap_031524[3] = 5;
    DDIM_fadegap_031524[4] = 2;
    DDIM_fadegap_031524[5] = 4;

    // 先通过 libfunc_? 取出/标准化 x/y 偏移表内容，
    // 再生成 block 级偏移符号表 (-1/0/1)
    for (loop_counter = 0; loop_counter <= 3; loop_counter++)
    {
        libfunc_?(DDIM_x_off_fff0_fff0_10_10[loop_counter]);
        libfunc_?(DDIM_y_off_8_fff8_fff8_8[loop_counter]);

        {
            short ax = DDIM_x_off_fff0_fff0_10_10[loop_counter];
            if (ax == 0) ax = 0;
            else if (ax > 0) ax = 1;
            else ax = -1;
            DDIM_x_block_off_ffff_ffff_1_1[loop_counter] = ax;
        }

        {
            short ax = DDIM_y_off_8_fff8_fff8_8[loop_counter];
            if (ax == 0) ax = 0;
            else if (ax > 0) ax = 1;
            else ax = -1;
            DDIM_y_block_off_1_ffff_ffff_1[loop_counter] = ax;
        }
    }

    Addr_videoscreen = 0xA000;
    decimal_200 = 200;
    decimal_320 = 320;
    constant_200d = 200;

    // ------------------------------------------------------------
    // [J] 播放标题 RNG
    // ------------------------------------------------------------
    rng_movie_id = 6;
    setMovie_impl(ref rng_movie_id);

    rng6_palette = 3;
    read_palette(ref rng6_palette);

    vga_mode = 0x13;
    Video_Func(ref vga_mode);

    set_palette(DDIM_palette.dataPointer);

    rng_startframe = 0;
    rng_stopframe = 999;
    rng_speed = 25;
    playRNG_impl(ref rng_speed, ref rng_stopframe, ref rng_startframe);

    wait_time = 180;
    wait_key(ref wait_time);

    fade_time_gap = 1;
    fade_out(ref fade_time_gap);

    begin_scene();

    curr_subfile_offset = bytes_leavingxms;

    // ------------------------------------------------------------
    // [K] 标题菜单前初始化
    // ------------------------------------------------------------
loc_B8A:
    RPG_ememy_chase_rate = 1;
    RPG_change_chaserate_times = 0;
    delay_in_centisecond = 3;

loc_B9C:
    palette_id = 0;
    read_palette(ref palette_id);

    musicSubfileId = 4;
    musicInitArg   = 1;
    play_rix_music(ref musicInitArg, ref musicSubfileId);

    // ------------------------------------------------------------
    // [L] 主菜单循环
    // ------------------------------------------------------------
select_loop:
    fbp_idx = 0x3C;        // “一书一剑一葫芦”
    not_align = 0;
    show_fbp(ref not_align, ref fbp_idx);

    fade_time_gap_ = 1;
    fade_in(ref fade_time_gap_);

    DDIM_buf_common_short[0]   = 7;
    DDIM_buf_common_short[1]   = 8;
    DDIM_buf_common_short[100] = 0xFFFF;   // 200 bytes offset => word index 100
    DDIM_buf_common_short[101] = 0xFFFF;

    par_0        = 0;
    par_x        = 0x70;
    par_y        = 0x54;
    par_no_frame = 0xFFFF;
    par_menus    = 2;

    flag_menu_loaded = menu_select(ref par_menus, ref par_no_frame, ref par_y, ref par_x, ref par_0);
    select_result = flag_menu_loaded;

    flag_to_load = 0x10;

    if (select_result == 1)
        goto next6;       // 读档
    else
        goto create_new;  // 新游戏 / 非“读档”路径

next6:
    tmp = select_RPG_internal();
    global_var_menu_selected = tmp;

    if (global_var_menu_selected < 0)
        goto select_loop;

next5:
    rpg_to_load = global_var_menu_selected + 1;
    LoadRPG_internal(ref rpg_to_load);

    if (RPG_save_number != 0)
        goto go_load_map;
    else
        goto create_new;

go_load_map:
    flag_to_load |= 0x02;   // 额外补一个 music 位
    goto gogo_load_map;

    // ------------------------------------------------------------
    // [M] 新游戏初始化
    // ------------------------------------------------------------
create_new:
    scene_to_load = 1;
    flag_to_load |= 0x0D;   // scene + evt + team_mgo

    for (loop_counter = 0; loop_counter <= 4; loop_counter++)
    {
        for (inner_counter = 0; inner_counter <= 7; inner_counter++)
        {
            if (inner_counter <= 0)
            {
                YJ_1_extracted_len = 0;
                random_m20 = 0;
            }
            else
            {
                YJ_1_extracted_len = RoundToInt(RND() * 2 + 2);
                random_m20         = RoundToInt(RND() * 20);
            }

            // 这里严格照汇编：先从 our_data 某处取基础值，再写入 RPG_kinds_of_exps
            {
                ushort baseValue =
                    DDIM_data_3_our_data[
                        6 * DDIM_data_3_our_data.Dimension2.Elements + loop_counter
                    ];

                ushort levelValue = (ushort)(baseValue + YJ_1_extracted_len);

                int expIndex =
                    DDIM_RPG_kinds_of_exps.Dimension2.Elements * inner_counter + loop_counter;

                DDIM_RPG_kinds_of_exps[expIndex].Level = levelValue;
                DDIM_RPG_kinds_of_exps[expIndex].Exp   = random_m20;
            }
        }
    }

    time_gap = 1;
    fade_out(ref time_gap);

    // ------------------------------------------------------------
    // [N] 统一进入切图/入场
    // ------------------------------------------------------------
gogo_load_map:
    step_off_x = 0x10;
    step_off_y = 8;
    scanline_top = 0;
    coordinate_x_max = 1696;
    coordinate_y_max = 1840;

call_change_map:
    Load_Data();

    // ------------------------------------------------------------
    // [O] 游戏主循环
    // ------------------------------------------------------------
mainloop:
    flag_which_key_pressed_ = 0;

    process_Key(ref y_off, ref x_off);   // 注意：汇编是 push x_off 再 push y_off
    flag_which_key_pressed_ = key_pressed;

    flag_to_load = 0;
    flag_trigger = -1;
    GameLoop_OneCycle(ref flag_trigger);

    if (flag_to_load != 0)
        goto call_change_map;

    bytes_to_clear = 0x2000;
    clear_DDIM(DDIM_buf_glb_1_redraw.dataPointer, ref bytes_to_clear);
    clear_spirite_array();

    calc_team_walking();
    our_team_setdraw();
    visible_NPC_movment_setdraw();

    Redraw_Tiles_or_Fade_to_pic();
    move_usable_screen();

    show_fade_gap = 1;
    scanline_draw_normal_scene(ref show_fade_gap);

    if (flag_which_key_pressed_ == 1)
        process_Menu();

    if (flag_which_key_pressed_ == 2)
        process_Explore();

    flag_parallel_mutex ^= 1;

    if (flag_to_load != 0)
        goto call_change_map;
    else
        goto mainloop;
}
