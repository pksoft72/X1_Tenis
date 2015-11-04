program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  tscap32_dt in '..\tscap32_dt.pas',
  tscap32_rt in '..\tscap32_rt.pas',
  tsDebug in '..\tsDebug.pas',
  tsDibRel in '..\tsDibRel.pas',
  tsLogbox in '..\tsLogbox.pas',
  tsMessages in '..\tsMessages.pas',
  tsmisc in '..\tsmisc.pas',
  tsTechAboutFrm in '..\tsTechAboutFrm.pas',
  tstlg in '..\tstlg.pas',
  tstlg2 in '..\tstlg2.pas',
  vfwunit in '..\vfwunit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
