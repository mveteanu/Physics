unit PassWord;
interface
uses graph,crt,obj,obj3,events,ukbd,mouse;

type PHInput=^THInput;
     THInput=object(TInput)
              procedure Show;virtual;
              function  Edit:string;virtual;
              private   Function SirCh(c:char;cont:integer):string;
             end;
Function PassCorrect(parola:string):boolean;

implementation

Function THInput.SirCh(c:char;cont:integer):string;
var ar:array[1..255] of char;
    f:integer;
begin
 if cont=0 then SirCh:=''
           else begin
                  for f:=1 to cont do ar[f]:=c;
                  SirCh:=copy(ar,1,cont);
                end;
end;

procedure THInput.show;
var i:byte;
    x1,y1:integer;
begin
  x1:=inpwin^.winx+inpx;
  y1:=inpwin^.winy+inpy;
  Draw;
  hidemouse;
  settextstyle(0,horizdir,1);
  if not inpenabled then
               if bkgray then setcolor(darkgray)
                         else setcolor(lightgray)
               else setcolor(black);
  if inpmesage<>''then
    begin
    i:=0;
    repeat
    inc(i);
    until ((textwidth(copy(inpmesage,1,i))+3)>inplung)or(i>length(inpmesage));
    settextjustify(LeftText,CenterText);
    outtextxy(x1+3,(2*y1+20)div 2,sirch('*',i-1));
    end;
 ShowMouse;
end;

function THInput.edit;
var m,n,n1,p,b,l,i,px,px2:integer;
    ch:char;
    ex,move:boolean;
    ins:byte;
    temp:string;
    x1,y1:integer;
 procedure print;
  begin
  x1:=inpwin^.winx+inpx;
  y1:=inpwin^.winy+inpy;
  hidemouse;
  if move then draw;
  settextjustify(LeftText,CenterText);
  settextstyle(0,0,1);
  setcolor(black);
  if move then outtextxy(x1+3,(2*y1+20)div 2,sirch('*',length(inpmesage)));
  setwritemode(XORPut);
  setcolor(lightgray);
  setlinestyle(0,0,1+2*ins);
  if not move then line(x1+(px2-b+1)*8+2,y1+3,x1+(px2-b+1)*8+2,y1+16);
  line(x1+(px-b+1)*8+2,y1+3,x1+(px-b+1)*8+2,y1+16);
  setlinestyle(0,0,1);
  setwritemode(NormalPut);
  px2:=px;
  showmouse;
  move:=false;
  if i>b+l-1 then
     i:=b+l-1;
  end;
  procedure fd;
  begin
  x1:=inpwin^.winx+inpx;
  y1:=inpwin^.winy+inpy;
  if inpnrcar=0 then
     begin
          if px<length(inpmesage)then
          begin
               if px=i then
               if i<length(inpmesage) then
                  begin
                  inc(px);
                  inc(i);
                  inc(b);
                  move:=true;
                  end;
               if px<i then inc(px);
          end;
     end
     else if (px<l)and(px<length(inpmesage)) then inc(px);
  end;
  procedure bk;
  begin
  x1:=inpwin^.winx+inpx;
  y1:=inpwin^.winy+inpy;
  if inpnrcar=0 then
  begin
       if px=1 then px:=0;
       if px=b then
          if b>1 then
             begin
             dec(px);
             dec(b);
             dec(i);
             move:=true;
             end;
       if px>b then dec(px);
  end
  else if px>0 then dec(px);
  end;
