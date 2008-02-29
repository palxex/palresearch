unit Shop;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls;

type
  TfrmShop = class(TForm)
    ListView1: TListView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
  private
    { Private declarations }
  public
    F: TMemoryStream;
    destructor Destroy; override;
  end;

procedure ShowShops;

implementation

uses Decoder, Main, Msg;

{$R *.dfm}

procedure ShowShops;
var
  frmShop: TfrmShop;
  i: integer;
begin
  frmShop := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmShop') then begin
      frmShop := frmMain.MDIChildren[i] as TfrmShop;
      Break;
    end;
  if frmShop = nil then begin
    Application.CreateForm(TfrmShop, frmShop);
    frmShop.F := TMemoryStream.Create;
    DecodeStream('DATA.MKF', 0, False, frmShop.F);

    frmShop.ListView1.Items.Count := frmShop.F.Size div 18;

  end;
  frmShop.Show;
end;

destructor TfrmShop.Destroy;
begin
  inherited Destroy;
  F.Free;
end;

procedure TfrmShop.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

function GetNameS(v: word): string;
begin
  if v = 0
    then Result := Format('(null)', [])
    else Result := Format('%0.2X:%s', [v, PalMsg.Words[v]]);
end;

procedure TfrmShop.ListView1Data(Sender: TObject; Item: TListItem);
var
  d: packed array [0..8] of Word;
begin
  F.Position := Item.Index * 18;
  F.Read(d, 18);
  Item.Caption := Format('0x%0.2X (%d)', [Item.Index, Item.Index]);
  Item.SubItems.Add( Format('%s,%s,%s,%s,%s,%s,%s,%s,%s', [GetNameS(d[0]),
     GetNameS(d[1]),GetNameS(d[2]),GetNameS(d[3]),GetNameS(d[4]),
     GetNameS(d[5]),GetNameS(d[6]),GetNameS(d[7]),GetNameS(d[8]) ]));
//  Item.Caption := Format('%d', [Item.Index]);

//  PalMsg.Words[(Item.Index )]

end;

end.
