// 它是一个非 CD 音乐入口，会先停 CD，再做 setup_RIX? / setup_MIDI? 初始化，再调用 rix_load? 把曲目装出来，最后按 music_mode 走后续播放路径。
void play_rix_music(ref ushort arg_flag_)
{
    // ------------------------------------------------------------
    // 如果当前有 CD 轨在播放，先停掉
    // ------------------------------------------------------------
    if (CDtrack_play != 0)
    {
        func_id.high = 2;
        CDROM_functions(ref func_id, ref func_id.high);
        CDtrack_play = 0;
    }

    // ------------------------------------------------------------
    // 先走一轮 setup_RIX?
    // 参数是局部构造出来的 2 / 0 / func_id
    // 这里只保留黑盒，不乱猜其内部语义
    // ------------------------------------------------------------
    var_18 = 2;
    var_1A = 0;
    setup_RIX?(ref func_id, ref var_1A, ref var_18);

    // ------------------------------------------------------------
    // 再走一轮 setup_MIDI?
    // argu_pointer = 0
    // argu_offset  = 2
    // ------------------------------------------------------------
    argu_pointer.high = 2;
    argu_pointer.low  = 0;
    setup_MIDI?(ref func_id, ref argu_pointer.low, ref argu_pointer.high);

    // ------------------------------------------------------------
    // 若 music_mode <= 0，直接返回
    // ------------------------------------------------------------
    if (music_mode <= 0)
        return;

    // ------------------------------------------------------------
    // 取调用者传入的 music 子文件号
    // 若 <= 0，直接返回
    // ------------------------------------------------------------
    if (arg_flag_ <= 0)
        return;

    // ------------------------------------------------------------
    // 加载曲目数据
    // rix_load? 内部会根据 midi_port / music_mode
    // 去 MIDI.MKF 或 MUS.MKF 中读取对应子文件
    // 并把长度写入全局 length
    // ------------------------------------------------------------
    rix_load?(ref arg_flag_);

    // 若 length <= 0，直接返回
    if (length <= 0)
        return;

    // ------------------------------------------------------------
    // 按 music_mode 进入后续播放路径
    // ------------------------------------------------------------

    // music_mode == 1：
    // 调 setup_RIX?，把 DDIM_buf_MPU401 路上的数据交给后续播放系统
    if (music_mode == 1)
    {
        argu_offset.high = 1;
        setup_RIX?(DDIM_buf_MPU401.dataPointer, ref arg_flag_, ref argu_offset.high);
        return;
    }

    // 其他正值：
    // 调 setup_MIDI?，把 xms_handle_22k_midi 路上的数据交给后续播放系统
    argu_offset.low = 1;
    setup_MIDI?(ref xms_handle_22k_midi, ref arg_flag_, ref argu_offset.low);
}
