object frmRNGView: TfrmRNGView
  Left = 315
  Top = 122
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'RNG View'
  ClientHeight = 240
  ClientWidth = 334
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
  object Label1: TLabel
    Left = 11
    Top = 9
    Width = 16
    Height = 13
    Caption = 'List'
  end
  object Image1: TImage
    Left = 6
    Top = 34
    Width = 320
    Height = 200
  end
  object ComboBox1: TComboBox
    Left = 35
    Top = 5
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = ComboBox1Change
  end
  object ComboBox2: TComboBox
    Left = 178
    Top = 5
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
    Text = 'Palette 0'
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
  object Timer1: TTimer
    Enabled = False
    Interval = 80
    OnTimer = Timer1Timer
    Left = 166
    Top = 83
  end
end
