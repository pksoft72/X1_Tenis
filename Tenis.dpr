program Tenis;

uses
  Forms,
  VSampleDemo_MainForm in 'VSampleDemo_MainForm.pas' {Form_Main},
  VSample in 'VSample.pas',
  VFrames in 'VFrames.pas',
  DirectShow9 in 'DirectX\DirectShow9.pas',
  DirectDraw in 'DirectX\DirectDraw.pas',
  DirectSound in 'DirectX\DirectSound.pas',
  DXTypes in 'DirectX\DXTypes.pas',
  Direct3D9 in 'DirectX\Direct3D9.pas',
  Frame_Video in 'Frame_Video.pas' {Frame1: TFrame},
  Ugame in 'Ugame.pas',
  UVector in 'UVector.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Tenis demo';
  Application.CreateForm(TForm_Main, Form_Main);
  Application.Run;
end.
