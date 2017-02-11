{$A+,B-,D-,E-,F+,G+,I+,L-,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y-}
{$M 16384,0,655360}

unit ViewHTD;   { Hiper Text Document Viewer }

interface
uses crt,appmcga,basicgif,graph,vesadrv,
     fonts,bk,kerets,mouse,obj,events,ukbd;

const titles:array[1..3,1..6] of string=
    (('Sumar','Prima pag','<< Inapoi','Inainte >>','Iesire','Detaliat'),
    ('Sumar','Prima','<<','>>','Iesire','Detal.'),
    ('S','P','<<','>>','I','D'));

type header=
       record
         copyright:string[32];           { mesajul de copyright }
         pc:byte;                        { numarul de pagini }
         pags:array[1..150] of longint;  { offseturile de la care incep paginile in fisierul compilat }
         cpc:byte;                       { numarul de pagini de la cuprins }
         ic:byte;                        { numarul de imagini }
         imags:array[1..250] of longint; { offseturile de la care incep imaginile in fisierul compilat }
         doctheme:byte;                  { tema documentului. Ex. mec,electric,optica }
         doctitle:string;                { titlul documentului }
       end;

type TBorders = record
                  x1,y1,x2,y2:integer;
                  pagedef:byte;
                  pagelink:byte;
                end;

type PManual=^TManual;
     TManual=object
           ev:tevent;
           main:pwindow;
           b1,b2,b3,b4,b5:pbutton;
           fra:pframe;sysarrow:byte;
           crtpag:byte;constfilename:string;
           txtfont,txtsize,txtcol:word;
            incuprins:boolean;memocrtpag:byte;
            pozfis:longint;lc:word;
           Constructor Init(x,y,lung,lat,tip:integer;winname,filename:string;initpag,SArrow:byte;savebk:boolean);
           Procedure   Run;virtual;
           Destructor  Done;virtual;
          private
           hdr:header;
           fis:fileb;ct:word;
           FillInfo:FillSettingsType;linst:Linesettingstype;cul:word;
           textst:textsettingstype;OldPattern:FillPatternType;
           Borders:array[1..500] of TBorders;
           indtitles:integer;
           procedure MemoAtribute(a:boolean);
           procedure GetTextBorders(x,y:integer;s:string;var border:TBorders);
           procedure TestLinks(x,y:integer);
           procedure TestLinkCursor(evw:TEvent);
           procedure readpage(pag:byte);
           procedure Readheader;
           function  Apartine(x,y,x1,y1,x2,y2:integer):boolean;
          end;

implementation


Constructor TManual.Init;
var lb,hb,fray,frayl:integer;
begin
 if savebk
  then new(main,initxms(x,y,lung,lat,WinName,tip,true))
  else new(main,init(x,y,lung,lat,WinName,tip,false));

 lb:=(lung-6*10) div 5;
 hb:=lat*30 div 576;
 if tip<>0 then begin fray:=23;frayl:=lat-hb-44;end
           else begin fray:=03;frayl:=lat-hb-24;end;
 if lb in [01..50] then indtitles:=3 else
 if lb in [51..80] then indtitles:=2 else
 indtitles:=1;

 new(b4,init(main,10+0*lb,lat-hb-12,lb,hb,titles[indtitles,1]));
 new(b1,init(main,20+1*lb,lat-hb-12,lb,hb,titles[indtitles,2]));
 new(b2,init(main,30+2*lb,lat-hb-12,lb,hb,titles[indtitles,3]));
 new(b3,init(main,40+3*lb,lat-hb-12,lb,hb,titles[indtitles,4]));
 new(b5,init(main,50+4*lb,lat-hb-12,lb,hb,titles[indtitles,5]));
 new(fra,init(main,3,fray,lung-6,frayl,4,lightgray,'Desen'));

 if x+lung>getmaxx then x:=getmaxx-lung-1;
 if y+lat >getmaxy then y:=getmaxy-lat -1;
 if x<0 then x:=0;if y<0 then y:=0;

