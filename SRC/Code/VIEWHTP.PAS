unit ViewHTP;     { Hiper Text Problems viewer }

interface
uses basicgif,obj,obj3,events,appmcga,graph,
     crt,dos,vesadrv,fonts,bk,mouse,clock,viewhtd;

type header=
  record
   copyright:string[32];             { mesaj de copyright }
   pc:byte;                          { numarul de pagini din fisier }
   pags:array[1..100] of longint;    { offseturile in fisier de la care incep paginile }
   ic:byte;                          { numarul de imagini .GIF incluse in fisier }
   imags:array[1..250] of longint;   { offseturile in fisier de la care incep imaginile }

   nrprobl:byte;                     { numarul de probleme din test }
   probl:array[1..50] of             { situatia fiecarei probleme }
   record
     capteorie:string[12];           { fisierul cu capitolul de teorie la care se sare daca s-a gresit }
     pagteorie:byte;                 { pagina din capitolul de teorie la care se sare daca s-a gresit }
     puncte:byte;                    { numarul de puncte care se obtine daca se rezolva }
     variante:byte;                  { numarul de variante de raspuns }
     nrcorecte:byte;                 { numarul de rapunsuri corecte }
     corecte:array[1..12]of byte;    { sirul raspunsurilor corecte. Ex. 3,5,7 sunt raspunsurile corecte }
   end;
   testautor:string;                 { autorul testului }
   timelimit:word;                   { numarul de minute in care trebuie rezolvat testul }
   testtheme:byte;
   testnivel:byte;                   { nivelul de dificultate al testului }
   testtitle:string;                 { titlul testului }
  end;

type PTeste=^TTeste;
     TTeste=object
            PuncteObtinute:integer;
            NotaObtinuta:real;
            RaspunsuriCorecte,ProblemeGresite:byte;
            Rezultat:array[1..50] of byte;
            PunctajMaxim:integer;
            NivelTest:byte;
            IsAuto:boolean;
            Constructor Init(x,y:integer;filename:string;autoverificare,timplimita,sound,savebk:boolean);
            Procedure   Run;
            Destructor  Done;
          private
            ev:tevent;
            main,raspuns,expirat:pwindow;
	    b1,b2,b3,b4,b5:pbutton;
            r1,r2,e1:pbutton;
            chks:array[1..50]of PChkBox;
            buts:array[1..50]of pbutton;
	    fra:pframe;
            crtpag:byte;txtfont,txtsize,txtcol:word;
            hdr:header;
            fis:fileb;problpepag:byte;
            FillInfo:FillSettingsType;linst:Linesettingstype;cul:word;
            textst:textsettingstype;OldPattern:FillPatternType;ct:word;
            constfilename:string;
            primapepag:array[1..15] of byte;
            incercat:array[1..50] of boolean;
            cusound:boolean;
            cutimplimita,cutimplimitaold:boolean;
            timebegin:longint;
            function  TimpRamas:longint;
            function  IntToStr(I: Longint): String;
            function  RealToStr(I: Real): String;
            procedure Mesaj(stri:string);
            procedure Mesaj2(stri:string);
            procedure Info;
            procedure AfisClock;
            procedure AfisRezultate;
            procedure AfisRezultate2;
            Procedure SituatieGrafica(a1,a2,a3,_b1,_b2,c1,c2:integer);
            procedure ViewManual(cap:string;pag:byte);
            procedure MemoAtribute(a:boolean);
            procedure Keret(xr1,yr1,xr2,yr2,tip:integer);
            procedure FillKeret(xr1,yr1,xr2,yr2,tip:integer);
            procedure HLine3D(x,y,lung,tip:integer);
            procedure VLine3D(x,y,lat,tip:integer);
            procedure Readheader;
            procedure ReadPage(pag:byte);
            Function  TestIesire:boolean;
          end;

implementation


Function TTeste.TimpRamas:longint;
var tiemh,timem,times,timehund:word;
begin
 gettime(tiemh,timem,times,timehund);
 TimpRamas:=(hdr.timelimit*60-((3600*tiemh+60*timem+times)-timebegin));
end;

Procedure TTeste.Info;
var fer2:pwindow;
    but,but2:pbutton;
    evw:tevent;
    x1,y1,x2,y2,t:integer;
    VP: ViewPortType;
