
MODULE Engine;

CONST
  TyReal = "R"; TyText = "T";

  OpNeg* = 0; OpNot* = 1;

TYPE
  Identifier* = ARRAY 32 OF CHAR;

  Expression* = POINTER TO ExpressionDesc;
  Real*       = POINTER TO RealDesc;
  Text*       = POINTER TO TextDesc;
  Variable*   = POINTER TO VariableDesc;
  Unary*      = POINTER TO UnaryDesc;
  Binary*     = POINTER TO BinaryDesc;
  Apply*      = POINTER TO ApplyDesc;

  Statement* = POINTER TO StatementDesc;
  Let*       = POINTER TO LetDesc;
  Input*     = POINTER TO InputDesc;
  Print*     = POINTER TO PrintDesc;
  If*        = POINTER TO IfDesc;
  While*     = POINTER TO WhileDesc;
  For*       = POINTER TO ForDesc;
  Call*      = POINTER TO CallDesc;
  Sequence*  = POINTER TO SequenceDesc;

  (**)
  ExpressionDesc = RECORD
    next : Expression
  END;

  RealDesc = RECORD(ExpressionDesc)
    value : REAL
  END;

  TextDesc = RECORD(ExpressionDesc)
    value : POINTER TO ARRAY OF CHAR
  END;

  VariableDesc = RECORD(ExpressionDesc)
    name : Identifier;
    type : CHAR
  END;

  UnaryDesc = RECORD(ExpressionDesc)
    opcode : INTEGER;
    expro : Expression
  END;

  BinaryDesc = RECORD(ExpressionDesc)
    opcode : INTEGER;
    expro, expri : Expression
  END;

  ApplyDesc = RECORD(ExpressionDesc)
    calee : Identifier;
    params : Expression
  END;

  StatementDesc = RECORD END;

  LetDesc = RECORD(StatementDesc)
    vari : Identifier; (* review *)
    valu : Expression
  END;  

  InputDesc = RECORD(StatementDesc)
    vari : Identifier
  END;

  PrintDesc = RECORD(StatementDesc)
    value : Expression
  END;

  IfDesc = RECORD(StatementDesc)
    cond : Expression;
    deci, alte : Statement
  END;

  WhileDesc = RECORD(StatementDesc)
    cond : Expression;
    body : Statement
  END;

  ForDesc = RECORD(StatementDesc)
    param : Identifier;
    init, stop, step : Expression;
    body : Statement
  END;

  CallDesc = RECORD(StatementDesc)
    calee : Identifier;
    params : Expression
  END;

  SequenceDesc = RECORD(StatementDesc)
    stato, stati : Statement
  END;

(**)
PROCEDURE CreateReal*(vl : REAL) : Real;
VAR rel : Real;
BEGIN NEW(rel); rel^.value := vl;
  RETURN rel
END CreateReal;

PROCEDURE CreateText*(vl : ARRAY OF CHAR) : Text;
VAR txt : Text;
BEGIN NEW(txt); NEW(txt^.value, LEN(vl));
  COPY(vl, txt^.value^);
  RETURN txt
END CreateText;

PROCEDURE CreateVariable*(nm : Identifier; ty : CHAR) : Variable;
VAR vr : Variabel;
BEGIN NEW(vr); COPY(nm, vr^.name); vr^.type := ty;
  RETURN vr
END CreateVariable;

PROCEDURE CreateUnary*(op : INTEGER; ex : Expression) : Unary;
VAR uno : Unary;
BEGIN NEW(uno); uno^.opcode := op; uno^.expor := ex;
  RETURN uno
END CreateUnary;

PROCEDURE CreateBinary*(op : INTEGER; exo, exi : Expression) : Binary;
VAR bry : Binary;
BEGIN NEW(bry); bry^.opcode := op;
  bry^.expro := exo; bry^.expri := exi;
  RETURN bry
END CreateBinary;


(**)
PROCEDURE (ex : Expression) Evaluate(env : Environment) : Value;
END Evaluate;

PROCEDURE (re : Real) Evaluate*(env : Environment) : Value;
END Evaluate;

PROCEDURE (txt : Text) Evaluate*(env : Environment) : Value;
END Evaluate;

PROCEDURE (vr : Variable) Evaluate*(env : Environment) : Value;
END Evaluate;

PROCEDURE (un : Unary) Evaluate*(env : Environment) : Value;
END Evaluate;

PROCEDURE (bi : Binary) Evaluate*(env : Environment) : Value;
END Evaluate;

PROCEDURE (ap : Apply) Evaluate*(env : Environment) : Value;
END Evaluate;

(**)
PROCEDURE (st : Statement) Execute(env : Environment);
END Execute;

PROCEDURE (el : Let) Execute*(env : Environment);
END Execute;

PROCEDURE (in : Input) Execute*(env : Environment);
END Execute;

PROCEDURE (pr : Print) Execute*(env : Environment);
END Execute;

PROCEDURE (br : If) Execute*(env : Environment);
END Execute;

PROCEDURE (wh : While) Execute*(env : Environment);
END Execute;

PROCEDURE (fr : For) Execute*(env : Environment);
END Execute;

PROCEDURE (cl : Call) Execute*(env : Environment);
END Execute;

PROCEDURE (sq : Sequence) Execute*(env : Environment);
END Execute;

END Engine.

