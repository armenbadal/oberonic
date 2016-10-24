
MODULE OberonUnit;

IMPORT Oberon, Texts;

TYPE
  String* = ARRAY 128 OF CHAR;
  Test* = PROCEDURE() : BOOLEAN;
  Proc* = PROCEDURE(); 

  Case* = POINTER TO CaseDesc;
  CaseDesc = RECORD
    text : String;
    proc : Test;
	status : BOOLEAN
  END;

  Suite* = POINTER TO SuiteDesc;
  SuiteDesc = RECORD
    name : String;
    setUp, tearDown : Proc;
    cases : ARRAY 64 OF Case;
    all, passes, fails : INTEGER;
  END;

(**)
PROCEDURE NewSuite*(nm : String) : Suite;
VAR su : Suite;
BEGIN NEW(su); COPY(nm, su^.name);
  su^.setUp := NIL; su^.tearDown := NIL;
  su^.all := -1; su^.passes := 0; su^.fails := 0;
  RETURN su
END NewSuite;

(**)
PROCEDURE (s : Suite) SetUp*(pr : Proc);
BEGIN s^.setUp := pr
END SetUp;

(**)
PROCEDURE (s : Suite) TearDown*(pr : Proc);
BEGIN s^.tearDown := pr
END TearDown;

(**)
PROCEDURE (s : Suite) AddCase*(cs : Test; ds : String);
VAR es : Case;
BEGIN NEW(es); COPY(ds, es^.text); 
  es^.proc := cs; es^.status := TRUE;
  INC(s^.all); s^.cases[s^.all] := es
END AddCase;

(**)
PROCEDURE (s : Suite) Run*;
VAR k : INTEGER;
BEGIN
  FOR k := 0 TO s^.all DO
    IF s^.setUp # NIL THEN s^.setUp() END;
    s^.cases[k].status := s^.cases[k].proc();
    IF s^.cases[k].status THEN INC(s^.passes)
    ELSE INC(s^.fails) END;
    IF s^.tearDown # NIL THEN s^.tearDown() END
  END;
END Run;

(**)
PROCEDURE (s : Suite) Results*;
VAR
  w : Texts.Writer;
  k : INTEGER;
  e : Case;
BEGIN
  Texts.OpenWriter(w);
  Texts.WriteString(w, s^.name); Texts.WriteLn(w);
  Texts.WriteString(w, '-----'); Texts.WriteLn(w);
  (* Files.WriteNum(r, s^.passes); Files.Write(r, 20X);
  Files.WriteNum(r, s^.fails); Files.Write(r, 0AX); *)
  FOR k := 0 TO s^.all DO
    e := s^.cases[k];
    Texts.WriteString(w, e^.text); Texts.Write(w,09X);
    IF e^.status THEN Texts.WriteString(w, "PASS")
    ELSE Texts.WriteString(w, "FAIL") END;
    Texts.WriteLn(w)
  END;
  Texts.Append(Oberon.Log, w.buf)
END Results;

END OberonUnit.


