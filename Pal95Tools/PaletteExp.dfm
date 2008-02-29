object frmPalette: TfrmPalette
  Left = 282
  Top = 119
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'PAL Palette'
  ClientHeight = 293
  ClientWidth = 354
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
  object Image1: TImage
    Left = 4
    Top = 29
    Width = 256
    Height = 256
  end
  object ComboBox1: TComboBox
    Left = 3
    Top = 3
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = 'Palette 0'
    OnSelect = ComboBox1Select
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
  object Button1: TButton
    Left = 269
    Top = 28
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
  end
end
