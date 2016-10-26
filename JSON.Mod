
MODULE JSON;

IMPORT Texts, Console;

CONST
  (* Tokens *)
  xUnknown = 0;
  xLeftBrack = 1; 
  xRightBrack = 2;
  xLeftBrace = 3;
  xRightBrace = 4;
  xColon = 5; 
  xComma = 6;
  xString = 7;
  xNumber = 8;
  xTrue = 9;
  xFalse = 10;
  xNull = 11;
  xEof = 12;

  (* Object types *)
  vString = 'S';
  vNumber = 'N'; 
  vObject = 'O';
  vArray = 'A';
  vConstant = 'C';

TYPE
  String* = ARRAY 256 OF CHAR;

  Object* = POINTER TO ObjectDesc;
  Pair* = POINTER TO PairDesc;
  Value* = POINTER TO ValueDesc;
  
  ObjectDesc = RECORD
    elems : Pair
  END;

  PairDesc = RECORD
    key : String;
    val : Value;
    next : Pair
  END;

  ValueDesc = RECORD
    kind : CHAR;
    str : String;
    num : REAL;
    obj : Object;
    arr : Value;
    (* true, fasle, null *)
    next : Value;
  END;


VAR
  text : Texts.Text;
  reader : Texts.Reader;
  ch : CHAR;
  lexeme : ARRAY 256 OF CHAR;
  length : INTEGER;
  lookahead : SHORTINT;

  jsontree : Object;


(* AST *)

(* Scanner *)
PROCEDURE scan;
  (* real numbers *)
  PROCEDURE scanNumber;
    PROCEDURE scanDigits;
    BEGIN
      WHILE (ch >= "0") & (ch <= "9") DO
        lexeme[length] := ch;
        INC(length);
        Texts.Read(reader, ch)
      END
    END scanDigits;
  BEGIN
    length := 0;
    IF ch = '-' THEN
        lexeme[length] := ch;
        INC(length);
        Texts.Read(reader, ch)
    END;
    IF (ch >= "0") & (ch <= "9") THEN
      scanDigits;
      IF ch = '.' THEN
        Texts.Read(reader, ch);
        scanDigits
      END;
	  IF (ch = 'e') OR (ch = 'E') THEN
        lexeme[length] := ch;
        INC(length);
        Texts.Read(reader, ch);
        IF (ch = '-') OR (ch = '+') THEN
          lexeme[length] := ch;
          INC(length);
          Texts.Read(reader, ch)
        END;
        scanDigits
      END;
      lexeme[length] := 0X;
    END
  END scanNumber;

  (* string - \"[^\"]*\" *)
  PROCEDURE scanString;
  BEGIN
    length := 0;
    Texts.Read(reader, ch);
    WHILE ch # 22X DO 
      lexeme[length] := ch;
      INC(length);
      Texts.Read(reader, ch)
    END;
    lexeme[length] := 0X;
    Texts.Read(reader, ch)
  END scanString;
BEGIN
  (* skip spaces *)
  WHILE ~reader.eot & (ch <= " ") DO
    Texts.Read(reader, ch)
  END;
  IF ch = 22X THEN
    scanString; lookahead := xString
  ELSIF (ch = "-") OR ((ch >= "0") & (ch <= "9")) THEN
    scanNumber; lookahead := xNumber
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
    lexeme[0] := 0X;
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
  PROCEDURE^ parseArray() : Value;

  PROCEDURE parseValue() : Value;
  VAR val : Value;
  BEGIN
    NEW(val);
    CASE lookahead OF
      xString : val^.kind := vString;
                COPY(lexeme, val^.str);
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

  PROCEDURE parseArray() : Value;
  VAR arr, vi : Value;
  BEGIN
    match(xLeftBrack);
    arr := parseValue();
    vi := arr;
    WHILE lookahead = xComma DO
      match(xComma);
      vi^.next := parseValue();
      vi := vi^.next
    END;
    match(xRightBrack);
    RETURN arr
  END parseArray;

  PROCEDURE parseObject() : Object;
  VAR obj : Object; e, p : Pair; 
  BEGIN
    match(xLeftBrace);
    IF lookahead # xRightBrace THEN
      NEW(e);
      COPY(lexeme, e^.key);
      match(xString);
      match(xColon);
      e^.val := parseValue();
      NEW(obj);
	  obj^.elems := e;
      p := obj^.elems;
      WHILE lookahead = xComma DO
        match(xComma);
        NEW(e);
		COPY(lexeme, e^.key);
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
    Console.String(pi^.key);
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
    vString : Console.String(val^.str)
  | vNumber : Console.String("REAL")
  | vObject : val^.obj.print
  | vArray : Console.String("["); v := val^.arr;
             WHILE v # NIL DO v.print; v := v^.next END;
			 Console.String("]")
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