if tip=0 then
begin
 hidemouse;
 setfillstyle(solidfill,lightgray);
 bar(x,y,x+lung-1,y+lat-1);
 keret(x+3,y+lat-hb-20,x+lung-3,y+lat-3,0);
 keret(x+4,y+lat-hb-19,x+lung-4,y+lat-4,1);
 setlinestyle(0,0,3);
 setcolor(lightgray);rectangle(x+1,y+1,x+lung-2,y+lat-2);
 setlinestyle(0,0,0);
 setcolor(black);rectangle(x,y,x+lung-1,y+lat-1);
 fra^.show;
 showmouse;
end
else
begin
 main^.show;
 fra^.show;
 setcolor(lightgray);
 hidemouse;
 keret(x+3,y+lat-hb-20,x+lung-3,y+lat-3,0);
 keret(x+4,y+lat-hb-19,x+lung-4,y+lat-4,1);
 showmouse;
end;

 constfilename:=filename;
 pozfis:=0;
 lc:=0;
 sysarrow:=sarrow;

 txtfont:=DefaultFont;
 txtsize:=1;
 txtcol:=black;

 crtpag:=initpag;memocrtpag:=1;
 incuprins:=false;
end;


Function TManual.Apartine(x,y,x1,y1,x2,y2:integer):boolean;
begin
 if ((x1<x) and (x<x2) and (y1<y) and (y<y2))
    then Apartine:=True
    else Apartine:=False
end;


Procedure TManual.TestLinks;
var f:word;
begin
if lc=0 then exit;
for f:=1 to lc do
 if (crtpag=borders[f].pagedef) and Apartine(x,y,borders[f].x1,borders[f].y1,borders[f].x2,borders[f].y2)
 then
 begin
  crtpag:=borders[f].pagelink;
  if ((crtpag=1)or(crtpag=hdr.pc+1))
       then begin b1^.disable;b2^.disable;end
       else begin b1^.enable ;b2^.enable ;end;
  if ((crtpag=hdr.pc)or(crtpag=hdr.cpc-1)) then b3^.disable else b3^.enable;
  if crtpag>hdr.pc then incuprins:=true else incuprins:=false;
  if incuprins then b4^.retitle(titles[indtitles,6]) else b4^.retitle(titles[indtitles,1]);
  readpage(crtpag);
 end;
end;

Procedure TManual.TestLinkCursor;
var f:byte;
    x,y:integer;
begin
if lc=0 then exit;
x:=ev.mx-fra^.frawin^.winx-fra^.frax;
y:=ev.my-fra^.frawin^.winy-fra^.fray;
for f:=1 to lc do
  if ((crtpag=borders[f].pagedef) and Apartine(x,y,borders[f].x1,borders[f].y1,borders[f].x2,borders[f].y2))
   then begin SelectStdCursor(Hand);exit;end;
for f:=1 to lc do
  if ((crtpag<>borders[f].pagedef) or (not Apartine(x,y,borders[f].x1,borders[f].y1,borders[f].x2,borders[f].y2)))
   then begin SelectStdCursor(SysArrow);exit;end;
end;

Destructor TManual.Done;
begin
 if fileexist(constfilename) then close(fis);
 dispose(fra, done);
 dispose(b1,  done);
 dispose(b2,  done);
 dispose(b3,  done);
 dispose(b4,  done);
 dispose(b5,  done);
 dispose(main,done);
end;

Procedure TManual.GetTextBorders(x,y:integer;s:string;var border:TBorders);
var TextStyle: TextSettingsType;
begin
 GetTextSettings(TextStyle);
 Border.X1:=X-((TextStyle.Horiz)*TextWidth(S)) div 2;
 Border.X2:=X+TextWidth(S)-((TextStyle.Horiz)*TextWidth(S)) div 2;
 Border.Y1:=3+Y-((2-TextStyle.Vert)*TextHeight(S)) div 2;
 Border.Y2:=3+Y+TextHeight(S)-((2-TextStyle.Vert)*TextHeight(S)) div 2;
