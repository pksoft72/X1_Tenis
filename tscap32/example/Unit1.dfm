object Form1: TForm1
  Left = 192
  Top = 107
  Width = 696
  Height = 474
  Caption = 'test application for tscap32'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object tsCap321: TtsCap32
    Left = 0
    Top = 73
    Width = 688
    Height = 374
    Logo = True
    PreventMessageHook = False
    Taborder = 0
    CapOrder = start
    Parameter.BufferFile = 'C:\Capture.avi'
    Parameter.BufferFileSize_Mb = 100
    Parameter.SaveFile = 'C:\SaveFile.avi'
    Parameter.PreviewRate_mspf = 100
    Parameter.PreviewRate_fps = 10
    Parameter.CaptureRate_uspf = 66667
    Parameter.CaptureRate_fps = 14
    Parameter.CapTechnique = ctStreamIntoFile
    Parameter.DlgFormat = False
    Parameter.DlgCompression = False
    Parameter.DlgSource = False
    Parameter.DlgDisplay = False
    Parameter.TimeLimit = 10
    Parameter.TimeLimitEnabled = False
    Parameter.UserHitToCapture = False
    Parameter.AbortKey = 0
    Parameter.ImageWidth = 0
    Parameter.ImageHeight = 0
    Parameter.MCIControl = False
    Parameter.MCIDeviceStep = False
    Parameter.MCIStartTime = 0
    Parameter.MCIStopTime = 0
    DriverCaps.HasOverlay = False
    DriverCaps.HasDlgVideoSource = False
    DriverCaps.HasDlgVideoFormat = False
    DriverCaps.HasDlgVideoDisplay = False
    DriverCaps.DriverSuppliesPalettes = False
    AudioParameter.AudioHardware = False
    AudioParameter.SplFrequ = fdefault
    AudioParameter.SplWidth = wdefault
    AudioParameter.Channels = chdefault
    CapWndDimensions.x = 0
    CapWndDimensions.y = 0
    CapWndDimensions.w = 0
    CapWndDimensions.h = 0
    Driver = 0
    AboutAuthor = '(c) 1997 Thomas St'#252'fe'
    AboutVersion = 'v3.1 open - Published under LGPL'
    PopupMenu = tsCap32PopupMenu1
    Error = 'No Error'
    Align = alBottom
    CopyToClipBoard = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 688
    Height = 73
    Align = alTop
    TabOrder = 1
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
  object tsCap32Dialogs1: TtsCap32Dialogs
    AttachedTsCap32 = tsCap321
    BufferFileDlg = False
    AboutDlg = False
    DriverDlg = False
    AudioParameterDlg = False
    CaptureSettingsDlg = False
    PreviewRateDlg = False
    AdvCaptureSettingsDlg = False
    Left = 312
    Top = 104
  end
  object tsCap32PopupMenu1: TtsCap32PopupMenu
    AttachedTsCap32 = tsCap321
    StartCaption = 'Start'
    StopCaption = 'Stop'
    SaveCaption = 'Save'
    GrabCaption = 'Grab'
    ConnectCaption = 'Connect'
    PreviewCaption = 'Preview'
    OverlayCaption = 'Overlay'
    DialogsCaption = 'Driver Dialogs...'
    DialogFormatCaption = 'Format...'
    DialogDisplayCaption = 'Display...'
    DialogCompressionCaption = 'Compression...'
    DialogSourceCaption = 'Source...'
    CopyCaption = 'Copy To Clipboard'
    SaveAsBmpCaption = 'Save As *.Bmp'
    BufferFileCaption = 'Buffer File ...'
    CaptureDriverCaption = 'Capture Driver ...'
    Left = 344
    Top = 104
  end
end
