uses mouse,obj,events,fonts,vesadrv,graph;

function stri(x:integer):string;
var strt:string;
  Begin
    str(x,strt);
    stri:=strt;
  End;


Procedure SituatieGrafica(a1,a2,a3,b1,b2,c1,c2:integer);
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
 outtextxy(x-30,yend+10,'Prob neåncercate : '+stri(v1));
 setfillstyle(solidfill,lightgreen);
 bar(x-40,yend+27,x-34,yend+35);rectangle(x-40,yend+27,x-34,yend+35);
 outtextxy(x-30,yend+25,'Prob greÅite     : '+stri(v2));
 setfillstyle(solidfill,lightblue);
 bar(x-40,yend+42,x-34,yend+50);rectangle(x-40,yend+42,x-34,yend+50);
 outtextxy(x-30,yend+40,'Prob rezolvate   : '+stri(v3));
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
 outtextxy(x-12,yend+10,'Timp folosit : '+stri(v1));
 setfillstyle(solidfill,lightgreen);
 bar(x-22,yend+27,x-16,yend+35);rectangle(x-22,yend+27,x-16,yend+35);
 outtextxy(x-12,yend+25,'Timp rÜmas   : '+stri(v2));
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
 outtextxy(x-12,yend+10,'Timp folosit : '+stri(v1));
 setfillstyle(solidfill,lightgreen);
 bar(x-22,yend+27,x-16,yend+35);rectangle(x-22,yend+27,x-16,yend+35);
 outtextxy(x-12,yend+25,'Timp rÜmas   : --');
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
 outtextxy(x-16,yend+10,'Puncte rÜmase  : '+stri(v1));
 setfillstyle(solidfill,lightgreen);
 bar(x-26,yend+27,x-20,yend+35);rectangle(x-26,yend+27,x-20,yend+35);
 outtextxy(x-16,yend+25,'Puncte obÄinute : '+stri(v2));
end;

var fer:pwindow;
    fra:pframe;
    but:pbutton;
    ev:tevent;
begin
 new(fer,init(20,0,430,395,'Statistica testului',3,false));fer^.show;
 new(fra,init(fer,10,27,410,315,5,lightgray,'Desen'));fra^.show;
 new(but,init(fer,215-80,355,160,20,'O.K.'));but^.show;
 fra^.activate;
 settextjustify(lefttext,toptext);
 hidemouse;
 probleme(040,10,a1,a2,a3);
 timp    (170,10,b1,b2);
 puncte  (300,10,c1,c2);
 showmouse;
 fra^.deactivate;
 repeat
  fer^.move;
  getevent(ev);
 until fer^.clicked(ev) or but^.clicked(ev);
 dispose(but,done);
 dispose(fra,done);
 dispose(fer,done);
end;


begin
 opengraph(vga_640x480x16);setuniformpal;
 initmouse;showmouse;
 SituatieGrafica(3,2,5,9,-1,3,12);
 closegraph;
end.
