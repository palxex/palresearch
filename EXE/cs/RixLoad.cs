// 该函数负责加载 RIX 音乐数据，具体行为取决于全局变量 midi_port 和 music_mode 的值。
// 按传入的音乐子文件号，把曲目数据从 MIDI.MKF 或 MUS.MKF 读到目标缓冲/XMS，并更新全局 length
void rix_load(ref ushort musicSubfileId)
{
    // 函数开头先把全局 length 清零
    length = 0;

    // ------------------------------------------------------------
    // 路线 A：midi_port != 0
    // 读 MIDI.MKF -> xms_handle_22k_midi
    // ------------------------------------------------------------
    if (midi_port != 0)
    {
        open_method = BSTR_CDriver_If_min_inst + BSTR_Midi_mkf;
        tmp_open_flag = 0;

        file_handle = Open_File(open_method, ref tmp_open_flag);

        // 取对应子文件长度
        (ax, dx) = get_subfile_len(ref file_handle, ref musicSubfileId);
        length = MakeInt32(dx, ax);

        argu_xmshandle = 0;
        read_subfile(ref xms_handle_22k_midi, ref argu_xmshandle);

        DOS_CloseFile(ref file_handle);
        return;
    }

    // ------------------------------------------------------------
    // 路线 B：midi_port == 0，但 music_mode == 1
    // 读 MUS.MKF -> DDIM_buf_MPU401
    // ------------------------------------------------------------
    if (music_mode == 1)
    {
        psdDest = BSTR_CDriver_If_min_inst + BSTR_MUS_MKF;
        tmp_open_flag2 = 0;

        file_handle = Open_File(psdDest, ref tmp_open_flag2);

        // 取对应子文件长度
        (ax, dx) = get_subfile_len(ref file_handle, ref musicSubfileId);
        length = MakeInt32(dx, ax);

        // 直接把子文件内容读到 DDIM_buf_MPU401
        DOS_ReadFile_toBuf(
            ref file_handle,
            DDIM_buf_MPU401.dataPointer,
            ref length
        );

        DOS_CloseFile(ref file_handle);
        return;
    }

    // ------------------------------------------------------------
    // 路线 C：其他情况
    // 什么也不做，直接返回
    // ------------------------------------------------------------
    return;
}