const nivele:array[0..7]of string=('special pt. BOBO',
                                   'NIVEL 1','NIVEL 2','NIVEL 3',
	                           'NIVEL 4','NIVEL 5','NIVEL 6','NIVEL 7');
begin
 new(fer2);
 fer2^.init(160,160,350,178,'Informatii test',2,true);fer2^.show;
 new(but,init(fer2,214,153,60,14,'O.K.'));but^.show;
 new(but2,init(fer2,77,153,60,14,'Detalii'));
 if not IsAuto then but2^.butenabled:=false;
 if ((not IsAuto) and cutimplimitaold and (not cutimplimita)) then but2^.butenabled:=true;
 but2^.show;
 x1:=fer2^.winx;
 y1:=fer2^.winy;
 x2:=fer2^.winx+fer2^.winlung;
 y2:=fer2^.winy+fer2^.winlat;
 hidemouse;
 getviewsettings(vp);setviewport(x1,y1,x2-5,y2,clipon);
 msettextstyle(5,0,4);settextjustify(lefttext,toptext);
 setcolor(black);
 outtextxy(20,30,'Titlu test');outtextxy(100,30,': '+hdr.testtitle);
 outtextxy(20,50,'Autor test');outtextxy(100,50,': '+hdr.testautor);
 outtextxy(20,70,'Nivel');outtextxy(100,70,': '+nivele[hdr.testnivel]);
 outtextxy(20,90,'Nr. probleme');outtextxy(100,90,': '+inttostr(hdr.nrprobl));
 outtextxy(20,110,'Timp de lucru');
 if cutimplimitaold then outtextxy(100,110,': '+inttostr(hdr.timelimit)+' minute')
                    else outtextxy(100,110,': nelimitat'); {daca nu e cu timp limita}
 t:=timpramas div 60;if t<0 then t:=0;
 outtextxy(20,130,'Timp r†mas');
 if (cutimplimita and cutimplimitaold) then {daca e cu timp limita si nu a expirat}
  outtextxy(100,130,': '+inttostr(t)+' minute');
 if ((not cutimplimita) and cutimplimitaold) then {daca e cu timp limita si a expirat}
  outtextxy(100,130,': 0');
 if (not cutimplimitaold) then
  outtextxy(100,130,': nelimitat'); {daca nu e cu timp limita}
 setviewport(vp.x1,vp.y1,vp.x2,vp.y2,vp.clip);
 showmouse;
 repeat
  fer2^.move;
  getevent(evw);
  if but2^.clicked(evw) then afisrezultate;
 until but^.clicked(evw) or fer2^.clicked(evw);
 dispose(but,done);
 dispose(but2,done);
 dispose(fer2,done);
end;

Procedure TTeste.SituatieGrafica(a1,a2,a3,_b1,_b2,c1,c2:integer);
procedure probleme(x,y:integer;v1,v2,v3:byte);
const lat=40;lung=200;
var v1lung,v2lung,v3lung:integer;
    yend:integer;
begin
 inc(y,45);
 v1lung:=(v1*lung) div (v1+v2+v3);
 v2lung:=(v2*lung) div (v1+v2+v3);
 v3lung:=(v3*lung) div (v1+v2+v3);
 yend:=y+v1lung+v2lung+v3lung;
 setcolor(black);
 setfillstyle(10,lightred);
 bar3d(x,y,x+lat,y+v1lung,lat div 2,true);
 setfillstyle(11,lightgreen);
 bar3d(x,y+v1lung,x+lat,y+v1lung+v2lung,lat div 2,false);
 setfillstyle(9,lightblue);
 bar3d(x,y+v1lung+v2lung,x+lat,yend,lat div 2,false);
 msettextstyle(10,0,1);outtextxy(x-6,y-45,'Probleme');
 msettextstyle(5,0,4);
 setfillstyle(solidfill,lightred);
 bar(x-40,yend+12,x-34,yend+20);rectangle(x-40,yend+12,x-34,yend+20);
 outtextxy(x-30,yend+10,'Prob neŒncercate : '+inttostr(v1));
 setfillstyle(solidfill,lightgreen);
 bar(x-40,yend+27,x-34,yend+35);rectangle(x-40,yend+27,x-34,yend+35);
 outtextxy(x-30,yend+25,'Prob greite     : '+inttostr(v2));
 setfillstyle(solidfill,lightblue);
 bar(x-40,yend+42,x-34,yend+50);rectangle(x-40,yend+42,x-34,yend+50);
 outtextxy(x-30,yend+40,'Prob rezolvate   : '+inttostr(v3));
