unit Setari;
interface
uses AppMcga,Graph,VesaDrv,Mouse,Ukbd;


type TConfig=record
               HeaderCfg         : string[18];
               OS2Buttons        : boolean;
               Sounds            : boolean;
               Pal               : virtualpal;
               SaveBk            : boolean;
               MouseSenzitivity  : word;
               VideMode          : integer;
               SystemBackground  : string[36];
               SystemMouseArrow  : byte;
               SystemExitKey     : word;
               ProfessorPassWord : string[25];
               TestTimeLimit     : boolean;
               TestTimeOutSound  : boolean;
               DocumentFiles     : string[5];
               ProblemFiles      : string[5];
             end;

var Config:TConfig;

procedure ReadConfiguration(filename:string);
procedure SaveConfiguration(filename:string);
procedure SaveDefaultConfig(filename:string);
procedure ReadConfigPal(filename:string;var pal:virtualpal);
procedure SetConfigPal(filename:string);

implementation

procedure ReadConfiguration(filename:string);
var f:file of TConfig;
begin
if not FileExist(filename) then exit;
assign(f,filename);reset(f);
read(f,config);
close(f);
end;


procedure ReadConfigPal(filename:string;var pal:virtualpal);
var f:file of TConfig;
    conftemp:TConfig;
begin
if not FileExist(filename) then
 begin setuniformpal;getallpal(pal);exit;end;
assign(f,filename);reset(f);
read(f,conftemp);
close(f);
move(conftemp.pal,pal,sizeof(virtualpal))
end;


procedure SetConfigPal;
var pal:virtualpal;
    f:integer;
begin
 ReadConfigPal(filename,pal);
 if Mode16 then for f:=0 to 15 do setpalette(f,f);
 SetAllPal(Pal);
end;

procedure SaveConfiguration(filename:string);
var f:file of TConfig;
    i:integer;
begin
 if Mode16 then for i:=0 to 15 do setpalette(i,i);
 GetAllPal(Config.Pal);
assign(f,filename);rewrite(f);
write(f,config);
close(f);
end;

procedure SaveDefaultConfig(filename:string);
var f:file of TConfig;
    Default:TConfig;
begin
 LoadPal('Uniform.pal',Default.Pal);
 Default.HeaderCfg         :='Configuration File';
 Default.OS2Buttons        := False;
 Default.Sounds            := True;
 Default.SaveBk            := True;
 Default.MouseSenzitivity  := 120;
 Default.VideMode          := VGA_640x480x16;
 Default.SystemBackground  := 'TIGRU2.BMP';
 Default.SystemMouseArrow  := Arrow;
 Default.SystemExitKey     := KbAltF4;
 Default.ProfessorPassWord := 'Marian';
 Default.TestTimeLimit     := True;
 Default.TestTimeOutSound  := True;
 Default.DocumentFiles     := '*.HTD';
 Default.ProblemFiles      := '*.HTP';
 assign(f,filename);rewrite(f);
 write(f,Default);
 close(f);
end;

begin
 Config.HeaderCfg         :='Configuration File';
 Config.OS2Buttons        := False;
 Config.Sounds            := True;
 Config.SaveBk            := True;
 Config.MouseSenzitivity  := 120;
 Config.VideMode          := VGA_640x480x16;
 Config.SystemBackground  := 'TIGRU2.BMP';
 Config.SystemMouseArrow  := Arrow;
 Config.SystemExitKey     := KbAltF4;
 Config.ProfessorPassWord := 'Marian';
 Config.TestTimeLimit     := True;
 Config.TestTimeOutSound  := True;
 Config.DocumentFiles     := '*.HTD';
 Config.ProblemFiles      := '*.HTP';
end.

