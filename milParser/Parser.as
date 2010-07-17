// -*- mode: actionscript; coding: utf-8-unix -*- 
package milParser {
  import milLexicalAnalyzer.*;
  
  public class Parser {
    private var _bytecode:Vector.<int>;
    private var labelTable:Vector.<Label>;
    private var varTable:Vector.<String>;
    private var strPool:Vector.<String>;
    private var lookAheadToken:Token;
    private var lex:LexicalAnalyzer;
    public function get bytecode():Vector.<int> {
      return _bytecode;
    }
    
    public function Parser(sourceCode:String) {
      _bytecode = new Vector.<int>();
      labelTable = new Vector.<Label>();
      varTable = new Vector.<String>();
      strPool = new Vector.<String>();

      lex = new LexicalAnalyzer(sourceCode);
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
      _bytecode.push(bytecode);
    }
    
    private function parseError(message:String):void {
      throw new Error("Parse error: " + message + " at " + lex.lineNumber);
    }

    /**
    トークンが期待する種類でなければparse errorを発生させる
    @param expected 期待するトークンの種類(TokenKind)
    */
    private function checkExpectedToken(expected:int):void {
      var token:Token = getToken();
      if (token.kind != expected) {
	parseError("parse error");
      }
    }

    private function searchOrNewVar(identifier:String):int {
      var ret:int = varTable.indexOf(identifier);
      if (ret < 0) {
	varTable.push(identifier);
	return varTable.length - 1;
      }
      return ret;
    }

    /** 基本式をパース */
    private function parsePrimaryExpression():void {
      var token:Token = getToken();
      switch (token.kind) {
	case TokenKind.INT_VALUE_TOKEN:
	addBytecode(OpCode.OP_PUSH_INT);
	addBytecode(token.intValue);
	break;

	case TokenKind.STRING_LITERAL_TOKEN:
	addBytecode(OpCode.OP_PUSH_STRING);
	strPool.push(token.stringValue);
	addBytecode(strPool.length - 1);
	break;

	case TokenKind.LEFT_PAREN_TOKEN:
	parseExpression();
	checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);
	break;
	
	case TokenKind.IDENTIFIER_TOKEN:
	var varIndex:int = varTable.indexOf(token.identifier);
	if (varIndex < 0) {
	  parseError("identifier not found.");
	}
	addBytecode(OpCode.OP_PUSH_VAR);
	addBytecode(varIndex);
	break;
      }
    }

    /** 負の数のある式をパース */
    private function parseUnaryExpression():void {
      var token:Token = getToken();
      if (token.kind == TokenKind.SUB_TOKEN) {
	parsePrimaryExpression();
	addBytecode(OpCode.OP_MINUS);
      }
      else {
	ungetToken(token);
	parsePrimaryExpression();
      }
    }

    /** *または/からなる式(項)をパース */
    private function parseMultiplicativeExpression():void {
      var token:Token;
      parseUnaryExpression();
      while (true) {
	token = getToken();
	if (token.kind != TokenKind.MUL_TOKEN
	  && token.kind != TokenKind.DIV_TOKEN) {
	  ungetToken(token);
	  break;
	}
	parseUnaryExpression();
	if (token.kind == TokenKind.MUL_TOKEN) {
	  addBytecode(OpCode.OP_MUL);
	}
	else {
	  addBytecode(OpCode.OP_DIV);
	}
      }
    }

    private function parseExpression():void {
      throw new Error("Not implemented yet!!");
    }

    public function test():void {
      
    }
  }
}


