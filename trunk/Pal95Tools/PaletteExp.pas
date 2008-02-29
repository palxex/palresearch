unit PaletteExp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmPalette = class(TForm)
    ComboBox1: TComboBox;
    Image1: TImage;
    Button1: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox1Select(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowPalette;

implementation

uses
  Main, Decoder;

{$R *.dfm}

procedure ShowPalette;
var
  frmPalette: TfrmPalette;
  i: integer;
begin
  frmPalette := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmPalette') then begin
      frmPalette := frmMain.MDIChildren[i] as TfrmPalette;
      Break;
    end;
  if frmPalette = nil then begin
    Application.CreateForm(TfrmPalette, frmPalette);
    frmPalette.ComboBox1Select(frmPalette.ComboBox1);
  end;
  frmPalette.Show;
end;

procedure TfrmPalette.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmPalette.ComboBox1Select(Sender: TObject);
var
  p: PPalRecs;
  i, j, k: integer;
begin
  p := Palette[ComboBox1.ItemIndex];

  Image1.Picture.Bitmap.FreeImage;
  Image1.Picture.Bitmap.Width := 256;
  Image1.Picture.Bitmap.Height := 256;
  Image1.Picture.Bitmap.PixelFormat := pf24bit;

  with Image1.Picture.Bitmap.Canvas do begin
    Lock;

    Pen.Color := clBlack;
    Pen.Style := psSolid;

    Brush.Style := bsSolid;

    k := 0;
    for j:=0 to 15 do
      for i:=0 to 15 do begin
        //
        Brush.Color := (((p^[k].r shl 2) + 0) shl 0)
                     + (((p^[k].g shl 2) + 0) shl 8)
                     + (((p^[k].b shl 2) + 0) shl 16);

        Rectangle( i * 16 + 1, j * 16 + 1, i * 16 + 15, j * 16 + 15 );
        Inc(k);
      end;
    Unlock;
  end;
  Image1.Invalidate;
end;

end.
