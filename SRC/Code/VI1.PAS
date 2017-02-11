{$d+,l+,s+}
uses AppMCGA,VesaDRV,Graph,Mouse,ViewHTD;

var app:PManual;

begin
 OpenGraph(VESA_640x480x256);
 setuniformpal;
 setfillstyle(solidfill,darkgray);bar(0,0,getmaxx,getmaxy);
 Initmouse;SelectStdCursor(arrow2);Showmouse;

 new(app,init(12,12,640,480,0,'VMA soft','cap1.htd',1,Arrow2,false));
 app^.run;
 dispose(app,done);

 CloseGraph;
end.


