object frmItemIndex: TfrmItemIndex
  Left = 240
  Top = 121
  Width = 619
  Height = 378
  Caption = 'Items SSS #2'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 429
    Height = 351
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        Width = 80
      end
      item
        Caption = 'RleID, Gold, UseS, EquS, DropS, InfoS,  Flags'
        Width = 240
      end
      item
        Caption = 'Name'
        Width = 80
      end>
    HideSelection = False
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = ListView1Change
    OnData = ListView1Data
  end
  object PageControl1: TPageControl
    Left = 429
    Top = 0
    Width = 182
    Height = 351
    ActivePage = TabSheet3
    Align = alRight
    TabIndex = 0
    TabOrder = 1
    object TabSheet3: TTabSheet
      Caption = 'Item'
      ImageIndex = 2
      object Image1: TImage
        Left = 5
        Top = 3
        Width = 144
        Height = 99
        Stretch = True
      end
      object Label1: TLabel
        Left = 6
        Top = 109
        Width = 38
        Height = 13
        Caption = 'Sell: $0 '
      end
      object Label2: TLabel
        Left = 8
        Top = 126
        Width = 31
        Height = 13
        Caption = 'Desc: '
      end
      object CheckBox1: TCheckBox
        Left = 6
        Top = 149
        Width = 71
        Height = 17
        Caption = 'can use'
        TabOrder = 0
      end
      object CheckBox2: TCheckBox
        Left = 6
        Top = 168
        Width = 71
        Height = 17
        Caption = 'can equip'
        TabOrder = 1
      end
      object CheckBox3: TCheckBox
        Left = 6
        Top = 187
        Width = 71
        Height = 17
        Caption = 'can drop'
        TabOrder = 2
      end
      object CheckBox4: TCheckBox
        Left = 6
        Top = 205
        Width = 71
        Height = 17
        Caption = 'dec count'
        TabOrder = 3
      end
      object CheckBox5: TCheckBox
        Left = 78
        Top = 151
        Width = 97
        Height = 17
        Caption = 'for Li Xiaoyao'
        TabOrder = 4
      end
      object CheckBox6: TCheckBox
        Left = 78
        Top = 170
        Width = 97
        Height = 17
        Caption = 'for Zhao Linger'
        TabOrder = 5
      end
      object CheckBox7: TCheckBox
        Left = 77
        Top = 189
        Width = 97
        Height = 17
        Caption = 'for Lin Yueru'
        TabOrder = 6
      end
      object CheckBox8: TCheckBox
        Left = 77
        Top = 208
        Width = 97
        Height = 17
        Caption = 'for Wu Hou'
        TabOrder = 7
      end
      object CheckBox9: TCheckBox
        Left = 78
        Top = 228
        Width = 97
        Height = 17
        Caption = 'for A Nu'
        TabOrder = 8
      end
      object CheckBox10: TCheckBox
        Left = 77
        Top = 247
        Width = 97
        Height = 17
        Caption = 'for Gai Luojiao'
        TabOrder = 9
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Magic'
      ImageIndex = 3
      object Image2: TImage
        Left = 9
        Top = 10
        Width = 134
        Height = 131
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Monster'
      ImageIndex = 2
      object Image3: TImage
        Left = 12
        Top = 8
        Width = 154
        Height = 143
      end
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 249
    Top = 87
  end
end
