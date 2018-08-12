unit Ugame;

interface

uses Windows,Graphics,SysUtils,
     UVector;

type
TGame = class
    Balls : array [0..5] of TVector;
    BallsSpeed : array [0..5] of TVector;
    constructor Create;
    destructor  Destroy;override;

    procedure StartBalls(const BMP: TBitmap);
    procedure FindTarget(BMP: TBitmap);
    procedure InitSounds;
  end;

implementation

{ TGame }

constructor TGame.Create;
begin

end;

destructor TGame.Destroy;
begin

  inherited;
end;

procedure TGame.FindTarget(BMP: TBitmap);
  var X,Y : integer;
      Xsum,Ysum : int64;
      Count : integer;
//      C : TColor;
//      Rsum,Gsum,Bsum : int64;
      radius : integer;
      R,G,B : integer;

      P : PAnsiChar;

      i : integer;
      distance : double;
      Player : TVector;
      Hit,Kick,speed : TVector;
begin
//  exit; // zatím
  Xsum := 0;
  Ysum := 0;
  Count := 0;

  Assert(BMP.PixelFormat = pf24bit);

  for Y := 0 to BMP.Height - 1 do begin
    P := PAnsiChar(BMP.ScanLine[Y]);
    for X := 0 to BMP.Width-1 do begin
      B := ord(P^);inc(P);
      G := ord(P^);inc(P);
      R := ord(P^);inc(P);
      if (R > 2*G) and (R > 2*B) then begin
//        BMP.Canvas.Pixels[X,Y] := clRed;
        Xsum := Xsum + X;
        Ysum := Ysum + Y;
        inc(Count);
        (P-3)^ := #0;
        (P-2)^ := #0;
        (P-1)^ := #255;
//        Rsum := Rsum + R;
//        Gsum := Gsum + G;
//        Bsum := Bsum + B;
      end;
    end;
  end;
  if Count > 100 then begin
    Player.X := Xsum / Count;
    Player.Y := Ysum / Count;
    X := Round(Player.X);
    Y := Round(Player.Y);

//    C := ((Rsum div Count) and $FF)+
//         (((Gsum div Count) and $FF) shl 8)+
//         (((Bsum div Count) and $FF) shl 16);
//    pnlColor.Color := C; // prùmìrná detekovaná barva
//    pnlColor.Caption := IntToHex(C,6);


    Radius := Round(sqrt(Count / PI));
    BMP.Canvas.Brush.Color := clRed;
    BMP.Canvas.Brush.Style := bsClear;
//    BMP.Canvas.Brush.Style := bsSolid;
    BMP.Canvas.Ellipse(X-Radius,Y-Radius,X+Radius,Y+Radius);
    BMP.Canvas.Brush.Style := bsClear;
    BMP.Canvas.Rectangle(X-Radius,Y-Radius,X+Radius,Y+Radius);

    BMP.Canvas.Pen.Color := clBlack;
    BMP.Canvas.MoveTo(X-10,Y);
    BMP.Canvas.LineTo(X+10,Y);
    BMP.Canvas.MoveTo(X,Y+10);
    BMP.Canvas.LineTo(X,Y-10);
  end else begin
    Radius := 1;
    Player.X := 0;
    Player.Y := 0;
  end;
  for i := 0 to High(Balls) do begin
    BMP.Canvas.Brush.Color := clWhite;
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
      Hit.Diff(Player,Balls[i]);
      distance := Hit.Length;
      distance := distance / radius;
      if distance < 1 then begin // zásah
        BMP.Canvas.Brush.Color := clBlack;
        // bude tam kopnutí ve smìru ven o síle odpovídající hloubce prùniku
        Speed.Init(BallsSpeed[i]);
        Kick.Diff(Player,Balls[i]);
        Kick.Normalize;
        Kick.Mul(Speed.Length+Distance*10);
        Speed.Add(Kick);
        BallsSpeed[i] := Speed;
      // nové místo zásahu
        Hit.Normalize;
        Hit.Mul(radius);
        Hit.Add(Player);
        Balls[i] := Hit;

      end;
      BMP.Canvas.Font.Color := clGreen;
      BMP.Canvas.TextOut(Round(Balls[i].X)+15,Round(Balls[i].Y),Format('d=%0.3f',[distance]));
    end;
    BMP.Canvas.Ellipse(Round(Balls[i].X)-10,Round(Balls[i].Y)-10,Round(Balls[i].X)-20,Round(Balls[i].Y)-20);
  end;
end;


procedure TGame.InitSounds;
begin

end;

procedure TGame.StartBalls(const BMP: TBitmap);
  var Angle : double;
      Center : TPoint;
      Speed,SpeedTarget : double;
      i : integer;
begin
  if BMP = nil then exit;
  Center.X := BMP.Width shr 1;
  Center.Y := BMP.Height shr 1;

  for i := 0 to High(Balls) do begin
    Angle := Random(180-90)/PI;
    Balls[i].X := Round(sin(Angle)*BMP.Width+Center.X);
    Balls[i].Y := Round(cos(Angle)*BMP.Height+Center.Y);
    BallsSpeed[i].X := (Center.X-Balls[i].X);
    BallsSpeed[i].Y := (Center.Y-Balls[i].Y)+10; // nahoru trochu
    Speed := sqrt(BallsSpeed[i].X*BallsSpeed[i].X+BallsSpeed[i].Y*BallsSpeed[i].Y);
    SpeedTarget := Random(10)+10;
    BallsSpeed[i].X := Round(BallsSpeed[i].X*SpeedTarget/Speed);
    BallsSpeed[i].Y := Round(BallsSpeed[i].Y*SpeedTarget/Speed);
  end;

end;

end.
