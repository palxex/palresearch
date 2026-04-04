// 这个函数是个完整开场演出，不是简单“进入场景”。
void begin_scene()
{
    // ------------------------------------------------------------
    // 1) 读调色板 #1
    // ------------------------------------------------------------
    var_14 = 1;
    read_palette(ref var_14);

    // ------------------------------------------------------------
    // 2) 读取场景图 #0x26（云谷鹤峰）
    // ------------------------------------------------------------
    var_16 = 0x26;
    get_fbp_two_scene_cat_to_glb_scrn(ref var_16);

    // ------------------------------------------------------------
    // 3) 读取并解包 MGO #0x49（雁）
    // ------------------------------------------------------------
    var_18 = 0x49;
    read_mgo_subfile_to_glb_1(ref var_18);
    DeYJ_1(DDIM_buf_glb_1_redraw.dataPointer, DDIM_NPC_mgo_decoded_pack.dataPointer);

    // ------------------------------------------------------------
    // 4) 读取并解包 MGO #0x47（仙剑狂徒标题图）
    // ------------------------------------------------------------
    var_1A = 0x47;
    read_mgo_subfile_to_glb_1(ref var_1A);
    DeYJ_1(DDIM_buf_glb_1_redraw.dataPointer, DDIM_role_mgo_decoded_pack_or_battle_ico.dataPointer);

    // ------------------------------------------------------------
    // 5) 随机生成 9 只仙鹤的初始参数
    //    counter = 0..8
    // ------------------------------------------------------------
    counter = 0;
    while (counter <= 8)
    {
        // X = rnd(260) + 420
        DDIM_posXs[counter] = RoundToInt(RND() * 260 + 420);

        // Y = rnd(80)
        DDIM_posYs[counter] = RoundToInt(RND() * 80);

        // 帧 = RoundToEven(rnd(8))
        DDIM_buf_common_short[counter] = RoundToEven(RND() * 8);

        counter++;
    }

    // ------------------------------------------------------------
    // 6) 播放开场音乐
    //    注意：这是统一音乐分发器，不擅自简化成“只播 RIX”
    // ------------------------------------------------------------
    var_20 = 7;
    var_22 = 5;
    var_24 = 0;
    play_all_kinds_music(ref var_20, ref var_22, ref var_24);

    // ------------------------------------------------------------
    // 7) 把 palette 的一份副本整体压黑
    //    block_tweak(dst = palette+0x600, src = palette, bytes = 0x2D0, multiplier = 0)
    // ------------------------------------------------------------
    bytes = 0x2D0;
    multi_ = 0;
    block_tweak(DDIM_palette.dataPointer + 0x600, DDIM_palette.dataPointer, ref bytes, ref multi_);
    set_palette(DDIM_palette.dataPointer + 0x600);

    // ------------------------------------------------------------
    // 8) 初始化滚动/标题显示相关变量
    // ------------------------------------------------------------
    deci_40 = 40;
    deci_16 = 16;
    pixels_scrolled = constant_200d;   // 200
    deci_0 = 0;
    curr_crazyboys_height = 8;

    // 从标题 RLE 头中取标题当前高度字段
    var_title_height = ReadRLEHeight(DDIM_role_mgo_decoded_pack_or_battle_ico);

    // ------------------------------------------------------------
    // 9) 主演出循环
    //    直到 pixels_scrolled <= -300
    // ------------------------------------------------------------
    while (pixels_scrolled > -300)
    {
        // --------------------------------------------------------
        // 9.1 先解析键盘
        // 若 key_pressed == 2，则强制提前结束滚动
        // --------------------------------------------------------
        Parse_key(ref key_pressed, DDIM_keybuf.dataPointer);
        if (key_pressed == 2)
        {
            pixels_scrolled = -999;
            // 原汇编这里还把 [bp-36h] 置为 -1，用来标记“确认跳过”
            jumped_by_confirm = -1;
        }

        // --------------------------------------------------------
        // 9.2 若尚未滚过 0，则构造 viewport_X 对应的画面段基址
        // --------------------------------------------------------
        if (pixels_scrolled > 0)
        {
            viewport_X.high = DDIM_screen_buf.segment + pixels_scrolled * 20;
        }
        viewport_X.low = 0;
        viewport_Y = 0;

        // --------------------------------------------------------
        // 9.3 把滚动背景切成 scanline redraw
        // --------------------------------------------------------
        split_scrn_to_scanlines_in_redraw(
            boundary: scanline_bottom_boundary_2,
            viewport_X: ref viewport_X,
            viewport_Y: ref viewport_Y,
            width: ref decimal_320,
            height: ref constant_200d,
            DDIM_scrn: ref viewport_X.high,          // 实际上传的是段基址那部分
            DDIM_redraw: DDIM_buf_glb_1_redraw.dataPointer
        );

        // --------------------------------------------------------
        // 9.4 画 9 只仙鹤
        // --------------------------------------------------------
        counter = 0;
        while (counter <= 8)
        {
            // X 每帧减 2
            DDIM_posXs[counter] -= 2;

            // 当画面尚未滚到 0 以上时，Y 会额外受 pixels_scrolled 奇偶影响
            if (pixels_scrolled > 0)
            {
                DDIM_posYs[counter] += (pixels_scrolled & 1);
            }

            // 帧号 = (帧号 + (deci_0 & 1)) & 7
            DDIM_buf_common_short[counter] =
                (ushort)((DDIM_buf_common_short[counter] + (deci_0 & 1)) & 7);

            // X > -40 才画
            if (DDIM_posXs[counter] > unchecked((short)0xFFD8))
            {
                argu_splice_len = 0;

                DeRLE_scanline(
                    argu_scrn_x: ref DDIM_posXs[counter],
                    argu_scrn_y: ref DDIM_posYs[counter],
                    argu_splice_len: ref argu_splice_len,
                    argu_eff_y: ref constant_200d,
                    argu_return: scanline_bottom_boundary_2,
                    argu_RLEsrc: GetNPCFrameRLE(
                        DDIM_NPC_mgo_decoded_pack,
                        DDIM_buf_common_short[counter]
                    ),
                    argu_DDIM: DDIM_buf_glb_1_redraw.dataPointer
                );
            }

            counter++;
        }

        // --------------------------------------------------------
        // 9.5 标题图高度逐步增大，直到真实高度
        // --------------------------------------------------------
        curr_crazyboys_height++;
        if (curr_crazyboys_height > var_title_height)
            curr_crazyboys_height = var_title_height;

        WriteRLEHeight(DDIM_role_mgo_decoded_pack_or_battle_ico, curr_crazyboys_height);

        // --------------------------------------------------------
        // 9.6 把标题图画到 redraw
        // --------------------------------------------------------
        argu_scrn_x = -2;
        argu_scrn_y = 10;
        begin_scanline = 0;

        DeRLE_scanline(
            argu_scrn_x: ref argu_scrn_x,
            argu_scrn_y: ref argu_scrn_y,
            argu_splice_len: ref begin_scanline.high,
            argu_eff_y: ref constant_200d,
            argu_return: scanline_bottom_boundary_2,
            argu_RLEsrc: GetTitleRLE(DDIM_role_mgo_decoded_pack_or_battle_ico),
            argu_DDIM: DDIM_buf_glb_1_redraw.dataPointer
        );

        // --------------------------------------------------------
        // 9.7 redraw -> 屏幕
        // --------------------------------------------------------
        begin_scanline.low = 0;
        draw_scanline_to_scrn(ref begin_scanline.low, ref constant_200d, DDIM_buf_glb_1_redraw.dataPointer);

        // --------------------------------------------------------
        // 9.8 延时 10 cs
        // --------------------------------------------------------
        delay_time = 10;
        delay_centisecond(ref delay_time);

        // --------------------------------------------------------
        // 9.9 渐亮系数推进
        // multiplier = deci_40 / 10
        // deci_40 += deci_16
        // deci_16--
        // deci_16 最低保持 3
        // --------------------------------------------------------
        multiplier.high = deci_40 / 10;
        deci_40 += deci_16;
        deci_16--;
        if (deci_16 < 3)
            deci_16 = 3;

        deci_0++;

        // --------------------------------------------------------
        // 9.10 若 multiplier <= 0x40，则更新调色板亮度
        // --------------------------------------------------------
        if (multiplier.high <= 0x40)
        {
            multiplier.low = 0x2D0;
            block_tweak(
                DDIM_palette.dataPointer + 0x600,
                DDIM_palette.dataPointer,
                ref multiplier.low,
                ref multiplier.high
            );
            set_palette(DDIM_palette.dataPointer + 0x600);
        }

        // --------------------------------------------------------
        // 9.11 画面继续向上滚
        // --------------------------------------------------------
        pixels_scrolled--;
    }

    // ------------------------------------------------------------
    // 10) 演出结束后分两路
    // ------------------------------------------------------------

    // jumped_by_confirm == 0:
    // 正常播完，等待按键后退出
    if (jumped_by_confirm == 0)
    {
        WaitForKey_internal();
    }
    else
    {
        // 被确认键跳过：
        // 先把标题高度恢复为完整高度
        WriteRLEHeight(DDIM_role_mgo_decoded_pack_or_battle_ico, var_title_height);

        // 把当前 screen 读回内存
        read_from_screen(DDIM_screen_buf.dataPointer);

        // 再把完整标题直接 DeRLE 到 screen_buf
        argu_y.high = -2;
        argu_y.low = 10;
        argu_addr.high = DDIM_screen_buf.segment;
        DeRLE(
            argu_x: ref argu_y.high,
            argu_y: ref argu_y.low,
            argu_rle: GetTitleRLE(DDIM_role_mgo_decoded_pack_or_battle_ico),
            argu_addr: ref argu_addr.high
        );

        // 写回屏幕
        write_to_screen(DDIM_screen_buf.dataPointer);

        // --------------------------------------------------------
        // 做 0..0x40 的亮度推进
        // --------------------------------------------------------
        counter = multiplier.high;
        while (counter <= 0x40)
        {
            argu_addr.low = 0x2D0;
            block_tweak(
                DDIM_palette.dataPointer + 0x600,
                DDIM_palette.dataPointer,
                ref argu_addr.low,
                ref counter
            );
            set_palette(DDIM_palette.dataPointer + 0x600);

            var_56 = 1;
            delay_centisecond(ref var_56);

            counter++;
        }

        // 然后再 wait_key(90)
        var_58 = 90;
        wait_key(ref var_58);
    }

    // ------------------------------------------------------------
    // 11) 收尾：重新做一轮 setup_RIX? / setup_MIDI?
    // ------------------------------------------------------------
    var_5E = 2;
    var_60 = 1;
    setup_RIX?(ref counter, ref var_60, ref var_5E);

    argu_pointer.high = 2;
    argu_pointer.low = 1;
    setup_MIDI?(ref counter, ref argu_pointer.low, ref argu_pointer.high);

    // ------------------------------------------------------------
    // 12) 允许后续改 palette，并淡出
    // ------------------------------------------------------------
    mutex_can_change_palette = 0;
    var_66 = 2;
    fade_out(ref var_66);

    // ------------------------------------------------------------
    // 13) 停音乐 / 清音乐状态
    // ------------------------------------------------------------
    var_68 = 0;
    var_6A = 0;
    var_6C = 0;
    play_all_kinds_music(ref var_68, ref var_6A, ref var_6C);
}