end;

Procedure TManual.MemoAtribute(a:boolean);
Begin
Case a of
 False : Begin
           GetFillSettings(FillInfo);
           GetLineSettings(Linst);
           Cul:=GetColor;
           GetTextSettings(Textst);
           GetFillPattern(OldPattern);
         End;
 True  : Begin
           SetFillPattern(OldPattern,FillInfo.Color);
           with FillInfo do SetFillStyle(Pattern, Color);
           with Linst do SetLineStyle(LineStyle, Pattern, Thickness);
           SetColor(Cul);
           with Textst do Begin SetTextJustify(Horiz, Vert);
                                SetTextStyle(Font, Direction, CharSize);
                          End;
         End;
End;End;

Procedure TManual.Readheader;
var ft:file;
begin
 assign(ft,constfilename);reset(ft,1);
 seek(ft,filesize(ft)-sizeof(header));
 blockread(ft,hdr,sizeof(header));
 close(ft);
end;

Procedure TManual.ReadPage(pag:byte);
var buf:array[1..255] of byte;
    cpl:word;a:byte;maxy:byte;
    pagx,pagy:word;
    t:word;incr:word;
    eop:boolean;

{procedure readline;
const f:word=1;
begin
 repeat
  read(fis,a);buf[f]:=a;inc(f);
  if a=255 then eop:=true;
 until a=13;
 cpl:=f-1;f:=1;
 read(fis,a);
end;}

procedure readline;
var f:word;
var iesire:boolean;
begin
 iesire:=false;f:=1;
 repeat
  read(fis,a);buf[f]:=a;inc(f);
  if a=255 then eop:=true;
  if a=13 then begin
                 read(fis,a);
                 if a=10 then iesire:=true
                         else begin buf[f]:=a;inc(f);end;
               end;
 until iesire;
 cpl:=f-1;
end;


procedure displayline;
var f:word;i,j:byte;
    sirt:array [1..255] of char;
    sirs:string;
    x1,y1:integer;
    w1,w2:word;