end;

procedure timp(x,y:integer;v1,v2:integer);
const lat=40;lung=200;
var v1lung,v2lung:integer;
    yend:integer;
begin
 inc(y,45);
 if v2<>-1 then begin
 v1lung:=(v1*lung) div (v1+v2);
 v2lung:=(v2*lung) div (v1+v2);
 yend:=y+v1lung+v2lung;
 setcolor(black);
 setfillstyle(11,lightred);
 bar3d(x,y,x+lat,y+v1lung,lat div 2,true);
 setfillstyle(9,lightgreen);
 bar3d(x,y+v1lung,x+lat,yend,lat div 2,false);
 msettextstyle(10,0,1);outtextxy(x+10,y-45,'Timp');
 msettextstyle(5,0,4);
 setfillstyle(solidfill,lightred);
 bar(x-22,yend+12,x-16,yend+20);rectangle(x-22,yend+12,x-16,yend+20);
 outtextxy(x-12,yend+10,'Timp folosit : '+inttostr(v1));
 setfillstyle(solidfill,lightgreen);
 bar(x-22,yend+27,x-16,yend+35);rectangle(x-22,yend+27,x-16,yend+35);
 outtextxy(x-12,yend+25,'Timp r†mas   : '+inttostr(v2));
 end
 else
 begin
 yend:=y+lung;
 setcolor(black);
 setfillstyle(1,yellow);
 bar3d(x,y,x+lat,y+lung,lat div 2,true);
 setcolor(blue);msettextstyle(4,1,1);outtextxy(x+5,y+40,'Nelimitat');
 setcolor(black);
 msettextstyle(10,0,1);outtextxy(x+10,y-45,'Timp');
 msettextstyle(5,0,4);
 setfillstyle(solidfill,lightred);
 bar(x-22,yend+12,x-16,yend+20);rectangle(x-22,yend+12,x-16,yend+20);
 outtextxy(x-12,yend+10,'Timp folosit : '+inttostr(v1));
 setfillstyle(solidfill,lightgreen);
 bar(x-22,yend+27,x-16,yend+35);rectangle(x-22,yend+27,x-16,yend+35);
 outtextxy(x-12,yend+25,'Timp r†mas   : --');
 end;
end;

procedure puncte(x,y:integer;v1,v2:byte);
const lat=40;lung=200;
var v1lung,v2lung:integer;
    yend:integer;
begin
 inc(y,45);
 v1lung:=(v1*lung) div (v1+v2);
 v2lung:=(v2*lung) div (v1+v2);
 yend:=y+v1lung+v2lung;
 setcolor(black);
 setfillstyle(11,lightred);
 bar3d(x,y,x+lat,y+v1lung,lat div 2,true);
 setfillstyle(9,lightgreen);
 bar3d(x,y+v1lung,x+lat,y+v1lung+v2lung,lat div 2,false);
 msettextstyle(10,0,1);outtextxy(x+5,y-45,'Puncte');
 msettextstyle(5,0,4);
 setfillstyle(solidfill,lightred);
 bar(x-26,yend+12,x-20,yend+20);rectangle(x-26,yend+12,x-20,yend+20);
 outtextxy(x-16,yend+10,'Puncte r†mase  : '+inttostr(v1));
 setfillstyle(solidfill,lightgreen);
 bar(x-26,yend+27,x-20,yend+35);rectangle(x-26,yend+27,x-20,yend+35);
 outtextxy(x-16,yend+25,'Puncte ob€inute : '+inttostr(v2));
end;

var fer:pwindow;
    _fra:pframe;
    but:pbutton;
    _ev:tevent;
begin
 new(fer,initxms(50,80,430,395,'Statistica testului',3,true));fer^.show;
 new(_fra,init(fer,10,27,410,315,5,lightgray,'Desen'));_fra^.show;
 new(but,init(fer,215-80,355,160,20,'O.K.'));but^.show;
 _fra^.activate;
 settextjustify(lefttext,toptext);
 hidemouse;
 probleme(040,10,a1,a2,a3);
 timp    (170,10,_b1,_b2);
 puncte  (300,10,c1,c2);
 showmouse;
 _fra^.deactivate;
 repeat
  fer^.move;
  getevent(_ev);
 until fer^.clicked(_ev) or but^.clicked(_ev);
 dispose(but,done);
 dispose(_fra,done);
 dispose(fer,done);
