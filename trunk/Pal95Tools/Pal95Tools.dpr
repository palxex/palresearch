program Pal95Tools;

uses
  Forms,
  Main in 'Main.pas' {frmMain},
  MapInfo in 'MapInfo.pas' {frmMap},
  Decoder in 'Decoder.pas',
  EventIndex in 'EventIndex.pas' {frmEventIndex},
  StageIndex in 'StageIndex.pas' {frmStageIndex},
  ItemIndex in 'ItemIndex.pas' {frmItemIndex},
  Msg in 'Msg.pas',
  Talks in 'Talks.pas' {frmTalk},
  Script in 'Script.pas' {frmScript},
  Scriptor in 'Scriptor.pas',
  PathSel in 'PathSel.pas' {frmPathSelect},
  CVCode in 'cvcode.pas',
  PaletteExp in 'PaletteExp.pas' {frmPalette},
  Shop in 'Shop.pas' {frmShop},
  Magic in 'Magic.pas' {frmMagic},
  RngView in 'RngView.pas' {frmRNGView},
  MkfExp in 'MkfExp.pas' {frmMKF};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  frmMain.Init;
  Application.Run;
end.
