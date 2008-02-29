<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class ExplorerWindow
    Inherits System.Windows.Forms.Form

    'Form 重写 Dispose，以清理组件列表。
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing AndAlso components IsNot Nothing Then
            components.Dispose()
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Windows 窗体设计器所必需的
    Private components As System.ComponentModel.IContainer

    '注意: 以下过程是 Windows 窗体设计器所必需的
    '可以使用 Windows 窗体设计器修改它。
    '不要使用代码编辑器修改它。
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container
        Me.SplitContainer1 = New System.Windows.Forms.SplitContainer
        Me.TreeViewFile = New System.Windows.Forms.TreeView
        Me.TabControlView = New System.Windows.Forms.TabControl
        Me.TabPageHex = New System.Windows.Forms.TabPage
        Me.ListViewHex = New System.Windows.Forms.ListView
        Me.ColumnHeaderOffset = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeaderHex = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeaderAscii = New System.Windows.Forms.ColumnHeader
        Me.TabPagePicture = New System.Windows.Forms.TabPage
        Me.PictureBoxImage = New System.Windows.Forms.PictureBox
        Me.PanelImage = New System.Windows.Forms.Panel
        Me.ButtonNext = New System.Windows.Forms.Button
        Me.ButtonPlay = New System.Windows.Forms.Button
        Me.ButtonPrev = New System.Windows.Forms.Button
        Me.ComboBoxPalette = New System.Windows.Forms.ComboBox
        Me.LabelInfo = New System.Windows.Forms.Label
        Me.TabPageMap = New System.Windows.Forms.TabPage
        Me.PanelMapImage = New System.Windows.Forms.Panel
        Me.PictureBoxMap = New System.Windows.Forms.PictureBox
        Me.PanelMap = New System.Windows.Forms.Panel
        Me.ComboBoxMap = New System.Windows.Forms.ComboBox
        Me.CheckBoxGrid = New System.Windows.Forms.CheckBox
        Me.CheckBoxLayer1 = New System.Windows.Forms.CheckBox
        Me.CheckBoxLayer0 = New System.Windows.Forms.CheckBox
        Me.ComboBoxPaletteMap = New System.Windows.Forms.ComboBox
        Me.TabPageSound = New System.Windows.Forms.TabPage
        Me.ButtonWave = New System.Windows.Forms.Button
        Me.LabelWave = New System.Windows.Forms.Label
        Me.ListBoxWave = New System.Windows.Forms.ListBox
        Me.ListBoxRix = New System.Windows.Forms.ListBox
        Me.ButtonRix = New System.Windows.Forms.Button
        Me.LabelRix = New System.Windows.Forms.Label
        Me.ListBoxVoc = New System.Windows.Forms.ListBox
        Me.ButtonVoc = New System.Windows.Forms.Button
        Me.LabelVoc = New System.Windows.Forms.Label
        Me.ListBoxMidi = New System.Windows.Forms.ListBox
        Me.ButtonMidi = New System.Windows.Forms.Button
        Me.LabelMidi = New System.Windows.Forms.Label
        Me.TabPagePalette = New System.Windows.Forms.TabPage
        Me.ListBoxPalette = New System.Windows.Forms.ListBox
        Me.PictureBoxPalette = New System.Windows.Forms.PictureBox
        Me.TimerPlay = New System.Windows.Forms.Timer(Me.components)
        Me.SplitContainer1.Panel1.SuspendLayout()
        Me.SplitContainer1.Panel2.SuspendLayout()
        Me.SplitContainer1.SuspendLayout()
        Me.TabControlView.SuspendLayout()
        Me.TabPageHex.SuspendLayout()
        Me.TabPagePicture.SuspendLayout()
        CType(Me.PictureBoxImage, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.PanelImage.SuspendLayout()
        Me.TabPageMap.SuspendLayout()
        Me.PanelMapImage.SuspendLayout()
        CType(Me.PictureBoxMap, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.PanelMap.SuspendLayout()
        Me.TabPageSound.SuspendLayout()
        Me.TabPagePalette.SuspendLayout()
        CType(Me.PictureBoxPalette, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'SplitContainer1
        '
        Me.SplitContainer1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.SplitContainer1.Location = New System.Drawing.Point(0, 0)
        Me.SplitContainer1.Name = "SplitContainer1"
        '
        'SplitContainer1.Panel1
        '
        Me.SplitContainer1.Panel1.Controls.Add(Me.TreeViewFile)
        '
        'SplitContainer1.Panel2
        '
        Me.SplitContainer1.Panel2.Controls.Add(Me.TabControlView)
        Me.SplitContainer1.Size = New System.Drawing.Size(603, 374)
        Me.SplitContainer1.SplitterDistance = 200
        Me.SplitContainer1.TabIndex = 0
        '
        'TreeViewFile
        '
        Me.TreeViewFile.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TreeViewFile.Location = New System.Drawing.Point(0, 0)
        Me.TreeViewFile.Name = "TreeViewFile"
        Me.TreeViewFile.Size = New System.Drawing.Size(200, 374)
        Me.TreeViewFile.TabIndex = 1
        '
        'TabControlView
        '
        Me.TabControlView.Controls.Add(Me.TabPageHex)
        Me.TabControlView.Controls.Add(Me.TabPagePicture)
        Me.TabControlView.Controls.Add(Me.TabPageMap)
        Me.TabControlView.Controls.Add(Me.TabPageSound)
        Me.TabControlView.Controls.Add(Me.TabPagePalette)
        Me.TabControlView.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TabControlView.Location = New System.Drawing.Point(0, 0)
        Me.TabControlView.Name = "TabControlView"
        Me.TabControlView.SelectedIndex = 0
        Me.TabControlView.Size = New System.Drawing.Size(399, 374)
        Me.TabControlView.TabIndex = 0
        '
        'TabPageHex
        '
        Me.TabPageHex.Controls.Add(Me.ListViewHex)
        Me.TabPageHex.Location = New System.Drawing.Point(4, 21)
        Me.TabPageHex.Name = "TabPageHex"
        Me.TabPageHex.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPageHex.Size = New System.Drawing.Size(391, 349)
        Me.TabPageHex.TabIndex = 0
        Me.TabPageHex.Text = "十六进制"
        Me.TabPageHex.UseVisualStyleBackColor = True
        '
        'ListViewHex
        '
        Me.ListViewHex.Columns.AddRange(New System.Windows.Forms.ColumnHeader() {Me.ColumnHeaderOffset, Me.ColumnHeaderHex, Me.ColumnHeaderAscii})
        Me.ListViewHex.Dock = System.Windows.Forms.DockStyle.Fill
        Me.ListViewHex.FullRowSelect = True
        Me.ListViewHex.Location = New System.Drawing.Point(3, 3)
        Me.ListViewHex.Name = "ListViewHex"
        Me.ListViewHex.ShowGroups = False
        Me.ListViewHex.Size = New System.Drawing.Size(385, 343)
        Me.ListViewHex.TabIndex = 1
        Me.ListViewHex.UseCompatibleStateImageBehavior = False
        Me.ListViewHex.View = System.Windows.Forms.View.Details
        Me.ListViewHex.VirtualMode = True
        '
        'ColumnHeaderOffset
        '
        Me.ColumnHeaderOffset.Text = "偏移量"
        Me.ColumnHeaderOffset.Width = 56
        '
        'ColumnHeaderHex
        '
        Me.ColumnHeaderHex.Text = "十六进制值"
        Me.ColumnHeaderHex.Width = 306
        '
        'ColumnHeaderAscii
        '
        Me.ColumnHeaderAscii.Text = "ASCII值"
        Me.ColumnHeaderAscii.Width = 108
        '
        'TabPagePicture
        '
        Me.TabPagePicture.Controls.Add(Me.PictureBoxImage)
        Me.TabPagePicture.Controls.Add(Me.PanelImage)
        Me.TabPagePicture.Location = New System.Drawing.Point(4, 21)
        Me.TabPagePicture.Name = "TabPagePicture"
        Me.TabPagePicture.Size = New System.Drawing.Size(391, 349)
        Me.TabPagePicture.TabIndex = 1
        Me.TabPagePicture.Text = "图片/动画"
        Me.TabPagePicture.UseVisualStyleBackColor = True
        '
        'PictureBoxImage
        '
        Me.PictureBoxImage.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PictureBoxImage.Location = New System.Drawing.Point(0, 27)
        Me.PictureBoxImage.Name = "PictureBoxImage"
        Me.PictureBoxImage.Size = New System.Drawing.Size(391, 322)
        Me.PictureBoxImage.TabIndex = 5
        Me.PictureBoxImage.TabStop = False
        '
        'PanelImage
        '
        Me.PanelImage.Controls.Add(Me.ButtonNext)
        Me.PanelImage.Controls.Add(Me.ButtonPlay)
        Me.PanelImage.Controls.Add(Me.ButtonPrev)
        Me.PanelImage.Controls.Add(Me.ComboBoxPalette)
        Me.PanelImage.Controls.Add(Me.LabelInfo)
        Me.PanelImage.Dock = System.Windows.Forms.DockStyle.Top
        Me.PanelImage.Location = New System.Drawing.Point(0, 0)
        Me.PanelImage.Name = "PanelImage"
        Me.PanelImage.Size = New System.Drawing.Size(391, 27)
        Me.PanelImage.TabIndex = 4
        '
        'ButtonNext
        '
        Me.ButtonNext.Location = New System.Drawing.Point(169, 3)
        Me.ButtonNext.Name = "ButtonNext"
        Me.ButtonNext.Size = New System.Drawing.Size(32, 20)
        Me.ButtonNext.TabIndex = 6
        Me.ButtonNext.Text = ">>"
        Me.ButtonNext.UseVisualStyleBackColor = True
        '
        'ButtonPlay
        '
        Me.ButtonPlay.Location = New System.Drawing.Point(207, 3)
        Me.ButtonPlay.Name = "ButtonPlay"
        Me.ButtonPlay.Size = New System.Drawing.Size(51, 20)
        Me.ButtonPlay.TabIndex = 5
        Me.ButtonPlay.Text = "播放"
        Me.ButtonPlay.UseVisualStyleBackColor = True
        '
        'ButtonPrev
        '
        Me.ButtonPrev.Location = New System.Drawing.Point(131, 3)
        Me.ButtonPrev.Name = "ButtonPrev"
        Me.ButtonPrev.Size = New System.Drawing.Size(32, 20)
        Me.ButtonPrev.TabIndex = 4
        Me.ButtonPrev.Text = "<<"
        Me.ButtonPrev.UseVisualStyleBackColor = True
        '
        'ComboBoxPalette
        '
        Me.ComboBoxPalette.FormattingEnabled = True
        Me.ComboBoxPalette.Items.AddRange(New Object() {"0#调色板（白天）", "0#调色板（夜晚）", "1#调色板", "2#调色板", "3#调色板", "4#调色板", "5#调色板（白天）", "5#调色板（夜晚）", "6#调色板", "7#调色板", "8#调色板"})
        Me.ComboBoxPalette.Location = New System.Drawing.Point(3, 3)
        Me.ComboBoxPalette.Name = "ComboBoxPalette"
        Me.ComboBoxPalette.Size = New System.Drawing.Size(122, 20)
        Me.ComboBoxPalette.TabIndex = 0
        Me.ComboBoxPalette.Text = "0#调色板（白天）"
        '
        'LabelInfo
        '
        Me.LabelInfo.AutoSize = True
        Me.LabelInfo.Location = New System.Drawing.Point(264, 7)
        Me.LabelInfo.Name = "LabelInfo"
        Me.LabelInfo.Size = New System.Drawing.Size(95, 12)
        Me.LabelInfo.TabIndex = 3
        Me.LabelInfo.Text = "第 0/0 幅 0 * 0"
        '
        'TabPageMap
        '
        Me.TabPageMap.Controls.Add(Me.PanelMapImage)
        Me.TabPageMap.Controls.Add(Me.PanelMap)
        Me.TabPageMap.Location = New System.Drawing.Point(4, 21)
        Me.TabPageMap.Name = "TabPageMap"
        Me.TabPageMap.Size = New System.Drawing.Size(391, 349)
        Me.TabPageMap.TabIndex = 4
        Me.TabPageMap.Text = "地图"
        Me.TabPageMap.UseVisualStyleBackColor = True
        '
        'PanelMapImage
        '
        Me.PanelMapImage.AutoScroll = True
        Me.PanelMapImage.Controls.Add(Me.PictureBoxMap)
        Me.PanelMapImage.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PanelMapImage.Location = New System.Drawing.Point(0, 25)
        Me.PanelMapImage.Name = "PanelMapImage"
        Me.PanelMapImage.Size = New System.Drawing.Size(391, 324)
        Me.PanelMapImage.TabIndex = 3
        '
        'PictureBoxMap
        '
        Me.PictureBoxMap.Location = New System.Drawing.Point(0, 0)
        Me.PictureBoxMap.Name = "PictureBoxMap"
        Me.PictureBoxMap.Size = New System.Drawing.Size(391, 324)
        Me.PictureBoxMap.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize
        Me.PictureBoxMap.TabIndex = 4
        Me.PictureBoxMap.TabStop = False
        '
        'PanelMap
        '
        Me.PanelMap.Controls.Add(Me.ComboBoxMap)
        Me.PanelMap.Controls.Add(Me.CheckBoxGrid)
        Me.PanelMap.Controls.Add(Me.CheckBoxLayer1)
        Me.PanelMap.Controls.Add(Me.CheckBoxLayer0)
        Me.PanelMap.Controls.Add(Me.ComboBoxPaletteMap)
        Me.PanelMap.Dock = System.Windows.Forms.DockStyle.Top
        Me.PanelMap.Location = New System.Drawing.Point(0, 0)
        Me.PanelMap.Name = "PanelMap"
        Me.PanelMap.Size = New System.Drawing.Size(391, 25)
        Me.PanelMap.TabIndex = 2
        '
        'ComboBoxMap
        '
        Me.ComboBoxMap.FormattingEnabled = True
        Me.ComboBoxMap.Location = New System.Drawing.Point(4, 4)
        Me.ComboBoxMap.Name = "ComboBoxMap"
        Me.ComboBoxMap.Size = New System.Drawing.Size(89, 20)
        Me.ComboBoxMap.TabIndex = 5
        '
        'CheckBoxGrid
        '
        Me.CheckBoxGrid.AutoSize = True
        Me.CheckBoxGrid.Location = New System.Drawing.Point(323, 6)
        Me.CheckBoxGrid.Name = "CheckBoxGrid"
        Me.CheckBoxGrid.Size = New System.Drawing.Size(60, 16)
        Me.CheckBoxGrid.TabIndex = 4
        Me.CheckBoxGrid.Text = "网格线"
        Me.CheckBoxGrid.UseVisualStyleBackColor = True
        '
        'CheckBoxLayer1
        '
        Me.CheckBoxLayer1.AutoSize = True
        Me.CheckBoxLayer1.Checked = True
        Me.CheckBoxLayer1.CheckState = System.Windows.Forms.CheckState.Checked
        Me.CheckBoxLayer1.Location = New System.Drawing.Point(275, 6)
        Me.CheckBoxLayer1.Name = "CheckBoxLayer1"
        Me.CheckBoxLayer1.Size = New System.Drawing.Size(42, 16)
        Me.CheckBoxLayer1.TabIndex = 3
        Me.CheckBoxLayer1.Text = "层1"
        Me.CheckBoxLayer1.UseVisualStyleBackColor = True
        '
        'CheckBoxLayer0
        '
        Me.CheckBoxLayer0.AutoSize = True
        Me.CheckBoxLayer0.Checked = True
        Me.CheckBoxLayer0.CheckState = System.Windows.Forms.CheckState.Checked
        Me.CheckBoxLayer0.Location = New System.Drawing.Point(227, 6)
        Me.CheckBoxLayer0.Name = "CheckBoxLayer0"
        Me.CheckBoxLayer0.Size = New System.Drawing.Size(42, 16)
        Me.CheckBoxLayer0.TabIndex = 2
        Me.CheckBoxLayer0.Text = "层0"
        Me.CheckBoxLayer0.UseVisualStyleBackColor = True
        '
        'ComboBoxPaletteMap
        '
        Me.ComboBoxPaletteMap.FormattingEnabled = True
        Me.ComboBoxPaletteMap.Items.AddRange(New Object() {"0#调色板（白天）", "0#调色板（夜晚）", "1#调色板", "2#调色板", "3#调色板", "4#调色板", "5#调色板（白天）", "5#调色板（夜晚）", "6#调色板", "7#调色板", "8#调色板"})
        Me.ComboBoxPaletteMap.Location = New System.Drawing.Point(99, 4)
        Me.ComboBoxPaletteMap.Name = "ComboBoxPaletteMap"
        Me.ComboBoxPaletteMap.Size = New System.Drawing.Size(122, 20)
        Me.ComboBoxPaletteMap.TabIndex = 1
        Me.ComboBoxPaletteMap.Text = "0#调色板（白天）"
        '
        'TabPageSound
        '
        Me.TabPageSound.Controls.Add(Me.ButtonWave)
        Me.TabPageSound.Controls.Add(Me.LabelWave)
        Me.TabPageSound.Controls.Add(Me.ListBoxWave)
        Me.TabPageSound.Controls.Add(Me.ListBoxRix)
        Me.TabPageSound.Controls.Add(Me.ButtonRix)
        Me.TabPageSound.Controls.Add(Me.LabelRix)
        Me.TabPageSound.Controls.Add(Me.ListBoxVoc)
        Me.TabPageSound.Controls.Add(Me.ButtonVoc)
        Me.TabPageSound.Controls.Add(Me.LabelVoc)
        Me.TabPageSound.Controls.Add(Me.ListBoxMidi)
        Me.TabPageSound.Controls.Add(Me.ButtonMidi)
        Me.TabPageSound.Controls.Add(Me.LabelMidi)
        Me.TabPageSound.Location = New System.Drawing.Point(4, 21)
        Me.TabPageSound.Name = "TabPageSound"
        Me.TabPageSound.Size = New System.Drawing.Size(391, 349)
        Me.TabPageSound.TabIndex = 3
        Me.TabPageSound.Text = "声音/音乐"
        Me.TabPageSound.UseVisualStyleBackColor = True
        '
        'ButtonWave
        '
        Me.ButtonWave.Enabled = False
        Me.ButtonWave.Location = New System.Drawing.Point(3, 3)
        Me.ButtonWave.Name = "ButtonWave"
        Me.ButtonWave.Size = New System.Drawing.Size(54, 21)
        Me.ButtonWave.TabIndex = 5
        Me.ButtonWave.Text = "播放"
        Me.ButtonWave.UseVisualStyleBackColor = True
        '
        'LabelWave
        '
        Me.LabelWave.AutoSize = True
        Me.LabelWave.Enabled = False
        Me.LabelWave.Location = New System.Drawing.Point(1, 27)
        Me.LabelWave.Name = "LabelWave"
        Me.LabelWave.Size = New System.Drawing.Size(35, 12)
        Me.LabelWave.TabIndex = 0
        Me.LabelWave.Text = "WAVE:"
        '
        'ListBoxWave
        '
        Me.ListBoxWave.Enabled = False
        Me.ListBoxWave.FormattingEnabled = True
        Me.ListBoxWave.ItemHeight = 12
        Me.ListBoxWave.Location = New System.Drawing.Point(3, 42)
        Me.ListBoxWave.Name = "ListBoxWave"
        Me.ListBoxWave.Size = New System.Drawing.Size(54, 136)
        Me.ListBoxWave.TabIndex = 4
        '
        'ListBoxRix
        '
        Me.ListBoxRix.Enabled = False
        Me.ListBoxRix.FormattingEnabled = True
        Me.ListBoxRix.ItemHeight = 12
        Me.ListBoxRix.Location = New System.Drawing.Point(183, 42)
        Me.ListBoxRix.Name = "ListBoxRix"
        Me.ListBoxRix.Size = New System.Drawing.Size(54, 136)
        Me.ListBoxRix.TabIndex = 13
        '
        'ButtonRix
        '
        Me.ButtonRix.Enabled = False
        Me.ButtonRix.Location = New System.Drawing.Point(183, 3)
        Me.ButtonRix.Name = "ButtonRix"
        Me.ButtonRix.Size = New System.Drawing.Size(54, 21)
        Me.ButtonRix.TabIndex = 12
        Me.ButtonRix.Text = "播放"
        Me.ButtonRix.UseVisualStyleBackColor = True
        '
        'LabelRix
        '
        Me.LabelRix.AutoSize = True
        Me.LabelRix.Enabled = False
        Me.LabelRix.Location = New System.Drawing.Point(181, 27)
        Me.LabelRix.Name = "LabelRix"
        Me.LabelRix.Size = New System.Drawing.Size(29, 12)
        Me.LabelRix.TabIndex = 11
        Me.LabelRix.Text = "RIX:"
        '
        'ListBoxVoc
        '
        Me.ListBoxVoc.Enabled = False
        Me.ListBoxVoc.FormattingEnabled = True
        Me.ListBoxVoc.ItemHeight = 12
        Me.ListBoxVoc.Location = New System.Drawing.Point(123, 42)
        Me.ListBoxVoc.Name = "ListBoxVoc"
        Me.ListBoxVoc.Size = New System.Drawing.Size(54, 136)
        Me.ListBoxVoc.TabIndex = 10
        '
        'ButtonVoc
        '
        Me.ButtonVoc.Enabled = False
        Me.ButtonVoc.Location = New System.Drawing.Point(123, 3)
        Me.ButtonVoc.Name = "ButtonVoc"
        Me.ButtonVoc.Size = New System.Drawing.Size(54, 21)
        Me.ButtonVoc.TabIndex = 9
        Me.ButtonVoc.Text = "播放"
        Me.ButtonVoc.UseVisualStyleBackColor = True
        '
        'LabelVoc
        '
        Me.LabelVoc.AutoSize = True
        Me.LabelVoc.Enabled = False
        Me.LabelVoc.Location = New System.Drawing.Point(121, 27)
        Me.LabelVoc.Name = "LabelVoc"
        Me.LabelVoc.Size = New System.Drawing.Size(29, 12)
        Me.LabelVoc.TabIndex = 8
        Me.LabelVoc.Text = "VOC:"
        '
        'ListBoxMidi
        '
        Me.ListBoxMidi.Enabled = False
        Me.ListBoxMidi.FormattingEnabled = True
        Me.ListBoxMidi.ItemHeight = 12
        Me.ListBoxMidi.Location = New System.Drawing.Point(63, 42)
        Me.ListBoxMidi.Name = "ListBoxMidi"
        Me.ListBoxMidi.Size = New System.Drawing.Size(54, 136)
        Me.ListBoxMidi.TabIndex = 7
        '
        'ButtonMidi
        '
        Me.ButtonMidi.Enabled = False
        Me.ButtonMidi.Location = New System.Drawing.Point(63, 3)
        Me.ButtonMidi.Name = "ButtonMidi"
        Me.ButtonMidi.Size = New System.Drawing.Size(54, 21)
        Me.ButtonMidi.TabIndex = 6
        Me.ButtonMidi.Text = "播放"
        Me.ButtonMidi.UseVisualStyleBackColor = True
        '
        'LabelMidi
        '
        Me.LabelMidi.AutoSize = True
        Me.LabelMidi.Enabled = False
        Me.LabelMidi.Location = New System.Drawing.Point(61, 27)
        Me.LabelMidi.Name = "LabelMidi"
        Me.LabelMidi.Size = New System.Drawing.Size(35, 12)
        Me.LabelMidi.TabIndex = 1
        Me.LabelMidi.Text = "MIDI:"
        '
        'TabPagePalette
        '
        Me.TabPagePalette.Controls.Add(Me.ListBoxPalette)
        Me.TabPagePalette.Controls.Add(Me.PictureBoxPalette)
        Me.TabPagePalette.Location = New System.Drawing.Point(4, 21)
        Me.TabPagePalette.Name = "TabPagePalette"
        Me.TabPagePalette.Size = New System.Drawing.Size(391, 349)
        Me.TabPagePalette.TabIndex = 2
        Me.TabPagePalette.Text = "调色板"
        Me.TabPagePalette.UseVisualStyleBackColor = True
        '
        'ListBoxPalette
        '
        Me.ListBoxPalette.Dock = System.Windows.Forms.DockStyle.Right
        Me.ListBoxPalette.FormattingEnabled = True
        Me.ListBoxPalette.ItemHeight = 12
        Me.ListBoxPalette.Items.AddRange(New Object() {"0#调色板（白天）", "0#调色板（夜晚）", "1#调色板", "2#调色板", "3#调色板", "4#调色板", "5#调色板（白天）", "5#调色板（夜晚）", "6#调色板", "7#调色板", "8#调色板"})
        Me.ListBoxPalette.Location = New System.Drawing.Point(288, 0)
        Me.ListBoxPalette.Name = "ListBoxPalette"
        Me.ListBoxPalette.Size = New System.Drawing.Size(103, 340)
        Me.ListBoxPalette.TabIndex = 3
        '
        'PictureBoxPalette
        '
        Me.PictureBoxPalette.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PictureBoxPalette.Location = New System.Drawing.Point(0, 0)
        Me.PictureBoxPalette.Name = "PictureBoxPalette"
        Me.PictureBoxPalette.Size = New System.Drawing.Size(391, 349)
        Me.PictureBoxPalette.TabIndex = 2
        Me.PictureBoxPalette.TabStop = False
        '
        'TimerPlay
        '
        '
        'ExplorerWindow
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 12.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(603, 374)
        Me.Controls.Add(Me.SplitContainer1)
        Me.Name = "ExplorerWindow"
        Me.Text = "Explorer"
        Me.SplitContainer1.Panel1.ResumeLayout(False)
        Me.SplitContainer1.Panel2.ResumeLayout(False)
        Me.SplitContainer1.ResumeLayout(False)
        Me.TabControlView.ResumeLayout(False)
        Me.TabPageHex.ResumeLayout(False)
        Me.TabPagePicture.ResumeLayout(False)
        CType(Me.PictureBoxImage, System.ComponentModel.ISupportInitialize).EndInit()
        Me.PanelImage.ResumeLayout(False)
        Me.PanelImage.PerformLayout()
        Me.TabPageMap.ResumeLayout(False)
        Me.PanelMapImage.ResumeLayout(False)
        Me.PanelMapImage.PerformLayout()
        CType(Me.PictureBoxMap, System.ComponentModel.ISupportInitialize).EndInit()
        Me.PanelMap.ResumeLayout(False)
        Me.PanelMap.PerformLayout()
        Me.TabPageSound.ResumeLayout(False)
        Me.TabPageSound.PerformLayout()
        Me.TabPagePalette.ResumeLayout(False)
        CType(Me.PictureBoxPalette, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents SplitContainer1 As System.Windows.Forms.SplitContainer
    Friend WithEvents TreeViewFile As System.Windows.Forms.TreeView
    Friend WithEvents TabControlView As System.Windows.Forms.TabControl
    Friend WithEvents TabPageHex As System.Windows.Forms.TabPage
    Friend WithEvents ListViewHex As System.Windows.Forms.ListView
    Friend WithEvents ColumnHeaderOffset As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeaderHex As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeaderAscii As System.Windows.Forms.ColumnHeader
    Friend WithEvents TabPagePicture As System.Windows.Forms.TabPage
    Friend WithEvents ComboBoxPalette As System.Windows.Forms.ComboBox
    Friend WithEvents LabelInfo As System.Windows.Forms.Label
    Friend WithEvents PanelImage As System.Windows.Forms.Panel
    Friend WithEvents PictureBoxImage As System.Windows.Forms.PictureBox
    Friend WithEvents ButtonPrev As System.Windows.Forms.Button
    Friend WithEvents ButtonPlay As System.Windows.Forms.Button
    Friend WithEvents ButtonNext As System.Windows.Forms.Button
    Friend WithEvents TabPagePalette As System.Windows.Forms.TabPage
    Friend WithEvents PictureBoxPalette As System.Windows.Forms.PictureBox
    Friend WithEvents ListBoxPalette As System.Windows.Forms.ListBox
    Friend WithEvents TimerPlay As System.Windows.Forms.Timer
    Friend WithEvents TabPageSound As System.Windows.Forms.TabPage
    Friend WithEvents LabelWave As System.Windows.Forms.Label
    Friend WithEvents ListBoxWave As System.Windows.Forms.ListBox
    Friend WithEvents LabelMidi As System.Windows.Forms.Label
    Friend WithEvents ButtonWave As System.Windows.Forms.Button
    Friend WithEvents ButtonMidi As System.Windows.Forms.Button
    Friend WithEvents ListBoxRix As System.Windows.Forms.ListBox
    Friend WithEvents ButtonRix As System.Windows.Forms.Button
    Friend WithEvents LabelRix As System.Windows.Forms.Label
    Friend WithEvents ListBoxVoc As System.Windows.Forms.ListBox
    Friend WithEvents ButtonVoc As System.Windows.Forms.Button
    Friend WithEvents LabelVoc As System.Windows.Forms.Label
    Friend WithEvents ListBoxMidi As System.Windows.Forms.ListBox
    Friend WithEvents TabPageMap As System.Windows.Forms.TabPage
    Friend WithEvents PanelMap As System.Windows.Forms.Panel
    Friend WithEvents CheckBoxGrid As System.Windows.Forms.CheckBox
    Friend WithEvents CheckBoxLayer1 As System.Windows.Forms.CheckBox
    Friend WithEvents CheckBoxLayer0 As System.Windows.Forms.CheckBox
    Friend WithEvents ComboBoxPaletteMap As System.Windows.Forms.ComboBox
    Friend WithEvents ComboBoxMap As System.Windows.Forms.ComboBox
    Friend WithEvents PanelMapImage As System.Windows.Forms.Panel
    Friend WithEvents PictureBoxMap As System.Windows.Forms.PictureBox
End Class
