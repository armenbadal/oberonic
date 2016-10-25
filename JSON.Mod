
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
  
(*
  Node = POINTER TO NodeDesc;
  NodeDesc = RECORD
    data : Value;
    next : Node
  END;
*)

  ObjectDesc = RECORD
  END;

  PairDesc = RECORD
    key : String;
    val : Value;
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
  lex : ARRAY 256 OF CHAR;
  len : INTEGER;
  kind : SHORTINT;

PROCEDURE parseObject;
END parseObject;

PROCEDURE parseArray;
END parseArray;

PROCEDURE parseValue;
END parseValue;

(* Scanner *)

PROCEDURE read;
BEGIN Texts.Read(reader, ch);
  lex[len] := ch; INC(len)
END read;

PROCEDURE isDigit(c : CHAR) : BOOLEAN;
BEGIN RETURN (ORD(c) >= ORD('0')) & (ORD(c) <= ORD('9'))
END isDigit;

PROCEDURE scanNumber;
  PROCEDURE scanDigits;
  BEGIN WHILE isDigit(ch) DO read END
  END scanDigits;
BEGIN
  IF ch = '-' THEN read END;
  IF isDigit(ch) THEN
    scanDigits;
    IF ch = '.' THEN read; scanDigits END;
	IF (ch = 'e') OR (ch = 'E') THEN read;
      IF (ch = '-') OR (ch = '+') THEN read END;
      scanDigits
    END;
    DEC(len); lex[len] := 0X;
    kind := xNumber
  END
END scanNumber;

PROCEDURE scanString;
BEGIN
  len := 0; read;
  WHILE ch # '"' DO read END;
  DEC(len); lex[len] := 0X;
  kind := xString
END scanString;

(* scan 'true', 'false' and 'null' *)
PROCEDURE scanConstant;
BEGIN
  IF ch = 't' THEN
  ELSIF ch = 'f' THEN
  ELSIF ch = 'n' THEN
  END
END scanConstant;

PROCEDURE scanMetaChar;
BEGIN
  CASE ch OF
    '{' : kind := xLeftBrace
  | '}' : kind := xRightBrace
  | '[' : kind := xLeftBrack
  | ']' : kind := xRightBrack
  | ':' : kind := xColon
  | ',' : kind := xComma
  ELSE kind := xUnknown
  END;
  IF kind # xUnknown THEN read END
END scanMetaChar;

PROCEDURE scan;
BEGIN
  REPEAT read UNTIL ORD(ch) > 32;
  kind := xUnknown;
  IF ch = '"' THEN scanString
  ELSIF (ch = '-') OR isDigit(ch) THEN scanNumber
  ELSIF (ch = 't') OR (ch = 'f') OR (ch = 'n') THEN scanConstant
  ELSE scanMetaChar
  END
END scan;

PROCEDURE Parse*(name : ARRAY OF CHAR) : BOOLEAN;
BEGIN RETURN TRUE
END Parse;

BEGIN (* Test *)
  NEW(text); Texts.Open(text, "test0.txt");
  Texts.OpenReader(reader, text, 0);

  WHILE TRUE DO
    scan;
    Console.String(lex); Console.Ln;
    Console.Int(len, 4); Console.Ln;
    Console.Int(kind, 4); Console.Ln
  END


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


