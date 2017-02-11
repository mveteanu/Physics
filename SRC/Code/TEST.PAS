USES PLAYHSC,SB,CRT;

VAR
  Music : HSC_obj;


{$F+}
PROCEDURE MUSIC1; EXTERNAL;{$L MUSIC1.OBJ}
PROCEDURE MUSIC2; EXTERNAL;{$L MUSIC2.OBJ}
{$F-}


PROCEDURE WaitKey;
VAR
  Dummy : CHAR;
BEGIN
  REPEAT UNTIL KeyPressed;
  WHILE KeyPressed DO Dummy := ReadKey;
END;

BEGIN
  if SBProDetect or SB16Detect then begin sound(1000);delay(100);nosound;end;
  Music.Init(0);

  Randomize;
  if random(100)<50 then Music.LoadMem (@MUSIC1)
                      else Music.LoadMem (@MUSIC2);
  Music.Start;
  WaitKey;
  Music.Done;
END.
