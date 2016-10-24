
MODULE JSON;

IMPORT Texts;

CONST
  xColon = ':';

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
  rider : Texts.Rider;

PROCEDURE parseObject;
END parseObject;

PROCEDURE parseArray;
END parseArray;

PROCEDURE parseValue;
END parseValue;

PROCEDURE scanNumber;
END scanNumber;

PROCEDURE scanString;
END scanString;

(* scan 'true', 'false' and 'null' *)
PROCEDURE scanConstant;
END scanConstant;

PROCEDURE Parse*(name : ARRAY OF CHAR) : BOOLEAN;
BEGIN RETURN TRUE
END Parse;

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


