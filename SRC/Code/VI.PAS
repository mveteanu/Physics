{$A+,B-,D-,E-,F+,G+,I+,L-,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y-}
{$M 16384,0,655360}

uses  XMS,Events,UKBD,Mouse,AppMCGA,
      Fonts,AppBMP,Graph,Kerets,VesaDrv,
      OBJ,OBJ3,ViewHTD,ViewHTP,ViewLST,
      HTPComp,PassWord,Setari,EditPal,CfgIntf,
      Adlib,PlayHSC;

const Teme:array[1..5] of MenuItemXMS = (
  (item:'Studiul fenomenelor mecanice';
        enabled:true;checked:false),
  (item:'Studiul fenomenelor termice';
        enabled:true;checked:false),
  (item:'Studiul fenomenelor electromagnetice';
        enabled:true;checked:false),
  (item:'Studiul fenomenelor optice';
        enabled:true;checked:false),
  (item:'Studiul fenomenelor atomice, nucleare si de corp solid ';
        enabled:true;checked:false));

const Nivele:array[1..7] of MenuItemXMS = (
  (item:'Test de nivel 1 ';enabled:true;checked:false),
  (item:'Test de nivel 2 ';enabled:true;checked:false),
  (item:'Test de nivel 3 ';enabled:true;checked:false),
  (item:'Test de nivel 4 ';enabled:true;checked:false),
  (item:'Test de nivel 5 ';enabled:true;checked:false),
  (item:'Test de nivel 6 ';enabled:true;checked:false),
  (item:'Test de nivel 7 ';enabled:true;checked:false));

const mainbuts:array[1..5] of string=
  ('Pentru elev','Pt. profesor','Setare','Informatii','Iesire');

const ConfigurationFile = 'WIN.CFG';

type barray=array[1..50000]of byte;bararray=^barray;
type PApp=^TApp;
     TApp=object
           main:pwindow;ev:tevent;
           maxx,maxy:integer;
           Constructor Init;
           Procedure   Run;
           Destructor  Done;
          private
           pal:virtualpal;
           han:word;
           BarY:integer;bara:bararray;
           b1,b2,b3,b4,b5:pbutton;
           BLung:integer;BSpace,BSp:integer;
           Procedure BeginManual;
           Procedure BeginTeste(auto:boolean);
           Function  TestIesire:boolean;
           Procedure SelectVideo;
           Procedure BeginProfesor;
           Procedure BeginHelp(pag:byte);
           Procedure EditeazaPaleta;
           Procedure ConfigInterface;
           Procedure ConfigMouse;
           Function  Alege:byte;
           Function  AlegeSetare:byte;
           Procedure InitBar(y:integer);
           Procedure ShowBar;
           Procedure HideBar;
          end;

Procedure TApp.EditeazaPaleta;
var editor:peditpal;
begin
 New(Editor,Init(ConfigurationFile,Config.SaveBk));
 Editor^.Run;
 Dispose(Editor,Done);
end;


Procedure TApp.ConfigInterface;
var ttt:PConfigInterface;
begin
 new(ttt,init(getmaxx div 2 - 150, 200, ConfigurationFile ));
 ttt^.run;
 dispose(ttt,done);
end;


Procedure TApp.ConfigMouse;
var fer:pwindow;
    rul:pruler;
    tex:ptext;
    _b1,_b2:pmsbutton;
    but1,but2,but3:pbutton;
    _ev:tevent;
    apasat:byte;

function IntToStr(I: Longint): String;
var S: string[11];
begin
 Str(I, S);IntToStr := S;
end;

