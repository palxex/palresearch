<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class MainWindow
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
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(MainWindow))
        Me.MenuStripMainWindow = New System.Windows.Forms.MenuStrip
        Me.ToolStripMenuItemFile = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripMenuItemOpen = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripMenuItemSaveAs = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripMenuItem1 = New System.Windows.Forms.ToolStripSeparator
        Me.ToolStripMenuItemExit = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripMenuItemHelp = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripMenuItemAbout = New System.Windows.Forms.ToolStripMenuItem
        Me.FolderBrowserDialogPal = New System.Windows.Forms.FolderBrowserDialog
        Me.StatusStripMainWindow = New System.Windows.Forms.StatusStrip
        Me.ToolStripStatusLabelFile = New System.Windows.Forms.ToolStripStatusLabel
        Me.ToolStripProgressBarFile = New System.Windows.Forms.ToolStripProgressBar
        Me.SplitContainerMain = New System.Windows.Forms.SplitContainer
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
        Me.TableLayoutPanelSound = New System.Windows.Forms.TableLayoutPanel
        Me.PanelRix = New System.Windows.Forms.Panel
        Me.ListBoxRix = New System.Windows.Forms.ListBox
        Me.Panel7 = New System.Windows.Forms.Panel
        Me.ButtonRix = New System.Windows.Forms.Button
        Me.LabelRix = New System.Windows.Forms.Label
        Me.PanelVoc = New System.Windows.Forms.Panel
        Me.ListBoxVoc = New System.Windows.Forms.ListBox
        Me.Panel5 = New System.Windows.Forms.Panel
        Me.ButtonVoc = New System.Windows.Forms.Button
        Me.LabelVoc = New System.Windows.Forms.Label
        Me.PanelWave = New System.Windows.Forms.Panel
        Me.ListBoxWave = New System.Windows.Forms.ListBox
        Me.Panel1 = New System.Windows.Forms.Panel
        Me.ButtonWave = New System.Windows.Forms.Button
        Me.LabelWave = New System.Windows.Forms.Label
        Me.PanelMidi = New System.Windows.Forms.Panel
        Me.ListBoxMidi = New System.Windows.Forms.ListBox
        Me.Panel3 = New System.Windows.Forms.Panel
        Me.ButtonMidi = New System.Windows.Forms.Button
        Me.LabelMidi = New System.Windows.Forms.Label
        Me.TabPagePalette = New System.Windows.Forms.TabPage
        Me.PictureBoxPalette = New System.Windows.Forms.PictureBox
        Me.ComboBoxPalettePat = New System.Windows.Forms.ComboBox
        Me.TabPageItem = New System.Windows.Forms.TabPage
        Me.SplitContainer1 = New System.Windows.Forms.SplitContainer
        Me.ListViewItems = New System.Windows.Forms.ListView
        Me.ColumnHeaderIndex = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader13 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeaderPrice = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeaderScriptUse = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeaderScriptWear = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeaderScriptThrow = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader1 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader2 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader3 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader4 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader5 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader6 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader7 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader8 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader9 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader10 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader11 = New System.Windows.Forms.ColumnHeader
        Me.ColumnHeader12 = New System.Windows.Forms.ColumnHeader
        Me.LabelItemInfo = New System.Windows.Forms.Label
        Me.TimerPlay = New System.Windows.Forms.Timer(Me.components)
        Me.PictureBoxItem = New System.Windows.Forms.PictureBox
        Me.MenuStripMainWindow.SuspendLayout()
        Me.StatusStripMainWindow.SuspendLayout()
        Me.SplitContainerMain.Panel1.SuspendLayout()
        Me.SplitContainerMain.Panel2.SuspendLayout()
        Me.SplitContainerMain.SuspendLayout()
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
        Me.TableLayoutPanelSound.SuspendLayout()
        Me.PanelRix.SuspendLayout()
        Me.Panel7.SuspendLayout()
        Me.PanelVoc.SuspendLayout()
        Me.Panel5.SuspendLayout()
        Me.PanelWave.SuspendLayout()
        Me.Panel1.SuspendLayout()
        Me.PanelMidi.SuspendLayout()
        Me.Panel3.SuspendLayout()
        Me.TabPagePalette.SuspendLayout()
        CType(Me.PictureBoxPalette, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.TabPageItem.SuspendLayout()
        Me.SplitContainer1.Panel1.SuspendLayout()
        Me.SplitContainer1.Panel2.SuspendLayout()
        Me.SplitContainer1.SuspendLayout()
        CType(Me.PictureBoxItem, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'MenuStripMainWindow
        '
        Me.MenuStripMainWindow.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ToolStripMenuItemFile, Me.ToolStripMenuItemHelp})
        Me.MenuStripMainWindow.Location = New System.Drawing.Point(0, 0)
        Me.MenuStripMainWindow.Name = "MenuStripMainWindow"
        Me.MenuStripMainWindow.Size = New System.Drawing.Size(574, 24)
        Me.MenuStripMainWindow.TabIndex = 1
        Me.MenuStripMainWindow.Text = "主窗体菜单"
        '
        'ToolStripMenuItemFile
        '
        Me.ToolStripMenuItemFile.DropDownItems.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ToolStripMenuItemOpen, Me.ToolStripMenuItemSaveAs, Me.ToolStripMenuItem1, Me.ToolStripMenuItemExit})
        Me.ToolStripMenuItemFile.Name = "ToolStripMenuItemFile"
        Me.ToolStripMenuItemFile.Size = New System.Drawing.Size(59, 20)
        Me.ToolStripMenuItemFile.Text = "文件(&F)"
        '
        'ToolStripMenuItemOpen
        '
        Me.ToolStripMenuItemOpen.Name = "ToolStripMenuItemOpen"
        Me.ToolStripMenuItemOpen.ShortcutKeys = CType((System.Windows.Forms.Keys.Control Or System.Windows.Forms.Keys.O), System.Windows.Forms.Keys)
        Me.ToolStripMenuItemOpen.Size = New System.Drawing.Size(195, 22)
        Me.ToolStripMenuItemOpen.Text = "打开目录(&O)..."
        '
        'ToolStripMenuItemSaveAs
        '
        Me.ToolStripMenuItemSaveAs.Name = "ToolStripMenuItemSaveAs"
        Me.ToolStripMenuItemSaveAs.ShortcutKeys = CType((System.Windows.Forms.Keys.Control Or System.Windows.Forms.Keys.S), System.Windows.Forms.Keys)
        Me.ToolStripMenuItemSaveAs.Size = New System.Drawing.Size(195, 22)
        Me.ToolStripMenuItemSaveAs.Text = "保存MKF(&S)"
        Me.ToolStripMenuItemSaveAs.Visible = False
        '
        'ToolStripMenuItem1
        '
        Me.ToolStripMenuItem1.Name = "ToolStripMenuItem1"
        Me.ToolStripMenuItem1.Size = New System.Drawing.Size(192, 6)
        '
        'ToolStripMenuItemExit
        '
        Me.ToolStripMenuItemExit.Name = "ToolStripMenuItemExit"
        Me.ToolStripMenuItemExit.Size = New System.Drawing.Size(195, 22)
        Me.ToolStripMenuItemExit.Text = "退出(&X)"
        '
        'ToolStripMenuItemHelp
        '
        Me.ToolStripMenuItemHelp.DropDownItems.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ToolStripMenuItemAbout})
        Me.ToolStripMenuItemHelp.Name = "ToolStripMenuItemHelp"
        Me.ToolStripMenuItemHelp.Size = New System.Drawing.Size(59, 20)
        Me.ToolStripMenuItemHelp.Text = "帮助(&H)"
        '
        'ToolStripMenuItemAbout
        '
        Me.ToolStripMenuItemAbout.Name = "ToolStripMenuItemAbout"
        Me.ToolStripMenuItemAbout.Size = New System.Drawing.Size(130, 22)
        Me.ToolStripMenuItemAbout.Text = "关于(&A)..."
        '
        'FolderBrowserDialogPal
        '
        Me.FolderBrowserDialogPal.Description = "请选择《仙剑奇侠传》的安装目录"
        Me.FolderBrowserDialogPal.ShowNewFolderButton = False
        '
        'StatusStripMainWindow
        '
        Me.StatusStripMainWindow.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ToolStripStatusLabelFile, Me.ToolStripProgressBarFile})
        Me.StatusStripMainWindow.Location = New System.Drawing.Point(0, 396)
        Me.StatusStripMainWindow.Name = "StatusStripMainWindow"
        Me.StatusStripMainWindow.Size = New System.Drawing.Size(574, 22)
        Me.StatusStripMainWindow.TabIndex = 3
        Me.StatusStripMainWindow.Text = "StatusStrip1"
        '
        'ToolStripStatusLabelFile
        '
        Me.ToolStripStatusLabelFile.Name = "ToolStripStatusLabelFile"
        Me.ToolStripStatusLabelFile.Size = New System.Drawing.Size(387, 17)
        Me.ToolStripStatusLabelFile.Spring = True
        Me.ToolStripStatusLabelFile.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'ToolStripProgressBarFile
        '
        Me.ToolStripProgressBarFile.Maximum = 170
        Me.ToolStripProgressBarFile.Name = "ToolStripProgressBarFile"
        Me.ToolStripProgressBarFile.Size = New System.Drawing.Size(170, 16)
        '
        'SplitContainerMain
        '
        Me.SplitContainerMain.Dock = System.Windows.Forms.DockStyle.Fill
        Me.SplitContainerMain.Location = New System.Drawing.Point(0, 24)
        Me.SplitContainerMain.Name = "SplitContainerMain"
        '
        'SplitContainerMain.Panel1
        '
        Me.SplitContainerMain.Panel1.Controls.Add(Me.TreeViewFile)
        '
        'SplitContainerMain.Panel2
        '
        Me.SplitContainerMain.Panel2.Controls.Add(Me.TabControlView)
        Me.SplitContainerMain.Size = New System.Drawing.Size(574, 372)
        Me.SplitContainerMain.SplitterDistance = 190
        Me.SplitContainerMain.TabIndex = 4
        '
        'TreeViewFile
        '
        Me.TreeViewFile.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TreeViewFile.HideSelection = False
        Me.TreeViewFile.Location = New System.Drawing.Point(0, 0)
        Me.TreeViewFile.Name = "TreeViewFile"
        Me.TreeViewFile.Size = New System.Drawing.Size(190, 372)
        Me.TreeViewFile.TabIndex = 1
        '
        'TabControlView
        '
        Me.TabControlView.Controls.Add(Me.TabPageHex)
        Me.TabControlView.Controls.Add(Me.TabPagePicture)
        Me.TabControlView.Controls.Add(Me.TabPageMap)
        Me.TabControlView.Controls.Add(Me.TabPageSound)
        Me.TabControlView.Controls.Add(Me.TabPagePalette)
        Me.TabControlView.Controls.Add(Me.TabPageItem)
        Me.TabControlView.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TabControlView.Location = New System.Drawing.Point(0, 0)
        Me.TabControlView.Name = "TabControlView"
        Me.TabControlView.SelectedIndex = 0
        Me.TabControlView.Size = New System.Drawing.Size(380, 372)
        Me.TabControlView.TabIndex = 0
        '
        'TabPageHex
        '
        Me.TabPageHex.Controls.Add(Me.ListViewHex)
        Me.TabPageHex.Location = New System.Drawing.Point(4, 21)
        Me.TabPageHex.Name = "TabPageHex"
        Me.TabPageHex.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPageHex.Size = New System.Drawing.Size(372, 347)
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
        Me.ListViewHex.Size = New System.Drawing.Size(366, 341)
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
        Me.TabPagePicture.Size = New System.Drawing.Size(372, 347)
        Me.TabPagePicture.TabIndex = 1
        Me.TabPagePicture.Text = "图片/动画"
        Me.TabPagePicture.UseVisualStyleBackColor = True
        '
        'PictureBoxImage
        '
        Me.PictureBoxImage.Location = New System.Drawing.Point(0, 27)
        Me.PictureBoxImage.Name = "PictureBoxImage"
        Me.PictureBoxImage.Size = New System.Drawing.Size(149, 134)
        Me.PictureBoxImage.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize
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
        Me.PanelImage.Size = New System.Drawing.Size(372, 27)
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
        Me.TabPageMap.Size = New System.Drawing.Size(372, 347)
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
        Me.PanelMapImage.Size = New System.Drawing.Size(372, 322)
        Me.PanelMapImage.TabIndex = 3
        '
        'PictureBoxMap
        '
        Me.PictureBoxMap.Location = New System.Drawing.Point(0, 0)
        Me.PictureBoxMap.Name = "PictureBoxMap"
        Me.PictureBoxMap.Size = New System.Drawing.Size(200, 200)
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
        Me.PanelMap.Enabled = False
        Me.PanelMap.Location = New System.Drawing.Point(0, 0)
        Me.PanelMap.Name = "PanelMap"
        Me.PanelMap.Size = New System.Drawing.Size(372, 25)
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
        Me.TabPageSound.Controls.Add(Me.TableLayoutPanelSound)
        Me.TabPageSound.Location = New System.Drawing.Point(4, 21)
        Me.TabPageSound.Name = "TabPageSound"
        Me.TabPageSound.Size = New System.Drawing.Size(372, 347)
        Me.TabPageSound.TabIndex = 3
        Me.TabPageSound.Text = "声音/音乐"
        Me.TabPageSound.UseVisualStyleBackColor = True
        '
        'TableLayoutPanelSound
        '
        Me.TableLayoutPanelSound.ColumnCount = 4
        Me.TableLayoutPanelSound.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25.0!))
        Me.TableLayoutPanelSound.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25.0!))
        Me.TableLayoutPanelSound.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25.0!))
        Me.TableLayoutPanelSound.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25.0!))
        Me.TableLayoutPanelSound.Controls.Add(Me.PanelRix, 3, 0)
        Me.TableLayoutPanelSound.Controls.Add(Me.PanelVoc, 2, 0)
        Me.TableLayoutPanelSound.Controls.Add(Me.PanelWave, 0, 0)
        Me.TableLayoutPanelSound.Controls.Add(Me.PanelMidi, 1, 0)
        Me.TableLayoutPanelSound.Dock = System.Windows.Forms.DockStyle.Fill
        Me.TableLayoutPanelSound.Location = New System.Drawing.Point(0, 0)
        Me.TableLayoutPanelSound.Name = "TableLayoutPanelSound"
        Me.TableLayoutPanelSound.RowCount = 1
        Me.TableLayoutPanelSound.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100.0!))
        Me.TableLayoutPanelSound.Size = New System.Drawing.Size(372, 347)
        Me.TableLayoutPanelSound.TabIndex = 16
        '
        'PanelRix
        '
        Me.PanelRix.Controls.Add(Me.ListBoxRix)
        Me.PanelRix.Controls.Add(Me.Panel7)
        Me.PanelRix.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PanelRix.Enabled = False
        Me.PanelRix.Location = New System.Drawing.Point(282, 3)
        Me.PanelRix.Name = "PanelRix"
        Me.PanelRix.Size = New System.Drawing.Size(87, 341)
        Me.PanelRix.TabIndex = 19
        '
        'ListBoxRix
        '
        Me.ListBoxRix.Dock = System.Windows.Forms.DockStyle.Fill
        Me.ListBoxRix.FormattingEnabled = True
        Me.ListBoxRix.ItemHeight = 12
        Me.ListBoxRix.Location = New System.Drawing.Point(0, 37)
        Me.ListBoxRix.Name = "ListBoxRix"
        Me.ListBoxRix.Size = New System.Drawing.Size(87, 304)
        Me.ListBoxRix.TabIndex = 18
        '
        'Panel7
        '
        Me.Panel7.Controls.Add(Me.ButtonRix)
        Me.Panel7.Controls.Add(Me.LabelRix)
        Me.Panel7.Dock = System.Windows.Forms.DockStyle.Top
        Me.Panel7.Location = New System.Drawing.Point(0, 0)
        Me.Panel7.Name = "Panel7"
        Me.Panel7.Size = New System.Drawing.Size(87, 37)
        Me.Panel7.TabIndex = 17
        '
        'ButtonRix
        '
        Me.ButtonRix.Location = New System.Drawing.Point(0, 0)
        Me.ButtonRix.Name = "ButtonRix"
        Me.ButtonRix.Size = New System.Drawing.Size(54, 21)
        Me.ButtonRix.TabIndex = 12
        Me.ButtonRix.Text = "播放"
        Me.ButtonRix.UseVisualStyleBackColor = True
        '
        'LabelRix
        '
        Me.LabelRix.AutoSize = True
        Me.LabelRix.Location = New System.Drawing.Point(3, 24)
        Me.LabelRix.Name = "LabelRix"
        Me.LabelRix.Size = New System.Drawing.Size(29, 12)
        Me.LabelRix.TabIndex = 11
        Me.LabelRix.Text = "RIX:"
        '
        'PanelVoc
        '
        Me.PanelVoc.Controls.Add(Me.ListBoxVoc)
        Me.PanelVoc.Controls.Add(Me.Panel5)
        Me.PanelVoc.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PanelVoc.Enabled = False
        Me.PanelVoc.Location = New System.Drawing.Point(189, 3)
        Me.PanelVoc.Name = "PanelVoc"
        Me.PanelVoc.Size = New System.Drawing.Size(87, 341)
        Me.PanelVoc.TabIndex = 19
        '
        'ListBoxVoc
        '
        Me.ListBoxVoc.Dock = System.Windows.Forms.DockStyle.Fill
        Me.ListBoxVoc.FormattingEnabled = True
        Me.ListBoxVoc.ItemHeight = 12
        Me.ListBoxVoc.Location = New System.Drawing.Point(0, 37)
        Me.ListBoxVoc.Name = "ListBoxVoc"
        Me.ListBoxVoc.Size = New System.Drawing.Size(87, 304)
        Me.ListBoxVoc.TabIndex = 18
        '
        'Panel5
        '
        Me.Panel5.Controls.Add(Me.ButtonVoc)
        Me.Panel5.Controls.Add(Me.LabelVoc)
        Me.Panel5.Dock = System.Windows.Forms.DockStyle.Top
        Me.Panel5.Location = New System.Drawing.Point(0, 0)
        Me.Panel5.Name = "Panel5"
        Me.Panel5.Size = New System.Drawing.Size(87, 37)
        Me.Panel5.TabIndex = 17
        '
        'ButtonVoc
        '
        Me.ButtonVoc.Location = New System.Drawing.Point(0, 1)
        Me.ButtonVoc.Name = "ButtonVoc"
        Me.ButtonVoc.Size = New System.Drawing.Size(54, 21)
        Me.ButtonVoc.TabIndex = 9
        Me.ButtonVoc.Text = "播放"
        Me.ButtonVoc.UseVisualStyleBackColor = True
        '
        'LabelVoc
        '
        Me.LabelVoc.AutoSize = True
        Me.LabelVoc.Location = New System.Drawing.Point(0, 24)
        Me.LabelVoc.Name = "LabelVoc"
        Me.LabelVoc.Size = New System.Drawing.Size(29, 12)
        Me.LabelVoc.TabIndex = 8
        Me.LabelVoc.Text = "VOC:"
        '
        'PanelWave
        '
        Me.PanelWave.Controls.Add(Me.ListBoxWave)
        Me.PanelWave.Controls.Add(Me.Panel1)
        Me.PanelWave.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PanelWave.Enabled = False
        Me.PanelWave.Location = New System.Drawing.Point(3, 3)
        Me.PanelWave.Name = "PanelWave"
        Me.PanelWave.Size = New System.Drawing.Size(87, 341)
        Me.PanelWave.TabIndex = 14
        '
        'ListBoxWave
        '
        Me.ListBoxWave.Dock = System.Windows.Forms.DockStyle.Fill
        Me.ListBoxWave.FormattingEnabled = True
        Me.ListBoxWave.ItemHeight = 12
        Me.ListBoxWave.Location = New System.Drawing.Point(0, 37)
        Me.ListBoxWave.Name = "ListBoxWave"
        Me.ListBoxWave.Size = New System.Drawing.Size(87, 304)
        Me.ListBoxWave.TabIndex = 7
        '
        'Panel1
        '
        Me.Panel1.Controls.Add(Me.ButtonWave)
        Me.Panel1.Controls.Add(Me.LabelWave)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Top
        Me.Panel1.Location = New System.Drawing.Point(0, 0)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(87, 37)
        Me.Panel1.TabIndex = 6
        '
        'ButtonWave
        '
        Me.ButtonWave.Location = New System.Drawing.Point(0, 0)
        Me.ButtonWave.Name = "ButtonWave"
        Me.ButtonWave.Size = New System.Drawing.Size(54, 21)
        Me.ButtonWave.TabIndex = 5
        Me.ButtonWave.Text = "播放"
        Me.ButtonWave.UseVisualStyleBackColor = True
        '
        'LabelWave
        '
        Me.LabelWave.AutoSize = True
        Me.LabelWave.Location = New System.Drawing.Point(3, 24)
        Me.LabelWave.Name = "LabelWave"
        Me.LabelWave.Size = New System.Drawing.Size(35, 12)
        Me.LabelWave.TabIndex = 0
        Me.LabelWave.Text = "WAVE:"
        '
        'PanelMidi
        '
        Me.PanelMidi.Controls.Add(Me.ListBoxMidi)
        Me.PanelMidi.Controls.Add(Me.Panel3)
        Me.PanelMidi.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PanelMidi.Enabled = False
        Me.PanelMidi.Location = New System.Drawing.Point(96, 3)
        Me.PanelMidi.Name = "PanelMidi"
        Me.PanelMidi.Size = New System.Drawing.Size(87, 341)
        Me.PanelMidi.TabIndex = 15
        '
        'ListBoxMidi
        '
        Me.ListBoxMidi.Dock = System.Windows.Forms.DockStyle.Fill
        Me.ListBoxMidi.FormattingEnabled = True
        Me.ListBoxMidi.ItemHeight = 12
        Me.ListBoxMidi.Location = New System.Drawing.Point(0, 37)
        Me.ListBoxMidi.Name = "ListBoxMidi"
        Me.ListBoxMidi.Size = New System.Drawing.Size(87, 304)
        Me.ListBoxMidi.TabIndex = 18
        '
        'Panel3
        '
        Me.Panel3.Controls.Add(Me.ButtonMidi)
        Me.Panel3.Controls.Add(Me.LabelMidi)
        Me.Panel3.Dock = System.Windows.Forms.DockStyle.Top
        Me.Panel3.Location = New System.Drawing.Point(0, 0)
        Me.Panel3.Name = "Panel3"
        Me.Panel3.Size = New System.Drawing.Size(87, 37)
        Me.Panel3.TabIndex = 17
        '
        'ButtonMidi
        '
        Me.ButtonMidi.Location = New System.Drawing.Point(0, 0)
        Me.ButtonMidi.Name = "ButtonMidi"
        Me.ButtonMidi.Size = New System.Drawing.Size(54, 21)
        Me.ButtonMidi.TabIndex = 6
        Me.ButtonMidi.Text = "播放"
        Me.ButtonMidi.UseVisualStyleBackColor = True
        '
        'LabelMidi
        '
        Me.LabelMidi.AutoSize = True
        Me.LabelMidi.Location = New System.Drawing.Point(3, 24)
        Me.LabelMidi.Name = "LabelMidi"
        Me.LabelMidi.Size = New System.Drawing.Size(35, 12)
        Me.LabelMidi.TabIndex = 1
        Me.LabelMidi.Text = "MIDI:"
        '
        'TabPagePalette
        '
        Me.TabPagePalette.Controls.Add(Me.PictureBoxPalette)
        Me.TabPagePalette.Controls.Add(Me.ComboBoxPalettePat)
        Me.TabPagePalette.Location = New System.Drawing.Point(4, 21)
        Me.TabPagePalette.Name = "TabPagePalette"
        Me.TabPagePalette.Size = New System.Drawing.Size(372, 347)
        Me.TabPagePalette.TabIndex = 2
        Me.TabPagePalette.Text = "调色板"
        Me.TabPagePalette.UseVisualStyleBackColor = True
        '
        'PictureBoxPalette
        '
        Me.PictureBoxPalette.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PictureBoxPalette.Location = New System.Drawing.Point(0, 20)
        Me.PictureBoxPalette.Name = "PictureBoxPalette"
        Me.PictureBoxPalette.Size = New System.Drawing.Size(372, 327)
        Me.PictureBoxPalette.TabIndex = 5
        Me.PictureBoxPalette.TabStop = False
        '
        'ComboBoxPalettePat
        '
        Me.ComboBoxPalettePat.Dock = System.Windows.Forms.DockStyle.Top
        Me.ComboBoxPalettePat.FormattingEnabled = True
        Me.ComboBoxPalettePat.Items.AddRange(New Object() {"0#调色板（白天）", "0#调色板（夜晚）", "1#调色板", "2#调色板", "3#调色板", "4#调色板", "5#调色板（白天）", "5#调色板（夜晚）", "6#调色板", "7#调色板", "8#调色板"})
        Me.ComboBoxPalettePat.Location = New System.Drawing.Point(0, 0)
        Me.ComboBoxPalettePat.Name = "ComboBoxPalettePat"
        Me.ComboBoxPalettePat.Size = New System.Drawing.Size(372, 20)
        Me.ComboBoxPalettePat.TabIndex = 4
        Me.ComboBoxPalettePat.Text = "0#调色板（白天）"
        '
        'TabPageItem
        '
        Me.TabPageItem.Controls.Add(Me.SplitContainer1)
        Me.TabPageItem.Location = New System.Drawing.Point(4, 21)
        Me.TabPageItem.Name = "TabPageItem"
        Me.TabPageItem.Size = New System.Drawing.Size(372, 347)
        Me.TabPageItem.TabIndex = 5
        Me.TabPageItem.Text = "物品"
        Me.TabPageItem.UseVisualStyleBackColor = True
        '
        'SplitContainer1
        '
        Me.SplitContainer1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.SplitContainer1.Location = New System.Drawing.Point(0, 0)
        Me.SplitContainer1.Name = "SplitContainer1"
        Me.SplitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal
        '
        'SplitContainer1.Panel1
        '
        Me.SplitContainer1.Panel1.Controls.Add(Me.ListViewItems)
        '
        'SplitContainer1.Panel2
        '
        Me.SplitContainer1.Panel2.Controls.Add(Me.PictureBoxItem)
        Me.SplitContainer1.Panel2.Controls.Add(Me.LabelItemInfo)
        Me.SplitContainer1.Size = New System.Drawing.Size(372, 347)
        Me.SplitContainer1.SplitterDistance = 189
        Me.SplitContainer1.TabIndex = 2
        '
        'ListViewItems
        '
        Me.ListViewItems.Columns.AddRange(New System.Windows.Forms.ColumnHeader() {Me.ColumnHeaderIndex, Me.ColumnHeader13, Me.ColumnHeaderPrice, Me.ColumnHeaderScriptUse, Me.ColumnHeaderScriptWear, Me.ColumnHeaderScriptThrow, Me.ColumnHeader1, Me.ColumnHeader2, Me.ColumnHeader3, Me.ColumnHeader4, Me.ColumnHeader5, Me.ColumnHeader6, Me.ColumnHeader7, Me.ColumnHeader8, Me.ColumnHeader9, Me.ColumnHeader10, Me.ColumnHeader11, Me.ColumnHeader12})
        Me.ListViewItems.Dock = System.Windows.Forms.DockStyle.Fill
        Me.ListViewItems.FullRowSelect = True
        Me.ListViewItems.Location = New System.Drawing.Point(0, 0)
        Me.ListViewItems.MultiSelect = False
        Me.ListViewItems.Name = "ListViewItems"
        Me.ListViewItems.ShowGroups = False
        Me.ListViewItems.Size = New System.Drawing.Size(372, 189)
        Me.ListViewItems.TabIndex = 1
        Me.ListViewItems.UseCompatibleStateImageBehavior = False
        Me.ListViewItems.View = System.Windows.Forms.View.Details
        '
        'ColumnHeaderIndex
        '
        Me.ColumnHeaderIndex.Text = "物品编号"
        '
        'ColumnHeader13
        '
        Me.ColumnHeader13.Text = "物品名称"
        '
        'ColumnHeaderPrice
        '
        Me.ColumnHeaderPrice.Text = "物品价格"
        '
        'ColumnHeaderScriptUse
        '
        Me.ColumnHeaderScriptUse.Text = "使用脚本"
        '
        'ColumnHeaderScriptWear
        '
        Me.ColumnHeaderScriptWear.Text = "装备脚本"
        '
        'ColumnHeaderScriptThrow
        '
        Me.ColumnHeaderScriptThrow.Text = "投掷脚本"
        '
        'ColumnHeader1
        '
        Me.ColumnHeader1.Text = "可使用"
        '
        'ColumnHeader2
        '
        Me.ColumnHeader2.Text = "可装备"
        '
        'ColumnHeader3
        '
        Me.ColumnHeader3.Text = "可投掷"
        '
        'ColumnHeader4
        '
        Me.ColumnHeader4.Text = "使用无损耗"
        '
        'ColumnHeader5
        '
        Me.ColumnHeader5.Text = "无须选择对象"
        '
        'ColumnHeader6
        '
        Me.ColumnHeader6.Text = "可出售"
        '
        'ColumnHeader7
        '
        Me.ColumnHeader7.Text = "李逍遥可装备"
        '
        'ColumnHeader8
        '
        Me.ColumnHeader8.Text = "赵灵儿可装备"
        '
        'ColumnHeader9
        '
        Me.ColumnHeader9.Text = "林月如可装备"
        '
        'ColumnHeader10
        '
        Me.ColumnHeader10.Text = "巫后可装备"
        '
        'ColumnHeader11
        '
        Me.ColumnHeader11.Text = "阿奴可装备"
        '
        'ColumnHeader12
        '
        Me.ColumnHeader12.Text = "盖罗娇可装备"
        '
        'LabelItemInfo
        '
        Me.LabelItemInfo.AutoSize = True
        Me.LabelItemInfo.Dock = System.Windows.Forms.DockStyle.Top
        Me.LabelItemInfo.Location = New System.Drawing.Point(0, 0)
        Me.LabelItemInfo.Name = "LabelItemInfo"
        Me.LabelItemInfo.Size = New System.Drawing.Size(0, 12)
        Me.LabelItemInfo.TabIndex = 4
        '
        'TimerPlay
        '
        '
        'PictureBoxItem
        '
        Me.PictureBoxItem.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PictureBoxItem.Location = New System.Drawing.Point(0, 12)
        Me.PictureBoxItem.Name = "PictureBoxItem"
        Me.PictureBoxItem.Size = New System.Drawing.Size(372, 142)
        Me.PictureBoxItem.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize
        Me.PictureBoxItem.TabIndex = 5
        Me.PictureBoxItem.TabStop = False
        '
        'MainWindow
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 12.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(574, 418)
        Me.Controls.Add(Me.SplitContainerMain)
        Me.Controls.Add(Me.StatusStripMainWindow)
        Me.Controls.Add(Me.MenuStripMainWindow)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.MainMenuStrip = Me.MenuStripMainWindow
        Me.Name = "MainWindow"
        Me.Text = "PalTools.NET -- PalViewer 升级版"
        Me.MenuStripMainWindow.ResumeLayout(False)
        Me.MenuStripMainWindow.PerformLayout()
        Me.StatusStripMainWindow.ResumeLayout(False)
        Me.StatusStripMainWindow.PerformLayout()
        Me.SplitContainerMain.Panel1.ResumeLayout(False)
        Me.SplitContainerMain.Panel2.ResumeLayout(False)
        Me.SplitContainerMain.ResumeLayout(False)
        Me.TabControlView.ResumeLayout(False)
        Me.TabPageHex.ResumeLayout(False)
        Me.TabPagePicture.ResumeLayout(False)
        Me.TabPagePicture.PerformLayout()
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
        Me.TableLayoutPanelSound.ResumeLayout(False)
        Me.PanelRix.ResumeLayout(False)
        Me.Panel7.ResumeLayout(False)
        Me.Panel7.PerformLayout()
        Me.PanelVoc.ResumeLayout(False)
        Me.Panel5.ResumeLayout(False)
        Me.Panel5.PerformLayout()
        Me.PanelWave.ResumeLayout(False)
        Me.Panel1.ResumeLayout(False)
        Me.Panel1.PerformLayout()
        Me.PanelMidi.ResumeLayout(False)
        Me.Panel3.ResumeLayout(False)
        Me.Panel3.PerformLayout()
        Me.TabPagePalette.ResumeLayout(False)
        CType(Me.PictureBoxPalette, System.ComponentModel.ISupportInitialize).EndInit()
        Me.TabPageItem.ResumeLayout(False)
        Me.SplitContainer1.Panel1.ResumeLayout(False)
        Me.SplitContainer1.Panel2.ResumeLayout(False)
        Me.SplitContainer1.Panel2.PerformLayout()
        Me.SplitContainer1.ResumeLayout(False)
        CType(Me.PictureBoxItem, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

    Friend WithEvents ToolStripMenuItemFile As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripMenuItemOpen As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripMenuItemSaveAs As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripMenuItem1 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents ToolStripMenuItemExit As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents FolderBrowserDialogPal As System.Windows.Forms.FolderBrowserDialog
    Friend WithEvents MenuStripMainWindow As System.Windows.Forms.MenuStrip
    Friend WithEvents StatusStripMainWindow As System.Windows.Forms.StatusStrip
    Friend WithEvents ToolStripStatusLabelFile As System.Windows.Forms.ToolStripStatusLabel
    Friend WithEvents ToolStripProgressBarFile As System.Windows.Forms.ToolStripProgressBar
    Friend WithEvents ToolStripMenuItemHelp As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripMenuItemAbout As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents SplitContainerMain As System.Windows.Forms.SplitContainer
    Friend WithEvents TreeViewFile As System.Windows.Forms.TreeView
    Friend WithEvents TabControlView As System.Windows.Forms.TabControl
    Friend WithEvents TabPageHex As System.Windows.Forms.TabPage
    Friend WithEvents ListViewHex As System.Windows.Forms.ListView
    Friend WithEvents ColumnHeaderOffset As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeaderHex As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeaderAscii As System.Windows.Forms.ColumnHeader
    Friend WithEvents TabPagePicture As System.Windows.Forms.TabPage
    Friend WithEvents PictureBoxImage As System.Windows.Forms.PictureBox
    Friend WithEvents PanelImage As System.Windows.Forms.Panel
    Friend WithEvents ButtonNext As System.Windows.Forms.Button
    Friend WithEvents ButtonPlay As System.Windows.Forms.Button
    Friend WithEvents ButtonPrev As System.Windows.Forms.Button
    Friend WithEvents ComboBoxPalette As System.Windows.Forms.ComboBox
    Friend WithEvents LabelInfo As System.Windows.Forms.Label
    Friend WithEvents TabPageMap As System.Windows.Forms.TabPage
    Friend WithEvents PanelMapImage As System.Windows.Forms.Panel
    Friend WithEvents PictureBoxMap As System.Windows.Forms.PictureBox
    Friend WithEvents PanelMap As System.Windows.Forms.Panel
    Friend WithEvents ComboBoxMap As System.Windows.Forms.ComboBox
    Friend WithEvents CheckBoxGrid As System.Windows.Forms.CheckBox
    Friend WithEvents CheckBoxLayer1 As System.Windows.Forms.CheckBox
    Friend WithEvents CheckBoxLayer0 As System.Windows.Forms.CheckBox
    Friend WithEvents ComboBoxPaletteMap As System.Windows.Forms.ComboBox
    Friend WithEvents TabPageSound As System.Windows.Forms.TabPage
    Friend WithEvents ButtonWave As System.Windows.Forms.Button
    Friend WithEvents LabelWave As System.Windows.Forms.Label
    Friend WithEvents ButtonRix As System.Windows.Forms.Button
    Friend WithEvents LabelRix As System.Windows.Forms.Label
    Friend WithEvents ButtonVoc As System.Windows.Forms.Button
    Friend WithEvents LabelVoc As System.Windows.Forms.Label
    Friend WithEvents ButtonMidi As System.Windows.Forms.Button
    Friend WithEvents LabelMidi As System.Windows.Forms.Label
    Friend WithEvents TabPagePalette As System.Windows.Forms.TabPage
    Friend WithEvents TimerPlay As System.Windows.Forms.Timer
    Friend WithEvents PanelWave As System.Windows.Forms.Panel
    Friend WithEvents PanelMidi As System.Windows.Forms.Panel
    Friend WithEvents TableLayoutPanelSound As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents PanelVoc As System.Windows.Forms.Panel
    Friend WithEvents Panel5 As System.Windows.Forms.Panel
    Friend WithEvents Panel3 As System.Windows.Forms.Panel
    Friend WithEvents Panel7 As System.Windows.Forms.Panel
    Friend WithEvents PanelRix As System.Windows.Forms.Panel
    Friend WithEvents ListBoxRix As System.Windows.Forms.ListBox
    Friend WithEvents ListBoxVoc As System.Windows.Forms.ListBox
    Friend WithEvents ListBoxWave As System.Windows.Forms.ListBox
    Friend WithEvents ListBoxMidi As System.Windows.Forms.ListBox
    Friend WithEvents PictureBoxPalette As System.Windows.Forms.PictureBox
    Friend WithEvents ComboBoxPalettePat As System.Windows.Forms.ComboBox
    Friend WithEvents TabPageItem As System.Windows.Forms.TabPage
    Friend WithEvents ListViewItems As System.Windows.Forms.ListView
    Friend WithEvents ColumnHeaderIndex As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeaderPrice As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeaderScriptUse As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeaderScriptWear As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeaderScriptThrow As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader1 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader2 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader3 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader4 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader5 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader6 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader7 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader8 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader9 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader10 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader11 As System.Windows.Forms.ColumnHeader
    Friend WithEvents ColumnHeader12 As System.Windows.Forms.ColumnHeader
    Friend WithEvents SplitContainer1 As System.Windows.Forms.SplitContainer
    Friend WithEvents ColumnHeader13 As System.Windows.Forms.ColumnHeader
    Friend WithEvents LabelItemInfo As System.Windows.Forms.Label
    Friend WithEvents PictureBoxItem As System.Windows.Forms.PictureBox

End Class
