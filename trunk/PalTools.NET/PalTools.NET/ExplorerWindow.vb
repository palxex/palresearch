Imports System.Runtime.InteropServices

Public Class ExplorerWindow

    Dim palette As System.IntPtr = System.IntPtr.Zero
    Dim same As Boolean = False
    Dim cur, total As Integer
    Dim bmp() As System.Drawing.Bitmap

    Private Sub SetHexView(ByVal file As PalTools.MkfFile, ByVal index As Integer)
        Dim buf As PalTools.MkfBufferItem
        Dim num As Integer
        If same Then Exit Sub
        If index >= 0 Then
            buf = PalMkfs(file).RawData(index)
        Else
            buf = PalMkfs(file).RawData()
        End If
        num = buf.Size >> 4
        If buf.Size And &HF Then num += 1
        ListViewHex.Tag = buf
        ListViewHex.VirtualListSize = num
        ListViewHex.Enabled = True
    End Sub

    Private Sub SetHexView(ByVal buf As PalTools.MkfBufferItem)
        Dim num As Integer
        num = buf.Size >> 4
        If buf.Size And &HF Then num += 1
        ListViewHex.Tag = buf
        ListViewHex.VirtualListSize = num
        ListViewHex.Enabled = True
    End Sub

    Private Function SetHexViewItem(ByVal buf As MkfBufferItem, ByVal offset As UInteger, ByVal len As Integer) As ListViewItem
        Dim item As ListViewItem
        Dim temp, tmp As String
        Dim j As Integer
        temp = offset.ToString("X8")
        item = New ListViewItem(temp)
        temp = buf.Buffer(offset).ToString("X2")
        If buf.Buffer(offset) >= 32 And buf.Buffer(offset) < 128 Then
            tmp = Chr(buf.Buffer(offset))
        Else
            tmp = "."
        End If
        For j = 1 To len - 1
            offset += 1
            temp &= " " & buf.Buffer(offset).ToString("X2")
            If buf.Buffer(offset) >= 32 And buf.Buffer(offset) < 128 Then
                tmp &= Chr(buf.Buffer(offset))
            Else
                tmp &= "."
            End If
        Next
        If len > 8 Then temp = temp.Insert(23, " -")
        item.SubItems.Add(temp)
        item.SubItems.Add(tmp)
        Return item
    End Function

    Private Sub SetPictureView(ByVal file As PalTools.MkfFile, ByVal index As Integer)
        If same Then Exit Sub
        If bmp IsNot Nothing Then Array.Clear(bmp, 0, bmp.Length)
        palette = SetPalette(CType(ComboBoxPalette, ComboBox).SelectedIndex)
        Select Case file
            Case MkfFile.MKF_FBP
                PictureBoxImage.Image = PalMkfs(file).GetBitmap(index, palette)
                If PictureBoxImage.Image IsNot Nothing Then
                    LabelInfo.Text = "第 1/1 幅 320 * 200"
                    PanelImage.Enabled = True
                Else
                    LabelInfo.Text = "第 0/0 幅 0 * 0"
                    PanelImage.Enabled = False
                End If
                SetGroup(False)
            Case MkfFile.MKF_BALL, MkfFile.MKF_RGM
                PictureBoxImage.Image = PalMkfs(file).GetBitmap(index, palette)
                If PictureBoxImage.Image IsNot Nothing Then
                    LabelInfo.Text = "第 1/1 幅 " & Format(PictureBoxImage.Image.Width) & " * " & Format(PictureBoxImage.Image.Height)
                    PanelImage.Enabled = True
                Else
                    LabelInfo.Text = "第 0/0 幅 0 * 0"
                    PanelImage.Enabled = False
                End If
                SetGroup(False)
            Case MkfFile.MKF_ABC, MkfFile.MKF_F, MkfFile.MKF_FIRE, MkfFile.MKF_MGO, MkfFile.MKF_GOP, MkfFile.MKF_DATA
                If file = MkfFile.MKF_DATA And index <> 9 And index <> 10 And index <> 12 Then
                    LabelInfo.Text = "第 0/0 幅 0 * 0"
                    PanelImage.Enabled = False
                    cur = 0 : total = 0
                    PictureBoxImage.Image = Nothing
                    SetGroup(False)
                    Exit Select
                End If
                cur = 1 : total = PalMkfs(file).Extract(index).Count
                bmp = PalMkfs(file).GetBitmaps(index, palette)
                If bmp IsNot Nothing Then
                    PictureBoxImage.Image = bmp(0)
                    LabelInfo.Text = "第 1/" & Format(total) & " 幅 " & Format(PictureBoxImage.Image.Width) & " * " & Format(PictureBoxImage.Image.Height)
                    PanelImage.Enabled = True
                    SetGroup(True)
                Else
                    PictureBoxImage.Image = Nothing
                    LabelInfo.Text = "第 0/0 幅 0 * 0"
                    PanelImage.Enabled = False
                    cur = 0 : total = 0
                    SetGroup(False)
                End If
            Case MkfFile.MKF_RNG
                cur = 1 : total = PalMkfs(file).Extract(index).Count
                bmp = PalMkfs(file).GetMovie(index, palette)
                If bmp IsNot Nothing Then
                    PictureBoxImage.Image = bmp(0)
                    LabelInfo.Text = "第 1/" & Format(total) & " 幅 320 * 200"
                    PanelImage.Enabled = True
                    SetGroup(True)
                Else
                    PictureBoxImage.Image = Nothing
                    LabelInfo.Text = "第 0/0 幅 0 * 0"
                    PanelImage.Enabled = False
                    cur = 0 : total = 0
                    SetGroup(False)
                End If
            Case Else
                PictureBoxImage.Image = Nothing
                LabelInfo.Text = "第 0/0 幅 0 * 0"
                PanelImage.Enabled = False
                cur = 0 : total = 0
                SetGroup(False)
        End Select
    End Sub

    Private Sub SetMap(ByVal index As Integer)
        If PalMkfs(MkfFile.MKF_MAP) Is Nothing Or PalMkfs(MkfFile.MKF_GOP) Is Nothing Then Exit Sub
        If index < 0 Or ComboBoxPaletteMap.SelectedIndex < 0 Then Exit Sub
        Dim pat As IntPtr = SetPalette(ComboBoxPaletteMap.SelectedIndex)
        Dim i As Integer = ComboBoxMap.SelectedItem
        Dim layer As Integer = 0
        Dim grid As Boolean = CheckBoxGrid.Checked
        If CheckBoxLayer0.Checked Then layer = layer Or &H1
        If CheckBoxLayer1.Checked Then layer = layer Or &H2
        PictureBoxMap.Image = PalMkfs(MkfFile.MKF_MAP).GetBitmap(i, pat, PalMkfs(MkfFile.MKF_GOP), layer, grid)
    End Sub

    Private Function SetPalette(ByVal index As Integer) As System.IntPtr
        Select Case index
            Case 0
                Return PalPat.GetPalette(0, False)
            Case 1
                Return PalPat.GetPalette(0, True)
            Case 2
                Return PalPat.GetPalette(1, False)
            Case 3
                Return PalPat.GetPalette(2, False)
            Case 4
                Return PalPat.GetPalette(3, False)
            Case 5
                Return PalPat.GetPalette(4, False)
            Case 6
                Return PalPat.GetPalette(5, False)
            Case 7
                Return PalPat.GetPalette(5, True)
            Case 8
                Return PalPat.GetPalette(6, False)
            Case 9
                Return PalPat.GetPalette(7, False)
            Case 10
                Return PalPat.GetPalette(8, False)
        End Select
    End Function

    Private Function CheckNode(ByVal node As TreeNode) As Boolean
        If node.Tag Is Nothing Then
            ListViewHex.VirtualListSize = 0
            PanelImage.Enabled = False
            ListViewHex.Enabled = False
            PictureBoxImage.Image = Nothing
            Return False
        ElseIf node.Tag.GetType Is GetType(PalTools.MkfFile) Then
            PanelImage.Enabled = False
            ListViewHex.Enabled = True
            PictureBoxImage.Image = Nothing
            Return True
        Else
            PanelImage.Enabled = True
            ListViewHex.Enabled = True
            Return True
        End If
    End Function

    Private Sub SetGroup(ByVal group As Boolean)
        ButtonPrev.Enabled = group
        ButtonNext.Enabled = group
        ButtonPlay.Enabled = group
    End Sub

    Private Sub ExplorerTreeView_AfterSelect(ByVal sender As System.Object, ByVal e As System.Windows.Forms.TreeViewEventArgs) Handles TreeViewFile.AfterSelect
        Dim tmp As PalTools.MkfBufferGroup
        Dim k As Integer
        Dim node As TreeNode
        If CheckNode(e.Node) Then
            If e.Node.Tag.GetType Is GetType(PalTools.MkfFile) Then
                If TabControlView.SelectedIndex = 0 Then SetHexView(e.Node.Tag, -1)
            Else
                If e.Node.Tag = 3 Then
                    Select Case TabControlView.SelectedIndex
                        Case 0
                            SetHexView(e.Node.Parent.Tag, e.Node.Index)
                        Case 1
                            SetPictureView(e.Node.Parent.Tag, e.Node.Index)
                    End Select
                    Select Case CType(e.Node.Parent.Tag, PalTools.MkfFile)
                        Case MkfFile.MKF_ABC, MkfFile.MKF_F, MkfFile.MKF_FIRE, MkfFile.MKF_GOP, MkfFile.MKF_MGO, MkfFile.MKF_RNG
                            e.Node.Nodes.Clear()
                            tmp = PalMkfs(e.Node.Parent.Tag).Extract(e.Node.Index)
                            For k = 0 To tmp.Count - 1
                                node = e.Node.Nodes.Add("(" & Format(k) & "):" & Format(tmp.Item(k).Size) & " 字节")
                                node.Tag = 4
                            Next
                    End Select
                ElseIf e.Node.Tag = 4 Then
                    tmp = PalMkfs(e.Node.Parent.Parent.Tag).Extract(e.Node.Parent.Index)
                    Select Case TabControlView.SelectedIndex
                        Case 0
                            SetHexView(tmp.Item(e.Node.Parent.Index))
                        Case 1
                            'SetPictureView(e.Node.Parent.Tag, e.Node.Index)
                    End Select
                End If
            End If
        End If
    End Sub

    Private Sub ComboBoxPalette_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ComboBoxPalette.SelectedIndexChanged
        If PalPat Is Nothing Then Exit Sub
        If TreeViewFile.SelectedNode.Tag.GetType Is GetType(Integer) Then
            If TreeViewFile.SelectedNode.Tag = 3 Then
                SetPictureView(TreeViewFile.SelectedNode.Parent.Tag, TreeViewFile.SelectedNode.Index)
            End If
        End If
    End Sub

    Private Sub TabControlView_Selected(ByVal sender As Object, ByVal e As System.Windows.Forms.TabControlEventArgs) Handles TabControlView.Selected
        If Not CheckNode(TreeViewFile.SelectedNode) Then Exit Sub
        Select Case e.TabPageIndex
            Case 0
                If TreeViewFile.SelectedNode.Tag.GetType Is GetType(PalTools.MkfFile) Then
                    SetHexView(TreeViewFile.SelectedNode.Tag, -1)
                Else
                    If TreeViewFile.SelectedNode.Tag = 3 Then
                        SetHexView(TreeViewFile.SelectedNode.Parent.Tag, TreeViewFile.SelectedNode.Index)
                    End If
                End If
            Case 1
                If TreeViewFile.SelectedNode.Tag.GetType Is GetType(Integer) Then
                    If TreeViewFile.SelectedNode.Tag = 3 Then
                        SetPictureView(TreeViewFile.SelectedNode.Parent.Tag, TreeViewFile.SelectedNode.Index)
                    End If
                End If
            Case 2
                If PalMkfs(MkfFile.MKF_MAP) Is Nothing Or PalMkfs(MkfFile.MKF_GOP) Is Nothing Then
                    PanelMap.Enabled = False
                Else
                    PanelMap.Enabled = True
                    If ComboBoxMap.SelectedIndex >= 0 Then SetMap(ComboBoxMap.SelectedIndex)
                End If
            Case 3
                If PalMkfs(MkfFile.MKF_SOUNDS) Is Nothing Then
                    ButtonWave.Enabled = False
                    LabelWave.Enabled = False
                    ListBoxWave.Enabled = False
                Else
                    ButtonWave.Enabled = True
                    LabelWave.Enabled = True
                    ListBoxWave.Enabled = True
                End If
        End Select
    End Sub

    Private Sub TreeViewFile_BeforeSelect(ByVal sender As Object, ByVal e As System.Windows.Forms.TreeViewCancelEventArgs) Handles TreeViewFile.BeforeSelect
        same = e.Node Is CType(sender, TreeView).SelectedNode
    End Sub

    Private Sub PictureBoxPalette_Paint(ByVal sender As Object, ByVal e As System.Windows.Forms.PaintEventArgs) Handles PictureBoxPalette.Paint
        If PalPat IsNot Nothing Then
            Dim colors(255) As System.Drawing.Color
            Dim i, j, x, y As Integer
            Dim patview As IntPtr
            If ListBoxPalette.SelectedIndex < 0 Then
                ListBoxPalette.SelectedIndex = 0
            End If
            patview = SetPalette(ListBoxPalette.SelectedIndex)
            For i = 0 To 255
                colors(i) = Color.FromArgb(255, Marshal.ReadByte(patview, j) << 2, Marshal.ReadByte(patview, j + 1) << 2, Marshal.ReadByte(patview, j + 2) << 2)
                j += 3
            Next
            x = 2 : y = 2
            e.Graphics.FillRectangle(Brushes.White, 0, 0, 322, 322)
            For i = 0 To 15
                For j = 0 To 15
                    e.Graphics.DrawRectangle(New Pen(Color.Black), x, y, 17, 17)
                    e.Graphics.FillRectangle(New System.Drawing.SolidBrush(colors(i * 16 + j)), x + 1, y + 1, 16, 16)
                    x += 20
                Next
                x = 2 : y += 20
            Next
        End If
    End Sub

    Private Sub ListBoxPalette_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ListBoxPalette.SelectedIndexChanged
        PictureBoxPalette.Invalidate()
    End Sub

    Private Sub ButtonPrev_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonPrev.Click
        cur -= 1
        If cur < 1 Then cur = 1
        PictureBoxImage.Image = bmp(cur - 1)
        LabelInfo.Text = "第 " & Format(cur) & "/" & Format(total) & " 幅 " & Format(PictureBoxImage.Image.Width) & " * " & Format(PictureBoxImage.Image.Height)
    End Sub

    Private Sub ButtonNext_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonNext.Click
        cur += 1
        If cur > total Then cur = total
        PictureBoxImage.Image = bmp(cur - 1)
        LabelInfo.Text = "第 " & Format(cur) & "/" & Format(total) & " 幅 " & Format(PictureBoxImage.Image.Width) & " * " & Format(PictureBoxImage.Image.Height)
    End Sub

    Private Sub TimerPlay_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles TimerPlay.Tick
        If cur < total Then
            cur += 1
        Else
            cur = 1
        End If
        PictureBoxImage.Image = bmp(cur - 1)
        LabelInfo.Text = "第 " & Format(cur) & "/" & Format(total) & " 幅 " & Format(PictureBoxImage.Image.Width) & " * " & Format(PictureBoxImage.Image.Height)
    End Sub

    Private Sub ButtonPlay_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonPlay.Click
        If TimerPlay.Enabled Then
            TimerPlay.Enabled = False
            ButtonPlay.Text = "播放"
        Else
            TimerPlay.Enabled = True
            ButtonPlay.Text = "暂停"
        End If
    End Sub

    Private Sub ButtonWave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonWave.Click
        If ListBoxWave.SelectedIndex >= 0 Then
            My.Computer.Audio.Play(PalMkfs(MkfFile.MKF_SOUNDS).RawData(CType(ListBoxWave.SelectedItem, System.Int32)).Buffer, AudioPlayMode.Background)
        End If
    End Sub

    Private Sub ButtonMidi_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonMidi.Click
        If ListBoxMidi.SelectedIndex >= 0 Then
            PalTools.MultiMediaPlayer.PlayMidi(PalMkfs(MkfFile.MKF_MIDI).RawData(CType(ListBoxMidi.SelectedItem, System.Int32)).Buffer)
        End If
    End Sub

    Private Sub ComboBoxMap_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ComboBoxMap.SelectedIndexChanged
        SetMap(ComboBoxMap.SelectedIndex)
    End Sub

    Private Sub ComboBoxPaletteMap_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ComboBoxPaletteMap.SelectedIndexChanged
        SetMap(ComboBoxMap.SelectedIndex)
    End Sub

    Private Sub CheckBoxLayer0_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CheckBoxLayer0.CheckedChanged
        SetMap(ComboBoxMap.SelectedIndex)
    End Sub

    Private Sub CheckBoxLayer1_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CheckBoxLayer1.CheckedChanged
        SetMap(ComboBoxMap.SelectedIndex)
    End Sub

    Private Sub CheckBoxGrid_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CheckBoxGrid.CheckedChanged
        SetMap(ComboBoxMap.SelectedIndex)
    End Sub

    Private Sub ListViewHex_RetrieveVirtualItem(ByVal sender As Object, ByVal e As System.Windows.Forms.RetrieveVirtualItemEventArgs) Handles ListViewHex.RetrieveVirtualItem
        Dim offset As UInteger = e.ItemIndex << 4
        Dim buf As MkfBufferItem = ListViewHex.Tag
        If e.ItemIndex >= buf.Size >> 4 Then
            e.Item = SetHexViewItem(buf, offset, buf.Size And &HF)
        Else
            e.Item = SetHexViewItem(buf, offset, 16)
        End If
    End Sub

End Class