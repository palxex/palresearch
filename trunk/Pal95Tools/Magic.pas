unit Magic;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls;

type
  TfrmMagic = class(TForm)
    ListView1: TListView;
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public             
    F: TMemoryStream;
    destructor Destroy; override;
  end;

procedure ShowMagics;

implementation

uses Main, Decoder, Msg;

{$R *.dfm}

procedure ShowMagics;
var
  frmMagic: TfrmMagic;
  i: integer;
begin
  frmMagic := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmMagic') then begin
      frmMagic := frmMain.MDIChildren[i] as TfrmMagic;
      Break;
    end;
  if frmMagic = nil then begin
    Application.CreateForm(TfrmMagic, frmMagic);
    frmMagic.F := TMemoryStream.Create;
    DecodeStream('DATA.MKF', 4, False, frmMagic.F);
    frmMagic.ListView1.Items.Count := frmMagic.F.Size div 32;
  end;
  frmMagic.Show;
end;

destructor TfrmMagic.Destroy;
begin
  inherited Destroy;
  F.Free;
end;

procedure TfrmMagic.ListView1Data(Sender: TObject; Item: TListItem);
var
  d: packed array [0..15] of Smallint;
begin
  Item.Caption := Format('#%0.2X (%d)', [Item.Index, Item.Index]);

  F.Position := Item.Index * 32;
  F.Read(d, 32);
  Item.SubItems.Add( PalMsg.Words[Item.Index + 295] );
  Item.SubItems.Add( Format('%d,%d (%d x %d)', [d[0], d[1], d[2], d[3]]));

  Item.SubItems.Add( Format('%d, %d, %d, %d, %d, %d, %d, %d', [d[4], d[5], d[6], d[7], d[8], d[9], d[10], d[11]]));

  Item.SubItems.Add( Format('%4d, %4d, %4d, %4d', [d[12], d[13], d[14], d[15]]));
end;

procedure TfrmMagic.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
