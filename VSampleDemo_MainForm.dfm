object Form_Main: TForm_Main
  Left = 333
  Top = 55
  Caption = 'Demo tenis'
  ClientHeight = 601
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  GlassFrame.Enabled = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inline Frame_Video1: TFrame1
    Left = 0
    Top = 0
    Width = 760
    Height = 601
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 760
    ExplicitHeight = 561
    inherited Panel_Top: TPanel
      Width = 760
      ExplicitTop = 2
      ExplicitWidth = 760
      DesignSize = (
        760
        104)
      inherited Label_Cameras: TLabel
        Width = 52
        ExplicitWidth = 52
      end
      inherited Label3: TLabel
        Width = 51
        ExplicitWidth = 51
      end
      inherited Label4: TLabel
        Width = 44
        ExplicitWidth = 44
      end
      inherited Bevel1: TBevel
        Width = 641
        ExplicitWidth = 641
      end
      inherited btnStartBalls: TButton
        Left = 361
        Top = 57
        ExplicitLeft = 361
        ExplicitTop = 57
      end
    end
    inherited Panel_Bottom: TPanel
      Width = 760
      Height = 497
      ExplicitWidth = 760
      ExplicitHeight = 457
      DesignSize = (
        760
        497)
      inherited Label_VideoSize: TLabel
        Width = 50
        ExplicitWidth = 50
      end
      inherited Label_fps: TLabel
        Width = 90
        ExplicitWidth = 90
      end
      inherited Label2: TLabel
        Width = 49
        ExplicitWidth = 49
      end
      inherited PaintBox_Video: TPaintBox
        Width = 751
        Height = 457
        ExplicitWidth = 367
        ExplicitHeight = 499
      end
    end
  end
end
