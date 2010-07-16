package {
  /** オペコード */
  class OpCode {
    public static const OP_PUSH_INT:int = 1;
    public static const OP_PUSH_STRING:int = 2;
    public static const OP_ADD:int = 3;
    public static const OP_SUB:int = 4;
    public static const OP_MUL:int = 5;
    public static const OP_DIV:int = 6;
    public static const OP_MINUS:int = 7;
    public static const OP_EQ:int = 8;
    public static const OP_NE:int = 9;
    public static const OP_GT:int = 10;
    public static const OP_GE:int = 11;
    public static const OP_LT:int = 12;
    public static const OP_LE:int = 13;
    public static const OP_PUSH_VAR:int = 14;
    public static const OP_ASSIGN_TO_VAR:int = 15;
    public static const OP_JUMP:int = 16;
    public static const OP_JUMP_IF_ZERO:int = 17;
    public static const OP_GOSUB:int = 18;
    public static const OP_RETURN:int = 19;
    public static const OP_PRINT:int = 20;
  }
}


