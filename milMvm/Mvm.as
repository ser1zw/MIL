// -*- mode: actionscript; coding: utf-8-unix -*- 
package milMvm {
  import milParser.OpCode;
  
  /** MILの仮想マシン */
  public class Mvm {
    private var _stack:Vector.<Value>;
    private var _variable:Vector.<Value>;
    private var _bytecode:Vector.<int>;
    private var _strPool:Vector.<String>;
    private var stdout:Function;
    
    /**
    コンストラクタ
    @param bytecode バイトコード(Vector.<int>)
    @param strPool 文字列プール(Vector.<String>)
    */
    public function Mvm(bytecode:Vector.<int>, strPool:Vector.<String>,
      stdout:Function = null) {
      _stack = new Vector.<Value>();
      _variable = new Vector.<Value>();
      this._bytecode = bytecode;
      this._strPool = strPool;
      this.stdout = stdout;
    }
    
    /** バイトコードを実行 */
    public function execute():void {
      var value:Value;
      var n:int, m:int
      var str:String;
      var bool:Boolean;
      var pc:int = 0;
      
      while (pc < _bytecode.length) {
	switch (_bytecode[pc]) {
	  case OpCode.OP_PUSH_INT:
	  value = Value.createIntValue(_bytecode[pc + 1]);
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_PUSH_STRING:
	  str = _strPool[_bytecode[pc + 1]];
	  value = Value.createStringValue(str);
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_ADD:
	  n = _stack.pop().intValue + _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_SUB:
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n - m));
	  pc++;
	  break;

	  case OpCode.OP_MUL:
	  n = _stack.pop().intValue * _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_DIV:
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n / m));
	  pc++;
	  break;

	  case OpCode.OP_MINUS:
	  n = _stack.pop().intValue * -1;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_EQ:
	  n = (_stack.pop().intValue == _stack.pop().intValue) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_NE:
	  n = (_stack.pop().intValue != _stack.pop().intValue) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_GT:
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n > m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_GE:
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n >= m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_LT:
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n < m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_LE:
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n <= m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_PUSH_VAR:
	  value = _variable[_bytecode[pc + 1]];
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_ASSIGN_TO_VAR:
	  _variable[_bytecode[pc + 1]] = _stack.pop();
	  pc += 2;
	  break;

	  case OpCode.OP_JUMP:
	  pc = _bytecode[pc + 1];
	  break;

	  case OpCode.OP_JUMP_IF_ZERO:
	  if (_stack.pop().intValue == 0) {
	    pc = _bytecode[pc + 1];
	  }
	  else {
	    pc += 2;
	  }
	  break;

	  case OpCode.OP_GOSUB:
	  _stack.push(Value.createIntValue(pc + 2));
	  pc = _bytecode[pc + 1];
	  break;

	  case OpCode.OP_RETURN:
	  pc = _stack.pop().intValue;
	  break;

	  case OpCode.OP_PRINT:
	  
	  value = _stack.pop();
	  if (stdout != null) {
	    if (value.type == ValueType.INT_VALUE_TYPE) {
	      stdout(value.intValue);
	    }
	    else {
	      stdout(value.stringValue);
	    }
	  }
	  pc++;
	  break;

	  default:
	  pc++;
	  throw new Error("MVM Error");
	  break;
	}
      }
    }

    /**
    バイトコードをアセンブリコードに変換
    @return アセンブリコード
    */
    public function dumpAsmCode():Array {
      var value:Value;
      var n:int, m:int
      var str:String;
      var bool:Boolean;
      var pc:int = 0;
      var asm:Array = [];
      
      while (pc < _bytecode.length) {
	switch (_bytecode[pc]) {
	  case OpCode.OP_PUSH_INT:
	  asm.push("OP_PUSH_INT");
	  asm.push(_bytecode[pc + 1]);
	  value = Value.createIntValue(_bytecode[pc + 1]);
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_PUSH_STRING:
	  asm.push("OP_PUSH_STRING");
	  asm.push(_bytecode[pc + 1]);

	  str = _strPool[_bytecode[pc + 1]];
	  value = Value.createStringValue(str);
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_ADD:
	  asm.push("OP_ADD " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  n = _stack.pop().intValue + _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_SUB:
	  asm.push("OP_SUB " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n - m));
	  pc++;
	  break;

	  case OpCode.OP_MUL:
	  asm.push("OP_MUL " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  n = _stack.pop().intValue * _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_DIV:
	  asm.push("OP_DIV " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n / m));
	  pc++;
	  break;

	  case OpCode.OP_MINUS:
	  asm.push("OP_MINUS " + _stack[_stack.length - 1].intValue);
	  n = _stack.pop().intValue * -1;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_EQ:
	  asm.push("OP_EQ " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  n = (_stack.pop().intValue == _stack.pop().intValue) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_NE:
	  asm.push("OP_NE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  n = (_stack.pop().intValue != _stack.pop().intValue) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_GT:
	  asm.push("OP_GT " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n > m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_GE:
	  asm.push("OP_GE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n >= m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_LT:
	  asm.push("OP_LT " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n < m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_LE:
	  asm.push("OP_LE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n <= m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_PUSH_VAR:
	  asm.push("OP_PUSH_VAR");
	  asm.push(_bytecode[pc + 1]);
	  value = _variable[_bytecode[pc + 1]];
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_ASSIGN_TO_VAR:
	  asm.push("OP_ASSIGN_TO_VAR");
	  asm.push(_bytecode[pc + 1]);
	  _variable[_bytecode[pc + 1]] = _stack.pop();
	  pc += 2;
	  break;

	  case OpCode.OP_JUMP:
	  asm.push("OP_JUMP");
	  asm.push(_bytecode[pc + 1]);
	  pc += 2;
	  break;
	  
	  case OpCode.OP_JUMP_IF_ZERO:
	  asm.push("OP_JUMP_IF_ZERO " + _stack[_stack.length - 1].intValue);
	  asm.push(_bytecode[pc + 1]);
	  pc += 2;
	  break;

	  case OpCode.OP_GOSUB:
	  asm.push("OP_GOSUB");
	  asm.push(_bytecode[pc + 1]);
	  _stack.push(Value.createIntValue(pc + 2));
	  pc += 2;
	  break;

	  case OpCode.OP_RETURN:
	  asm.push("OP_RETURN " + _stack.pop().intValue);
	  pc++;
	  break;

	  case OpCode.OP_PRINT:
	  value = _stack.pop();
	  if (stdout != null) {
	    if (value.type == ValueType.INT_VALUE_TYPE) {
	      asm.push("OP_PRINT " + value.intValue);
	    }
	    else {
	      asm.push("OP_PRINT " + value.stringValue);
	    }
	  }
	  pc++;
	  break;

	  default:
	  asm.push(_bytecode[pc] + " << ERROR");
	  pc++;
	  break;
	}
      }
      return asm;
    }
  }
}

