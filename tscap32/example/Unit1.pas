unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, tscap32_rt, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    tsCap321: TtsCap32;
    tsCap32Dialogs1: TtsCap32Dialogs;
    tsCap32PopupMenu1: TtsCap32PopupMenu;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button4Click(Sender: TObject);
begin
  tscap321.Connected := Not tscap321.Connected;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  tscap321.SaveAsBMP := 'C:\test.bmp';
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  tscap321.CapOrder := start;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  tscap321.CapOrder := stop;
end;

end.
