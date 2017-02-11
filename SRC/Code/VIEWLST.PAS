unit ViewLST;
interface
uses basicgif,events,appmcga,graph,obj,obj3,
     crt,Ukbd,dos,vesadrv,xms,fonts,bk,mouse,clock;


type TListaFis = record
                  Fisier:string;
                  Descriere:string;
                 end;

type TDocInfo  = record
                  DocTheme:byte;    { tema documentului. Ex. mec,electric,optica }
                  DocTitle:string;  { titlul documentului }
                 end;

type TTstInfo  = record
                  TestTheme:byte;   { tema testului. Ex. mec,electric,optica }
   		  TestNivel:byte;   { nivelul de dificultate al testului }
                  TestTitle:string; { titlul testului }
                 end;

type Plista=^TLista;
     TLista=object
             fisales:byte;
             fismasca:string;
             fistheme:byte;
             fisnivel:byte;
             Constructor InitHTD(x,y:integer;masca:string;theme:byte;title:string);
             Constructor InitHTP(x,y:integer;masca:string;theme,nivel:byte;title:string);
             Function    Run:string;
             Destructor  Done;
            private
             lista:PMenuXMS;evw:tevent;
             nrfis:word;listafis:array[1..25]of tlistafis;
             Procedure Message(stri:string);
             Procedure CreazaLista1;
             Procedure CreazaLista2;
            end;

implementation

procedure Keret(xr1,yr1,xr2,yr2,tip:integer);
begin
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
end;

Procedure PanouCuZoom(x1,y1,x2,y2:integer;col:byte;dela:word);
  function sgn(a:real):integer;
  begin
       if a>0 then sgn:=+1;
       if a<0 then sgn:=-1;
       if a=0 then sgn:=0;
  end;
var a,b,c,d,i,s,d1x,d1y,d2x,d2y,u,v,m,n:integer;
begin
     u:= x2 - x1;
     v:= y2 - y1;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := m shr 1;
     a:=(x1+x2)div 2;c:=a;
     b:=(y1+y2)div 2;d:=b;
     setcolor(col);
     setlinestyle(0,0,0);setwritemode(copyput);
     FOR i := 0 TO m div 2 DO
     BEGIN
          rectangle(a,b,c,d);delay(dela);
          inc(s,n);
          IF not (s<m) THEN
          BEGIN
               dec(s,m);
               inc(a,d1x);inc(b,d1y);
               dec(c,d1x);dec(d,d1y);
          END
          ELSE
          BEGIN
               inc(a,d2x);inc(b,d2y);
               dec(c,d2x);dec(d,d2y);
          END;
     end;
END;

     {  --- * --- }

Constructor TLista.InitHTD;
begin
 fisales:=1;
 fismasca:=masca;
 fistheme:=theme;
 new(lista,init(x,y,title));
 nrfis:=0;CreazaLista1;
 lista^.show(1);
end;

Constructor TLista.InitHTP;
begin
 fisales:=2;
 fismasca:=masca;
 fistheme:=theme;
 fisnivel:=nivel;
 new(lista,init(x,y,title));
 nrfis:=0;CreazaLista2;
 lista^.show(1);
end;

Procedure TLista.Message(stri:string);
var fer2:PBorWindow1B;
begin
 new(fer2,init(300,180,2,'O.K.','Mesaj',stri));
 fer2^.SetAttr(5,5,1);
 fer2^.run;
 dispose(fer2,done);
end;

Function TLista.Run;
var i:integer;
begin
 if nrfis=0 then
   begin
    message('Nu exist† nici un fiier din aceast† categorie. Programul pe care Œl de€ine€i fiind o versiune demonstrativ†.');
    run:='';
    exit;
   end;
 repeat
   GetEvent(evw);
   i:=lista^.run(evw);
   if i in [1..nrfis] then begin run:=listafis[i].fisier;break;end;
   if i = -1 then begin run:='';break;end;
 until false;
end;

Destructor TLista.Done;
begin
 dispose(lista,done);
end;

Procedure TLista.CreazaLista1;
var Tema:byte;
var Titl:string;
Procedure FindDocInfo(fis:string);
var ft:file;s:TDocInfo;
begin
 assign(ft,fis);reset(ft,1);
 seek(ft,filesize(ft)-sizeof(TDocInfo));
 blockread(ft,s,sizeof(TDocInfo));
 close(ft);
 titl:=s.doctitle;
 tema:=s.doctheme;
end;
var DirInfo: SearchRec;
    i:word;
begin
 i:=1;
 FindFirst(fismasca, Archive+ReadOnly+Hidden, DirInfo);
 while DosError = 0 do
 begin
  FindDocInfo(dirinfo.name);
  if FisTheme=Tema then
    begin
      ListaFis[i].fisier    := dirinfo.name;
      ListaFis[i].descriere := Titl;
      lista^.NewItem(ListaFis[i].descriere,true,false);
      inc(i);
    end;

   FindNext(DirInfo);
 end;
 nrfis:=i-1;
end;


Procedure TLista.CreazaLista2;
var Tema:byte;
    Titl:string;
    Nivel:byte;
Procedure FindTestInfo(fis:string);
var ft:file;s:TTstInfo;
begin
 assign(ft,fis);reset(ft,1);
 seek(ft,filesize(ft)-sizeof(TTstInfo));
 blockread(ft,s,sizeof(TTstInfo));
 close(ft);
 titl:=s.testtitle;
 tema:=s.testtheme;
 nivel:=s.testnivel;
end;
var DirInfo: SearchRec;
    i:word;
begin
 i:=1;
 FindFirst(fismasca, Archive+ReadOnly+Hidden, DirInfo);
 while DosError = 0 do
 begin
  FindTestInfo(dirinfo.name);
  if ((FisTheme=Tema)and(FisNivel=Nivel)) then
    begin
      ListaFis[i].fisier    := dirinfo.name;
      ListaFis[i].descriere := Titl;
      lista^.NewItem(ListaFis[i].descriere,true,false);
      inc(i);
    end;

   FindNext(DirInfo);
 end;
 nrfis:=i-1;
end;

end.
