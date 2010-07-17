package parser {
  public class Parser {
    private var bytecode:Vector.<int>;
    private var labelTable:Vector.<Label>;
    private var lookAheadToken:Token;
    private var lex:LexicalAnalyzer;
    
    public function Parser() {
      
    }

    private function getToken():Token {
      var ret:Token;
      if (lookAheadToken != null) {
	ret = lookAheadToken;
	lookAheadToken = null;
      }
      else {
	ret = lex.lexGetToken();
      }
      return ret;
    }

    private function ungetToken(token:Token):void {
      lookAheadToken = token;
    }

    private function addBytecode(bytecode:int) {
      this.bytecode.push(bytecode);
    }
    
    private function parseError(message:String):void {
      throw new Error("Parse error: " + message + " at " + lex.lineNumber);
    }

    private function isExpectedToken(expected:TokenKind):Boolean {
      var token:TokenKind = getToken();
      if (token.tokenKind != expected) {
	parseError("parse error");
      }
      return true;
    }
  }
}

class Label {
  public var identifier:String;
  public var address:int;

  public Label(identifier:String, address:int) {
    this.identifier = identifier;
    this.address = address;
  }
}


