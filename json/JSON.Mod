
MODULE JSON;

IMPORT Texts, Console;

CONST
  (* Tokens *)
  xUnknown    = 0;
  xLeftBrack  = 1; 
  xRightBrack = 2;
  xLeftBrace  = 3;
  xRightBrace = 4;
  xColon      = 5; 
  xComma      = 6;
  xString     = 7;
  xNumber     = 8;
  xTrue       = 9;
  xFalse      = 10;
  xNull       = 11;
  xEof        = 12;

  (* Object types *)
  vString = 'S';
  vNumber = 'R'; 
  vObject = 'O';
  vArray  = 'A';
  vTrue   = 'T';
  vFalse  = 'F';
  vNull   = 'N';

TYPE
  String* = POINTER TO ARRAY OF CHAR;

  Object* = POINTER TO ObjectDesc;
  Pair*   = POINTER TO PairDesc;
  Array*  = POINTER TO ArrayDesc;
  Value*  = POINTER TO ValueDesc;
  

  ObjectDesc = RECORD
    elems, ep : Pair
  END;

  PairDesc = RECORD
    key* : String;
    val* : Value;
    next : Pair
  END;

  ArrayDesc = RECORD
    count : INTEGER;
    elems : POINTER TO ARRAY OF Value
  END;

  ValueDesc = RECORD
    kind : CHAR;
    str : String;
    num : REAL;
    obj : Object;
    arr : Array;
    next : Value;
  END;


VAR
  text : Texts.Text;
  reader : Texts.Reader;
  ch : CHAR;
  string : String;
  number : REAL;
  lookahead : SHORTINT;

  jsontree : Object;


(* AST *)
PROCEDURE (obj : Object) reset;
BEGIN NEW(obj^.ep);
  obj^.ep^.next := obj^.elems
END reset;

PROCEDURE (obj : Object) hasNext() : BOOLEAN;
BEGIN RETURN obj^.ep # NIL
END hasNext;

PROCEDURE (obj : Object) next() : Pair;
BEGIN obj^.ep := obj^.ep^.next;
  RETURN obj^.ep
END next;

PROCEDURE (arr : Array) set(inx : INTEGER; val : Value);
BEGIN arr^.elems^[inx] := val
END set;

PROCEDURE (arr : Array) get(inx : INTEGER) : Value;
BEGIN RETURN arr^.elems^[inx]
END get;

PROCEDURE NewNumber*(nm : REAL) : Value;
VAR val : Value;
BEGIN NEW(val); val^.kind := vNumber;
  val^.num := nm;
  RETURN val
END NewNumber;

PROCEDURE NewString*(sr : ARRAY OF CHAR) : Value;
VAR val : Value;
BEGIN NEW(val); val^.kind := vString;
  NEW(val^.str, LEN(sr)); COPY(sr, val^.str^);
  RETURN val
END NewString;

PROCEDURE NewArray(sz : INTEGER) : Value;
VAR ar : Array; val : Value;
BEGIN NEW(ar); ar^.count := sz; 
  NEW(ar^.elems, ar^.count);
  NEW(val); val^.kind := vArray;
  val^.arr := ar;
  RETURN val
END NewArray;


(* Scanner *)
(* real numbers *)
PROCEDURE scanNumber() : REAL;
VAR
  minus : BOOLEAN;
  value : REAL;
  ce : INTEGER;
  expo : REAL;

BEGIN
  minus := FALSE;
  value := 0.0;
  ce := 1;
  expo := 1.0;

  IF ch = '-' THEN
    minus := TRUE;
    Texts.Read(reader, ch)
  END;

  IF (ch >= "0") & (ch <= "9") THEN
    IF ch = "0" THEN
      Texts.Read(reader, ch)
    ELSE
      WHILE (ch >= "0") & (ch <= "9") DO
        value := value * 10 + (ORD(ch) - ORD("0"));
        Texts.Read(reader, ch)
      END 
    END;

    IF ch = '.' THEN
      Texts.Read(reader, ch);
      WHILE (ch >= "0") & (ch <= "9") DO
        value := value * 10 + (ORD(ch) - ORD("0"));
        ce := ce * 10;
		Texts.Read(reader, ch)
      END;
      value := value / ce
    END;

    IF minus THEN value := -value END;
    minus := FALSE;

    IF (ch = 'e') OR (ch = 'E') THEN
        Texts.Read(reader, ch);
        IF ch = '-' THEN
          minus := TRUE;
		  Texts.Read(reader, ch)
        ELSIF ch = '+' THEN
		  Texts.Read(reader, ch)
        END;

        ce := 0;
        WHILE (ch >= "0") & (ch <= "9") DO
          ce := ce * 10 + (ORD(ch) - ORD("0"));
	      Texts.Read(reader, ch)
        END;
    END;

    WHILE ce > 0 DO
      IF minus THEN expo := expo / 10
      ELSE expo := expo * 10 END;
      DEC(ce)
    END;
    value := value * expo;
  END;

  RETURN value
END scanNumber;