end;


Procedure TTeste.AfisRezultate;
var fer2:pwindow;
    but1,but2,but3:pbutton;
    evw:tevent;
    x1,y1,x2,y2,t:integer;
    VP: ViewPortType;
    total,f:word;
    partemp1,partemp2:integer;
begin
 new(fer2,initxms(240,120,200,330,'Rezultate',2,true));
 new(but1,init(fer2,20,267,70,20,'Detalii'));
 new(but3,init(fer2,110,267,70,20,'Grafic'));
 new(but2,init(fer2,20,300,160,16,'O.K.'));
 fer2^.show;but1^.show;but2^.show;but3^.show;
 x1:=fer2^.winx;
 y1:=fer2^.winy;
 x2:=fer2^.winx+fer2^.winlung;
 y2:=fer2^.winy+fer2^.winlat;
 hidemouse;
 getviewsettings(vp);setviewport(x1,y1,x2-5,y2,clipon);
 msettextstyle(5,0,4);setcolor(black);settextjustify(lefttext,toptext);
 total:=punctajmaxim;notaobtinuta:=1+(9*puncteobtinute)/total;
 outtextxy(25,40,'Num†r probleme');outtextxy(155,40,': '+inttostr(hdr.nrprobl));
 outtextxy(25,60,'Probleme rezolvate');outtextxy(155,60,': '+inttostr(raspunsuricorecte));
 outtextxy(25,80,'Probleme greite');outtextxy(155,80,': '+inttostr(problemegresite));
 outtextxy(25,100,'Probleme neŒncercate');outtextxy(155,100,': '+inttostr(hdr.nrprobl-problemegresite-raspunsuricorecte));
 outtextxy(25,120,'Timp folosit (minute)');
 if ((not cutimplimita) and cutimplimitaold) then {daca e cu timp limita si a expirat}
    outtextxy(155,120,': '+inttostr(hdr.timelimit));
 if (not cutimplimitaold) or (cutimplimita and cutimplimitaold) then
    {daca testul nu e cu timp limita sau (daca e cu timp limita si nu a expirat)}
    outtextxy(155,120,': '+inttostr(hdr.timelimit-timpramas div 60));

 outtextxy(25,140,'Timp r†mas (minute)');
 if ((not cutimplimita) and cutimplimitaold) then
   outtextxy(155,140,': 0');    {daca e cu timp limita si a expirat}
 if not cutimplimitaold then
   outtextxy(155,140,': nel.'); {daca nu e cu timp limita}
 if (cutimplimita and cutimplimitaold) then   {daca e cu timp limita si nu a expirat}
   outtextxy(155,140,': '+inttostr(timpramas div 60));
 outtextxy(25,185,'Punctaj total');outtextxy(155,185,': '+inttostr(total));
 outtextxy(25,205,'Puncte ob€inute');outtextxy(155,205,': '+inttostr(puncteobtinute));
 outtextxy(25,225,'Nota ob€inut†');outtextxy(155,225,': '+realtostr(notaobtinuta));
 keret(6,25,195,168,0);keret(6,172,195,255,0);
 setviewport(vp.x1,vp.y1,vp.x2,vp.y2,vp.clip);
 showmouse;
 repeat
  fer2^.move;
  getevent(evw);
  if but1^.clicked(evw) then afisrezultate2;
  if but3^.clicked(evw) then
   begin
     if not cutimplimitaold then      {daca testul nu e cu timp limita}
      begin partemp1:=hdr.timelimit-timpramas div 60;partemp2:=-1;end;
     if (cutimplimita and cutimplimitaold) then   {daca e cu timp limita si nu a expirat}
      begin partemp1:=hdr.timelimit-timpramas div 60;
            partemp2:=timpramas div 60;end;
     if ((not cutimplimita) and cutimplimitaold) then {daca e cu timp limita si a expirat}
      begin partemp1:=hdr.timelimit;
            partemp2:=0;end;
     SituatieGrafica(hdr.nrprobl-problemegresite-raspunsuricorecte,
                   problemegresite,raspunsuricorecte,
                   partemp1,partemp2,
                   total-puncteobtinute,puncteobtinute);
   end;
 until but2^.clicked(evw) or fer2^.clicked(evw);
 dispose(but1,done);
 dispose(but2,done);
 dispose(but3,done);
 dispose(fer2,done);
