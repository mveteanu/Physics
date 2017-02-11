{$d+,l+,s+}
uses AppMCGA,VesaDrv,Graph,Mouse,ViewHTP,HTPComp;

Var   app:PTestCompiler;

begin
 OpenGraph(VGA_640x480x16);
 setuniformpal;
 setfillstyle(solidfill,darkgray);bar(0,0,getmaxx,getmaxy);
 Initmouse;Showmouse;

 new(app,init(12,40,'Profesor'));
 app^.run;
 dispose(app,done);

 CloseGraph;
end.

