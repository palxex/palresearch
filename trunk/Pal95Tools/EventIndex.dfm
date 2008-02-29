object frmEventIndex: TfrmEventIndex
  Left = 259
  Top = 110
  Width = 618
  Height = 453
  Caption = 'Event Objects  SSS #0'
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
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 610
    Height = 315
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        Width = 80
      end
      item
        Caption = '0, X, Y, Layer; TrigScr, AutoScr,  State, TrigMode'
        Width = 250
      end
      item
        Caption = 'RleID, Frame, Dir, ??, ??, MonstRef, ??, ??'
        Width = 250
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
  object Panel1: TPanel
    Left = 0
    Top = 315
    Width = 610
    Height = 111
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 102
      Top = 11
      Width = 43
      Height = 13
      Caption = 'Position: '
    end
    object Image1: TImage
      Left = 4
      Top = 9
      Width = 92
      Height = 99
    end
    object Label2: TLabel
      Left = 103
      Top = 31
      Width = 38
      Height = 13
      Caption = 'Bitmap: '
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 77
    Top = 73
  end
end