begin
 f:=1;
 while f<=cpl do
 begin
   if buf[f]=1 then
       begin
         txtcol:=word(buf[f+1]);
	 setcolor(txtcol);incr:=1;
       end
   else
   if buf[f]=2 then
       begin
         txtfont:=word(buf[f+1]);txtsize:=word(buf[f+2]);
	 msettextstyle(txtfont,0,txtsize);incr:=2;
       end
   else
   if buf[f]=3 then
       begin
         case buf[f+1]+256*buf[f+2] of
         0:loadgif(buf[f+3]+256*(buf[f+4]),buf[f+5]+256*(buf[f+6]),fis,hdr.imags[buf[f+7]]);
         1:loadtranspgif(buf[f+3]+256*(buf[f+4]),buf[f+5]+256*(buf[f+6]),fis,hdr.imags[buf[f+7]]);
         2:begin
            x1:=buf[f+3]+256*(buf[f+4]);y1:=buf[f+5]+256*(buf[f+6]);
            loadtranspgif(x1,y1,fis,hdr.imags[buf[f+7]]);
            ct:=getcolor;setcolor(0);setcolor(ct);
            rectangle(x1,y1,x1+ImageDescriptor.ImageWidth,y1+ImageDescriptor.ImageHeight);
           end;
         3:begin
            x1:=buf[f+3]+256*(buf[f+4]);y1:=buf[f+5]+256*(buf[f+6]);
            loadtranspgif(x1,y1,fis,hdr.imags[buf[f+7]]);
            keret(x1,y1,x1+ImageDescriptor.ImageWidth,y1+ImageDescriptor.ImageHeight,1);
            keret(x1+1,y1+1,x1+ImageDescriptor.ImageWidth-1,y1+ImageDescriptor.ImageHeight-1,0);
           end;
         end;
         incr:=7;
       end
   else
   if buf[f]=4 then
       begin
        j:=buf[f+1];
        for i:=1 to j do sirt[i]:=chr(buf[f+1+i]);
        settextjustify(centertext,toptext);
        outtextxy(fra^.fralung div 2,pagy,copy(sirt,1,j));
        maxy:=textheight(copy(sirt,1,j));
        incr:=buf[f+1]+1;
       end
   else
   if buf[f]=5 then
       begin
        inc(pagy,word(buf[f+1]));
        incr:=1;
       end
   else
   if buf[f]=6 then
       begin
        j:=buf[f+1];
        for i:=1 to j do sirt[i]:=chr(buf[f+1+i]);
        settextjustify(lefttext,toptext);
        outtextxy(pagx,pagy+(textheight('VMA') div 2),copy(sirt,1,j));
        inc(pagx,textwidth(copy(sirt,1,j))+2);
        incr:=buf[f+1]+1;
       end
   else
   if buf[f]=7 then
       begin
        j:=buf[f+1];
        for i:=1 to j do sirt[i]:=chr(buf[f+1+i]);
        settextjustify(lefttext,toptext);
        outtextxy(pagx,pagy,copy(sirt,1,j));
        w1:=textwidth(copy(sirt,1,j));
         line(pagx,pagy+1,pagx+w1,pagy+1);
         putpixel(pagx+w1-1,pagy+0,getcolor);
	 putpixel(pagx+w1-1,pagy+2,getcolor);
        inc(pagx,w1+2);
        incr:=buf[f+1]+1;
       end
   else
   if buf[f]=8 then
       begin
        j:=buf[f+1];
        for i:=1 to j do sirt[i]:=chr(buf[f+1+i]);
        settextjustify(lefttext,toptext);
        outtextxy(pagx,pagy+2-(textheight('VMA') div 2),copy(sirt,1,j));
        inc(pagx,textwidth(copy(sirt,1,j))+2);
        incr:=buf[f+1]+1;
       end
   else
   if buf[f]=9 then
       begin
        inc(lc);
	borders[lc].pagelink:=buf[f+1];borders[lc].pagedef:=pag;
        j:=buf[f+2];for i:=1 to j do sirt[i]:=chr(buf[f+2+i]);sirs:=copy(sirt,1,j);
        settextjustify(lefttext,toptext);
        GetTextBorders(pagx,pagy,sirs,borders[lc]);
        inc(borders[lc].y1,2);inc(borders[lc].y2,2);
        outtextxy(pagx,pagy,sirs);
        {SetLineStyle(3, 0, NormWidth);
	Line(borders[lc].x1,borders[lc].y2,borders[lc].x2,borders[lc].y2);
	SetLineStyle(0, 0, 0);}
        maxy:=textheight(sirs);inc(pagx,textwidth(sirs)+2);
        incr:=buf[f+2]+2;
       end
   else
   if buf[f] in [32..165,224..254] then
       begin
         settextjustify(lefttext,toptext);
         outtextxy(pagx,pagy,chr(buf[f]));
         inc(pagx,textwidth(chr(buf[f])));
         if textheight(chr(buf[f]))>maxy then maxy:=textheight(chr(buf[f]));
         incr:=0;
       end
   else
   if buf[f]=13 then maxy:=textheight('VMA software');
  inc(f,incr+1);
  end;
end;


begin
  seek(fis,hdr.pags[pag]);
  hidemouse;fra^.show;
  memoatribute(false);
  setcolor(txtcol);msettextstyle(txtfont,0,txtsize);
  eop:=false;
  pagx:=12;pagy:=12;maxy:=0;
  fra^.activate;
  repeat
     readline;displayline;
     inc(pagy,3+maxy);
     pagx:=12;maxy:=0;
  until eop or eof(fis);
  fra^.deactivate;
  showmouse;memoatribute(true);
end;

Procedure TManual.Run;
var s:string;
begin
 if not fileexist(constfilename)
