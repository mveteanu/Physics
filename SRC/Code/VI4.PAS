{$d+,l+,s+}
uses AppMCGA,VesaDRV,Graph,Mouse;

var app:PManual;

begin
 OpenGraph(VESA_800x600x256);
 setuniformpal;
 setfillstyle(solidfill,darkgray);bar(0,0,getmaxx,getmaxy);
 Initmouse;SelectStdCursor(arrow);Showmouse;

 new(app,init(115,70,570,460,2,'help.htd',1,Arrow,false));
 app^.run;
 dispose(app,done);

 CloseGraph;
end.


