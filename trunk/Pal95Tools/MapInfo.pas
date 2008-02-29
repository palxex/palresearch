unit MapInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst;

type
  TfrmMap = class(TForm)
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    StatusBar1: TStatusBar;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    CheckBox3: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox1Change(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox3Click(Sender: TObject);
  private
    NpcX, NpcY: integer;
    DrawLayer0, DrawLayer1, DrawGridMargin: Boolean;
  public
    MapStream: TMemoryStream;
    GopStream: TMemoryStream;
    procedure MoveNpcTo(x, y: integer);
    procedure setCurs(x, y: integer);
  end;

var
  mMap: TfrmMap = nil;

procedure DoMapInfo(MapId: integer);

implementation

uses
  Main, Decoder;

{$R *.dfm}

procedure DoMapInfo(MapId: integer);
var
  frmMap: TfrmMap;
  i, j: integer;
begin
  frmMap := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmMap') then begin
      frmMap := frmMain.MDIChildren[i] as TfrmMap;
      Break;
    end;

  if frmMap = nil then begin
    Application.CreateForm(TfrmMap, frmMap);
    j := MKFFileCount('MAP');
    for i:=0 to j-1 do frmMap.ComboBox1.Items.Add( Format('%3d# - 0x%0.4X', [i, i]));
    frmMap.MapStream := TMemoryStream.Create;
    frmMap.GopStream := TMemoryStream.Create;
    frmMap.ScrollBox1.DoubleBuffered := True;

//    frmMap.Image1.Picture.Bitmap.Width := 2048 + 16 + 128; // (W:17)
    frmMap.Image1.Picture.Bitmap.Width := 2048 + 16;

    frmMap.Image1.Picture.Bitmap.Height := 2048 + 8;
    frmMap.Image1.Picture.Bitmap.PixelFormat := pf24bit;

    frmMap.Image1.Width := frmMap.Image1.Picture.Bitmap.Width;
    frmMap.Image1.Height := frmMap.Image1.Picture.Bitmap.Height;


    frmMap.DrawLayer0 := True;
    frmMap.DrawLayer1 := True;
    frmMap.DrawGridMargin := False;
  end;

  if MapId <> frmMap.ComboBox1.ItemIndex then begin
    frmMap.ComboBox1.ItemIndex := MapId;
    frmMap.ComboBox1Change(frmMap.ComboBox1);
  end;

  frmMap.Show;
  mMap := frmMap;
end;

procedure TfrmMap.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  mMap := nil;
  Action := caFree;
  MapStream.Free;
  GopStream.Free;
end;

procedure TfrmMap.ComboBox1Change(Sender: TObject);
type
  TRGBRec = packed record b,g,r: Byte; end;
  PRGBRec = ^TRGBRec;
var
  i, j, m, k: integer;
  xx, yy: integer;
  b: boolean;
  mi: integer;
  p: PRGBRec;
begin
  NpcX := -1;
  NpcY := -1;
  DecodeMap(ComboBox1.ItemIndex, MapStream, GopStream);

  Image1.Picture.Bitmap.Canvas.Brush.Style := bsSolid;
  Image1.Picture.Bitmap.Canvas.Brush.Color := clBlack;
  Image1.Picture.Bitmap.Canvas.Pen.Style := psSolid;
  Image1.Picture.Bitmap.Canvas.Pen.Color := clBlack;
  Image1.Picture.Bitmap.Canvas.FillRect( Image1.ClientRect );

  if GopStream.Size <= 0 then Exit;

  MapStream.Position := 0;

  yy := 0;
  for j:=0 to 127 do begin
    xx := 0;
    b := false;
    for i:=0 to 127 do begin

      MapStream.Read(m, 4);

      if DrawLayer0 then begin
        mi := m and $FF;
        if (m and $1000) <> 0 then Inc(mi, $100);
        if b
          then DrawRle(GopStream, mi, Image1.Picture.Bitmap, xx, yy + 8)
          else DrawRle(GopStream, mi, Image1.Picture.Bitmap, xx, yy);
      end;

      if DrawLayer1 then begin
        mi := (m and $FF0000) shr 16;
        if (m and $10000000) <> 0 then Inc(mi, $100);
        if mi <> 0 then begin
          if b
            then DrawRle(GopStream, mi-1, Image1.Picture.Bitmap, xx, yy + 8)
            else DrawRle(GopStream, mi-1, Image1.Picture.Bitmap, xx, yy);
        end;
      end;

      if DrawGridMargin then begin
        for k:=0 to 7 do begin
          if b
            then p := Image1.Picture.Bitmap.ScanLine[yy+8+k]
            else p := Image1.Picture.Bitmap.ScanLine[yy+0+k];
          Inc(p, xx+17+k+k);
          p^.r := 0;
          p^.g := 0;
          p^.b := 0;
        end;
        for k:=0 to 6 do begin
          if b
            then p := Image1.Picture.Bitmap.ScanLine[yy+16+k]
            else p := Image1.Picture.Bitmap.ScanLine[yy+8+k];
          Inc(p, xx+29-k-k);
          p^.r := 0;
          p^.g := 0;
          p^.b := 0;
        end;
      end;

      //Inc(xx, 17); // (W:17)
      Inc(xx, 16);

      b := not b;
    end;
    Inc(yy, 16);
  end;

//  StatusBar1.Panels[1].Text := 'Load map ' + IntToStr(ComboBox1.ItemIndex) + ' ' + IntToStr(GopStream.Size);

end;

procedure TfrmMap.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  xx, yy: integer;
begin
  ScrollBox1.SetFocus;

  //xx := (X div 34) * 2;         // (W:17)
  //case X mod 34 of
  xx := (X div 32) * 2;
  case X mod 32 of
    0..8 : Dec(xx);
   26..34: Inc(xx);
  end;

  if (xx mod 2) = 0 then begin
    yy := Y div 16;
  end else begin
    yy := (Y - 8) div 16;
  end;

  if (xx>=0) and (xx<128) and (yy>=0) and (yy<=128) then begin
    MoveNpcTo(xx, yy);
    //StatusBar1.Panels[1].Text := Format(' %d, %d (%dx%d)', [xx, yy, X - (X div 17), Y] ); // (W:17)
    StatusBar1.Panels[1].Text := Format(' %d, %d (%dx%d)', [xx, yy, X, Y] );
  end;
end;

procedure TfrmMap.MoveNpcTo(x, y: integer);

  procedure drawScreenArea(xx, yy: integer);
  var
    xxx, yyy: integer;
  begin
    with Image1.Picture.Bitmap.Canvas do begin
      Pen.Style := psSolid;
      Pen.Mode := pmXor;
      Pen.Color := clWhite;

      //xxx := xx * 17 + 16; // (W:17)
      xxx := xx * 16 + 16;
      yyy := yy * 16 + 7;
      if (xx mod 2) <> 0 then yyy := yyy + 8;

      MoveTo( xxx - 5, yyy );
      LineTo( xxx + 5, yyy );
      MoveTo( xxx, yyy - 3);
      LineTo( xxx, yyy + 4);

   {   MoveTo( xxx - 34 * 5, yyy - 16 * 7 + 8 );  // (W:17)
      LineTo( xxx + 34 * 5, yyy - 16 * 7 + 8 );
      LineTo( xxx + 34 * 5, yyy + 16 * 6 );
      LineTo( xxx - 34 * 5, yyy + 16 * 6 );
      LineTo( xxx - 34 * 5, yyy - 16 * 7 + 8 ); {}
      MoveTo( xxx - 32 * 5, yyy - 16 * 7 + 8 );
      LineTo( xxx + 32 * 5, yyy - 16 * 7 + 8 );
      LineTo( xxx + 32 * 5, yyy + 16 * 6 );
      LineTo( xxx - 32 * 5, yyy + 16 * 6 );
      LineTo( xxx - 32 * 5, yyy - 16 * 7 + 8 );


    end;
  end;

  function ByteToStr( b: Byte ): string;
  var
    i, j: integer;

  begin
    Result := '00000000';
    j := $80;
    for i:=1 to 8 do begin
      if (j and b) <> 0 then Result[i] := '1';
      j := j shr 1;
    end;
  end;

var
  p: PLongword;
  m0, m1: Word;
  ms0, ms1: Word;
begin
  if MapStream.Size < 1 then Exit;
  if (NpcX = x) and (NpcY = y) then Exit;

  if NpcX <> -1 then drawScreenArea(NpcX, NpcY);
  NpcX := x; NpcY := y; drawScreenArea(x, y);

  p := MapStream.Memory;
  Inc(p, Y * 128 + X);

  m0 := (p^ and $EF00) shr 8;
  m1 := ((p^ shr 16) and $EF00) shr 8;

  ms0 := p^ and $FF;
  if (p^ and $1000) <> 0 then Inc(ms0, 256);
  ms1 := (p^ shr 16) and $FF;
  if (p^ and $10000000) <> 0 then Inc(ms1, 256);

  StatusBar1.Panels[2].Text := Format('Layer A: %s (%d),  Layer B: %s (%d)', [ByteToStr(m0), ms0, ByteToStr(m1), ms1] );

end;

procedure TfrmMap.setCurs(x, y: integer);
begin
  Image3.Left := Image1.Left + x - 4;
  Image3.Top := Image1.Top + y - 4;
  ScrollBox1.ScrollInView(Image3);
end;

procedure TfrmMap.CheckBox1Click(Sender: TObject);
begin
  DrawLayer0 := CheckBox1.Checked;
  ComboBox1Change(ComboBox1);
end;

procedure TfrmMap.CheckBox2Click(Sender: TObject);
begin
  DrawLayer1 := CheckBox2.Checked;
  ComboBox1Change(ComboBox1);
end;

procedure TfrmMap.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1MouseDown(Sender, Button, Shift, X + Image2.Left, Y + Image2.Top);
end;

procedure TfrmMap.Image3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1MouseDown(Sender, Button, Shift, X + Image3.Left - Image1.Left , Y + Image3.Top - Image1.Top);
end;

procedure TfrmMap.CheckBox3Click(Sender: TObject);
begin
  DrawGridMargin := CheckBox3.Checked;
  ComboBox1Change(ComboBox1);
end;

end.
