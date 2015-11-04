unit Frame_Video;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls,
  Buttons, MMSystem, Menus, ComCtrls, JPEG,
  VFrames;

type
  TPropertyControl = RECORD
    PCLabel: TLabel;
    PCTrackbar: TTrackBar;
    PCCheckbox: TCheckBox;
  END;

TVector = object
  X,Y : double;
  procedure Init(A : TPoint);
  function Length : double;
  function QLength : double;
  procedure Normalize;
  function Point : TPoint;
  procedure Diff(A,B : TPoint);
  procedure Mul(C : double);
  procedure Add(const A : TVector);
end;

  TFrame1 = class(TFrame)
    Panel_Top: TPanel;
    Label_Cameras: TLabel;
    ComboBox_Cams: TComboBox;
    PopupMenu1: TPopupMenu;
    Updatelistofcameras1: TMenuItem;
    Label1: TLabel;
    ComboBox_DisplayMode: TComboBox;
    ComboBox1: TComboBox;
    Panel_Bottom: TPanel;
    Label_VideoSize: TLabel;
    Label_fps: TLabel;
    Label2: TLabel;
    PaintBox_Video: TPaintBox;
    SpeedButton_RunVideo: TSpeedButton;
    SpeedButton_Pause: TSpeedButton;
    SpeedButton_Stop: TSpeedButton;
    SpeedButton_VidSettings: TSpeedButton;
    SpeedButton_VidSize: TSpeedButton;
    Label3: TLabel;
    SpeedButton1: TSpeedButton;
    Label4: TLabel;
    Bevel1: TBevel;
    pnlColor: TPanel;
    btnStartBalls: TButton;
    procedure Updatelistofcameras1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure SpeedButton_RunVideoClick(Sender: TObject);
    procedure SpeedButton_PauseClick(Sender: TObject);
    procedure SpeedButton_StopClick(Sender: TObject);
    procedure SpeedButton_VidSettingsClick(Sender: TObject);
    procedure SpeedButton_VidSizeClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure PaintBox_VideoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnStartBallsClick(Sender: TObject);
  private
    { Private declarations }
    Initialized: boolean;
    OnNewFrameBusy: boolean;
    fFrameCnt: integer;
    fSkipCnt: integer;
    f30FrameTick: integer;
    VideoImage: TVideoImage;
    VideoBMPIndex: integer;
    VideoBMP: ARRAY [0 .. 1] OF TBitmap; // Used below in case we want to paint the image by ourselfs....
    CopyBMP: TBitmap;
    ModeBMP: TBitmap;
    DiffCol: ARRAY [-255 .. 255] OF byte;
    DiffRatio: double;
    AppPath: string;
    SpyIndex: integer;
    LocalJPG: TJPEGImage;
    PropCtrl: ARRAY [TVideoProperty] OF TPropertyControl;

    Balls : array [0..5] of TPoint;
    BallsSpeed : array [0..5] of TPoint;
    procedure CleanPaintBoxVideo;
    procedure CalcInvertedImage(BM1, Inv: TBitmap);
    procedure CalcGrayScaleImage(BM1, Gray: TBitmap);
    procedure CalcDiffImage(BM1, BM2, Diff: TBitmap; VAR DiffRatio: double);
    procedure CalcDiffImage2(BM1, BM2, Diff: TBitmap; VAR DiffRatio: double);
    procedure OnNewFrame(Sender: TObject; Width, Height: integer; DataPtr: pointer);
    procedure PropertyTrackBarChange(Sender: TObject);
    procedure PropertyCheckBoxClick(Sender: TObject);

    procedure FindTarget(BMP: TBitmap);
  public
    { Public declarations }
    procedure UpdateCamList;
    procedure InitFrame;
    procedure Stop;
    PROCEDURE Close;
  end;

implementation

{$R *.dfm}

procedure TFrame1.UpdateCamList;
var
  SL: TStringList;
begin
  // Load ComboBox_Cams with list of available video interfaces (WebCams...)
  SL := TStringList.Create;
  VideoImage.GetListOfDevices(SL);
  ComboBox_Cams.Items.Assign(SL);
  SL.Free;

  // At least one WebCam found: enable "Run video" button
  SpeedButton_RunVideo.Enabled := false;
  IF ComboBox_Cams.Items.Count > 0 then begin
    IF (ComboBox_Cams.ItemIndex < 0) or (ComboBox_Cams.ItemIndex >= ComboBox_Cams.Items.Count) then
      ComboBox_Cams.ItemIndex := 0;
    SpeedButton_RunVideo.Enabled := true;
  end
  else begin
    ComboBox_Cams.Items.add('No cameras found.');
    SpeedButton_RunVideo.Enabled := false;
  end;
