Imports System.Runtime.InteropServices

Public Class MainWindow

    Dim cur As Integer
    Dim samepic As Boolean = False
    Dim bmp() As System.Drawing.Bitmap

    Private Sub ClearAll()
        If TimerPlay.Enabled Then
            TimerPlay.Enabled = False
            ButtonPlay.Text = "播放"
        End If
        bmp = Nothing
        ListViewHex.VirtualListSize = 0
        ListViewItems.Items.Clear()
        TreeViewFile.Nodes.Clear()
        ListBoxWave.Items.Clear()
        ListBoxVoc.Items.Clear()
        ListBoxMidi.Items.Clear()
        ListBoxRix.Items.Clear()
        ComboBoxMap.Items.Clear()
        PanelWave.Enabled = False
        PanelMidi.Enabled = False
        PanelVoc.Enabled = False
        PanelRix.Enabled = False
    End Sub

    Private Sub SetTabPages(ByVal i As MkfFile)
        Dim j As Integer
        Select Case i
            Case MkfFile.MKF_PAT
                PalPat = New PalTools.PalPalette(PalPath & PalMkfName(i))
            Case MkfFile.MKF_MAP
                PanelMap.Enabled = True
                For j = 0 To PalMkfs(i).Count - 1
                    If PalMkfs(i).RawLength(j) > 0 Then ComboBoxMap.Items.Add(j)
                Next
            Case MkfFile.MKF_MIDI
                PanelMidi.Enabled = True
                For j = 0 To PalMkfs(i).Count - 1
                    If PalMkfs(i).RawLength(j) > 0 Then ListBoxMidi.Items.Add(j)
                Next
            Case MkfFile.MKF_MUS
                PanelRix.Enabled = True
                For j = 0 To PalMkfs(i).Count - 1
                    If PalMkfs(i).RawLength(j) > 0 Then ListBoxRix.Items.Add(j)
                Next
            Case MkfFile.MKF_SOUNDS
                PanelWave.Enabled = True
                For j = 0 To PalMkfs(i).Count - 1
                    If PalMkfs(i).RawLength(j) > 0 Then ListBoxWave.Items.Add(j)
                Next
            Case MkfFile.MKF_VOC
                PanelVoc.Enabled = True
                For j = 0 To PalMkfs(i).Count - 1
                    If PalMkfs(i).RawLength(j) > 0 Then ListBoxVoc.Items.Add(j)
                Next
        End Select
    End Sub

    Private Sub SetHexView(ByVal buf As PalTools.MkfBufferItem)
        Dim num As Integer
        num = buf.Size >> 4
        If buf.Size And &HF Then num += 1
        If ListViewHex.VirtualListSize = num Then ListViewHex.VirtualListSize = 0
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

    Private Sub SetPicturePanel()
        If cur = 0 Then
            PictureBoxImage.Image = Nothing
            LabelInfo.Text = "第 0/0 幅 0 * 0"
            PanelImage.Enabled = False
            ButtonPrev.Enabled = False
            ButtonNext.Enabled = False
            ButtonPlay.Enabled = False
        Else
            PictureBoxImage.Image = bmp(cur - 1)
            LabelInfo.Text = "第 " & cur.ToString & "/" & bmp.Length.ToString & " 幅 " & PictureBoxImage.Image.Width.ToString & " * " & PictureBoxImage.Image.Height.ToString
            PanelImage.Enabled = True
            ButtonPrev.Enabled = True
            ButtonNext.Enabled = True
            ButtonPlay.Enabled = True
        End If
    End Sub

    Private Sub SetPictureView(ByVal file As MkfFile, ByVal index As Integer, ByVal subindex As Integer)
        Dim pat As IntPtr
        Dim bm As System.Drawing.Bitmap
        If samepic And bmp IsNot Nothing Then
            cur = subindex + 1
            SetPicturePanel()
            Exit Sub
        End If
        If PalPat Is Nothing Then Exit Sub
        If bmp IsNot Nothing Then bmp = Nothing
        pat = PalPat.GetPalette(ComboBoxPalette.SelectedIndex)
        If pat = IntPtr.Zero Then Exit Sub
        Select Case file
            Case MkfFile.MKF_BALL, MkfFile.MKF_FBP, MkfFile.MKF_RGM
                bm = PalMkfs(file).GetBitmap(index, pat)
                If bm IsNot Nothing Then
                    ReDim bmp(0)
                    bmp(0) = bm
                End If
            Case MkfFile.MKF_ABC, MkfFile.MKF_DATA, MkfFile.MKF_F, MkfFile.MKF_FIRE, MkfFile.MKF_GOP, MkfFile.MKF_MGO
                bmp = PalMkfs(file).GetBitmaps(index, pat)
            Case MkfFile.MKF_RNG
                bmp = PalMkfs(file).GetMovie(index, pat)
        End Select
        If bmp Is Nothing Then
            cur = 0
        Else
            If subindex < 0 Then
                subindex = 0
            ElseIf subindex >= bmp.Length Then
                subindex = bmp.Length - 1
            End If
            cur = subindex + 1
        End If
        SetPicturePanel()
    End Sub

    Private Sub SetMapView()
        Dim layer As Integer = 0
        If ComboBoxMap.SelectedIndex < 0 Then Exit Sub
        If ComboBoxPaletteMap.SelectedIndex < 0 Then Exit Sub
        If PalPat Is Nothing Then Exit Sub
        If PalMkfs(MkfFile.MKF_GOP) Is Nothing Then Exit Sub
        If CheckBoxLayer0.Checked Then layer = layer Or &H1
        If CheckBoxLayer1.Checked Then layer = layer Or &H2
        PictureBoxMap.Image = PalMkfs(MkfFile.MKF_MAP).GetBitmap(ComboBoxMap.SelectedItem, PalPat.GetPalette(ComboBoxPaletteMap.SelectedIndex), PalMkfs(MkfFile.MKF_GOP), layer, CheckBoxGrid.Checked)
    End Sub

    Private Sub MenuExitToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ToolStripMenuItemExit.Click
        Me.Close()
    End Sub

    Private Sub ToolStripMenuItemAbout_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ToolStripMenuItemAbout.Click
        Dim about As String
        about = "PalTools.NET(PalViewer 升级版)" & vbCrLf
        about &= "基于 .NET Framework 2.0 版本创建。" & vbCrLf
        about &= "参考了 OopsWare 的 Pal95Tools 设计风格"
        MsgBox(about, MsgBoxStyle.OkOnly, "关于 PalTools.NET")
    End Sub

    Private Sub ToolStripMenuItemOpen_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ToolStripMenuItemOpen.Click
        If FolderBrowserDialogPal.ShowDialog(Me) <> Windows.Forms.DialogResult.OK Then Exit Sub
        PalPath = FolderBrowserDialogPal.SelectedPath
        If Microsoft.VisualBasic.Right(PalPath, 1) <> "\" Then PalPath &= "\"
        ClearAll()
        Dim i As MkfFile
        Dim node As TreeNode = TreeViewFile.Nodes.Add(PalPath)
        Dim node1 As TreeNode
        Dim temp As String
        node.Tag = New TreeNodeValue(0, Nothing)
        For i = MkfFile.MKF_ABC To MkfFile.MKF_VOC
            If PalMkfs(i) IsNot Nothing Then PalMkfs(i).Dispose()
            If System.IO.File.Exists(PalPath & PalMkfName(i)) Then
                PalMkfs(i) = New PalTools.PalMkf(PalPath & PalMkfName(i), i)
                temp = PalMkfName(i) & "(" & PalMkfs(i).RawLength.ToString & " 字节)"
                node1 = node.Nodes.Add(temp)
                node1.Tag = New TreeNodeValue(1, i)
                SetTabPages(i)
            End If
        Next
        If PalMkfs(MkfFile.MKF_DATA) IsNot Nothing And _
           PalMkfs(MkfFile.MKF_BALL) IsNot Nothing And _
           PalMkfs(MkfFile.MKF_SSS) IsNot Nothing And _
           System.IO.File.Exists(PalPath & PalWordName) And _
           System.IO.File.Exists(PalPath & PalMsgName) Then
            Dim j As Integer
            Dim item As ListViewItem
            Dim obj As PalTools.PalObjectData
            If PalItems IsNot Nothing Then PalItems.Dispose()
            PalItems = New PalItem(PalPath & PalMkfName(MkfFile.MKF_DATA), _
                PalPath & PalMkfName(MkfFile.MKF_SSS), PalPath & PalMsgName, PalPath & PalWordName)
            For j = &H3D To &H126
                item = ListViewItems.Items.Add(j.ToString("X4"))
                obj = PalItems.Object(j)
                item.Tag = New ListNodeItemValue(j, obj.Item.Description)
                item.SubItems.Add(Trim(PalItems.Word(j)))
                item.SubItems.Add(obj.Item.Price.ToString)
                item.SubItems.Add(obj.Item.ScriptUse.ToString("X4"))
                item.SubItems.Add(obj.Item.ScriptWear.ToString("X4"))
                item.SubItems.Add(obj.Item.ScriptThrow.ToString("X4"))
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.Useable Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.Wearable Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.Throwable Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.Noconsume Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.Noconsume Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.Sellable Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.LiUse Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.ZhaoUse Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.LinUse Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.WuUse Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.NuUse Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
                If obj.Item.Attribute And PalObjectData.PalItemObjectData.GaiUse Then
                    item.SubItems.Add("是")
                Else
                    item.SubItems.Add("否")
                End If
            Next
        End If
    End Sub

    Private Sub PictureBoxPalette_Paint(ByVal sender As Object, ByVal e As System.Windows.Forms.PaintEventArgs) Handles PictureBoxPalette.Paint
        If PalPat IsNot Nothing Then
            Dim colors(255) As System.Drawing.Color
            Dim i, j, x, y As Integer
            Dim patview As IntPtr
            If PalPat Is Nothing Then Exit Sub
            If ComboBoxPalettePat.SelectedIndex < 0 Then
                ComboBoxPalettePat.SelectedIndex = 0
            End If
            patview = PalPat.GetPalette(ComboBoxPalettePat.SelectedIndex)
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

    Private Sub ComboBoxPalettePat_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ComboBoxPalettePat.SelectedIndexChanged
        PictureBoxPalette.Invalidate()
    End Sub

    Private Sub TreeViewFile_AfterSelect(ByVal sender As System.Object, ByVal e As System.Windows.Forms.TreeViewEventArgs) Handles TreeViewFile.AfterSelect
        Dim temp As String
        Dim node As TreeNode
        Dim i As Integer
        Dim tag As TreeNodeValue = e.Node.Tag
        If tag.Level = 0 Then Exit Sub
        Select Case tag.Level
            Case 1
                If e.Node.Nodes.Count = 0 Then
                    For i = 0 To PalMkfs(tag.Mkf).Count - 1
                        temp = "(" & i.ToString("D3") & "):偏移量 " & PalMkfs(tag.Mkf).Offset(i).ToString
                        temp &= ",长度 " & PalMkfs(tag.Mkf).RawLength(i).ToString & " 字节"
                        node = e.Node.Nodes.Add(temp)
                        node.Tag = New TreeNodeValue(2, tag.Mkf)
                    Next
                End If
                If TabControlView.SelectedIndex = 0 Then
                    SetHexView(PalMkfs(tag.Mkf).RawData)
                ElseIf TabControlView.SelectedIndex = 1 Then
                    cur = 0
                    SetPicturePanel()
                End If
            Case 2
                If tag.Mkf = MkfFile.MKF_ABC Or tag.Mkf = MkfFile.MKF_F Or _
                   tag.Mkf = MkfFile.MKF_FIRE Or tag.Mkf = MkfFile.MKF_GOP Or _
                   tag.Mkf = MkfFile.MKF_MGO Or tag.Mkf = MkfFile.MKF_RNG Then
                    If e.Node.Nodes.Count = 0 Then
                        Dim lens() As Integer
                        lens = PalMkfs(tag.Mkf).ExtractLength(e.Node.Index)
                        If lens IsNot Nothing Then
                            For i = 0 To lens.Length - 1
                                temp = "(" & i.ToString("D3") & "):长度 "
                                temp &= lens(i).ToString & " 字节"
                                node = e.Node.Nodes.Add(temp)
                                node.Tag = New TreeNodeValue(3, tag.Mkf)
                            Next
                        End If
                    End If
                End If
                If TabControlView.SelectedIndex = 0 Then
                    SetHexView(PalMkfs(tag.Mkf).RawData(e.Node.Index))
                ElseIf TabControlView.SelectedIndex = 1 Then
                    SetPictureView(tag.Mkf, e.Node.Index, 0)
                    SetPicturePanel()
                End If
            Case 3
                If TabControlView.SelectedIndex = 0 Then
                    SetHexView(PalMkfs(tag.Mkf).Extract(e.Node.Parent.Index).Item(e.Node.Index))
                ElseIf TabControlView.SelectedIndex = 1 Then
                    SetPictureView(tag.Mkf, e.Node.Parent.Index, e.Node.Index)
                    SetPicturePanel()
                End If
            Case Else
                cur = 0
                SetPicturePanel()
        End Select
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

    Private Sub ComboBoxPalette_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ComboBoxPalette.SelectedIndexChanged
        If TreeViewFile.SelectedNode Is Nothing Then
            cur = 0
            SetPicturePanel()
            Exit Sub
        End If
        Dim tag As TreeNodeValue = TreeViewFile.SelectedNode.Tag
        Dim index As Integer = TreeViewFile.SelectedNode.Index
        If tag.Level = 2 Then
            samepic = False
            SetPictureView(tag.Mkf, index, 0)
            SetPicturePanel()
        ElseIf tag.Level = 3 Then
            samepic = False
            SetPictureView(tag.Mkf, TreeViewFile.SelectedNode.Parent.Index, index)
            SetPicturePanel()
        Else
            cur = 0
            SetPicturePanel()
        End If
    End Sub

    Private Sub TreeViewFile_BeforeSelect(ByVal sender As Object, ByVal e As System.Windows.Forms.TreeViewCancelEventArgs) Handles TreeViewFile.BeforeSelect
        Dim tag0, tag1 As TreeNodeValue
        samepic = False
        If e.Node Is Nothing Or TreeViewFile.SelectedNode Is Nothing Then
            If TimerPlay.Enabled Then
                TimerPlay.Enabled = False
                ButtonPlay.Text = "播放"
            End If
            Exit Sub
        End If
        tag0 = TreeViewFile.SelectedNode.Tag : tag1 = e.Node.Tag
        If tag0.Level = 3 And tag1.Level = 3 And tag0.Mkf = tag1.Mkf Then
            If e.Node.Parent Is TreeViewFile.SelectedNode.Parent Then
                samepic = True
            End If
        ElseIf tag0.Level = 2 And tag1.Level = 3 Then
            If e.Node.Parent Is TreeViewFile.SelectedNode Then
                samepic = True
            End If
        ElseIf tag0.Level = 3 And tag1.Level = 2 Then
            If e.Node Is TreeViewFile.SelectedNode.Parent Then
                samepic = True
            End If
        End If
        If Not samepic Then
            If TimerPlay.Enabled Then
                TimerPlay.Enabled = False
                ButtonPlay.Text = "播放"
            End If
        End If
    End Sub

    Private Sub ButtonPrev_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonPrev.Click
        Dim node As TreeNode = TreeViewFile.SelectedNode
        cur -= 1
        If cur < 1 Then cur = 1
        If node IsNot Nothing Then
            Dim tag As TreeNodeValue = node.Tag
            If tag.Level = 2 Then
                TreeViewFile.SelectedNode = node.Nodes(cur - 1)
            Else
                TreeViewFile.SelectedNode = node.Parent.Nodes(cur - 1)
            End If
        End If
    End Sub

    Private Sub ButtonNext_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonNext.Click
        Dim node As TreeNode = TreeViewFile.SelectedNode
        cur += 1
        If cur > bmp.Length Then cur = bmp.Length
        If node IsNot Nothing Then
            Dim tag As TreeNodeValue = node.Tag
            If tag.Level = 2 Then
                TreeViewFile.SelectedNode = node.Nodes(cur - 1)
            Else
                TreeViewFile.SelectedNode = node.Parent.Nodes(cur - 1)
            End If
        End If
    End Sub

    Private Sub ButtonPlay_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonPlay.Click
        If TimerPlay.Enabled Then
            ButtonPlay.Text = "播放"
        Else
            ButtonPlay.Text = "暂停"
        End If
        TimerPlay.Enabled = Not TimerPlay.Enabled
    End Sub

    Private Sub TimerPlay_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles TimerPlay.Tick
        Dim node As TreeNode = TreeViewFile.SelectedNode
        cur += 1
        If cur > bmp.Length Then cur = 1
        If node IsNot Nothing Then
            Dim tag As TreeNodeValue = node.Tag
            If tag.Level = 2 Then
                TreeViewFile.SelectedNode = node.Nodes(cur - 1)
            Else
                TreeViewFile.SelectedNode = node.Parent.Nodes(cur - 1)
            End If
        End If
    End Sub

    Private Sub TabControlView_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles TabControlView.SelectedIndexChanged
        Dim tag As TreeNodeValue
        Dim node As TreeNode = TreeViewFile.SelectedNode
        If TimerPlay.Enabled Then
            TimerPlay.Enabled = False
            ButtonPlay.Text = "播放"
        End If
        If node Is Nothing Then Exit Sub
        tag = node.Tag
        Select Case tag.Level
            Case 1
                If TabControlView.SelectedIndex = 0 Then
                    SetHexView(PalMkfs(tag.Mkf).RawData)
                ElseIf TabControlView.SelectedIndex = 1 Then
                    cur = 0
                    SetPicturePanel()
                End If
            Case 2
                If TabControlView.SelectedIndex = 0 Then
                    SetHexView(PalMkfs(tag.Mkf).RawData(node.Index))
                ElseIf TabControlView.SelectedIndex = 1 Then
                    SetPictureView(tag.Mkf, node.Index, 0)
                    SetPicturePanel()
                End If
            Case 3
                If TabControlView.SelectedIndex = 0 Then
                    SetHexView(PalMkfs(tag.Mkf).Extract(node.Parent.Index).Item(node.Index))
                ElseIf TabControlView.SelectedIndex = 1 Then
                    SetPictureView(tag.Mkf, node.Parent.Index, node.Index)
                    SetPicturePanel()
                End If
            Case Else
                cur = 0
                SetPicturePanel()
        End Select

    End Sub

    Private Sub ComboBoxMap_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ComboBoxMap.SelectedIndexChanged
        SetMapView()
    End Sub

    Private Sub ComboBoxPaletteMap_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ComboBoxPaletteMap.SelectedIndexChanged
        SetMapView()
    End Sub

    Private Sub CheckBoxLayer0_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CheckBoxLayer0.CheckedChanged
        SetMapView()
    End Sub

    Private Sub CheckBoxLayer1_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CheckBoxLayer1.CheckedChanged
        SetMapView()
    End Sub

    Private Sub CheckBoxGrid_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CheckBoxGrid.CheckedChanged
        SetMapView()
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

    Private Sub ButtonVoc_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonVoc.Click
        If ListBoxVoc.SelectedIndex >= 0 Then
            My.Computer.Audio.Play(PalMkfs(MkfFile.MKF_VOC).GetWave(CType(ListBoxVoc.SelectedItem, System.Int32)), AudioPlayMode.Background)
        End If
    End Sub

    Private Sub ListViewItems_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ListViewItems.SelectedIndexChanged
        If ListViewItems.SelectedIndices.Count > 0 Then
            Dim i As ListNodeItemValue = ListViewItems.SelectedItems(0).Tag
            PictureBoxItem.Image = PalMkfs(MkfFile.MKF_BALL).GetBitmap(PalItems.Object(i.Index).Item.Index, PalPat.GetPalette(0))
            LabelItemInfo.Text = ""
            If i.Description > 0 Then
                Dim pes As PalEventScript
                pes = PalItems.Script(i.Description)
                If pes.Instruction = &HA7 Then
                    Dim j As Integer = i.Description + 1
                    Do
                        pes = PalItems.Script(j)
                        If pes.Instruction <> &HFFFF Then Exit Do
                        LabelItemInfo.Text &= PalItems.Message(pes.Parameter0)
                        j += 1
                    Loop
                End If
            Else
                LabelItemInfo.Visible = False
            End If
        End If
    End Sub

End Class
