
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
  lexeme : ARRAY 256 OF CHAR;
  length : INTEGER;
  lookahead : SHORTINT;

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
PROCEDURE Parse*(name : ARRAY OF CHAR) : BOOLEAN;
  PROCEDURE match(exp : SHORTINT);
  BEGIN
    IF lookahead = exp THEN scan
    ELSE (* syntax error *)
    END
  END match;

  PROCEDURE^ parseObject;
  PROCEDURE^ parseArray;

  PROCEDURE parseValue;
  BEGIN
    CASE lookahead OF
      xString : scan
    | xNumber : scan
    | xLeftBrace : parseObject
    | xLeftBrack : parseArray
    | xTrue, xFalse, xNull : scan
    ELSE (* syntax error *)
    END
  END parseValue;

  PROCEDURE parseArray;
  BEGIN
    match(xLeftBrack);
    parseValue;
    WHILE lookahead = xComma DO
      match(xComma);
      parseValue;
    END;
    match(xRightBrack)
  END parseArray;

  PROCEDURE parseObject;
  BEGIN
    match(xLeftBrace);
    IF lookahead # xRightBrace THEN
      match(xString);
      match(xColon);
      parseValue;
      WHILE lookahead = xComma DO
        match(xComma);
        match(xString);
        match(xColon);
        parseValue;
      END
    END;
    match(xRightBrace)
  END parseObject;

BEGIN
  parseObject;
  RETURN TRUE
END Parse;

BEGIN (* Test *)
  NEW(text); Texts.Open(text, "test0.txt");
  Texts.OpenReader(reader, text, 0);

  Texts.Read(reader, ch);
  REPEAT
    scan;
    Console.String(lexeme); Console.Ln;
  UNTIL lookahead = xEof


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