end;

type
  tbytearray = array [0 .. 16383] OF byte;
  pbytearray = ^tbytearray;


procedure TFrame1.CalcInvertedImage(BM1, Inv: TBitmap);
VAR
  X, Y: integer;
  p1, d: pbytearray;
begin
  Inv.Width := BM1.Width;
  Inv.Height := BM1.Height;
  Inv.PixelFormat := pf24bit;

  FOR Y := BM1.Height - 1 DOWNTO 0 DO BEGIN
    p1 := BM1.ScanLine[Y];
    d := Inv.ScanLine[Y];
    FOR X := 0 TO BM1.Width * 3 - 1 DO // "*3" because we have pf24bit images
      d^[X] := 255 - p1^[X];
  END;
end;


procedure TFrame1.CalcGrayScaleImage(BM1, Gray: TBitmap);
VAR
  X, Y, i: integer;
  p1, d: pbytearray;
  g: byte;
begin
  Gray.Width := BM1.Width;
  Gray.Height := BM1.Height;
  Gray.PixelFormat := pf24bit; // Not really necessary. pf8bit together with a suitable color palette would be better.

  FOR Y := BM1.Height - 1 DOWNTO 0 DO BEGIN
    p1 := BM1.ScanLine[Y];
    d := Gray.ScanLine[Y];
    i := 0;
    FOR X := 0 TO BM1.Width - 1 DO begin
      g := ((p1^[i] * 100) + (p1^[i + 1] * 128) + (p1^[i + 2] * 28)) shr 8;
      d^[i] := g;
      Inc(i);
      d^[i] := g;
      Inc(i);
      d^[i] := g;
      Inc(i);
    end;
  END;
end;


procedure TFrame1.btnStartBallsClick(Sender: TObject);
  var Angle : double;
      Center : TPoint;
      Speed,SpeedTarget : double;
      i : integer;
begin
  if VideoBMP[0] = nil then exit;
  Center.X := VideoBMP[0].Width shr 1;
  Center.Y := VideoBMP[0].Height shr 1;

  for i := 0 to High(Balls) - 1 do begin
    Angle := Random(180-90)/PI;
    Balls[i].X := Round(sin(Angle)*VideoBMP[0].Width+Center.X);
    Balls[i].Y := Round(cos(Angle)*VideoBMP[0].Height+Center.Y);
    BallsSpeed[i].X := (Center.X-Balls[i].X);
    BallsSpeed[i].Y := (Center.Y-Balls[i].Y)+10; // nahoru trochu
    Speed := sqrt(BallsSpeed[i].X*BallsSpeed[i].X+BallsSpeed[i].Y*BallsSpeed[i].Y);
    SpeedTarget := Random(10)+10;
    BallsSpeed[i].X := Round(BallsSpeed[i].X*SpeedTarget/Speed);
    BallsSpeed[i].Y := Round(BallsSpeed[i].Y*SpeedTarget/Speed);
  end;
end;

procedure TFrame1.CalcDiffImage(BM1, BM2, Diff: TBitmap; VAR DiffRatio: double);
VAR
  X, Y: integer;
  p1, p2, d: pbytearray;
  TotalDiff: integer;
begin
  DiffRatio := 0;
  IF (BM1.Width <> BM2.Width) or (BM1.Height <> BM2.Height) or (BM1.PixelFormat <> pf24bit) or (BM2.PixelFormat <> pf24bit) then begin
    Diff.Width := 1;
    Diff.Height := 1;
    Diff.PixelFormat := pf24bit;
    exit;
  end;

  Diff.Width := BM1.Width;
  Diff.Height := BM1.Height;
  Diff.PixelFormat := pf24bit; // Not really necessary. pf8bit together with a suitable color palette would be better.

  TotalDiff := 0;
  FOR Y := BM1.Height - 1 DOWNTO 0 DO BEGIN
    p1 := BM1.ScanLine[Y];
    p2 := BM2.ScanLine[Y];
    d := Diff.ScanLine[Y];
    FOR X := 0 + 3 TO BM1.Width * 3 - 1 - 3 DO // "*3" because we have pf24bit images
      begin
      // d^[X] := DiffCol[p1^[X]-p2^[X]];  // Without averaging
      d^[X] := DiffCol[((p1^[X - 3] + 2 * p1^[X] + p1^[X + 3]) - (p2^[X - 3] + 2 * p2^[X] + p2^[X + 3])) div 4];
      Inc(TotalDiff, d^[X]);
    end;
  END;
  DiffRatio := TotalDiff / (3 * Diff.Width * Diff.Height * 255);
