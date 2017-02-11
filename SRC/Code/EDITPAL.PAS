unit EditPal;
interface
uses events,appmcga,obj,graph,mouse,kerets,setari;

Type PEditPal=^TEditPal;
     TEditPal=object
               fileconfig:string;
               Constructor Init(filename:string;savebk:boolean);
               Procedure   Run;
               Destructor  Done;
               private
               ev:tevent;
               pal:virtualpal;
               fer1:pwindow;
               red,green,blue:pruler;
               reda,greena,bluea:ptext;
               but1,but2,but3,but4:pbutton;
               culs:array [0..15] of PDefButton;
               wx,wy:integer;
               rc,gc,bc:byte;
               culactiv:byte;
               procedure SetImplicit;
              end;

implementation

function stri(x:integer):string;
var strt:string;
  Begin
    str(x,strt);
    stri:=strt;
  End;

Procedure TEditPal.SetImplicit;
begin
 SetPal( 0,00,00,00);
 SetPal( 1,00,00,42);
 SetPal( 2,00,42,00);
 SetPal( 3,00,42,42);
 SetPal( 4,42,00,00);
 SetPal( 5,42,00,42);
 SetPal( 6,42,21,00);
 SetPal( 7,48,48,48);
 SetPal( 8,32,32,32);
 SetPal( 9,41,50,60);
 SetPal(10,21,63,21);
 SetPal(11,21,63,63);
 SetPal(12,63,21,21);
 SetPal(13,63,21,63);
 SetPal(14,63,63,21);
 SetPal(15,63,63,63);
 GetPal(CulActiv,rc,gc,bc);
 red^.setpos(rc);red^.show;
 green^.setpos(gc);green^.show;
 blue^.setpos(bc);blue^.show;
 reda^.redefine(' R:'+stri(red^.getpos));reda^.show;
 greena^.redefine(' G:'+stri(green^.getpos));greena^.show;
 bluea^.redefine(' B:'+stri(blue^.getpos));bluea^.show;
end;

Constructor TEditPal.Init;
var f,g:integer;
begin
 fileconfig:=filename;
 if GetMaxColor<255 then for f:=0 to 15 do setpalette(f,f);
 GetAllPal(Pal);

 if savebk
  then new(fer1,initxms(100,100,440,280,'Editare paleta',3,true))
  else new(fer1,init(100,100,440,280,'Editare paleta',3,false));

 fer1^.show;
 new(but1,init(fer1,024,240,80,20,'Implicit'));but1^.show;
 new(but2,init(fer1,128,240,80,20,'Salveaza'));but2^.show;
 new(but3,init(fer1,232,240,80,20,'Accepta'));but3^.show;
 new(but4,init(fer1,336,240,80,20,'Anuleaza'));but4^.show;

 CulActiv:=0;
 GetPal(CulActiv,rc,gc,bc);
 new(red,init(fer1,220,40,130,20,1,0,63,1,rc));red^.show;
 new(green,init(fer1,300,40,130,20,1,0,63,1,gc));green^.show;
 new(blue,init(fer1,380,40,130,20,1,0,63,1,bc));blue^.show;

 new(reda,init(fer1,200,180,60,20,5,' R:'+stri(red^.getpos)));
 reda^.SetJustify(LeftText,CenterText,True);reda^.show;
 new(greena,init(fer1,280,180,60,20,5,' G:'+stri(green^.getpos)));
 greena^.SetJustify(LeftText,CenterText,True);greena^.show;
 new(bluea,init(fer1,360,180,60,20,5,' B:'+stri(blue^.getpos)));
 bluea^.SetJustify(LeftText,CenterText,True);bluea^.show;
 wx:=fer1^.winx;wy:=fer1^.winy;
 HideMouse;
 keret(wx+10,wy+230,wx+430,wy+270,1);
 keret(wx+10,wy+025,wx+430,wy+220,1);
 for f:=1 to 4 do for g:=1 to 4 do
  Begin
    setfillstyle(solidfill,(f-1)*4+(g-1));
    bar(wx+g*40-15,wy+f*44-4,wx+g*40+10,wy+f*44+21);
    keret(wx+g*40-15,wy+f*44-4,wx+g*40+10,wy+f*44+21,1);
    keret(wx+g*40-16,wy+f*44-5,wx+g*40+11,wy+f*44+22,0);
    new(culs[pred(f)*4+pred(g)],init(fer1,g*40-15,f*44-4,25,25));
  End;
 ShowMouse;
end;

Procedure TEditPal.Run;
var f,g:integer;
    apasat:byte;
begin
 apasat:=0;
 repeat
   fer1^.move;
   GetEvent(ev);
   if red^.clicked(ev) then
      begin
        reda^.redefine(' R:'+stri(red^.getpos));
        reda^.show;
        SetPal(CulActiv,red^.getpos,green^.getpos,blue^.getpos);
      end;
   if green^.clicked(ev) then
      begin
        greena^.redefine(' G:'+stri(green^.getpos));
        greena^.show;
        SetPal(CulActiv,red^.getpos,green^.getpos,blue^.getpos);
      end;
   if blue^.clicked(ev) then
      begin
        bluea^.redefine(' B:'+stri(blue^.getpos));
        bluea^.show;
        SetPal(CulActiv,red^.getpos,green^.getpos,blue^.getpos);
      end;
   for f:=0 to 15 do if culs[f]^.clicked(ev) then
      begin
        CulActiv:=f;
        GetPal(CulActiv,rc,gc,bc);
        red^.setpos(rc);red^.show;
        green^.setpos(gc);green^.show;
        blue^.setpos(bc);blue^.show;
        reda^.redefine(' R:'+stri(red^.getpos));reda^.show;
        greena^.redefine(' G:'+stri(green^.getpos));greena^.show;
        bluea^.redefine(' B:'+stri(blue^.getpos));bluea^.show;
      end;
 if but1^.clicked(ev) then SetImplicit;
 if but2^.clicked(ev) then apasat:=2;
 if but3^.clicked(ev) then apasat:=3;
 if (fer1^.clicked(ev) or but4^.clicked(ev)) then apasat:=4;
 until apasat<>0;
 case apasat of
  2 : begin GetAllPal(Config.Pal);SaveConfiguration(fileconfig);end; {Save}
  3 : GetAllPal(Config.Pal);    {O.K.}
  4 : SetAllPal(Pal);           {Anuleaza}
 end;
end;

Destructor TEditPal.Done;
var f:integer;
begin
 dispose(red,done);
 dispose(green,done);
 dispose(blue,done);
 dispose(reda,done);
 dispose(greena,done);
 dispose(bluea,done);
 dispose(but1,done);
 dispose(but2,done);
 dispose(but3,done);
 dispose(but4,done);
 for f:=0 to 15 do dispose(culs[f],done);
 dispose(fer1,done);
end;


end.
