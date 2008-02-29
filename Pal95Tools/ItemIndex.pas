unit ItemIndex;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;

type
  TfrmItemIndex = class(TForm)
    ListView1: TListView;
    PageControl1: TPageControl;
    TabSheet3: TTabSheet;
    Timer1: TTimer;
    Image1: TImage;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    Label2: TLabel;
    TabSheet4: TTabSheet;
    TabSheet1: TTabSheet;
    Image2: TImage;
    Image3: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    SSS3: TMemoryStream;
    BALL: TMemoryStream;
    DATA4: TMemoryStream;

    destructor Destroy; override;
  end;

procedure ShowItemIndex;

implementation

uses
  Main, Decoder, Msg;

{$R *.dfm}

procedure ShowItemIndex;
var
  frmItemIndex: TfrmItemIndex;
  i: integer;
begin
  frmItemIndex := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmItemIndex') then begin
      frmItemIndex := frmMain.MDIChildren[i] as TfrmItemIndex;
      Break;
    end;
  if frmItemIndex = nil then begin
    Application.CreateForm(TfrmItemIndex, frmItemIndex);
    frmItemIndex.ListView1.Column[1].Caption := 'RleID, Gold, UseS, EquS, DropS, Flags';
    frmItemIndex.SSS3 := TMemoryStream.Create;
    DecodeStream('sss.mkf', 2, False, frmItemIndex.SSS3);

    frmItemIndex.BALL := TMemoryStream.Create;
    frmItemIndex.BALL.LoadFromFile(PalPath + 'BALL.MKF');

    frmItemIndex.DATA4 := TMemoryStream.Create;
    DecodeStream('data.mkf', 4, False, frmItemIndex.DATA4);

    frmItemIndex.Image1.Picture.Bitmap.Width := frmItemIndex.Image1.Width;
    frmItemIndex.Image1.Picture.Bitmap.Height := frmItemIndex.Image1.Height;
    frmItemIndex.Image1.Picture.Bitmap.PixelFormat := pf24bit;

    if PalIsDos = 0
      then frmItemIndex.ListView1.Items.Count := frmItemIndex.SSS3.Size div 14
      else frmItemIndex.ListView1.Items.Count := frmItemIndex.SSS3.Size div 12;

  end;
  frmItemIndex.Show;
end;

destructor TfrmItemIndex.Destroy;
begin
  inherited Destroy;
  SSS3.Free;
  BALL.Free;
  DATA4.Free;
end;

procedure TfrmItemIndex.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree
end;

procedure TfrmItemIndex.ListView1Data(Sender: TObject; Item: TListItem);
var
  eb: packed array [0..6] of Word;
begin
  if PalIsDos = 0 then begin
    Item.Caption := Format('$%0.4X #%d', [Item.Index, Item.Index]);
    SSS3.Position := Item.Index * 14;
    SSS3.Read(eb, sizeof(eb));
    Item.SubItems.Add (Format('%0.4X %0.4X %0.4X %0.4X %0.4X %0.4X %0.4X', [eb[0], eb[1], eb[2], eb[3], eb[4], eb[5], eb[6] ] ) );
    Item.SubItems.Add ( PalMsg.Words[(Item.Index )] );
  end else begin
    Item.Caption := Format('$%0.4X #%d', [Item.Index, Item.Index]);
    SSS3.Position := Item.Index * 12;
    SSS3.Read(eb, sizeof(eb));
    Item.SubItems.Add (Format('%0.4X %0.4X %0.4X %0.4X %0.4X %0.4X', [eb[0], eb[1], eb[2], eb[3], eb[4], eb[5] ] ) );
    Item.SubItems.Add ( PalMsg.Words[(Item.Index )] );
  end;
end;

procedure TfrmItemIndex.ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  if Item = nil then Exit;
  if Timer1.Enabled then begin
    Timer1.Enabled := False;
  end;
  Timer1.Tag := Item.Index;
  Timer1.Enabled := True;
end;

procedure TfrmItemIndex.Timer1Timer(Sender: TObject);
var
  eb: packed array [0..6] of Word;
  i: integer;
  ty:integer;
  flagi: integer;
begin
  Timer1.Enabled := False;

  if PalIsDos = 0 then begin
    SSS3.Position := Timer1.Tag * 14;
    flagi := 6;
  end else begin
    SSS3.Position := Timer1.Tag * 12;
    flagi := 5;
  end;
  SSS3.Read(eb, sizeof(eb));


//  Memo1.Lines.Add( IntToStr(Timer1.Tag) )
  case Timer1.Tag of
    61..294:    // 0x003D ~ 0x0126
      begin
        PageControl1.ActivePageIndex := 0;
        i := eb[0];
        DrawBall(BALL, i, Image1.Picture.Bitmap);
//        Image1.Refresh;
        Image1.Width := Image1.Picture.Bitmap.Width * 2;
        Image1.Height := Image1.Picture.Bitmap.Height * 2;

        Label1.Caption := 'Sell: $' + IntToStr(eb[1]);

        CheckBox1.Checked := (eb[flagi] and $0001) <> 0;
        CheckBox2.Checked := (eb[flagi] and $0002) <> 0;
        CheckBox3.Checked := (eb[flagi] and $0004) <> 0;
        CheckBox4.Checked := (eb[flagi] and $0008) <> 0;

        CheckBox5.Checked  := (eb[flagi] and $0040) <> 0;
        CheckBox6.Checked  := (eb[flagi] and $0080) <> 0;
        CheckBox7.Checked  := (eb[flagi] and $0100) <> 0;
        CheckBox8.Checked  := (eb[flagi] and $0200) <> 0;
        CheckBox9.Checked  := (eb[flagi] and $0400) <> 0;
        CheckBox10.Checked := (eb[flagi] and $0800) <> 0;
      end;
    295..397: begin   // 0x0127 ~ 0x018D
        PageControl1.ActivePageIndex := 1;
        i := eb[0]*32;
        DATA4.Position := i;
        DATA4.Read(i,2);
        DATA4.Read(ty,2);
        if ty=9 then begin
          DATA4.Position := DATA4.Position+4;
          DATA4.Read(i,2);
          i := i+10;
          Draw('f.mkf',i,Image2.Picture.Bitmap);
        end
        else
          Draw('fire.mkf',i,Image2.Picture.Bitmap);  
      end;
    398..550: begin   // 0x019E ~ 0x0226
        PageControl1.ActivePageIndex := 2;
//        i := eb[0];
        Draw('abc.mkf',eb[0],Image3.Picture.Bitmap);
      end;

  end;

end;

end.
