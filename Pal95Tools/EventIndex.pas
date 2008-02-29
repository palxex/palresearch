unit EventIndex;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls;

type
  TfrmEventIndex = class(TForm)
    ListView1: TListView;
    Panel1: TPanel;
    Timer1: TTimer;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    SSS1: TMemoryStream;
    MGO: TMemoryStream;
    destructor Destroy; override;
  end;

procedure ShowEventIndex;

implementation

uses
  Main, Decoder, MapInfo;

{$R *.dfm}

procedure ShowEventIndex;
var
  frmEventIndex: TfrmEventIndex;
  i: integer;
begin
  frmEventIndex := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmEventIndex') then begin
      frmEventIndex := frmMain.MDIChildren[i] as TfrmEventIndex;
      Break;
    end;
  if frmEventIndex = nil then begin
    Application.CreateForm(TfrmEventIndex, frmEventIndex);

    frmEventIndex.SSS1 := TMemoryStream.Create;
    DecodeStream('sss.mkf', 0, False, frmEventIndex.SSS1);

    frmEventIndex.ListView1.Items.Count := frmEventIndex.SSS1.Size div 32;

    frmEventIndex.MGO := TMemoryStream.Create;
    frmEventIndex.MGO.LoadFromFile(PalPath + 'MGO.MKF');

  end;
  frmEventIndex.Show;
end;

destructor TfrmEventIndex.Destroy;
begin
  inherited Destroy;
  SSS1.Free;
  MGO.Free;
end;

procedure TfrmEventIndex.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmEventIndex.ListView1Data(Sender: TObject; Item: TListItem);
var
  eb: packed array [0..15] of Word;
begin
  Item.Caption := Format('$%0.4X #%d', [Item.Index+1, Item.Index+1]);
  SSS1.Position := Item.Index * 32;
  SSS1.Read(eb, sizeof(eb));
  Item.SubItems.Add (Format('%0.4X %0.4X %0.4X %0.4X , %0.4X %0.4X %0.4X %0.4X',
                     [eb[0], eb[1], eb[2], eb[3], eb[4], eb[5], eb[6], eb[7] ] ) );
  Item.SubItems.Add (Format('%0.4X %0.4X %0.4X %0.4X , %0.4X %0.4X %0.4X %0.4X',
                     [eb[8], eb[9], eb[10], eb[11], eb[12], eb[13], eb[14], eb[15] ] ) );



end;

procedure TfrmEventIndex.ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  if Item = nil then Exit;
  if Timer1.Enabled then Timer1.Enabled := False;
  Timer1.Tag := Item.Index;
  Timer1.Enabled := True;
end;

procedure TfrmEventIndex.Timer1Timer(Sender: TObject);
var
  eb: packed array [0..15] of Word;
  xx, yy: integer;

begin
  Timer1.Enabled := False;
  SSS1.Position := Timer1.Tag * 32;
  SSS1.Read(eb, sizeof(eb));

  xx := (eb[1] div 32) * 2;
  case eb[1] mod 32 of
    0..8 : Dec(xx);
   26..34: Inc(xx);
  end;
  if (xx mod 2) = 0 then begin
    yy := eb[2] div 16;
  end else begin
    yy := (eb[2] - 8) div 16;
  end;

  Label1.Caption := Format('Position: %0.4Xx%0.4X -> %dx%d -> %dx%d',
                     [eb[1], eb[2], eb[1], eb[2], xx, yy ]);

  DrawMGO(eb[8], Image1.Picture.Bitmap);
  Image1.Invalidate;
  Label2.Caption := Format('Bitmap: %dx%d', [Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height ]);

  if mMap <> nil then begin
    mMap.Image2.Picture.Bitmap.Assign( Image1.Picture.Bitmap);
    if Image1.Picture.Bitmap.Width > 1 then begin
    //mMap.Image2.Left := eb[1] + (eb[1] div 16) - (Image1.Picture.Bitmap.Width div 2) + 16;  (W:17)
    {mMap.Image2.Picture.Bitmap.Canvas.Pixels[0, 0] := $00FF0000;
    mMap.Image2.Picture.Bitmap.Canvas.Pixels[0, 1] := $00FF0000;
    mMap.Image2.Picture.Bitmap.Canvas.Pixels[1, 0] := $00FF0000;}
      mMap.Image2.Width := mMap.Image2.Picture.Bitmap.Width;
      mMap.Image2.Height := mMap.Image2.Picture.Bitmap.Height;
      mMap.Image2.Canvas.Pen.Color := clRed;
      mMap.Image2.Picture.Bitmap.TransparentColor := clWhite;
      mMap.Image2.Canvas.MoveTo(0, 0);
      mMap.Image2.Canvas.LineTo(mMap.Image2.Picture.Bitmap.Width-1, 0);
      mMap.Image2.Canvas.LineTo(mMap.Image2.Picture.Bitmap.Width-1, mMap.Image2.Picture.Bitmap.Height-1);
      mMap.Image2.Canvas.LineTo(0, mMap.Image2.Picture.Bitmap.Height-1);
      mMap.Image2.Canvas.LineTo(0, 0);

      mMap.Image2.Left := mMap.Image1.Left + eb[1] - (Image1.Picture.Bitmap.Width div 2) + 16;
      //mMap.Image2.Top := mMap.Image1.Top + eb[2] - (Image1.Picture.Bitmap.Height div 2) - 8; // + abs( Smallint(eb[3]) * 2);
      mMap.Image2.Top := mMap.Image1.Top + eb[2] - Image1.Picture.Bitmap.Height + 15;
    end;
    mMap.setCurs(eb[1], eb[2]  );
  end;

end;

end.