end;


Procedure TTeste.Afisrezultate2;
var fer2:pwindow;
    but:pbutton;
    evw:tevent;
    x1,y1,x2,y2,t:integer;
    f,nrp,lw:word;
    VP: ViewPortType;
begin
 nrp:=hdr.nrprobl;if nrp>20 then nrp:=20;
 lw:=(528*nrp)div 20+4;
 new(fer2,init(160,160,72+lw,100,'Detalii',2,true));
 new(but,init(fer2,(72+lw) div 2-40,84,80,10,'O.K.'));
 fer2^.show;but^.show;
 x1:=fer2^.winx;
 y1:=fer2^.winy;
 x2:=fer2^.winx+fer2^.winlung;
 y2:=fer2^.winy+fer2^.winlat;
 hidemouse;
 getviewsettings(vp);setviewport(x1,y1,x2-5,y2,clipon);
 msettextstyle(5,0,4);settextjustify(lefttext,toptext);setcolor(black);
 outtextxy(17,32,'Problema');outtextxy(17,58,'Puncte');
 keret(5,25,26*nrp+72,78,1);
 keret(6,26,26*nrp+73,77,0);
 hline3d(7,51,26*nrp+64,1);
 for f:=1 to nrp do
   begin
    vline3d(46+26*f,27,49,1);
    outtextxy(53+26*f,34,inttostr(f));
    outtextxy(53+26*f,60,inttostr(rezultat[f]));
   end;
 setviewport(vp.x1,vp.y1,vp.x2,vp.y2,vp.clip);
 showmouse;
 repeat
  fer2^.move;
  getevent(evw);
 until but^.clicked(evw) or fer2^.clicked(evw);
 dispose(but,done);
 dispose(fer2,done);
end;



procedure TTeste.AfisClock;
var cl:PClock;
begin
  new(cl,Init(200,160,250,220,3,lightblue,'','Ceas'));
  cl^.SetClock(blue);
  cl^.Run;
  dispose(cl,Done);
end;

Procedure TTeste.Mesaj(stri:string);
var fer1:pborwindow1b;
begin
 new(fer1,init(240,150,2,'O.K.','Mesaj',stri));
 fer1^.setattr(LittFont,5,Blue);
 if cusound then
  begin
   sound(2000);delay(80);nosound;delay(100);
   sound(2000);delay(80);nosound;
   delay(200);
   sound(2000);delay(80);nosound;delay(100);
   sound(2000);delay(80);nosound;
  end;
 fer1^.run;
 dispose(fer1,done);
end;

Procedure TTeste.Mesaj2(stri:string);
var fer1:pborwindow1b;
begin
 new(fer1,init(240,150,2,'O.K.','Mesaj',stri));
 fer1^.setattr(LittFont,5,Blue);
 fer1^.run;
 dispose(fer1,done);
end;


Procedure TTeste.Readheader;
var ft:file;
begin
 assign(ft,constfilename);reset(ft,1);
 seek(ft,filesize(ft)-sizeof(header));
 blockread(ft,hdr,sizeof(header));
 close(ft);
end;

Procedure TTeste.ReadPage(pag:byte);
var buf:array[1..255] of byte;
    cpl:word;a:byte;maxy:byte;
    pagx,pagy:word;
    t:word;incr:word;
    eop:boolean;


procedure readline;
const f:word=1;
begin
 repeat
  read(fis,a);buf[f]:=a;inc(f);
  if a=255 then eop:=true;
 until a=13;
 cpl:=f-1;f:=1;
 read(fis,a);
end;

procedure displayline;
var f:word;i,j:byte;
    sirt:array [1..255] of char;
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
         putpixel(pagx+w1-1,pagy,getcolor);
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
   if buf[f]=20 then
       begin
         problpepag:=buf[f+1];
	 incr:=1;
       end
   else
   if buf[f] in [32..127,224..254] then
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

Constructor TTeste.Init;
var f:word;
    tiemh,timem,times,timehund:Word;
