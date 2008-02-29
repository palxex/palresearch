object frmMKF: TfrmMKF
  Left = 204
  Top = 126
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'MKF Explorer'
  ClientHeight = 421
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefaultPosOnly
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 177
    Height = 421
    Align = alLeft
    HideSelection = False
    Indent = 19
    ReadOnly = True
    ShowRoot = False
    TabOrder = 0
    OnChange = TreeView1Change
    OnCollapsing = TreeView1Collapsing
    OnExpanding = TreeView1Expanding
    Items.Data = {
      01000000210000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      0850414C20526F6F74}
  end
  object PageControl1: TPageControl
    Left = 177
    Top = 0
    Width = 523
    Height = 421
    ActivePage = TabSheet2
    Align = alClient
    TabIndex = 1
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Hex'
      object ListView1: TListView
        Left = 0
        Top = 0
        Width = 515
        Height = 393
        Align = alClient
        Columns = <
          item
            Caption = 'Offset'
            Width = 64
          end
          item
            Caption = 'Hex'
            Width = 300
          end
          item
            Caption = 'ASCII'
            Width = 130
          end>
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        OwnerData = True
        ReadOnly = True
        RowSelect = True
        ParentFont = False
        TabOrder = 0
        ViewStyle = vsReport
        OnData = ListView1Data
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Picture'
      ImageIndex = 1
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 515
        Height = 31
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 8
          Top = 8
          Width = 24
          Height = 13
          Caption = 'Info: '
        end
        object Button1: TButton
          Left = 170
          Top = 2
          Width = 43
          Height = 25
          Caption = '<<'
          TabOrder = 0
          OnClick = Button1Click
        end
        object Button2: TButton
          Left = 214
          Top = 2
          Width = 39
          Height = 25
          Caption = '>>'
          TabOrder = 1
          OnClick = Button2Click
        end
        object ComboBox2: TComboBox
          Left = 269
          Top = 5
          Width = 105
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 2
          Text = 'Palette 0'
          OnChange = ComboBox2Change
          Items.Strings = (
            'Palette 0'
            'Palette 0 (night)'
            'Palette 1'
            'Palette 2'
            'Palette 3'
            'Palette 4'
            'Palette 5'
            'Palette 5 (night)'
            'Palette 6'
            'Palette 7'
            'Palette 8')
        end
      end
      object ScrollBox1: TScrollBox
        Left = 0
        Top = 31
        Width = 515
        Height = 362
        Align = alClient
        TabOrder = 1
        object Image1: TImage
          Left = 0
          Top = 0
          Width = 448
          Height = 251
          AutoSize = True
        end
      end
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer1Timer
    Left = 126
    Top = 94
  end
end
