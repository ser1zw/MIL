package milMvm {
  import milParser.*;
  
  public class Mvm {
    private var _stack:Vector.<Value>;
    private var _variable:Vector.<Value>;
    private var _bytecode:Vector.<int>;
    private var _strPool:Vector.<String>;
    public function get stack():Vector.<Value> { return _stack; }
    
    public function Mvm(bytecode:Vector.<int>, strPool:Vector.<String>) {
      _stack = new Vector.<Value>();
      _variable = new Vector.<Value>();
      this._bytecode = bytecode;
      this._strPool = strPool;
    }

    public function execute():void {
      var value:Value;
      var n:int, m:int
      var str:String;
      var bool:Boolean;
      var pc:int = 0;
      log("bytecode: " + _bytecode.join(" "));
      log("strPool: " + _strPool.join(" "));
      
      while (pc < _bytecode.length) {
	switch (_bytecode[pc]) {
	  case OpCode.OP_PUSH_INT:
	  // log("pc = " + pc + ": in OP_PUSH_INT:");
	  value = Value.createIntValue(_bytecode[pc + 1]);
	  _stack.push(value);
	  pc += 2;
	  // log("exit OP_PUSH_INT:");
	  break;

	  case OpCode.OP_PUSH_STRING:
	  // log("pc = " + pc + ": in OP_PUSH_STRING:");
	  str = _strPool[_bytecode[pc + 1]];
	  value = Value.createStringValue(str);
	  _stack.push(value);
	  pc += 2;
	  // log("exit OP_PUSH_STRING:");
	  break;

	  case OpCode.OP_ADD:
	  // log("in OP_ADD:");
	  n = _stack.pop().intValue + _stack.pop().intValue;
	  _stack.push(Value.createIntValue(n));
	  pc++;
	  break;

	  case OpCode.OP_SUB:
	  // log("in OP_SUB:");
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
	  // log("in OP_PRINT:");
	  value = _stack.pop();
	  if (value.type == ValueType.INT_VALUE_TYPE) {
	    log(value.intValue);
	  }
	  else {
	    log(value.stringValue);
	  }
	  pc++;
	  // log("exit OP_PRINT:");
	  break;

	  default:
	  throw new Error("MVM Error");
	  break;
	}
      }
    }
  }
}


