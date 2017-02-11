unit MicroEdt;
interface

uses UKbd,Obj,Events,Mouse,Graph,Fonts,Kerets,VesaDrv;
type PLine     =^TLine;
     TLine     =object
                  inpx,inpy,inplung,inplat,inpnrcar:integer;
                  inpmesage:string;inpwin:pwindow;
                  bkgray:boolean;px,b,l,i,px2:integer;
                  Constructor Init(w:pwindow;x,y,nrcar:integer);
                  procedure   SetText(mesage:string);virtual;
                  procedure   Show;virtual;
                  function    Edit(ev:tevent):word;virtual;
                  function    Clicked(ev:TEvent):boolean;virtual;
                  Procedure   ShowCursor;
                  Destructor  Done;virtual;
                  private
                  move:boolean;
                  ins:byte;
                  procedure   Draw;virtual;
                end;

type PEditor   =^TEditor;
     TEditor   =object
                 ChrX,ChrY:Word;EdtWin:pwindow;
                 CurX,CurY:Word;
                 EdtX,EdtY:Integer;
                 Linii:array[1..50] of PLine;
                 Constructor Init(w:pwindow;x,y:integer;ChX,ChY:word);
                 Procedure   Show;
                 Procedure   Run(ev:tevent);
                 Destructor  Done;
                end;

type PMicroEditor=^TMicroEditor;
     TMicroEditor=object
                   fer1:pwindow;filename:string;ChrX,ChrY:Word;
                   mx,my:word;mlung,mlat:integer;mev:tevent;
                   edt1:peditor;
                   Constructor Init(w:pwindow;X,Y,ChX,ChY:word;fis:string);
                   Procedure   Run;
                   Destructor  Done;
                   private
                   but1:pbutton;
                  end;

implementation

Constructor TMicroEditor.Init;
begin
 fer1:=w;
 ChrX:=ChX;ChrY:=ChY;
 filename:=fis;
 Mx:=X;My:=y;
 mlung:=ChrX*8+6+14;mlat:=22*chry+40+60;
 new(fer1,initxms(X,Y,mlung,mlat,'Editor',3,true));fer1^.show;
 new(edt1,init(fer1,7,25,chx,chy));edt1^.show;
 new(but1,init(fer1,mlung div 2-40,mlat-50,80,32,'O.K.'));but1^.show;
 hidemouse;setcolor(black);
 rectangle(x+6,y+24,x+ChrX*8+14,y+mlat-100+25);
 showmouse;
end;

Procedure TMicroEditor.Run;
begin
 repeat
   fer1^.move;
   GetEvent(mev);
   Edt1^.Run(mev);
 until Fer1^.clicked(mev) or but1^.clicked(mev);
end;

Destructor TMicroEditor.Done;
var f:integer;fis:text;
begin
 assign(fis,filename);rewrite(fis);
 for f:=1 to ChrY do WriteLn(Fis,Edt1^.Linii[f]^.InpMesage);
 close(fis);
 dispose(edt1,done);
 dispose(but1,done);
 dispose(fer1,done);
end;


Constructor TEditor.Init;
var f:integer;
begin
 Edtwin:=w;
 EdtX:=x;EdtY:=y;
 ChrX:=ChX;ChrY:=ChY;
 CurX:=0;CurY:=1;
 for f:=1 to ChY do New(Linii[f],Init(W,X,Y+(f-1)*22,ChX));
end;

Procedure TEditor.Show;
var f:Integer;
begin
 for f:=1 to ChrY do Linii[f]^.Show;
end;

Procedure TEditor.Run;
var EdLnRet:word;
    pxprev:integer;