end;


procedure TFrame1.CalcDiffImage2(BM1, BM2, Diff: TBitmap; VAR DiffRatio: double);
begin
  CalcDiffImage(BM1, BM2, Diff, DiffRatio);
  IF (Diff.Width = BM1.Width) then begin
    Diff.Canvas.CopyMode := cmSrcPaint;
    Diff.Canvas.Draw(0, 0, BM1);
    Diff.Canvas.CopyMode := cmSrcCopy;
  end;
end;


procedure TFrame1.OnNewFrame(Sender: TObject; Width, Height: integer; DataPtr: pointer);
VAR
  i, X, Y, T1: integer;
  d: double;
  s: string;
  hour, min, sec, msec: word;
begin
  Inc(fFrameCnt);
  IF OnNewFrameBusy then begin
    Inc(fSkipCnt);
    exit;
  end;

  OnNewFrameBusy := true;
  // Calculate "Frames per second"...
  IF fFrameCnt mod 30 = 0 then begin
    T1 := TimeGetTime;
    if f30FrameTick > 0 then
      Label_fps.Caption := 'fps: ' + FloatToStrf(30000 / (T1 - f30FrameTick), ffFixed, 16, 1) + ' [' + FloatToStrf(VideoImage.FramesPerSecond, ffFixed, 16, 1)
        + '] (' + IntToStr(fSkipCnt) + ' [' + IntToStr(VideoImage.FramesSkipped) + '] skipped)';
    f30FrameTick := T1;
  end;

  // In the following part the actual video frame is retreived from VideoImage and than
  // painted to the Paintbox_Video. This is usefull, if the image is to be modified
  // before painting. Otherwise we could have set "VideoImage.SetDisplayCanvas(PaintBox_Video.Canvas);"
  // in routine InitFrame below, and the painting would have been done by VideoImage.

  VideoBMPIndex := 1 - VideoBMPIndex;
  VideoImage.GetBitmap(VideoBMP[VideoBMPIndex]);

  FindTarget(VideoBMP[VideoBMPIndex]);

  IF ComboBox_DisplayMode.ItemIndex <= 0 then begin
    PaintBox_Video.Canvas.Draw(0, 0, VideoBMP[VideoBMPIndex]);
  end
  else begin
    DiffRatio := 0;
    CASE ComboBox_DisplayMode.ItemIndex OF
      1:
        CalcInvertedImage(VideoBMP[VideoBMPIndex], ModeBMP);
      2:
        CalcGrayScaleImage(VideoBMP[VideoBMPIndex], ModeBMP);
      3:
        CalcDiffImage(VideoBMP[VideoBMPIndex], VideoBMP[1 - VideoBMPIndex], ModeBMP, DiffRatio);
      4, 5:
        CalcDiffImage2(VideoBMP[VideoBMPIndex], VideoBMP[1 - VideoBMPIndex], ModeBMP, DiffRatio);
    else
      ModeBMP.Assign(VideoBMP[VideoBMPIndex]);
    END; { case }
    PaintBox_Video.Canvas.Draw(0, 0, ModeBMP);
    Label2.Caption := 'Diff-Ratio: ' + FloatToStrf(DiffRatio * 100, ffFixed, 16, 3) + '%';
    // Surveillance
    IF (DiffRatio > 0.03 / 100) and (ComboBox_DisplayMode.ItemIndex = 5) THEN BEGIN
      CopyBMP.Width := VideoBMP[VideoBMPIndex].Width;
      CopyBMP.Height := VideoBMP[VideoBMPIndex].Height;
      CopyBMP.Canvas.Draw(0, 0, VideoBMP[VideoBMPIndex]);
      WITH CopyBMP DO begin
        DecodeTime(Now, hour, min, sec, msec);
        Canvas.Brush.Style := bsClear;
        Canvas.TextOut(4, Height - 4 - Canvas.TextHeight('W'), DateTimetoStr(Now));
        Canvas.Brush.Style := bsSolid;
        Canvas.ellipse(4, 4, 36, 36);
        Canvas.Pen.Color := clBlack;
        FOR i := 0 TO 11 DO BEGIN
          Canvas.Pen.Color := clGray;
          Canvas.Brush.Color := clBlack;
          X := round(20 + 12 * Sin(i * 30 * Pi / 180));
          Y := round(20 - 12 * cos(i * 30 * Pi / 180));
          Canvas.ellipse(X - 2, Y - 2, X + 2, Y + 2);
        END;
        Canvas.Pen.Color := clBlack;
        d := (hour + min / 60) * 30 * Pi / 180;
        X := round(20 + 7 * Sin(d));
        Y := round(20 - 7 * cos(d));
        Canvas.Pen.Width := 3;
        Canvas.moveto(20, 20);
        Canvas.LineTo(X, Y);
        Canvas.Pen.Width := 1;
        Canvas.Pen.Color := clBlue;
        d := (min + sec / 60) * 6 * Pi / 180;
        X := round(20 + 10 * Sin(d));
        Y := round(20 - 10 * cos(d));
        Canvas.moveto(20, 20);
        Canvas.LineTo(X, Y);
        Canvas.Pen.Color := clRed;
        d := (sec) * 6 * Pi / 180;
        X := round(20 + 10 * Sin(d));
        Y := round(20 - 10 * cos(d));
        Canvas.moveto(20, 20);
        Canvas.LineTo(X, Y);
      end;

      ForceDirectories(AppPath + 'Spy\');
      Inc(SpyIndex);
      IF SpyIndex <= 4000 then begin
        s := IntToStr(SpyIndex);
        while length(s) < 4 do
          s := '0' + s;
        LocalJPG.Assign(CopyBMP);
        LocalJPG.SaveToFile(AppPath + 'Spy\Spy_' + s + '.jpg');
        // VideoBMP[VideoBMPIndex].SaveToFile(AppPath + 'Spy\Spy_'+s+'.bmp');
      end;
    END;
  end;
  OnNewFrameBusy := false;
end;


procedure TFrame1.InitFrame;
var
  i: integer;
  VP: TVideoProperty;
begin
  IF Initialized then
    exit;
  fSkipCnt := 0;
  Initialized := true;
  LocalJPG := TJPEGImage.Create;
  AppPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  SpeedButton_Stop.Enabled := false;

  // --- Instantiate TVideoImage
  VideoImage := TVideoImage.Create;
  // VideoImage.SetDisplayCanvas(PaintBox_Video.Canvas); // For automatically drawing video frames on paintbox
  VideoImage.SetDisplayCanvas(nil); // For drawing video by ourself
  VideoImage.OnNewVideoFrame := OnNewFrame;

  // --- Load ComboBox_Cams with list of available video interfaces (WebCams...)
  UpdateCamList;


  VideoBMP[0] := TBitmap.Create;
  VideoBMP[1] := TBitmap.Create;
  ModeBMP := TBitmap.Create;
  CopyBMP := TBitmap.Create;
  VideoBMP[0].PixelFormat := pf24bit;
  VideoBMP[1].PixelFormat := pf24bit;

  CopyBMP.PixelFormat := pf24bit;
  CopyBMP.Canvas.Font.Name := 'Arial';
  CopyBMP.Canvas.Font.Size := 10;
  CopyBMP.Canvas.Brush.Style := bsClear;

  FOR i := -255 TO 255 DO
    IF Abs(i) < 48// Differences between images must be larger than 24 to be displayed
      then
      DiffCol[i] := 0
    else IF Abs(i) < 48 + 64 then
      DiffCol[i] := (Abs(i) - 48) * 4
    else
      DiffCol[i] := 255;

  FOR VP := Low(TVideoProperty) TO High(TVideoProperty) DO
    WITH PropCtrl[VP] DO BEGIN
      PCLabel := TLabel.Create(Panel_Top);
      PCLabel.Parent := Panel_Top;
      PCLabel.Left := 8;
      PCLabel.Top := 112 + integer(VP) * 26;
      PCLabel.Caption := GetVideoPropertyName(VP);

      PCTrackbar := TTrackBar.Create(Panel_Top);
      PCTrackbar.Parent := Panel_Top;
      PCTrackbar.Left := 100;
      PCTrackbar.Top := PCLabel.Top - 8;
      PCTrackbar.Width := 218;
      PCTrackbar.Tag := integer(VP);
      PCTrackbar.Enabled := false;
      PCTrackbar.ThumbLength := 9;
      PCTrackbar.Height := 25;
      PCTrackbar.TickMarks := tmBoth;
      PCTrackbar.OnChange := PropertyTrackBarChange;
      PCTrackbar.Anchors := [akLeft, akTop, akRight];

      PCCheckbox := TCheckBox.Create(Panel_Top);
      PCCheckbox.Parent := Panel_Top;
      PCCheckbox.Left := PCTrackbar.Left + PCTrackbar.Width + 8;
      PCCheckbox.Top := PCLabel.Top - 3;
      PCCheckbox.Tag := integer(VP);
      PCCheckbox.Enabled := false;
      PCCheckbox.Caption := '';
      PCCheckbox.Width := PCCheckbox.Height + 4;
      PCCheckbox.OnClick := PropertyCheckBoxClick;
      PCCheckbox.Anchors := [akTop, akRight];
    END;
end;


procedure TFrame1.CleanPaintBoxVideo;
begin
  PaintBox_Video.Canvas.Brush.Color := Color;
  PaintBox_Video.Canvas.rectangle(-1, -1, PaintBox_Video.Width + 1, PaintBox_Video.Height + 1);
end;


PROCEDURE TFrame1.Stop;
BEGIN
  IF SpeedButton_Stop.Enabled then
    SpeedButton_StopClick(nil);
END;


PROCEDURE TFrame1.Close;
BEGIN
  IF assigned(VideoImage) then begin
    VideoImage.Free;
    VideoImage := nil;
    Initialized := false;
  end;
END;

procedure TFrame1.Updatelistofcameras1Click(Sender: TObject);
begin
  UpdateCamList;
end;

procedure TFrame1.ComboBox1Change(Sender: TObject);
begin
  VideoImage.SetResolutionByIndex(ComboBox1.ItemIndex);
  Label_VideoSize.Caption := 'Video size ' + IntToStr(VideoImage.VideoWidth) + ' x ' + IntToStr(VideoImage.VideoHeight);
end;

procedure TFrame1.FindTarget(BMP: TBitmap);
  var X,Y : integer;
      Xavg,Yavg : int64;
      Count : integer;
      C : TColor;
      Rsum,Gsum,Bsum : int64;
      radius : integer;
      R,G,B : integer;

      P : PAnsiChar;

      i : integer;
      distance : double;
      Player : TPoint;
      Hit,Kick,speed,player2 : TVector;
begin
//  exit; // zatím
  Xavg := 0;
  Yavg := 0;
  Count := 0;

  Assert(BMP.PixelFormat = pf24bit);

  for Y := 0 to BMP.Height - 1 do begin
    P := PAnsiChar(BMP.ScanLine[Y]);
    for X := 0 to BMP.Width-1 do begin
      B := ord(P^);inc(P);
      G := ord(P^);inc(P);
      R := ord(P^);inc(P);
      if (R > 2*G) and (R > 2*B)
      then begin
//        BMP.Canvas.Pixels[X,Y] := clRed;
        Xavg := Xavg + X;
        Yavg := Yavg + Y;
        inc(Count);

//        Rsum := Rsum + R;
//        Gsum := Gsum + G;
//        Bsum := Bsum + B;
      end;
    end;
  end;
  if Count > 100 then begin
    X := Xavg div Count;
    Y := Yavg div Count;

//    C := ((Rsum div Count) and $FF)+
//         (((Gsum div Count) and $FF) shl 8)+
//         (((Bsum div Count) and $FF) shl 16);
//    pnlColor.Color := C; // prùmìrná detekovaná barva
//    pnlColor.Caption := IntToHex(C,6);


    Radius := Round(sqrt(Count / PI));
    BMP.Canvas.Brush.Color := clRed;
    BMP.Canvas.Ellipse(X-Radius,Y-Radius,X+Radius,Y+Radius);

    BMP.Canvas.Pen.Color := clBlack;
    BMP.Canvas.MoveTo(X-10,Y);
    BMP.Canvas.LineTo(X+10,Y);
    BMP.Canvas.MoveTo(X,Y+10);
    BMP.Canvas.LineTo(X,Y-10);
  end;
  BMP.Canvas.Brush.Color := clWhite;
  for i := 0 to High(Balls) - 1 do begin
  // pohyb
    Balls[i].X := Balls[i].X + BallsSpeed[i].X;
    Balls[i].Y := Balls[i].Y + BallsSpeed[i].Y; // zrychlení
    BallsSpeed[i].Y := BallsSpeed[i].Y + 1;
  // odrazy od stìn
    if (BallsSpeed[i].X < 0) and (Balls[i].X < 0) then BallsSpeed[i].X := round(-0.9*BallsSpeed[i].X);
    if (BallsSpeed[i].X > 0) and (Balls[i].X >= BMP.Width) then BallsSpeed[i].X := round(-0.9*BallsSpeed[i].X);
    if (BallsSpeed[i].Y < 0) and (Balls[i].Y < 0) then BallsSpeed[i].Y := round(-0.9*BallsSpeed[i].Y);
    if (BallsSpeed[i].Y > 0) and (Balls[i].Y >= BMP.Height) then BallsSpeed[i].Y := round(-0.9*BallsSpeed[i].Y);

    if count > 100 then begin
      Player.X := X;
      Player.Y := Y;
      Hit.Diff(Player,Balls[i]);
      distance := Hit.Length;
      distance := distance / radius;
      if distance < 1 then begin // zásah
        // bude tam kopnutí ve smìru ven o síle odpovídající hloubce prùniku
        Speed.X := BallsSpeed[i].X;
        Speed.Y := BallsSpeed[i].Y;
        Kick.X := Balls[i].X - X;
        Kick.Y := Balls[i].Y - Y;
        Kick.Normalize;
        Kick.Mul(Speed.Length+Distance*10);
        Speed.Add(Kick);
        BallsSpeed[i] := Speed.Point;
      // nové místo zásahu
        Hit.Normalize;
        Hit.Mul(radius);
        player2.Init(player);
        Hit.Add(player2);
        Balls[i] := Hit.Point;
      end;
    end;
    BMP.Canvas.Ellipse(Balls[i].X-10,Balls[i].Y-10,Balls[i].X-20,Balls[i].Y-20);
  end;
end;


procedure TFrame1.SpeedButton_RunVideoClick(Sender: TObject);
{ - Start live video }
var
  i: integer;
  SL: TStringList;
  VP: TVideoProperty;
  MinVal, MaxVal, StepSize, Default, Actual: integer;
  AutoMode: boolean;
begin
  // Video already initialized, but paused?
  IF assigned(VideoImage) then
    IF VideoImage.IsPaused then begin
      VideoImage.VideoResume;
      SpeedButton_VidSettings.Enabled := true;
      SpeedButton_VidSize.Enabled := true;
      SpeedButton_Stop.Enabled := true;
      SpeedButton_Pause.Enabled := true;
      SpeedButton_RunVideo.Enabled := false;
      exit;
    end;

  // Initialize Video
  Screen.Cursor := crHourGlass;
  CleanPaintBoxVideo;
  Application.ProcessMessages;
  // Starting video using name of device
  // i := VideoImage.VideoStart(ComboBox_Cams.Items[ComboBox_Cams.itemIndex]);
  // Starting video using index number of device within list of devices.
  // This helps in case two cameras have the same name.
  i := VideoImage.VideoStart('#' + IntToStr(ComboBox_Cams.ItemIndex + 1));
  Screen.Cursor := crDefault;
  Application.ProcessMessages;

  IF i <> 0 then begin
    MessageDlg('Could not start video (Error ' + IntToStr(i) + ')', mtError, [mbOK], 0);
    exit;
  end;
  Label_VideoSize.Caption := 'Video size ' + IntToStr(VideoImage.VideoWidth) + ' x ' + IntToStr(VideoImage.VideoHeight);
  fFrameCnt := 0;

  SpeedButton_VidSettings.Enabled := true;
  SpeedButton_VidSize.Enabled := true;
  SpeedButton_Stop.Enabled := true;
  SpeedButton_Pause.Enabled := true;
  SpeedButton_RunVideo.Enabled := false;
  ComboBox_Cams.Enabled := false;

  SL := TStringList.Create;
  VideoImage.GetListOfSupportedVideoSizes(SL);
  ComboBox1.Items.Assign(SL);
  SL.Free;

  FOR VP := Low(TVideoProperty) TO High(TVideoProperty) DO BEGIN
    IF Succeeded(VideoImage.GetVideoPropertySettings(VP, MinVal, MaxVal, StepSize, Default, Actual, AutoMode)) then begin
      WITH PropCtrl[VP] DO BEGIN
        PCLabel.Enabled := true;
        PCTrackbar.Enabled := true;
        PCTrackbar.min := MinVal;
        PCTrackbar.Max := MaxVal;
        PCTrackbar.Frequency := StepSize;
        PCTrackbar.Position := Actual;
        PCCheckbox.Enabled := true;
        PCCheckbox.Checked := AutoMode;
      end;
    end
    else begin
      WITH PropCtrl[VP] DO BEGIN
        PCLabel.Enabled := false;
      end;
    end;
  END;
end;

procedure TFrame1.SpeedButton_PauseClick(Sender: TObject);
begin
  IF assigned(VideoImage) then
    VideoImage.VideoPause;
  SpeedButton_VidSettings.Enabled := false;
  SpeedButton_VidSize.Enabled := false;
  SpeedButton_Stop.Enabled := true;
  SpeedButton_Pause.Enabled := false;
  SpeedButton_RunVideo.Enabled := true;
end;

procedure TFrame1.SpeedButton_StopClick(Sender: TObject);
begin
  SpeedButton_VidSettings.Enabled := false;
  SpeedButton_VidSize.Enabled := false;
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  VideoImage.VideoStop;
  Screen.Cursor := crDefault;
  SpeedButton_Stop.Enabled := false;
  SpeedButton_RunVideo.Enabled := true;
  SpeedButton_Pause.Enabled := false;
  ComboBox_Cams.Enabled := true;
  UpdateCamList;
end;

procedure TFrame1.SpeedButton_VidSettingsClick(Sender: TObject);
begin
  VideoImage.ShowProperty;
  CleanPaintBoxVideo;
end;

procedure TFrame1.SpeedButton_VidSizeClick(Sender: TObject);
begin
  IF assigned(VideoImage) then begin
    CleanPaintBoxVideo;
    VideoImage.ShowProperty_Stream;
    Label_VideoSize.Caption := 'Video size ' + IntToStr(VideoImage.VideoWidth) + ' x ' + IntToStr(VideoImage.VideoHeight);
  end;
end;


procedure TFrame1.PropertyTrackBarChange(Sender: TObject);
VAR
  VP: TVideoProperty;
begin
  WITH Sender as TTrackBar DO BEGIN
    VP := TVideoProperty(Tag);
    VideoImage.SetVideoPropertySettings(VP, PropCtrl[VP].PCTrackbar.Position, PropCtrl[VP].PCCheckbox.Checked);
  end;
end;


procedure TFrame1.PaintBox_VideoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  pnlColor.color := TPaintBox(Sender).Canvas.Pixels[X,Y];
  pnlColor.Caption := IntToHex(pnlColor.Color,6);
end;

procedure TFrame1.PropertyCheckBoxClick(Sender: TObject);
VAR
  VP: TVideoProperty;
begin
  WITH Sender as TCheckBox DO BEGIN
    VP := TVideoProperty(Tag);
    VideoImage.SetVideoPropertySettings(VP, PropCtrl[VP].PCTrackbar.Position, PropCtrl[VP].PCCheckbox.Checked);
  end;
end;

procedure TFrame1.SpeedButton1Click(Sender: TObject);
begin
  IF Panel_Top.Height = 104 then
    Panel_Top.Height := 377
  else
    Panel_Top.Height := 104;
end;

{ TVector }

procedure TVector.Add(const A: TVector);
begin
  X := X + A.X;
  Y := Y + A.Y;
end;

procedure TVector.Diff(A, B: TPoint);
begin
  X := B.X - A.X;
  Y := B.Y - A.Y;
end;

procedure TVector.Init(A: TPoint);
begin
  X := A.X;
  Y := A.Y;
end;

function TVector.Length: double;
begin
  Result := sqrt(sqr(X)+sqr(Y));
end;

procedure TVector.Mul(C: double);
begin
  X := X * C;
  Y := Y * C;
end;

procedure TVector.Normalize;
  var L : double;
begin
  L := Length;
  if L > 0 then begin
    L := 1/L;
    X := X * L;
    Y := Y * L;
  end;
end;

function TVector.Point: TPoint;
begin
  Result.X := Round(X);
  Result.Y := Round(Y);
end;

function TVector.QLength: double;
begin
  Result := sqr(X)+sqr(Y);
end;

end.