then
   begin
    b1^.butenabled:=false;
    b2^.butenabled:=false;
    b3^.butenabled:=false;
    b4^.butenabled:=false;
    b5^.butenabled:=true;
    b1^.show;b2^.show;b3^.show;b4^.show;b5^.show;
    fra^.activate;
    hidemouse;
    settextjustify(lefttext,toptext);setcolor(red);
    msettextstyle(tripfont,0,4);
    outtextxy(40,60,'Eroare:');
    msettextstyle(tscrfont,0,3);setcolor(blue);
    outtextxy(60,100,'Fiierul '+constfilename+' este inexistent.');
    showmouse;
    fra^.deactivate;
   end
else
   begin
 ReadHeader;dec(hdr.pc);
 if crtpag>hdr.pc then crtpag:=hdr.pc;
 if crtpag<0 then crtpag:=1;

 if crtpag=0 then
  begin
   if hdr.cpc=0 then crtpag:=1
   else begin crtpag:=hdr.pc+1;incuprins:=true;b4^.retitle(titles[indtitles,6]);end;
  end;

 if hdr.cpc=0 then b4^.butenabled:=false;
 b1^.show;b2^.show;b3^.show;b4^.show;b5^.show;

 assign(fis,constfilename);reset(fis);
 readpage(crtpag);
 if ((crtpag=1)or(crtpag=hdr.pc+1)) then begin b1^.disable;b2^.disable;end;
 if ((crtpag=hdr.pc)or(crtpag=hdr.cpc-1)) then b3^.disable;
  end;
repeat
 getevent(ev);
 if b1^.clicked(ev) or ((b1^.butenabled) and (ev.tip=EvKbd) and (ev.scankey=KbHome)) then
   begin
    if incuprins then crtpag:=hdr.pc+1 else crtpag:=1;
    readpage(crtpag);
    if ((crtpag=1)or(crtpag=hdr.pc+1)) then begin b1^.disable;b2^.disable;end;
    b3^.enable;
   end;
 if b2^.clicked(ev) or ((b2^.butenabled) and (ev.tip=EvKbd) and (ev.scankey=KbLeft)) then
   begin
    dec(crtpag);readpage(crtpag);
    if ((crtpag=1)or(crtpag=hdr.pc+1)) then begin b1^.disable;b2^.disable;end;
    b3^.enable;
   end;
 if b3^.clicked(ev) or ((b3^.butenabled) and (ev.tip=EvKbd) and (ev.scankey=KbRight)) then
   begin
    inc(crtpag);readpage(crtpag);
    if ((crtpag=hdr.pc)or(crtpag=hdr.cpc-1)) then b3^.disable;
    b1^.enable;b2^.enable;
   end;
 if ((b3^.butenabled) and (ev.tip=EvKbd) and (ev.scankey=KbEnd)) then {Sare la sfarsit}
   begin
    if incuprins then crtpag:=hdr.cpc-1 else crtpag:=hdr.pc;
    readpage(crtpag);
    b3^.disable;b1^.enable;b2^.enable;
   end;
 if b4^.clicked(ev) then
   begin
    if incuprins
      then
       begin
        b4^.retitle(titles[indtitles,1]);
	crtpag:=memocrtpag;
        if crtpag=1 then begin b1^.disable;b2^.disable;end
                    else begin b1^.enable;b2^.enable;end;
        if crtpag=hdr.pc then b3^.disable else b3^.enable;
       end
      else
       begin
        b4^.retitle(titles[indtitles,6]);
        memocrtpag:=crtpag;
	crtpag:=hdr.pc+1;
        if crtpag=hdr.cpc-1 then b3^.disable else b3^.enable;
        if crtpag=hdr.pc+1 then begin b1^.disable;b2^.disable;end
                           else begin b1^.enable;b2^.enable;end;
       end;
    incuprins:=not incuprins;
    readpage(crtpag);
   end;

   TestLinkCursor(ev);
   if fra^.clicked(ev) then TestLinks(fra^.getx,fra^.gety);

until b5^.clicked(ev)or ((ev.tip=EvKbd) and (ev.scankey=kbEsc));
end;


end.

