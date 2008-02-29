object frmStageIndex: TfrmStageIndex
  Left = 276
  Top = 134
  Width = 540
  Height = 345
  Caption = 'Stages SSS 1#'
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
    Width = 532
    Height = 318
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        Width = 80
      end
      item
        Caption = 'Info'
        Width = 250
      end
      item
        Caption = 'Data'
        Width = 150
      end>
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListView1Data
  end
  object PopupMenu1: TPopupMenu
    Left = 106
    Top = 87
    object GotoMap1: TMenuItem
      Caption = 'Goto &Map ...'
      OnClick = GotoMap1Click
    end
    object GotoEnterScript1: TMenuItem
      Caption = 'Goto &Enter Script ...'
      OnClick = GotoEnterScript1Click
    end
    object GotoExitScript1: TMenuItem
      Caption = 'Goto E&xit Script ...'
      OnClick = GotoExitScript1Click
    end
  end
end
