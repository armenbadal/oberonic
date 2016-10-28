
MODULE Test4;

IMPORT Texts, Oberon;

TYPE
  Value*  = POINTER TO ValueDesc;
  Pair*   = POINTER TO PairDesc;
  Object* = POINTER TO ObjectDesc;
  Array*  = POINTER TO ArrayDesc;
  String* = POINTER TO StringDesc;
  Number* = POINTER TO NumberDesc;

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
    value : REAL
  END;


VAR
  v0, v1, v2, v3 : Value;
  W : Texts.Writer;


(* Constructors *)
PROCEDURE NewObject*() : Object;
VAR obj : Object;
BEGIN NEW(obj);
   obj^.elems := NIL;
  NEW(obj^.ep);
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


(**)
PROCEDURE (val : Value) Print*(VAR w : Texts.Writer);
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
VAR ep : Pair;
BEGIN Texts.WriteString(w, "{");
  obj.Reset;
  IF obj.HasNext() THEN
    ep := obj.Next();
    ep^.key.Print(w);
    Texts.WriteString(w, " : ");
    ep^.value.Print(w);
    WHILE obj.HasNext() DO
      Texts.WriteString(w, ", ");
      ep := obj.Next();
      ep^.key.Print(w);
      Texts.WriteString(w, " : ");
      ep^.value.Print(w)
    END
  END;
  Texts.WriteString(w, "}")
END Print;


BEGIN
  v0 := NewNumber(3.14);
  v1 := NewString("Text");
  v2 := NewArray(2); v2(Array).set(0, v0); v2(Array).set(1, v1);
  v3 := NewObject(); v3(Object).add(NewString("k0"), v1);
    v3(Object).add(NewString("k1"), v2);

  Texts.OpenWriter(W);
  v0.Print(W); Texts.WriteLn(W);
  v1.Print(W); Texts.WriteLn(W); 
  v2.Print(W); Texts.WriteLn(W);
  v3.Print(W); Texts.WriteLn(W);
  Texts.Append(Oberon.Log, W.buf)
END Test4.

