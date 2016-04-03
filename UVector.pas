unit UVector;

interface

uses Windows;

type
TVector = object
  X,Y : double;
  procedure Init(A : TPoint);overload;
  procedure Init(A : TVector);overload;
  function Length : double;
  function QLength : double;
  procedure Normalize;
  function Point : TPoint;
  procedure Diff(A,B : TPoint);overload;
  procedure Diff(A,B : TVector);overload;
  procedure Mul(C : double);
  procedure Add(const A : TVector);
end;



implementation
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

procedure TVector.Diff(A, B: TVector);
begin
  X := B.X - A.X;
  Y := B.Y - A.Y;
end;

procedure TVector.Init(A: TVector);
begin
  X := A.X;
  Y := A.Y;
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