begin
 apasat:=0;
 new(fer,init(100,100,310,200,'Setare mouse',4,true));fer^.show;
 hidemouse;
  keret(fer^.winx+5,fer^.winy+24,fer^.winx+305,fer^.winy+140,0);
  keret(fer^.winx+6,fer^.winy+25,fer^.winx+304,fer^.winy+139,1);
  keret(fer^.winx+5,fer^.winy+137,fer^.winx+305,fer^.winy+195,0);
  keret(fer^.winx+6,fer^.winy+138,fer^.winx+304,fer^.winy+194,1);
 showmouse;
 new(_b1,init(fer,36,40,100,30,'Sageata 1'));_b1^.show;
 new(_b2,init(fer,172,40,100,30,'Sageata 2'));_b2^.show;
 new(rul,init(fer,36,090,236,20,0,10,250,10,Config.MouseSenzitivity));rul^.show;
 new(tex,init(fer,36,115,236,20,6,'Senzitivitate cursor : '+inttostr(rul^.getpos)));tex^.show;
 new(but1,init(fer,015,155,80,20,'Salveaza'));but1^.show;
 new(but2,init(fer,115,155,80,20,'Accepta'));but2^.show;
 new(but3,init(fer,215,155,80,20,'Anuleaza'));but3^.show;
 repeat
  fer^.move;
  getevent(_ev);
  if _b1^.clicked(_ev) then SelectStdCursor(Arrow);
  if _b2^.clicked(_ev) then SelectStdCursor(Arrow2);
  if rul^.clicked(_ev) then
   begin
     SetSenzitivity(word(trunc(Rul^.GetPos*0.75)),word(Rul^.GetPos),2);
     tex^.redefine('Senzitivitate cursor : '+inttostr(rul^.getpos));
   end;
  if but1^.clicked(_ev) then apasat:=1;
  if fer^.clicked(_ev) or but2^.clicked(_ev) then apasat:=2;
  if but3^.clicked(_ev) then apasat:=3;
 until apasat<>0;
 case apasat of
  1:begin
     Config.MouseSenzitivity:=Word(Rul^.GetPos);
     Config.SystemMouseArrow:=GetStdCursor;
     SaveConfiguration(ConfigurationFile);
    end;
  2:begin
     Config.MouseSenzitivity:=Word(Rul^.GetPos);
     Config.SystemMouseArrow:=GetStdCursor;
    end;
  3:begin
     SetSenzitivity(Trunc(Config.MouseSenzitivity*0.75),Config.MouseSenzitivity,2);
     SelectStdCursor(Config.SystemMouseArrow);
    end;
 end;
 dispose(_b1,done);
 dispose(_b2,done);
 dispose(but1,done);
 dispose(but2,done);
 dispose(but3,done);
 dispose(rul,done);
 dispose(tex,done);
 dispose(fer,done);
end;


Procedure TApp.SelectVideo;
var fer:pwindow;
    fer1:PBorWindow1B;
    chk     :array[1..3] of pchkbox;
    chkstate:array[1..3] of boolean;
    f,g,state:byte;
    but1,but2:pbutton;
    ok,cancel:boolean;
begin
 ok:=false;cancel:=false;
 case ModeCrt of
  VGA_640x480x16   : state:=1;
  VESA_640x480x256 : state:=2;
  VESA_800x600x256 : state:=3;
 end;
 for f:=1 to 3 do chkstate[f]:=false;chkstate[state]:=true;
 new(fer   ,init(100,100,310,200,'Alegeti modul video',2,true));fer^.show;
 new(but1  ,init(fer,210,050,80,32,'Accepta'));but1^.show;
 new(but2  ,init(fer,210,137,80,32,'Anuleaza'));but2^.show;
 new(chk[1],init(fer,30,050,1,chkstate[1],'VGA  640x480x16 '));chk[1]^.show;
 new(chk[2],init(fer,30,100,1,chkstate[2],'VESA 640x480x256'));chk[2]^.show;
 new(chk[3],init(fer,30,150,1,chkstate[3],'VESA 800x600x256'));chk[3]^.show;
 if Not IsVESA then begin chk[2]^.disable;chk[3]^.disable;end;
repeat
 fer^.move;
 GetEvent(ev);
 for f:=1 to 3 do if chk[f]^.clicked(ev) then
     begin
      for g:=1 to 3 do chk[g]^.chkchecked:=false;
      chk[f]^.chkchecked:=true;
      for g:=1 to 3 do chk[g]^.show;
     end;
 if but1^.clicked(ev) then ok:=true;
 if but2^.clicked(ev) or fer^.clicked(ev) then cancel:=true;
