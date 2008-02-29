unit PathSel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls;

type
  TfrmPathSelect = class(TForm)
    ShellTreeView1: TShellTreeView;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function SelectSavePath(const cap: string; var path: string): integer;

implementation

{$R *.dfm}

function SelectSavePath(const cap: string; var path: string): integer;
var
  frmPathSelect: TfrmPathSelect;
begin
  Application.CreateForm(TfrmPathSelect, frmPathSelect);
  frmPathSelect.Caption := cap;
  Result := frmPathSelect.ShowModal;
  if Result = ID_OK then begin
     path := frmPathSelect.ShellTreeView1.Path;
     if (Length(path) > 3) and (path[Length(path)] <> '\')
       then path := path + '\';
  end;
end;

end.