begin

 constfilename:=filename;
 ReadHeader;dec(hdr.pc);

 if savebk                 {650,500}
 then new(main,initxms(x,y,639,479,hdr.testtitle,1,true))
 else new(main,init(x,y,639,479,hdr.testtitle,1,false));
 new(b1,init(main,020,442,80,20,'Info'));
 new(b2,init(main,140,442,80,20,'Ceas'));
 new(b3,init(main,260,442,80,20,'<<<' ));
 new(b4,init(main,380,442,80,20,'>>>' ));
 new(b5,init(main,500,442,80,20,'Iesire'));
 new(fra,init(main,15,30,560,400,4,lightgray,'Desen'));
 main^.show;fra^.show;
 b1^.show;b2^.show;b3^.show;b4^.show;b5^.show;
 keret(x+580,y+30,x+630,y+430,0);

 txtfont:=DefaultFont;txtsize:=1;txtcol:=black;crtpag:=1;
 raspunsuricorecte:=0;problemegresite:=0;
 puncteobtinute:=0;
 NivelTest:=hdr.testnivel;
 for f:=1 to 50 do begin rezultat[f]:=0;incercat[f]:=false;end;
 punctajmaxim:=0;
 for f:=1 to hdr.nrprobl do inc(punctajmaxim,hdr.probl[f].puncte);
 gettime(tiemh,timem,times,timehund);
 timebegin:=3600*tiemh+60*timem+times;
 cutimplimita:=timplimita;
 cutimplimitaold:=cutimplimita;
 cusound:=sound;
 IsAuto:=autoverificare;
end;


Destructor TTeste.Done;
var f:word;
begin
 dispose(fra,done);
 dispose(b1,done);
 dispose(b2,done);
 dispose(b3,done);
 dispose(b4,done);
 dispose(b5,done);
 for f:=primapepag[crtpag] to primapepag[crtpag]+problpepag-1 do dispose(buts[f],done);
 dispose(main,done);
 close(fis);
end;

Procedure TTeste.Run;
var s,l:word;
    f,g,h:word;
    okpressed,cancel:boolean;
    alese:byte;
    rezult:byte;
    fer1:PBorWindow1B;
    dontputagain:boolean;
    iesire:boolean;
begin
 iesire:=false;
 assign(fis,constfilename);reset(fis);
 readpage(crtpag);
 if crtpag=hdr.pc then b4^.disable;
 if crtpag=1      then b3^.disable;
 primapepag[crtpag]:=1;
 for f:=primapepag[crtpag] to primapepag[crtpag]+problpepag-1 do
   begin
    new(buts[f],init(main,590,10+30*(f-primapepag[crtpag]+1),30,20,inttostr(f)));
    if (not IsAuto) and incercat[f] then buts[f]^.butenabled:=false;
    buts[f]^.show;
   end;
