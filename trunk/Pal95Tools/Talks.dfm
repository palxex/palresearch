object frmTalk: TfrmTalk
  Left = 202
  Top = 113
  Caption = 'Talk Messages'
  ClientHeight = 333
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 288
    Top = 268
    Width = 64
    Height = 64
    Stretch = True
  end
  object Label1: TLabel
    Left = 361
    Top = 270
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object Memo1: TMemo
    Left = 5
    Top = 7
    Width = 271
    Height = 324
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 285
    Top = 10
    Width = 206
    Height = 25
    Caption = 'Calc Words Used'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 418
    Top = 235
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 291
    Top = 234
    Width = 121
    Height = 21
    TabOrder = 3
    Text = #21834
  end
  object Button3: TButton
    Left = 285
    Top = 38
    Width = 207
    Height = 25
    Caption = 'Hori Font 16x16 - > 16x15'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 418
    Top = 262
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 418
    Top = 292
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 287
    Top = 74
    Width = 204
    Height = 25
    Caption = 'Make HZK used ONLY !!!'
    TabOrder = 7
    OnClick = Button6Click
  end
end
