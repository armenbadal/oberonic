
MODULE Test4;

IMPORT Texts, Oberon;

TYPE
  Value*   = POINTER TO ValueDesc;
  Pair*    = POINTER TO PairDesc;
  Object*  = POINTER TO ObjectDesc;
  Array*   = POINTER TO ArrayDesc;
  String*  = POINTER TO StringDesc;
  Number*  = POINTER TO NumberDesc;
  Boolean* = POINTER TO BooleanDesc;

  ValueDesc = RECORD
    next : Value
  END;

  PairDesc = RECORD
    key- : String;
    value- : Value;
    next : Pair;
  END;

  ObjectDesc = RECORD(ValueDesc)
    elems, ep : Pair
  END;

  ArrayDesc = RECORD(ValueDesc)
    count- : INTEGER;
    elems : POINTER TO ARRAY OF Value
  END;

  StringDesc = RECORD(ValueDesc)
    data : ARRAY 256 OF CHAR
  END;

  NumberDesc = RECORD(ValueDesc)
    value- : REAL
  END;

  BooleanDesc = RECORD(ValueDesc)
    value- : BOOLEAN
  END;

VAR
  v0, v1, v2, v3, v4 : Value; (* Test *)
  W : Texts.Writer;
  indent : INTEGER;


(* Constructors *)
PROCEDURE NewNull() : Value;
VAR val : Value;
BEGIN NEW(val); val^.next := NIL;
  RETURN val
END NewNull;

PROCEDURE NewObject*() : Object;
VAR obj : Object;
BEGIN NEW(obj); obj^.elems := NIL;
  NEW(obj^.ep); obj^.ep^.key := NIL; obj^.ep^.value := NIL;
  RETURN obj
END NewObject;

PROCEDURE (obj : Object) add*(k : String; v : Value);
VAR el, p : Pair;
BEGIN
  NEW(el); el^.key := k; el^.value := v;
  IF obj^.elems = NIL THEN
    obj^.elems := el
  ELSE
    p := obj^.elems;
    WHILE p^.next # NIL DO p := p^.next END;
    p^.next := el
  END
END add;

PROCEDURE (obj : Object) Reset*;
BEGIN obj^.ep^.next := obj^.elems
END Reset;

PROCEDURE (obj : Object) HasNext*() : BOOLEAN;
BEGIN RETURN obj^.ep^.next # NIL
END HasNext;

PROCEDURE (obj : Object) Next*() : Pair;
BEGIN obj^.ep := obj^.ep^.next;
  RETURN obj^.ep
END Next;

PROCEDURE NewArray*(sz : INTEGER) : Array;
VAR arr : Array;
BEGIN NEW(arr); arr^.count := sz;
  NEW(arr^.elems, arr^.count);
  RETURN arr
END NewArray;

PROCEDURE (arr : Array) set*(inx : INTEGER; val : Value);
BEGIN arr^.elems^[inx] := val
END set;

PROCEDURE (arr : Array) get*(inx : INTEGER) : Value;
BEGIN RETURN arr^.elems^[inx]
END get;

PROCEDURE NewNumber*(rv : REAL) : Number;
VAR num : Number;
BEGIN NEW(num); num^.value := rv;
  RETURN num
END NewNumber;

PROCEDURE NewString*(sr : ARRAY OF CHAR) : String;
VAR str : String;
BEGIN NEW(str); COPY(sr, str^.data);
  RETURN str;
END NewString;

PROCEDURE NewBoolean*(vl : BOOLEAN) : Boolean;
VAR bol : Boolean;
BEGIN NEW(bol); bol^.value := vl;
  RETURN bol
END NewBoolean;

(**)
PROCEDURE (val : Value) Print*(VAR w : Texts.Writer);
BEGIN Texts.WriteString(w, "null")
END Print;

PROCEDURE (bol : Boolean) Print*(VAR w : Texts.Writer);
BEGIN
  IF bol^.value THEN Texts.WriteString(w, "true")
  ELSE Texts.WriteString(w, "false") END;
END Print;

PROCEDURE (num : Number) Print*(VAR w : Texts.Writer);
BEGIN Texts.WriteReal(w, num^.value, 10)
END Print;

PROCEDURE (str : String) Print*(VAR w : Texts.Writer);
BEGIN Texts.Write(w, 22X);
  Texts.WriteString(w, str^.data);
  Texts.Write(w, 22X)
END Print;

PROCEDURE (arr : Array) Print*(VAR w : Texts.Writer);
VAR k : INTEGER; vp : Value;
BEGIN Texts.WriteString(w, "[");
  IF arr^.count # 0 THEN
    vp := arr.get(0); vp.Print(w);
    FOR k := 1 TO arr^.count - 1 DO
      Texts.WriteString(w, ", ");
      vp := arr.get(k); vp.Print(w)
	END
  END;
  Texts.WriteString(w, "]")
END Print;

PROCEDURE (obj : Object) Print*(VAR w : Texts.Writer);
VAR ep : Pair; s : INTEGER;
BEGIN Texts.WriteString(w, "{"); Texts.WriteLn(W);
  indent := indent + 4;
  obj.Reset;
  IF obj.HasNext() THEN
    ep := obj.Next();
    FOR s := 1 TO indent DO Texts.Write(W, ' ') END;
    ep^.key.Print(w);
    Texts.WriteString(w, " : ");
    ep^.value.Print(w);
    WHILE obj.HasNext() DO
      Texts.WriteString(w, ", ");  Texts.WriteLn(W);
      FOR s := 1 TO indent DO Texts.Write(W, ' ') END;
      ep := obj.Next();
      ep^.key.Print(w);
      Texts.WriteString(w, " : ");
      ep^.value.Print(w)
    END
  END;
  Texts.WriteLn(W); indent := indent - 4;
  FOR s := 1 TO indent DO Texts.Write(W, ' ') END;
  Texts.WriteString(w, "}")
END Print;


BEGIN indent := 0;
  v0 := NewNumber(3.14);

  v1 := NewString("Text");

  v2 := NewArray(2);
  v2(Array).set(0, v0);
  v2(Array).set(1, v1);

  v3 := NewObject();
  v3(Object).add(NewString("k0"),
		 NewBoolean(TRUE));
  v3(Object).add(NewString("k1"),
		 v2);

  v4 := NewObject();
  v4(Object).add(NewString("e2"), NewNull());
  v4(Object).add(NewString("e0"), v3);
  v4(Object).add(NewString("e1"), NewBoolean(FALSE));

  Texts.OpenWriter(W);
(*
  v0.Print(W); Texts.WriteLn(W);
  v1.Print(W); Texts.WriteLn(W);
  v2.Print(W); Texts.WriteLn(W);
*)
  v3.Print(W); Texts.WriteLn(W);
  (* v3.Print(W); Texts.WriteLn(W); *)
  Texts.Append(Oberon.Log, W.buf)
END Test4.