repeat
 main^.move;
 getevent(ev);

 if b1^.clicked(ev) then Info;
 if b2^.clicked(ev) then AfisClock;
 if b3^.clicked(ev) then if crtpag>1 then
   begin
    for f:=primapepag[crtpag] to primapepag[crtpag]+problpepag-1 do dispose(buts[f],done);
    fillkeret(main^.winx+580,main^.winy+30,main^.winx+630,main^.winy+430,0);
    dec(crtpag);readpage(crtpag);
    if crtpag=1 then b3^.disable;
    if not b4^.butenabled then b4^.enable;
    for f:=primapepag[crtpag] to primapepag[crtpag]+problpepag-1 do
     begin
       new(buts[f],init(main,590,10+30*(f-primapepag[crtpag]+1),30,20,inttostr(f)));
       if (not IsAuto) and incercat[f] then buts[f]^.butenabled:=false;
       buts[f]^.show;
     end;
   end;
 if b4^.clicked(ev) then if crtpag<hdr.pc then
   begin
    for f:=primapepag[crtpag] to primapepag[crtpag]+problpepag-1 do dispose(buts[f],done);
    fillkeret(main^.winx+580,main^.winy+30,main^.winx+630,main^.winy+430,0);
    primapepag[crtpag+1]:=primapepag[crtpag]+problpepag;
    inc(crtpag);readpage(crtpag);
    if crtpag=hdr.pc then b4^.disable;
    if not b3^.butenabled then b3^.enable;
    for f:=primapepag[crtpag] to primapepag[crtpag]+problpepag-1 do
     begin
       new(buts[f],init(main,590,10+30*(f-primapepag[crtpag]+1),30,20,inttostr(f)));
       if (not IsAuto) and incercat[f] then buts[f]^.butenabled:=false;
       buts[f]^.show;
     end;
   end;

 if cutimplimita then
 if timpramas<0 then
   begin
    cutimplimita:=false;
    for f:=1 to hdr.nrprobl do incercat[f]:=true;
    for f:=primapepag[crtpag] to primapepag[crtpag]+problpepag-1 do buts[f]^.disable;
    Mesaj('Timpul de '+inttostr(hdr.timelimit)+' minute acordat pentru rezolvarea acestui test a expirat');
   end;

 for f:=primapepag[crtpag] to primapepag[crtpag]+problpepag-1 do if buts[f]^.clicked(ev) then
   begin
    new(raspuns,init(200,140,320,150,'Problema '+inttostr(f),1,true));
    new(r1,init(raspuns,50,118,80,16,'O.K.'));
    new(r2,init(raspuns,190,118,80,16,'Cancel'));
    raspuns^.show;r1^.show;r2^.show;
    setlinestyle(0,0,0);setwritemode(copyput);
    setcolor(lightgray);line(raspuns^.winx+5,raspuns^.winy+106,raspuns^.winx+raspuns^.winlung-7,raspuns^.winy+106);
    setcolor(white);line(raspuns^.winx+5,raspuns^.winy+107,raspuns^.winx+raspuns^.winlung-7,raspuns^.winy+107);
    for g:=1 to hdr.probl[f].variante do
     begin
      l:=raspuns^.winlung;
      s:=(l-40*hdr.probl[f].variante)div(hdr.probl[f].variante+1);
      new(chks[g],init(raspuns,g*s+(g-1)*40,54,0,false,chr(64+g)+'.'));
      chks[g]^.show;
     end;
     cancel:=true;okpressed:=false;
    repeat
     raspuns^.move;
     getevent(ev);
     for g:=1 to hdr.probl[f].variante do
      if chks[g]^.clicked(ev) then begin cancel:=false;r2^.disable;chks[g]^.toggle;end;
     if r1^.clicked(ev) then okpressed:=true;
    until ((cancel and raspuns^.clicked(ev)) or r2^.clicked(ev) or okpressed);

  dispose(raspuns,done);
  dispose(r1,done);
  dispose(r2,done);

  if okpressed then
  begin
    alese:=0;rezult:=hdr.probl[f].puncte;
    for g:=1 to hdr.probl[f].variante do
     if chks[g]^.chkchecked then inc(alese);
    if alese=hdr.probl[f].nrcorecte then
     begin
      for g:=1 to alese do
       if not chks[hdr.probl[f].corecte[g]]^.chkchecked then
          begin rezult:=0;break;end;
     end
     else rezult:=0;
  if (not IsAuto) then buts[f]^.disable;


  if (rezult<>0) and (not incercat[f]) then
    begin
     inc(puncteobtinute,hdr.probl[f].puncte);
     inc(raspunsuricorecte);
    end;
  if (rezult<>0) and (incercat[f]) and (rezultat[f]=0) then
    begin
      inc(puncteobtinute,hdr.probl[f].puncte);
      inc(raspunsuricorecte);
      dec(problemegresite);
    end;
  dontputagain:=false;
  if (rezult<>0) and (incercat[f]) and (rezultat[f]<>0) then
    begin
      mesaj2('Aceast† problem† a€i mai rezolvat-o odat†');
      dontputagain:=true;
    end;
  if (rezult=0) and (not incercat[f]) then
    inc(problemegresite);
  if (rezult=0) and (incercat[f]) and (rezultat[f]<>0) then
    begin
      mesaj2('     Ce a€i p†€it ?     Aceast† problem† era rezolvat† dar acum a€i greit-o');
      dec(puncteobtinute,hdr.probl[f].puncte);
      dec(raspunsuricorecte);
      inc(problemegresite);
    end;

  incercat[f]:=true;rezultat[f]:=rezult;
  end;
  for g:=1 to hdr.probl[f].variante do dispose(chks[g],done);

  if (IsAuto and okpressed and (rezultat[f]=0))
    then ViewManual(hdr.probl[f].capteorie,hdr.probl[f].pagteorie)
    else if (not dontputagain)and IsAuto and okpressed then begin
          new(fer1,init(240,150,3,'O.K.','Bravo !',
          'Felicit†ri...               A€i rezolvat aceast† problem†'));
          fer1^.setattr(LittFont,5,Blue);
          fer1^.run;
          dispose(fer1,done);
         end;