(* string - \"[^\"]*\" *)
PROCEDURE scanString() : String;
VAR str : String;
  buf : ARRAY 256 OF CHAR;
  len : INTEGER;
BEGIN
  len := 0;
  Texts.Read(reader, ch);
  WHILE ch # 22X DO 
    buf[len] := ch;
    INC(len);
    Texts.Read(reader, ch)
  END;
  buf[len] := 0X;
  Texts.Read(reader, ch);

  NEW(str, len + 1);
  COPY(buf, str^);

  RETURN str
END scanString;

(**)
PROCEDURE scan;
BEGIN
  (* skip spaces *)
  WHILE ~reader.eot & (ch <= " ") DO
    Texts.Read(reader, ch)
  END;
  IF ch = 22X THEN
    string := scanString(); lookahead := xString
  ELSIF (ch = "-") OR ((ch >= "0") & (ch <= "9")) THEN
    number := scanNumber(); lookahead := xNumber
  ELSE
    CASE ch OF
      "{" : lookahead := xLeftBrace
    | "}" : lookahead := xRightBrace
    | "[" : lookahead := xLeftBrack
    | "]" : lookahead := xRightBrack
    | ":" : lookahead := xColon
    | "," : lookahead := xComma
    | 0X  : lookahead := xEof
    ELSE lookahead := xUnknown
    END;
    Texts.Read(reader, ch)
  END
END scan;

(* Parser *)
PROCEDURE Parse*(name : ARRAY OF CHAR);
  PROCEDURE match(exp : SHORTINT);
  BEGIN
    IF lookahead = exp THEN scan
    ELSE (* syntax error *)
    END
  END match;

  PROCEDURE^ parseObject() : Object;
  PROCEDURE^ parseArray() : Array;

  PROCEDURE parseValue() : Value;
  VAR val : Value;
  BEGIN
    NEW(val);
    CASE lookahead OF
      xString : val^.kind := vString;
                val^.str := string;
                scan
    | xNumber : val^.kind := vNumber;
                val^.num := 0.0;
                scan
    | xLeftBrace : val^.kind := vObject;
                   val^.obj := parseObject()
    | xLeftBrack : val^.kind := vArray;
                   val^.arr := parseArray()
    | xTrue, xFalse, xNull : scan
    ELSE (* syntax error *)
    END;
    RETURN val
  END parseValue;

  PROCEDURE parseArray() : Array;
  VAR arr : Array;
    vl, vi : Value;
    k : INTEGER;
  BEGIN
    NEW(arr); arr^.count := 0;

    match(xLeftBrack);
    vl := parseValue();
    INC(arr^.count);
    vi := vl;
    WHILE lookahead = xComma DO
      match(xComma);
      vi^.next := parseValue();
      INC(arr^.count);
      vi := vi^.next
    END;
    match(xRightBrack);

    NEW(arr^.elems, arr^.count);
    vi := vl;
    FOR k := 0 TO arr^.count - 1 DO
      arr^.elems[k] := vi;
      vi := vi^.next;
    END;

    RETURN arr
  END parseArray;

  PROCEDURE parseObject() : Object;
  VAR obj : Object; e, p : Pair; 
  BEGIN
    match(xLeftBrace);
    IF lookahead # xRightBrace THEN
      NEW(e);
      e^.key := string;
      match(xString);
      match(xColon);
      e^.val := parseValue();
      NEW(obj);
	  obj^.elems := e;
	  obj^.ep := obj^.elems;
      p := obj^.elems;
      WHILE lookahead = xComma DO
        match(xComma);
        NEW(e);
		e^.key := string;
        match(xString);
        match(xColon);
        e^.val := parseValue();
        p^.next := e;
		p := p^.next
      END
    END;
    match(xRightBrace);
    RETURN obj
  END parseObject;

BEGIN
  NEW(text); Texts.Open(text, name);
  Texts.OpenReader(reader, text, 0);
  Texts.Read(reader, ch); scan;
  jsontree := parseObject();
END Parse;

(* ~ ~ TEST ~ ~ *)
PROCEDURE^ (val : Value) print;

PROCEDURE (obj : Object) print;
VAR pi : Pair;
BEGIN
  Console.String("{");
  pi := obj^.elems;
  WHILE pi # NIL DO
    Console.String(pi^.key^);
    Console.String(" : ");
    pi^.val.print;
    Console.String(",");
    Console.Ln;
    pi := pi^.next
  END;
  Console.String("}");
  Console.Ln
END print;

PROCEDURE (val : Value) print;
VAR v : Value;
BEGIN
  CASE val^.kind OF
    vString : Console.String(val^.str^)
  | vNumber : Console.String("REAL")
  | vObject : val^.obj.print
(*
  | vArray : Console.String("["); v := val^.arr;
             WHILE v # NIL DO v.print; v := v^.next END;
			 Console.String("]") *)
  ELSE
  END
END print;
(* ~ ~ TEST ~ ~ *)

BEGIN Parse("test01.json");
  jsontree.print
END JSON.

(*
Object =
    '{' [string ':' Value {',' string ':' Value}] '}'.
Array =
    '[' [Value {',' Value}] ']'.
Value =
     string
    | Number
    | Object
    | Array
    | 'true'
    | 'false'
    | 'null'.


string =
     '"' {char} '"'.
char =
     any-Unicode-character-
    |    except-"-or-\-or-
    |    control-character
    | \"
    | \\
    | \/
    | \b
    | \f
    | \n
    | \r
    | \t
    | \u four-hex-digits.
number =
     int
    | int frac
    | int exp
    | int frac exp.
int =
     digit
    | digit1-9 digits
    | '-' digit
    | '-' digit1-9 digits.
frac =
    '.' digits.
exp =
    e digits.
digits =
     digit
    | digit digits.
e =
     'e'
    | 'e+'
    | 'e-'
    | 'E'
    | 'E+'
    | 'E-'.
*)


