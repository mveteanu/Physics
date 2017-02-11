var f,g:file of byte;
var i:word;a:byte;b:byte;
begin
assign(f,'fig13.bmp');reset(f);
assign(g,'fig13c.bmp');rewrite(g);
b:=255;
while not eof(f) do begin
 read(f,a);
 if ((a=1) and (filepos(f)>$400)) then write(g,b) else write(g,a);
end;
close(f);close(g);
end.