Procedure DaLiniileJos(lin:integer);
var f:integer;
begin
 if Length(Linii[ChrY]^.InpMesage)<>0 then exit;
 for f:=Chry downto lin+2 do
   begin
     Linii[f]^.InpMesage:=Linii[f-1]^.InpMesage;
     Linii[f]^.Px:=Linii[f-1]^.Px;
     Linii[f]^.B:=Linii[f-1]^.B;
     Linii[f]^.L:=Linii[f-1]^.L;
     Linii[f]^.I:=Linii[f-1]^.I;
     Linii[f]^.Px2:=Linii[f-1]^.Px2;
   end;
     Linii[lin+1]^.px:=Length(Linii[lin]^.InpMesage)-Linii[lin]^.Px+1;
     Linii[lin+1]^.i:=Linii[lin+1]^.px;
     Linii[lin+1]^.b:=Linii[lin+1]^.i-Linii[lin+1]^.l+1;
     if Linii[lin+1]^.l>Linii[lin+1]^.i then Linii[lin+1]^.b:=1;
     Linii[lin+1]^.InpMesage:=Copy(Linii[lin]^.InpMesage,Linii[lin]^.Px+1,Length(Linii[lin]^.InpMesage)-Linii[lin]^.Px);

     Delete(Linii[lin]^.InpMesage,Linii[lin]^.Px+1,Length(Linii[lin]^.InpMesage)-Linii[lin]^.Px);
     Linii[lin]^.px:=Length(Linii[lin]^.InpMesage);
     Linii[lin]^.i:=Linii[lin]^.px;
     Linii[lin]^.b:=Linii[lin]^.i-Linii[lin]^.l+1;
     if Linii[lin]^.l>Linii[lin+1]^.i then Linii[lin]^.b:=1;
 for f:=Lin to ChrY do Linii[f]^.Show;
end;

begin
 If ev.tip=evkbd then EdLnRet:=Linii[CurY]^.Edit(Ev);
 case EdLnRet of
  KbEnter:begin
          if CurY<ChrY then
           begin
            DaLiniileJos(CurY);
           end;
         end;
  KbDown:begin
          if CurY<ChrY then
           begin
             Pxprev:=Linii[CurY]^.px;
             Linii[CurY]^.Show;
             Inc(CurY);
             if PxPrev<Length(Linii[CurY]^.InpMesage)
              then Linii[CurY]^.Px:=PxPrev
              else Linii[CurY]^.Px:=Length(Linii[CurY]^.InpMesage);
             Linii[CurY]^.ShowCursor;
           end;
         end;
  KbUp  :begin
          if CurY>1 then
           begin
             Pxprev:=Linii[CurY]^.px;
             Linii[CurY]^.Show;
             Dec(CurY);
             if PxPrev<Length(Linii[CurY]^.InpMesage)
              then Linii[CurY]^.Px:=PxPrev
              else Linii[CurY]^.Px:=Length(Linii[CurY]^.InpMesage);
             Linii[CurY]^.ShowCursor;
           end;
         end;
 end;
end;

Destructor TEditor.Done;
var f:Integer;
begin
 for f:=1 to ChrY do Dispose(Linii[f],Done);
end;

Constructor TLine.Init;
begin
 inpx:=x;inpy:=y;
 inpnrcar:=nrcar;
 inplung:=nrcar*8+6;
 inplat:=22;
 inpmesage:='';
 inpwin:=w;

 move:=true;
 ins:=1;
 i:=length(inpmesage);
 l:=(inplung-3) div textwidth('A');
 b:=i-l+1;
 if l>i then b:=1;
 px:=i;

end;

procedure TLine.settext;
begin
 inpmesage:=mesage;
 inpmesage:=copy(mesage,1,inpnrcar);
end;


procedure TLine.Draw;
var x1,y1:integer;
begin
x1:=inpwin^.winx+inpx;
y1:=inpwin^.winy+inpy;
setfillstyle(solidfill,white);
bar(x1,y1,x1+inplung,y1+21);
bkgray:=false;
end;

procedure TLine.show;
var ii:byte;
    x1,y1:integer;
begin
   x1:=inpwin^.winx+inpx;
   y1:=inpwin^.winy+inpy;

  hidemouse;
  Draw;
  settextstyle(0,horizdir,1);
  setcolor(black);
  if inpmesage<>''then
    begin
    ii:=0;
    repeat
    inc(ii);
    until ((textwidth(copy(inpmesage,1,ii))+3)>inplung)or(ii>length(inpmesage));
    settextjustify(LeftText,CenterText);
    outtextxy(x1+3,(2*y1+20)div 2,copy(inpmesage,1,ii-1));
    end;
 ShowMouse;
end;

function TLine.Clicked;
begin
 Clicked:=false;
 if (ev.tip=evmouse)and(ev.but=1) then
     if (ev.mx>inpwin^.winx+inpx)and(ev.mx<inpwin^.winx+inpx+inplung)and
        (ev.my>inpwin^.winy+inpy)and(ev.my<inpwin^.winy+inpy+inplat)
 then Clicked:=true;
end;

