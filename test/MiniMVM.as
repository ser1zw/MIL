package {
  import flash.display.Sprite;
  
  [SWF(width="400", height="300", backgroundColor="#eeffee")] 
  public class MiniMVM extends Sprite {
    private const OP_PUSH_INT:int = 1;
    private const OP_ADD:int = 2;
    private const OP_MUL:int = 3;
    private const OP_PRINT:int = 4;
    
    private var stack:Vector.<int>;
    private var bytecode:Vector.<int>;

    private var sp:int; // スタックポインタ
    private var pc:int; // プログラムカウンタ

    public function MiniMVM() {
      stack = new Vector.<int>();
      bytecode = new Vector.<int>();
      for each (var code:int in [OP_PUSH_INT, 10, OP_PUSH_INT, 2, OP_PUSH_INT, 4, OP_MUL, OP_ADD, OP_PRINT]) {
	bytecode.push(code);
      }
      
      log("start");
      mvmExecute();
      log("end");
    }

    private function mvmExecute():void {
      sp = 0;
      pc = 0;
      // log("In mvmExecute():");
      // log("bytecode: " + bytecode.join(" "));
      
      while (pc < bytecode.length) {
	// log("pc = " + pc);
	// log("bytecode[pc] = " + bytecode[pc]);
	switch (bytecode[pc]) {
	  case OP_PUSH_INT:
	  // log("OP_PUSH_INT");
	  stack[sp] = bytecode[pc + 1];
	  sp++;
	  pc += 2;
	  break;
	  case OP_ADD:
	  // log("OP_ADD");
	  stack[sp - 2] = stack[sp - 2] + stack[sp - 1];
	  sp--;
	  pc++;
	  break;
	  case OP_MUL:
	  // log("OP_MUL");
	  stack[sp - 2] = stack[sp - 2] * stack[sp - 1];
	  sp--;
	  pc++;
	  break;
	  case OP_PRINT:
	  // log("OP_PRINT");
	  log(stack[sp - 1]);
	  sp--;
	  pc++;
	  break;
	  default:
	  log("ERROR");
	  break;
	}
      }
    }
  }
}



