{$d+,l+,s+}
uses AppMCGA,VesaDrv,Graph,Mouse,ViewHTP;

Const TimeLimit=true;
      Sound=true;
Var   app:PTeste;

begin
 OpenGraph(VGA_640x480x16);
 setuniformpal;
 setfillstyle(solidfill,darkgray);bar(0,0,getmaxx,getmaxy);
 Initmouse;Showmouse;

 new(app,init(80,30,'test1.htp',true,TimeLimit,Sound,false));
 app^.run;
 app^.done;

 CloseGraph;
end.