end;
 if ((main^.clicked(ev) or b5^.clicked(ev))) then
    if IsAuto or      {daca este de autoverificare}
       ((not IsAuto) and (not cutimplimita) and cutimplimitaold)
        then Iesire:=true  {daca e de verificare cu timp limita si a expirat}
        else Iesire:=TestIesire;
until Iesire;
AfisRezultate;
end;

Function  TTeste.TestIesire:boolean;
var fer1:PBorWindow2B;
    rasp:byte;
begin
 new(fer1,init(240,220,1,'Da','Nu','Mesaj','Sunte€i sigur c† a€i terminat testul ?'));
 fer1^.setattr(10,1,blue);
 rasp:=fer1^.run;
 dispose(fer1,done);
 TestIesire:=false;
 If rasp=1 then TestIesire:=true;
end;

procedure TTeste.ViewManual;
var manual:pmanual;
    fer1:PBorWindow2B;
    rasp:byte;
begin
 if cusound then
  begin
   sound(1000);delay(80);
   sound(2000);delay(80);
   sound(4000);delay(80);nosound;
  end;
 new(fer1,init(240,150,4,'Da','Nu','GRESIT !!!',
  'Dori€i s† consulta€i partea de teorie necesar† rezolv†rii problemei ?'));
 fer1^.setattr(LittFont,5,Blue);
 rasp:=fer1^.run;
 dispose(fer1,done);
 if rasp=1 then
  begin
    new(manual,init(0,0,639,479,0,'Manual',cap,pag,Arrow,true));
    manual^.run;
    dispose(manual,done);
  end;
end;

function TTeste.IntToStr(I: Longint): String;
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

function TTeste.RealToStr(I: Real): String;
var
 S: string[11];
begin
 Str(I:2:2,S);
 RealToStr:=S;
end;

procedure TTeste.Keret(xr1,yr1,xr2,yr2,tip:integer);
begin
   ct:=getcolor;
   hidemouse;
   setwritemode(copyput);setlinestyle(0,0,0);
   if tip=0 then setcolor(darkgray)else
   setcolor(white);
   graph.line(xr1+1,yr1+1,xr2-2,yr1+1);
   line(xr1+1,yr1+1,xr1+1,yr2-1);
   if tip=0 then setcolor(white)else
   setcolor(darkgray);
   line(xr2-1,yr1+1,xr2-1,yr2-1);
   line(xr2-1,yr2-1,xr1+1,yr2-1);
   showmouse;
   setcolor(ct);
end;

procedure TTeste.FillKeret(xr1,yr1,xr2,yr2,tip:integer);
var f,g:integer;
begin
   ct:=getcolor;
   hidemouse;
   setfillstyle(solidfill,lightgray);
   setwritemode(copyput);setlinestyle(0,0,0);
   graph.bar(xr1+1,yr1+1,xr2-1,yr2-1);
   g:=yr1;
   repeat
     f:=xr1;
     repeat
       putpixel(f,g,white);inc(f,2);
     until f>=xr2;
     inc(g,2);
   until g>=yr2;

   if tip=0 then setcolor(darkgray)else
   setcolor(white);
   graph.line(xr1+1,yr1+1,xr2-2,yr1+1);
   line(xr1+1,yr1+1,xr1+1,yr2-1);
   if tip=0 then setcolor(white)else
   setcolor(darkgray);
   line(xr2-1,yr1+1,xr2-1,yr2-1);
   line(xr2-1,yr2-1,xr1+1,yr2-1);
   showmouse;
   setcolor(ct);
end;

procedure TTeste.HLine3D(x,y,lung,tip:integer);
begin
   ct:=getcolor;
   hidemouse;
   setwritemode(copyput);setlinestyle(0,0,0);
   if tip=0 then setcolor(darkgray)else setcolor(white);
   line(x,y,x+lung,y);
   if tip=0 then setcolor(white) else setcolor(darkgray);
   line(x,y+1,x+lung,y+1);
   showmouse;
   setcolor(ct);
end;

procedure TTeste.VLine3D(x,y,lat,tip:integer);
begin
   ct:=getcolor;
   hidemouse;
   setwritemode(copyput);setlinestyle(0,0,0);
   if tip=0 then setcolor(darkgray)else setcolor(white);
   line(x,y,x,y+lat);
   if tip=0 then setcolor(white) else setcolor(darkgray);
   line(x+1,y,x+1,y+lat);
   showmouse;
   setcolor(ct);
end;

Procedure TTeste.MemoAtribute(a:boolean);
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

end.