{$X+,S+}
unit UTVEdit;

interface

uses Dos, Objects, Drivers, Memory, Views, Menus, Dialogs,
  StdDlg, MsgBox, App, Calc, Editors,
  DocComp,TestComp;

type
  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
                 constructor Init;
                 procedure   HandleEvent(var Event: TEvent); virtual;
                 procedure   InitMenuBar; virtual;
                 procedure   InitStatusLine; virtual;
                 procedure   OutOfMemory; virtual;
               end;

implementation

const
  HeapSize = 32 * (1024 div 16);

const
  cmCalculator = 101;
  cmShowClip   = 102;
  cmCompile    = 103;
  cmAbout      = 104;

var ClipWindow: PEditWindow;
    Fisier:string;
    Ext:string;

function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
var
  P: PWindow;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := New(PEditWindow, Init(R, FileName, wnNoNumber));
  if not Visible then P^.Hide;
  OpenEditor := PEditWindow(Application^.InsertWindow(P));
  Fisier:=FileName;
end;

constructor TEditorApp.Init;
var
  H: Word;
  R: TRect;
begin
  MaxHeapSize := HeapSize;
  inherited Init;
  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain]);
  EditorDialog := StdEditorDialog;
  ClipWindow := OpenEditor('', False);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
end;

procedure TEditorApp.HandleEvent(var Event: TEvent);

procedure FileOpen;
var
  FileName: FNameStr;
begin
  FileName :='*.*';
  if ExecuteDialog(New(PFileDialog, Init('*.*', 'Alegeti fisierul',
    '*.MAN = Manual  *.TST = Teste', fdOpenButton, 100)), @FileName) <> cmCancel then
    OpenEditor(FileName, True);
end;

procedure FileNew;
begin
  OpenEditor('', True);
end;

procedure ChangeDir;
begin
  ExecuteDialog(New(PChDirDialog, Init(cdNormal, 0)), nil);
end;

procedure ShowClip;
begin
  ClipWindow^.Select;
  ClipWindow^.Show;
end;

procedure Calculator;
begin
  InsertWindow(New(PCalculator, Init));
end;

procedure About;
begin
MessageBox('Compilatator de documente & teste'#13#13'         (c) VMA software',
            nil,mfInformation or mfOKButton);
end;

procedure Compile;
var nume:string;
    error:word;
begin
 Nume:=Copy(fisier,1,length(fisier)-4);
 Ext:=Copy(fisier,length(fisier)-3,length(fisier));
 If ext= '.MAN' then Error:=CompileDocFile(Nume) else
   If ext= '.TST' then Error:=CompileTestFile(Nume) else
      Error:=$FFFF;
 case error of
   0 : MessageBox('       Compilare reusita !',nil,mfInformation or mfOKButton);
   1 : MessageBox('Fisierul '+nume+ext+' este inexistent',nil,mfError or mfOKButton);
   2 : MessageBox('Posibile erori in fisierul '+fisier,nil,mfError or mfOKButton);
   3:  MessageBox('Fisier .GIF extern negasit'#13#10,nil,mfError or mfOKButton);
$FFFF: MessageBox('Tip de fisier necunoscut ',nil,mfError or mfOKButton);
 end;
end;

begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmOpen: FileOpen;
        cmNew: FileNew;
        cmChangeDir: ChangeDir;
        cmCalculator: Calculator;
        cmShowClip: ShowClip;
        cmCompile:Compile;
        cmAbout:About;
      else
        Exit;
      end;
  else
    Exit;
  end;
  ClearEvent(Event);
end;

procedure TEditorApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~isiere', hcNoContext, NewMenu(
      StdFileMenuItems(
      nil)),
    NewSubMenu('~E~ditare', hcNoContext, NewMenu(
      StdEditMenuItems(
      nil)),
    NewSubMenu('~C~auta', hcNoContext, NewMenu(
      NewItem('~G~aseste...', '', kbNoKey, cmFind, hcNoContext,
      NewItem('~I~nlocuieste...', '', kbNoKey, cmReplace, hcNoContext,
      NewItem('~R~epeta iar', '', kbNoKey, cmSearchAgain, hcNoContext,
      nil)))),
    NewSubMenu('~C~ompilare', hcNoContext, NewMenu(
      NewItem('~C~ompileaza', 'F9', kbF9, cmCompile, hcNoContext,
      nil)),
    NewSubMenu('~F~erestre', hcNoContext, NewMenu(
      StdWindowMenuItems(
      NewLine(
      NewItem('Ca~l~culator', '', kbNoKey, cmCalculator, hcNoContext,
      nil)))),
    NewSubMenu('~I~nformatii', hcNoContext, NewMenu(
      NewItem('~D~espre...', '', kbNoKey, cmAbout, hcNoContext,
      nil)),
    nil)))))))));
end;

procedure TEditorApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F2~ Salveaza', kbF2, cmSave,
      NewStatusKey('~F3~ Deschide', kbF3, cmOpen,
      NewStatusKey('~Alt-F3~ Inchide', kbAltF3, cmClose,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('~F9~ Compileaza', kbF9, cmCompile,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize,
      nil))))))),
    nil)));
end;

procedure TEditorApp.OutOfMemory;
begin
  MessageBox('Memorie insuficienta.',
    nil, mfError + mfOkButton);
end;

end.