until (ok or cancel);
if ok then
  begin
    for f:=1 to 3 do if chk[f]^.chkchecked then state:=f;
    case state of
     1:Config.VideMode:=VGA_640x480x16;
     2:Config.VideMode:=VESA_640x480x256;
     3:Config.VideMode:=VESA_800x600x256;
    end;
    SaveConfiguration(ConfigurationFile);
    new(fer1,init(240,150,3,'O.K.','Mesaj',
    'Trebuie s† reporni€i programul pentru a beneficia de setarea f†cut†.'));
    fer1^.setattr(LittFont,5,Blue);
    fer1^.run;
    dispose(fer1,done);
  end;
 dispose(but1,done);
 dispose(but2,done);
 dispose(chk[1],done);
 dispose(chk[2],done);
 dispose(chk[3],done);
 dispose(fer,done);
end;


Function  TApp.TestIesire:boolean;
var fer1:PBorWindow2B;
    rasp:byte;
begin
 new(fer1,init(240,220,1,'Da','Nu','Mesaj','Dori€i s† p†r†si€i acest program ?'));
 fer1^.setattr(10,1,blue);
 rasp:=fer1^.run;
 dispose(fer1,done);
 TestIesire:=false;
 If rasp=1 then TestIesire:=true;
end;

Function TApp.Alege:byte;
const Butoane:array[1..3] of string=
      ('Manual','Teste verificare','Teste autoverificare');
var
  fer1:pwindow;
  buts:array[1..3] of pbutton;
  evw:tevent;
  f:word;iesire:byte;
begin
 iesire:=0;
 New(fer1,init(0,MaxY-199,200,140,'Selecteaza',2,true));
 fer1^.makezoom(1);fer1^.show;
 for f:=1 to 3 do
  begin
   new(buts[f],init(fer1,8,f*32,133+50,30,Butoane[f]));
   buts[f]^.show;
  end;
 repeat
  fer1^.move;
  GetEvent(evw);
  for f:=1 to 3 do if buts[f]^.clicked(evw) then iesire:=f;
 until fer1^.clicked(evw) or fer1^.outclicked(evw) or (iesire<>0);
 for f:=1 to 3 do dispose(buts[f],done);
 dispose(fer1,done);
 alege:=iesire;
end;

Function TApp.AlegeSetare:byte;
const Butoane:array[1..4] of string=
      ('Mod video','Paleta culori','Mouse','Interfata');
var
  fer1:pwindow;
  buts:array[1..4] of pbutton;
  evw:tevent;
  f:word;iesire:byte;
begin
 iesire:=0;
 New(fer1,init(2*BLung+3*BSp,MaxY-199-30,200,170,'Setare',2,true));
 fer1^.makezoom(1);fer1^.show;
 for f:=1 to 4 do
  begin
   new(buts[f],init(fer1,8,f*32,133+50,30,Butoane[f]));
   buts[f]^.show;
  end;
 repeat
  fer1^.move;
  GetEvent(evw);
  for f:=1 to 4 do if buts[f]^.clicked(evw) then iesire:=f;
 until fer1^.clicked(evw) or fer1^.outclicked(evw) or (iesire<>0);
 for f:=1 to 4 do dispose(buts[f],done);
 dispose(fer1,done);
 alegesetare:=iesire;
end;

{$F+}
PROCEDURE MUSIC1; EXTERNAL;{$L MUSIC1.OBJ}
PROCEDURE MUSIC2; EXTERNAL;{$L MUSIC2.OBJ}
{$F-}


Procedure TApp.BeginHelp;
var HelpApp:PManual;
    x,y:integer;
    SBDetect:boolean;
    Music : HSC_obj;
begin
 SBDetect:=false;
 if AdlibExists then SBDetect:=True;
 if GetMaxX=639 then begin x:=035;y:=05;end
                else begin x:=115;y:=70;end;
 HideBar;
 if Config.Sounds and SBDetect then
  begin
    Music.Init(0);
    Randomize;
    if random(100)<50 then Music.LoadMem (@MUSIC1)
                      else Music.LoadMem (@MUSIC2);
    Music.Start;
  end;

 new(HelpApp,init(x,y,570,460,2,'Info','Help.HTD',pag,Config.SystemMouseArrow,true));
 HelpApp^.run;
 dispose(HelpApp,done);

 if Config.Sounds and SBDetect then Music.Done;
 ShowBar;
end;

Procedure TApp.BeginProfesor;
Var profapp:PTestCompiler;
begin
 HideBar;
 new(profapp,init(80,60,'Profesor'));
 profapp^.run;
 dispose(profapp,done);
 ShowBar;
end;

