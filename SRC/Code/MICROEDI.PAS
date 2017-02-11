uses Graph,Mouse,VesaDrv,Obj,MicroEDT;

var medit:PMicroEditor;
    main:pwindow;

begin
 opengraph(VESA_800x600x256);SetUniformPal;
 initmouse;showmouse;SetSenzitivity(trunc(180*0.75),100,2);
 new(main,init(0,0,getmaxx,getmaxy,'VMA soft',1,false));main^.show;


 new(medit,init(main,20,20,70,15,'test.txt'));
 medit^.run;
 medit^.done;

 dispose(main,done);
 CloseGraph;
end.
