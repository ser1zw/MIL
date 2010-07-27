package {
  import flash.display.Sprite;

  [SWF(width="400", height="300", backgroundColor="#eeffee")] 
  public class ParseTest extends Sprite {
    private var expression:String;
    private var eIndex:int;

    public function ParseTest() {
      expression = "1*(2+8)/2";
      eIndex = 0;
      parseExpression();
    }

    private function getToken():String {
      var token:String = expression.charAt(eIndex);
      eIndex++;
      return token;
    }

    private function parseExpression():void {
      var t:String;
      parseTerm();
      while(true) {
	t = getToken();
	if (t != "+" && t != "-") {
	  eIndex--; // トークンを押し戻す
	  break;
	}
	parseTerm();
	if (t == "+") {
	  log("OP_ADD");
	}
	else {
	  log("OP_SUB");
	}
      }
    }

    private function parseTerm():void {
      var t:String;
      // parseInt();
      parsePrimaryExpression();
      while(true) {
	t = getToken();
	if (t != "*" && t != "/") {
	  eIndex--; // トークンを押し戻す
	  break;
	}
	// parseInt();
	parsePrimaryExpression();
	if (t == "*") {
	  log("OP_MUL");
	}
	else {
	  log("OP_DIV");
	}
      }
    }

    private function parseInt():void {
      var t:String = getToken();
      var charCode:Number = t.charCodeAt(0);
      if (charCode < 48 || charCode > 57) { // t is a number?
	// "0".charCodeAt(0) == 47, "9".charCodeAt(0) == 57
	log("syntax error: " + t + " is not a number.");
	throw new Error("syntax error");
      }
      log("OP_PUSH_INT " + t);
    }

    private function parsePrimaryExpression():void {
      var t:String = getToken();
      if (t == "(") {
	parseExpression();
	t = getToken();
	if (t != ")") {
	  log("syntax error: ) is missing.");
	  throw new Error("syntax error");
	}
      }
      else {
	eIndex--;
	parseInt();
      }
    }
  }
}