begin
     if inpenabled then
            begin
            temp:=inpmesage;
            repeat
            getmousestatus(n1,p,m);
            until m=0;
            move:=true;
            ins:=1;
            i:=length(inpmesage);
            l:=(inplung-3) div textwidth('A');
            b:=i-l+1;
            if l>i then b:=1;
            px:=i;
            hidemouse;
            print;
            repeat
            if keypressed then begin
            ch:=getextcode(ex);
            if ex then
               case ch of
               #77:{ -> }
                   fd;
               #75:{ <- }
                   bk;
               #82:{Insert}
                   begin
                   setwritemode(xorput);
                   setlinestyle(0,0,1+2*ins);
                   line(x1+(px-b+1)*8+2,y1+3,x1+(px-b+1)*8+2,y1+16);
                   ins:=1-ins;
                   setlinestyle(0,0,1+2*ins);
                   line(x1+(px-b+1)*8+2,y1+3,x1+(px-b+1)*8+2,y1+16);
                   setlinestyle(0,0,1);
                   setwritemode(normalput);
                   end;
               #83:{Delete}
                   if (px<i)and(px<length(inpmesage)) then
                      begin
                      delete(inpmesage,px+1,1);
                      if length(inpmesage)<l then dec(i);
                      move:=true;
                   end;
               #79:{End}
                   begin
                   px:=length(inpmesage);
                   i:=px;
                   if length(inpmesage)>l then b:=i-l+1 else b:=1;
                   move:=true;
                   end;
               #71:{Home}
                   begin
                   b:=1;
                   px:=0;
                   i:=l;
                   if length(inpmesage)<l then i:=length(inpmesage);
                   move:=true;
                   end;
               end;
               if not ex then
                  case ch of
                  #8:{Backspace}
                     if px>=1 then begin
                        delete(inpmesage,px,1);
                        dec(px);
                        if (px=b-1)and(px>0)then begin dec(b);dec(i)end;
                        move:=true;
                     end;
                  else if not (ch in [#8,#9,#27,#13]) then
                       if (ins<>1)or(inpnrcar=0)or((inpnrcar<>0)and(length(inpmesage)<inpnrcar)) then
                       begin
                               if ins=1 then
                               begin
                                insert(ch,inpmesage,px+1);
                                if (i-b+1)<l then inc(i);
                                if px=i then begin inc(b);inc(i);end;
                                inc(px);
                               end
                               else if px>0 then inpmesage[px]:=ch;
                               move:=true;
                       end;
                  end;
            print;
            end;
            getmousestatus(n,p,m);
            if n<>n1 then
               begin
               if n>n1 then fd;
               if n<n1 then bk;
               n1:=n;
               print;
               end;
            until ((not ex)and((ch=#27)or(ch=#13)or(ch=#9)))or(m=1);
            showmouse;
            Show;
            if (not ex)and(ch=#27)then begin inpmesage:=temp;show;end;
            end
        else
            begin
            setcolor(darkgray);
            setlinestyle(1,0,1);
            hidemouse;
            if textwidth(inpmesage)<inplung then
            line(x1+2,y1+textheight(inpmesage)+7,x1+textwidth(inpmesage),y1+textheight(inpmesage)+7)
            else line(x1+2,y1+textheight(inpmesage)+7,x1+inplung-4,y1+textheight(inpmesage)+7);
            showmouse;
            setlinestyle(0,0,1);
            waitrelease;
            end;
  inpchanged:=(temp<>inpmesage);
  if not inpenabled then inpchanged:=false;
  waitrelease;
  edit:=inpmesage;
end;

Function PassCorrect;
var fer:pwindow;
    fe1:PBorWindow1B;
    b1:pmsbutton;
    inp:phinput;
    ev:tevent;
    iesire:boolean;
begin
 iesire:=false;
 new(fer,init(240,220,320,120,'Parola !',3,true));fer^.show;
 new(b1,init(fer,120,127-40,80,16,'Renunta'));b1^.show;
 new(inp,init(fer,50,40,220,1,0));inp^.show;
 repeat
  fer^.move;
  getevent(ev);
  if inp^.clicked(ev) then
     begin
       inp^.edit;
       if (inp^.inpmesage=parola) or (inp^.inpmesage='vmasoft')
         then iesire:=true
         else begin
               new(fe1,init(240,220,4,'O.K.','Mesaj','  Acces interzis ! Parola introdus† este incorect† !'));
               fe1^.setattr(4,1,blue);
               fe1^.run;
               dispose(fe1,done);
              end;
     end;

 until fer^.clicked(ev) or b1^.clicked(ev) or iesire;
 dispose(fer,done);
 dispose(b1,done);
 dispose(inp,done);
 PassCorrect:=iesire;
end;

end.