Procedure TApp.BeginManual;
var manual:PManual;
    menu1:PMenuXMS;
    testlista:PLista;
    a1:integer;
    s:string;
    t:longint;
begin
 t:=memavail;
 new(menu1,init(40,340,'Manual'));
 menu1^.setitems(5,@Teme);
 menu1^.show(1);
 a1:=0;
 repeat
  getevent(ev);
  a1:=menu1^.run(ev);
 until a1<>0;
 if a1 = -1 then begin dispose(menu1,done);exit;end;

 new(testlista,InitHTD(350,390,Config.DocumentFiles,a1,'Selectati capitolul'));
 s:=testlista^.run;
 dispose(testlista,done);
 dispose(menu1,done);
 if s<>'' then
   begin
     HideBar;
     new(manual,init(80,60,639,479,0,'Manual',s,1,Config.SystemMouseArrow,Config.SaveBk));
     manual^.run;
     dispose(manual,done);
     ShowBar;
   end;
   {dec(t,memavail);if t<>0 then begin closegraph;writeln(t);halt;end;}
end;

Procedure TApp.BeginTeste;
var teste :PTeste;
    testlista:PLista;
    menu1,menu2:PMenuXMS;
    s:string;a1,a2:integer;
    t:longint;
begin
 t:=memavail;
 s:='Teste verificare';if auto then s:='Teste autoverificare';
 new(menu1,init(40,340,s));
 menu1^.setitems(5,@Teme);
 menu1^.show(1);
 a1:=0;
 repeat
  getevent(ev);
  a1:=menu1^.run(ev);
 until a1<>0;
 if a1 = -1 then begin dispose(menu1,done);exit;end;

 new(menu2,init(380,390,'Selectati nivelul'));
 menu2^.setitems(7,@Nivele);
 menu2^.show(1);
 a2:=0;
 repeat
  getevent(ev);
  a2:=menu2^.run(ev);
 until a2<>0;
 if a2 = -1 then begin dispose(menu2,done);dispose(menu1,done);exit;end;

 new(testlista,InitHTP(450,440,Config.ProblemFiles,a1,a2,'Selectati testul'));
 s:=testlista^.run;
 dispose(testlista,done);
 dispose(menu2,done);
 dispose(menu1,done);

 if s<>'' then
   begin
     HideBar;
     new(teste,init(100,70,s,Auto,Not Auto,Config.TestTimeOutSound,Config.SaveBk));
     teste^.run;
     dispose(teste,done);
     ShowBar;
   end;
  {dec(t,memavail);if t<>0 then begin closegraph;writeln(t);halt;end;}
end;


Constructor TApp.Init;
var f,g:word;
    mustsave:boolean;