Procedure TLine.ShowCursor;
var x1,y1:integer;
begin
  x1:=inpwin^.winx+inpx;
  y1:=inpwin^.winy+inpy;
  hidemouse;
  move:=true;
  draw;
  settextjustify(LeftText,CenterText);settextstyle(0,0,1);
  setcolor(black);
  outtextxy(x1+3,(2*y1+20)div 2,copy(inpmesage,b,i-b+1));
  setwritemode(XORPut);setcolor(lightgray);
  setlinestyle(0,0,1+2*ins);
  line(x1+(px-b+1)*8+2,y1+3,x1+(px-b+1)*8+2,y1+16);
  setlinestyle(0,0,1);
  setwritemode(NormalPut);
  px2:=px;
  showmouse;
  move:=false;
  if i>b+l-1 then i:=b+l-1;
end;

function TLine.Edit;
var Ch:Word;
    x1,y1:integer;
Procedure Print;
  begin
  x1:=inpwin^.winx+inpx;
  y1:=inpwin^.winy+inpy;
  hidemouse;
  if move then draw;
  settextjustify(LeftText,CenterText);
  settextstyle(0,0,1);
  setcolor(black);
  if move then outtextxy(x1+3,(2*y1+20)div 2,copy(inpmesage,b,i-b+1));
  setwritemode(XORPut);
  setcolor(lightgray);
  setlinestyle(0,0,1+2*ins);
  if not move then line(x1+(px2-b+1)*8+2,y1+3,x1+(px2-b+1)*8+2,y1+16);
  line(x1+(px-b+1)*8+2,y1+3,x1+(px-b+1)*8+2,y1+16);
  setlinestyle(0,0,1);
  setwritemode(NormalPut);
  px2:=px;
  showmouse;
  move:=false;
  if i>b+l-1 then
     i:=b+l-1;
  end;

begin
            If Ev.Tip=EvKbd then begin
            Ch:=Ev.ScanKey;
            Case ch of
               kbright:{ -> }
                 begin
                   if (px<l)and(px<length(inpmesage)) then inc(px);
                   move:=true;
                 end;
               kbleft:{ <- }
                 begin
                   if px>0 then dec(px);
                   move:=true;
                 end;
               kbend:{End}
                 begin
                   px:=length(inpmesage);
                   i:=px;
                   if length(inpmesage)>l then b:=i-l+1 else b:=1;
                   move:=true;
                 end;
               kbhome:{Home}
                 begin
                   b:=1;
                   px:=0;
                   i:=l;
                   if length(inpmesage)<l then i:=length(inpmesage);
                   move:=true;
                 end;
               kbins:{Insert}
                 begin
                   hidemouse;
                   setwritemode(xorput);
                   setlinestyle(0,0,1+2*ins);
                   line(x1+(px-b+1)*8+2,y1+3,x1+(px-b+1)*8+2,y1+16);
                   ins:=1-ins;
                   setlinestyle(0,0,1+2*ins);
                   line(x1+(px-b+1)*8+2,y1+3,x1+(px-b+1)*8+2,y1+16);
                   setlinestyle(0,0,1);
                   setwritemode(normalput);
                   showmouse;
                 end;
               kbdel:{Delete}
                 if (px<i)and(px<length(inpmesage)) then
                 begin
                   delete(inpmesage,px+1,1);
                   if length(inpmesage)<l then dec(i);
                   move:=true;
                 end;
               kbback:{Backspace}
                 if px>=1 then
                 begin
                   delete(inpmesage,px,1);
                   dec(px);
                   if (px=b-1)and(px>0)then begin dec(b);dec(i)end;
                   move:=true;
                 end;
               else if (Scan2Char(ch) in [#32..#254])
                      then
                       if length(inpmesage)<inpnrcar then
                       begin
                       if ins=1
                       then begin
                             Insert(Scan2Char(ch),Inpmesage,Px+1);
                            end
                       else begin
                             if px+1>length(inpmesage)
                               then Insert(Scan2Char(ch),Inpmesage,Px+1)
                               else Inpmesage[px+1]:=Scan2Char(ch);
                            end;
                            if (i-b+1)<l then inc(i);
                            if px=i then begin inc(b);inc(i);end;
                            Inc(px);
                            Move:=true;
                       end;
                  end;
            print;
            end;
   Edit:=Ch;
end;


destructor TLine.Done;
begin
end;

end.
