unit GraphCrt;
interface

Const Liniistas=50;Colstas=128;
type PTextScr=^TTextScr;
     TTextScr=array[1..Liniistas,1..Colstas] of
                  record
                   Chr:Char;
                   BG,FG:byte;
                   X,Y:Integer;
                  end;

type PCrt=^TCrt;
     TCrt=object
           TxtScr:PTextScr;
           XCrt,YCrt:Integer;
           BkCol,FGCol:byte;
           ChrX,ChrY:word;
           XCur,YCur:word;
           ChrLu,ChrLa:byte;
           WX1,WY1,WX2,WY2:word;
           Constructor Init(x,y:integer;ChX,ChY:word;bkc,fgc:byte);
           Procedure   Write(s:string);
           Procedure   WriteLn(s:string);
           Procedure   ClrScr;
           Procedure   GoToXY(x,y:word);
           Procedure   TextBackground(Color: Byte);
           Procedure   TextColor(Color: Byte);
           Function    WhereX:word;
           Function    WhereY:word;
           Procedure   Window(x1,y1,x2,y2:integer);
           Function    IntToStr(I: Longint): String;
           Destructor  Done;
           private
           lung,lat:word;
           Procedure   PutChar(l,c:word);
           Procedure   ScrollUp;
          end;

implementation
uses crt,fonts,vesadrv,graph;

function TCrt.IntToStr(I: Longint): String;
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;


Procedure TCrt.PutChar;
begin
  SetFillStyle(SolidFill,TxtScr^[l,c].BG);SetColor(TxtScr^[l,c].FG);
  Bar(TxtScr^[l,c].X,TxtScr^[l,c].Y,TxtScr^[l,c].X+ChrLu-1,TxtScr^[l,c].Y+ChrLa-1);
  OutTextXY(TxtScr^[l,c].X,TxtScr^[l,c].Y,TxtScr^[l,c].Chr);
end;


Procedure TCrt.ScrollUp;
var l,c:word;
begin
 for l:=wy1+1 to wy2 do
   for c:=wx1 to wx2 do
     begin
      TxtScr^[l-1,c].Chr:=TxtScr^[l,c].Chr;
      TxtScr^[l-1,c].BG :=TxtScr^[l,c].BG;
      TxtScr^[l-1,c].FG :=TxtScr^[l,c].FG;
      PutChar(l-1,c);
     end;
 for c:=wx1 to wx2 do
     begin
      TxtScr^[wy2,c].Chr:=' ';
      TxtScr^[wy2,c].BG:=BkCol;
      TxtScr^[wy2,c].FG:=FgCol;
      PutChar(wy2,c);
     end;
end;

Constructor TCrt.Init;
var l,c:integer;
begin
 ChrLu:=8;ChrLa:=16;               { Lungimea si Latimea unui caracter}
 XCrt:=x;YCrt:=y;                  { Pozitia ferestrei CRT in pixeli  }
 ChrX:=ChX;ChrY:=ChY;              { Numarul de coloane si de linii   }
 WX1:=1;WY1:=1;
 WX2:=ChrX;WY2:=ChrY;              { Coordonatele CRT.Window          }
 XCur:=WX1;YCur:=WY1;              { Pozitia curenta a cursorului     }
 BkCol:=bkc;FGCol:=fgc;            { Culoarea de fond si de caractere }
 Lung:=ChrX*ChrLu;Lat:=ChrY*ChrLa; { Lungimea ferestrei CRT in pixeli }
 SetFillStyle(SolidFill,BkCol);
 Bar(XCrt,YCrt,XCrt+Lung,YCrt+Lat);
 New(TxtScr);
 for l:=1 to chry do for c:=1 to chrx do
  begin
   TxtScr^[l,c].chr:=' ';
   TxtScr^[l,c].BG:=BkCol;
   TxtScr^[l,c].FG:=FgCol;
   TxtScr^[l,c].X:=XCrt+Pred(C)*ChrLu;
   TxtScr^[l,c].Y:=YCrt+Pred(L)*ChrLa;
  end;
end;


Procedure TCrt.Write(s:string);
var f:integer;
begin
 MSetTextStyle(5,0,5);SetTextJustify(LeftText,TopText);
 for f:=1 to length(s) do
  begin
   case S[F] of
   #07:begin sound(500);delay(100);nosound;end;
   #08:Dec(XCur);
   #10:begin
       Inc(YCur);
       if YCur>WY2 then begin dec(YCur);ScrollUp;end;
      end;
   #13:XCur:=WX1;
   else
    begin
     TxtScr^[YCur,XCur].Chr:=S[F];
     TxtScr^[YCur,XCur].BG :=BkCol;
     TxtScr^[YCur,XCur].FG :=FgCol;
     PutChar(YCur,XCur);
     Inc(XCur);
     If XCur>WX2 then
      begin
       XCur:=WX1;
       Inc(YCur);
       if YCur>WY2 then begin dec(YCur);ScrollUp;end;
      end;
    end;
    end;
 end;
end;

Procedure TCrt.WriteLn(s:string);
begin
 Write(s);
 XCur:=WX1;
 Inc(YCur);
 if YCur>WY2 then begin dec(YCur);ScrollUp;end;
end;

Procedure TCrt.ClrScr;
var l,c:word;
begin
 for l:=WY1 to WY2 do for c:=WX1 to WX2 do
  begin
    TxtScr^[l,c].chr:=' ';
    TxtScr^[l,c].BG:=BkCol;
    TxtScr^[l,c].FG:=FgCol;
  end;
 XCur:=WX1;YCur:=WY1;              { Pozitia curenta a cursorului     }
 SetFillStyle(SolidFill,BkCol);
 Bar(TxtScr^[WY1,WX1].X,TxtScr^[WY1,WX1].Y,
     TxtScr^[WY2,WX2].X+ChrLu,TxtScr^[WY2,WX2].Y+ChrLa);
end;

Procedure TCrt.GotoXY;
begin
 If (WX1+X-1>WX2)or(WY1+Y-1>WY2) then Exit;
 XCur:=WX1+X-1;
 YCur:=WY1+Y-1;
end;

Function TCrt.WhereX;
begin
 WhereX:=Succ(XCur-WX1);
end;

Function TCrt.WhereY;
begin
 WhereY:=Succ(YCur-WY1);
end;

Procedure TCrt.TextBackground(Color: Byte);
begin
 BKCol:=Color;
end;

Procedure TCrt.TextColor(Color: Byte);
begin
 FGCol:=Color;
end;

Procedure TCrt.Window(x1,y1,x2,y2:integer);
begin
 WX1:=X1;WY1:=Y1;WX2:=X2;WY2:=Y2;
end;

Destructor TCrt.Done;
begin
 Dispose(TxtScr);
end;


end.
