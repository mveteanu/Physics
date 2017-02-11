uses Crt,Fonts,VesaDrv,Graph,GraphCrt;

var MCrt:PCrt;
    f:integer;

begin
 opengraph(VESA_800x600x256);

 New(MCrt,Init(100,100,80,25,White,Black));
 for f:=1 to 27 do MCrt^.writeln(MCrt^.inttostr(f));
 MCrt^.write('Acesta este un program ca-n modul text dar e facut in modul grafic.');
 MCrt^.writeLn('');
 MCrt^.write(' - End - ');
 Dispose(MCrt,Done);

 ReadLn;closegraph;
end.
