unit cfgintf;

interface

uses graph,obj,obj3,events,Ukbd,fonts,setari;

Type PConfigInterface=^TConfigInterface;
     TConfigInterface=object
         fileconfig:string;
         Constructor Init(x,y:integer;filename:string);
         Procedure   Run;
         Destructor  Done;
         private
         evw:tevent;
         fer1:pwindow;
         but1,but2:pbutton;
         chk1,chk2:pchkbox;
         fr1:PBorWindow1B;
         iesire,but1pressed,but2pressed:boolean;
     end;

implementation

Constructor TConfigInterface.Init;
begin
 new(fer1,init(x,y,300,170,'Setare interfata',2,true));fer1^.show;
 new(chk1,init(fer1,20,40,0,Config.OS2Buttons,'Bara de START cu butoane OS2'));chk1^.show;
 new(chk2,init(fer1,20,70,0,Config.Sounds,    'Sunete                      '));chk2^.show;
 new(but1,init(fer1,45 ,130,60,20,'O.K.'));but1^.show;
 new(but2,init(fer1,195,130,60,20,'Cancel'));but2^.show;

 fileconfig:=filename;
 iesire:=false;
 but1pressed:=false;
 but2pressed:=false;
end;

Procedure TConfigInterface.Run;
begin
 repeat
   fer1^.move;
   GetEvent(evw);
   if chk1^.clicked(evw) then chk1^.toggle;
   if chk2^.clicked(evw) then chk2^.toggle;
   if but1^.clicked(evw) then begin iesire:=true;but1pressed:=true;end;
   if but2^.clicked(evw) then begin iesire:=true;but2pressed:=true;end;
   if fer1^.clicked(evw) or (evw.scankey=kbesc) then begin iesire:=true;but2pressed:=true;end;
 until iesire;

 if but1pressed then
   begin
    Config.OS2Buttons:=chk1^.chkchecked;
    Config.Sounds:=chk2^.chkchecked;
    SaveConfiguration(fileconfig);
    new(fr1,init(320,250,3,'O.K.','Mesaj',
    'Trebuie s† reporni€i programul pentru a beneficia de setarea f†cut†.'));
    fr1^.setattr(LittFont,5,Blue);
    fr1^.run;
    dispose(fr1,done);
   end;

end;

Destructor TConfigInterface.Done;
begin
 dispose(fer1,done);
 dispose(but1,done);
 dispose(but2,done);
 dispose(chk1,done);
 dispose(chk2,done);
end;

end.



