object Form1: TForm1
  Left = 192
  Top = 107
  Caption = 'test application for tscap32'
  ClientHeight = 435
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 680
    Height = 73
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 334
      Height = 13
      Caption = 
        'Use right mouseclick to open context menu for the Capture Compon' +
        'ent'
    end
    object Label2: TLabel
      Left = 8
      Top = 24
      Width = 277
      Height = 13
      Caption = 'Use Buttons to start/stop capture or to capture a still image'
    end
    object Label3: TLabel
      Left = 8
      Top = 40
      Width = 289
      Height = 13
      Caption = 'The capture'#39'd AVI is at C:\capture.avi - limited to size 100Mb.'
    end
    object Button1: TButton
      Left = 552
      Top = 8
      Width = 129
      Height = 25
      Caption = 'Start AVI Capture'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 552
      Top = 40
      Width = 129
      Height = 25
      Caption = 'Stop AVI Capture'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 352
      Top = 40
      Width = 169
      Height = 25
      Caption = 'Capture Image (C:\test.bmp)'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 352
      Top = 8
      Width = 129
      Height = 25
      Caption = 'Connect/Disconnect'
      TabOrder = 3
      OnClick = Button4Click
    end
  end
end
