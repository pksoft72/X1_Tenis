unit VSampleDemo_MainForm;

interface

uses
  Windows, Classes, Controls, Forms, ExtCtrls, FormAbout, Frame_Video, Menus,
  StdCtrls;


type
  TForm_Main = class(TForm)
    Frame_Video1: TFrame1;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    SplitterRatio : double;
  public
    { Public declarations }
  end;


var
  Form_Main: TForm_Main;


implementation

{$R *.dfm}







procedure TForm_Main.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  Frame_Video1.Stop;
  Screen.Cursor := crdefault;
end;



procedure TForm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Frame_Video1.Close;
end;

procedure TForm_Main.FormShow(Sender: TObject);
begin
  Frame_Video1.InitFrame;
end;

procedure TForm_Main.Quit1Click(Sender: TObject);
begin
  close;
end;

procedure TForm_Main.About1Click(Sender: TObject);
begin
  AboutBox.Show;
end;

procedure TForm_Main.FormCreate(Sender: TObject);
begin
  SplitterRatio := 0.5;
end;

end.