begin
 mustsave:=false;
 ReadConfiguration(ConfigurationFile);
 if (not IsVESA) and (Config.VideMode>-1) then
   begin
    WriteLn;
    WriteLn(' Eroare : Configuratie incorecta');
    WriteLn(' Nu este prezenta extensia VESA BIOS, se va folosi modul VGA !');
    WriteLn(' Apasati orice tasta...');
    WriteLn(#7);
    ReadLn;
    Config.VideMode:=-1;mustsave:=true;
   end;
 OpenGraph(Config.VideMode);
 maxx:=getmaxx;maxy:=getmaxy;
 if maxx=799 then
   begin BLung:=148;BSpace:=30;Bsp:=10;end
   else begin BLung:=118;BSpace:=24;Bsp:=8;end;
 SetConfigPal(ConfigurationFile);
 OutTextXY(10,10,'Asteptati putin ...');
 if MustSave then SaveConfiguration(ConfigurationFile);

 if FileExist(Config.SystemBackGround) and (not Mode16) then
begin
 if not XMSInstalled then
   begin
     CloseGraph;
     writeln('Eroare XMS');
     halt(1);
   end;
 AllocExtMem(512,han);
 if XMSError>0 then
   begin
     CloseGraph;
     writeln('Insuficienta memorie extinsa sau sunteti in modul protejat');
     halt(1);
   end;
 LoadBMPinXMS(Config.SystemBackGround,han,0,pal);
 VideoScreenOff;RestoreImage2(0,0,han,0,pal);VideoScreenOn;
 FreeExtMem(han);end
else
begin
  SetFillStyle(SolidFill,DarkGray);Bar(0,0,getmaxx,getmaxy);
  setcolor(lightgray);
  for f:=0 to getmaxx do line(f*20,0,f*20,getmaxy);
  for f:=0 to getmaxy do line(0,f*20,getmaxx,f*20);
  setcolor(black);
  for f:=0 to getmaxx do line(f*20+2,0,f*20+2,getmaxy);
  for f:=0 to getmaxy do line(0,f*20+2,getmaxx,f*20+2);
end;

 InitMouse;
 SelectStdCursor(Config.SystemMouseArrow);
 ShowMouse;
 SetSenzitivity(Trunc(Config.MouseSenzitivity*0.75),Config.MouseSenzitivity,2);
 new(main,init(0,0,getmaxx,getmaxy,'VMA soft',1,false));
end;

Procedure TApp.InitBar(y:integer);
begin
 bary:=y;
 if Config.OS2Buttons
  then begin
    b1:=new(pos2button,init(main,0*BLung+1*BSp,MaxY-39,BLung,BSpace,mainbuts[1],3));
    b2:=new(pos2button,init(main,1*BLung+2*BSp,MaxY-39,BLung,BSpace,mainbuts[2],3));
    b3:=new(pos2button,init(main,2*BLung+3*BSp,MaxY-39,BLung,BSpace,mainbuts[3],3));
    b4:=new(pos2button,init(main,3*BLung+4*BSp,MaxY-39,BLung,BSpace,mainbuts[4],3));
    b5:=new(pos2button,init(main,4*BLung+5*BSp,MaxY-39,BLung,BSpace,mainbuts[5],3));
  end
  else begin
    b1:=new(pbutton,init(main,0*BLung+1*BSp,MaxY-39,BLung,BSpace,mainbuts[1]));
    b2:=new(pbutton,init(main,1*BLung+2*BSp,MaxY-39,BLung,BSpace,mainbuts[2]));
    b3:=new(pbutton,init(main,2*BLung+3*BSp,MaxY-39,BLung,BSpace,mainbuts[3]));
    b4:=new(pbutton,init(main,3*BLung+4*BSp,MaxY-39,BLung,BSpace,mainbuts[4]));
    b5:=new(pbutton,init(main,4*BLung+5*BSp,MaxY-39,BLung,BSpace,mainbuts[5]));
  end;
end;

Procedure TApp.ShowBar;
begin
 new(bara);
 hidemouse;
 getimage(0,bary,MaxX,bary+49,bara^);
 panou3d(0,MaxY-49,MaxX,MaxY);
 showmouse;
 b1^.show;b2^.show;b3^.show;b4^.show;b5^.show;
end;

Procedure TApp.HideBar;
begin
 hidemouse;
 putimage(0,bary,bara^,copyput);
 showmouse;
 dispose(bara);
end;

Procedure TApp.Run;
var iesire:boolean;
begin
 InitBar(Maxy-49);
 ShowBar;
 iesire:=false;
repeat
 getevent(ev);
 if b1^.clicked(ev) then
  begin
   b1^.select(red);
   case alege of
    1:BeginManual;
    2:BeginTeste(False);
    3:BeginTeste(True);
   end;
   b1^.deselect;
  end;
 if b2^.clicked(ev) then
    begin
      b2^.select(red);
      if PassCorrect(Config.ProfessorPassWord) then BeginProfesor;
      b2^.deselect;
    end;
 if b3^.clicked(ev) then
  begin
   b3^.select(red);
   case alegesetare of
    1:SelectVideo;
    2:EditeazaPaleta;
    3:ConfigMouse;
    4:ConfigInterface;
   end;
   b3^.deselect;
  end;
 if b4^.clicked(ev) then BeginHelp(1);
 if b5^.clicked(ev)or ((ev.tip=EvKbd) and (ev.scankey=Config.SystemExitKey))then
    begin
     b5^.select(red);
     Iesire:=TestIesire;
     b5^.deselect;
    end;
until Iesire;
end;

Destructor TApp.Done;
begin
 dispose(main,done);
 dispose(b1,done);
 dispose(b2,done);
 dispose(b3,done);
 dispose(b4,done);
 dispose(b5,done);
 HideBar;
 CloseGraph;
end;

var app:PApp;

begin
 new(app,init);
 app^.run;
 dispose(app,done);
end.

