package milMvm {
  import milParser.*;
  
  public class Mvm {
    private var _stack:Vector.<Value>;
    private var _variable:Vector.<Value>;
    private var _bytecode:Vector.<int>;
    private var _strPool:Vector.<String>;
    private var stdout:Function;
    public function get stack():Vector.<Value> { return _stack; }
    
    public function Mvm(bytecode:Vector.<int>, strPool:Vector.<String>,
      stdout:Function = null) {
      _stack = new Vector.<Value>();
      _variable = new Vector.<Value>();
      this._bytecode = bytecode;
      this._strPool = strPool;
      this.stdout = stdout;
    }

    public function execute():void {
      var value:Value;
      var n:int, m:int
      var str:String;
      var bool:Boolean;
      var pc:int = 0;
      // _bytecode[13] = 2;
      // log("bytecode: " + _bytecode.join(" "));
      // log("strPool: " + _strPool.join(" "));
      
      while (pc < _bytecode.length) {
	switch (_bytecode[pc]) {
	  case OpCode.OP_PUSH_INT:
	  // log(pc + " : OP_PUSH_INT");
	  // log((pc + 1) + " : " + _bytecode[pc + 1]);
	  value = Value.createIntValue(_bytecode[pc + 1]);
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_PUSH_STRING:
	  // log(pc + " : OP_PUSH_STRING");
	  // log((pc + 1) + " : " + _bytecode[pc + 1]);

	  str = _strPool[_bytecode[pc + 1]];
	  value = Value.createStringValue(str);
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_ADD:
	  // log(pc + " : OP_ADD " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  n = _stack.pop().intValue + _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_SUB:
	  // log(pc + " : OP_SUB " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n - m));
	  pc++;
	  break;

	  case OpCode.OP_MUL:
	  // log(pc + " : OP_MUL " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  n = _stack.pop().intValue * _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_DIV:
	  // log(pc + " : OP_DIV " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n / m));
	  pc++;
	  break;

	  case OpCode.OP_MINUS:
	  // log(pc + " : OP_MINUS " + _stack[_stack.length - 1].intValue);
	  n = _stack.pop().intValue * -1;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_EQ:
	  // log(pc + " : OP_EQ " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  n = (_stack.pop().intValue == _stack.pop().intValue) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_NE:
	  // log(pc + " : OP_NE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  n = (_stack.pop().intValue != _stack.pop().intValue) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_GT:
	  // log(pc + " : OP_GT " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n > m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_GE:
	  // log(pc + " : OP_GE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n >= m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_LT:
	  // log(pc + " : OP_LT " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n < m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_LE:
	  // log(pc + " : OP_LE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
	  m = _stack.pop().intValue;
	  n = _stack.pop().intValue;
	  n = (n <= m) ? 1 : 0;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_PUSH_VAR:
	  // log(pc + " : OP_PUSH_VAR");
	  // log((pc + 1) + " : " + _bytecode[pc + 1]);
	  value = _variable[_bytecode[pc + 1]];
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_ASSIGN_TO_VAR:
	  // log(pc + " : OP_ASSIGN_TO_VAR");
	  // log((pc + 1) + " : " + _bytecode[pc + 1]);
	  _variable[_bytecode[pc + 1]] = _stack.pop();
	  pc += 2;
	  break;

	  case OpCode.OP_JUMP:
	  // log(pc + " : OP_JUMP");
	  // log((pc + 1) + " : " + _bytecode[pc + 1]);
	  pc = _bytecode[pc + 1];
	  break;

	  case OpCode.OP_JUMP_IF_ZERO:
	  // log(pc + " : OP_JUMP_IF_ZERO " + _stack[_stack.length - 1].intValue);
	  // log((pc + 1) + " : " + _bytecode[pc + 1]);
	  if (_stack.pop().intValue == 0) {
	    pc = _bytecode[pc + 1];
	  }
	  else {
	    pc += 2;
	  }
	  break;

	  case OpCode.OP_GOSUB:
	  // log(pc + " : OP_GOSUB");
	  // log((pc + 1) + " : " + _bytecode[pc + 1]);
	  _stack.push(Value.createIntValue(pc + 2));
	  pc = _bytecode[pc + 1];
	  break;

	  case OpCode.OP_RETURN:
	  // log(pc + " : OP_RETURN " + _stack[_stack.length - 1].intValue);
	  pc = _stack.pop().intValue;
	  break;

	  case OpCode.OP_PRINT:
	  
	  value = _stack.pop();
	  if (stdout != null) {
	    if (value.type == ValueType.INT_VALUE_TYPE) {
	      stdout(value.intValue);
	      // log(pc + " : OP_PRINT " + value.intValue);
	    }
	    else {
	      stdout(value.stringValue);
	      // log(pc + " : OP_PRINT " + value.stringValue);
	    }
	  }
	  pc++;
	  break;

	  default:
	  // log(pc + " : " + _bytecode[pc]);
	  pc++;
	  throw new Error("MVM Error");
	  break;
	}
      }
    }

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
	  asm.push( _bytecode[pc + 1]);
	  value = _variable[_bytecode[pc + 1]];
	  _stack.push(value);
	  pc += 2;
	  break;

	  case OpCode.OP_ASSIGN_TO_VAR:
	  asm.push("OP_ASSIGN_TO_VAR");
	  asm.push( _bytecode[pc + 1]);
	  _variable[_bytecode[pc + 1]] = _stack.pop();
	  pc += 2;
	  break;

	  case OpCode.OP_JUMP:
	  asm.push("OP_JUMP");
	  asm.push( _bytecode[pc + 1]);
	  // pc = _bytecode[pc + 1];
	  break;

	  case OpCode.OP_JUMP_IF_ZERO:
	  asm.push("OP_JUMP_IF_ZERO " + _stack[_stack.length - 1].intValue);
	  asm.push(_bytecode[pc + 1]);
	  // if (_stack.pop().intValue == 0) {
	  //   pc = _bytecode[pc + 1];
	  // }
	  // else {
	  pc += 2;
	  // }
	  break;

	  case OpCode.OP_GOSUB:
	  asm.push("OP_GOSUB");
	  asm.push(_bytecode[pc + 1]);
	  _stack.push(Value.createIntValue(pc + 2));
	  // pc = _bytecode[pc + 1];
	  break;

	  case OpCode.OP_RETURN:
	  asm.push("OP_RETURN " + _stack[_stack.length - 1].intValue);
	  // pc = _stack.pop().intValue;
	  break;

	  case OpCode.OP_PRINT:
	  value = _stack.pop();
	  if (stdout != null) {
	    if (value.type == ValueType.INT_VALUE_TYPE) {
	      stdout(value.intValue);
	      asm.push("OP_PRINT " + value.intValue);
	    }
	    else {
	      stdout(value.stringValue);
	      asm.push("OP_PRINT " + value.stringValue);
	    }
	  }
	  pc++;
	  break;

	  default:
	  asm.push(_bytecode[pc]);
	  pc++;
	  // throw new Error("MVM Error");
	  break;
	}
      }
      
      return asm;
    }
  }
}

