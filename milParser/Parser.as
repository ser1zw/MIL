// -*- mode: actionscript; coding: utf-8-unix -*- 
package milParser {
  import milLexicalAnalyzer.*;
  
  public class Parser {
    private var _bytecode:Vector.<int>;
    private var _labelTable:Vector.<Label>;
    private var _varTable:Vector.<String>;
    private var _strPool:Vector.<String>;
    private var lookAheadToken:Token;
    private var lex:LexicalAnalyzer;
    public function get bytecode():Vector.<int> { return _bytecode; }
    public function get labelTable():Vector.<Label> { return _labelTable; }
    public function get varTable():Vector.<String> { return _varTable; }
    public function get strPool():Vector.<String> { return _strPool; }
    
    public function Parser(sourceCode:String) {
      _bytecode = new Vector.<int>();
      _labelTable = new Vector.<Label>();
      _varTable = new Vector.<String>();
      _strPool = new Vector.<String>();

      lex = new LexicalAnalyzer(sourceCode);
      parse();
      fixLabels();
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

    private function addBytecode(bytecode:int):void {
      // if (bytecode == 23) {
      // 	log("***" + _bytecode.length);
      // 	throw new Error("mikumiku");
      // }

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
	parseError("parse error - TokenKind " + expected + " is expected, but is " + token.kind + " (" + token.stringValue + ", " + token.identifier + ", " + token.intValue + ")");
      }
    }

    private function searchOrNewVar(identifier:String):int {
      var ret:int = _varTable.indexOf(identifier);
      if (ret < 0) {
	_varTable.push(identifier);
	return _varTable.length - 1;
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
	_strPool.push(token.stringValue);
	addBytecode(_strPool.length - 1);
	// log(token.stringValue + " is pushed.");
	break;

	case TokenKind.LEFT_PAREN_TOKEN:
	parseExpression();
	checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);
	break;
	
	case TokenKind.IDENTIFIER_TOKEN:
	var varIndex:int = _varTable.indexOf(token.identifier);
	if (varIndex < 0) {
	  parseError(token.identifier + " - identifier not found.");
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

    /** +または-からなる式をパース */
    private function parseAdditiveExpression():void {
      var token:Token;
      parseMultiplicativeExpression();
      while (true) {
	token = getToken();
	if (token.kind != TokenKind.ADD_TOKEN
	  && token.kind != TokenKind.SUB_TOKEN) {
	  ungetToken(token);
	  break;
	}
	parseMultiplicativeExpression();
	if (token.kind == TokenKind.ADD_TOKEN) {
	  addBytecode(OpCode.OP_ADD);
	}
	else {
	  addBytecode(OpCode.OP_SUB);
	}
      }
    }

    private function parseCompareExpression():void {
      var token:Token;
      parseAdditiveExpression();
      while (true) {
	token = getToken();
	if (token.kind != TokenKind.EQ_TOKEN
	  && token.kind != TokenKind.NE_TOKEN
	  && token.kind != TokenKind.GT_TOKEN
	  && token.kind != TokenKind.GE_TOKEN
	  && token.kind != TokenKind.LT_TOKEN
	  && token.kind != TokenKind.LE_TOKEN) {
	  ungetToken(token);
	  break;
	}
	parseAdditiveExpression();

	switch (token.kind) {
	  case TokenKind.EQ_TOKEN:
	  addBytecode(OpCode.OP_EQ);
	  break;

	  case TokenKind.NE_TOKEN:
	  addBytecode(OpCode.OP_NE);
	  break;

	  case TokenKind.GT_TOKEN:
	  addBytecode(OpCode.OP_GT);
	  break;

	  case TokenKind.GE_TOKEN:
	  addBytecode(OpCode.OP_GE);
	  break;

	  case TokenKind.LT_TOKEN:
	  addBytecode(OpCode.OP_LT);
	  break;

	  case TokenKind.LE_TOKEN:
	  addBytecode(OpCode.OP_LE);
	  break;
	}
      }
    }

    private function parseExpression():void {
      parseCompareExpression();
    }

    /**
    新しいラベルを作成
    @return ラベルのインデックス
    */
    private function getLabel():int {
      _labelTable.push(new Label(null));
      return _labelTable.length - 1;
    }

    /**
    ラベルのアドレスをバイトコードの最後尾+1にセット
    @param labelIndex アドレスをセットするラベルのインデックス
    */
    private function setLabel(labelIndex:int):void {
      _labelTable[labelIndex].address = _bytecode.length;
    }

    private function searchOrNewLabel(label:String):int {
      var i:int;
      for (i = 0; i < _labelTable.length; i++) {
	if (_labelTable[i] != null && _labelTable[i].identifier != null
	  && _labelTable[i].identifier == label) {
	  return i;
	}
      }
      _labelTable.push(new Label(label));
      return _labelTable.length - 1;
    }

    private function parseIfStatement():void {
      var token:Token;
      var elseLabel:int;
      var endIfLabel:int;

      checkExpectedToken(TokenKind.LEFT_PAREN_TOKEN);
      parseExpression();
      checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);

      elseLabel = getLabel();
      addBytecode(OpCode.OP_JUMP_IF_ZERO);
      addBytecode(elseLabel);
      parseBlock();
      token = getToken();
      if (token.kind == TokenKind.ELSE_TOKEN) {
	endIfLabel = getLabel();
	addBytecode(OpCode.OP_JUMP);
	addBytecode(endIfLabel);
	setLabel(elseLabel);
	parseBlock();
	setLabel(endIfLabel);
      }
      else {
	ungetToken(token);
	setLabel(elseLabel);
      }
    }

    private function parseWhileStatement():void {
      var loopLabel:int;
      var endWhileLabel:int;

      loopLabel = getLabel();
      setLabel(loopLabel);
      checkExpectedToken(TokenKind.LEFT_PAREN_TOKEN);
      parseExpression();
      checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);

      endWhileLabel = getLabel();
      addBytecode(OpCode.OP_JUMP_IF_ZERO);
      addBytecode(endWhileLabel);
      parseBlock();
      addBytecode(OpCode.OP_JUMP);
      addBytecode(loopLabel);
      setLabel(endWhileLabel);
    }

    private function parsePrintStatement():void {
      checkExpectedToken(TokenKind.LEFT_PAREN_TOKEN);
      parseExpression();
      checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);
      addBytecode(OpCode.OP_PRINT);
      checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
    }

    private function parseAssignStatement(identifier:String):void {
      var varIndex:int = searchOrNewVar(identifier);
      checkExpectedToken(TokenKind.ASSIGN_TOKEN);
      parseExpression();
      addBytecode(OpCode.OP_ASSIGN_TO_VAR);
      addBytecode(varIndex);
      checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
    }

    private function parseGotoStatement():void {
      var token:Token;
      var label:int;

      checkExpectedToken(TokenKind.MUL_TOKEN);
      token = getToken();
      if (token.kind != TokenKind.IDENTIFIER_TOKEN) {
	parseError("label identifier expected");
      }
      label = searchOrNewLabel(token.identifier);
      addBytecode(OpCode.OP_JUMP);
      addBytecode(label);
      checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
    }

    private function parseGosubStatement():void {
      var token:Token;
      var label:int;

      checkExpectedToken(TokenKind.MUL_TOKEN);
      token = getToken();
      if (token.kind != TokenKind.IDENTIFIER_TOKEN) {
	parseError("label identifier expected");
      }
      label = searchOrNewLabel(token.identifier);
      addBytecode(OpCode.OP_GOSUB);
      addBytecode(label);
      checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
    }

    private function parseLabelStatement():void {
      var token:Token;
      var label:int;

      token = getToken();
      if (token.kind != TokenKind.IDENTIFIER_TOKEN) {
	parseError("label identifier expected");
      }
      label = searchOrNewLabel(token.identifier);
      setLabel(label);
    }

    private function parseReturnStatement():void {
      addBytecode(OpCode.OP_RETURN);
      checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
    }

    /** トークンを読み取り種別ごとに分岐 */
    private function parseStatement():void {
      var token:Token = getToken();
      
      switch (token.kind) {
	case TokenKind.IF_TOKEN:
	parseIfStatement();
	break;

	case TokenKind.WHILE_TOKEN:
	parseWhileStatement();
	break;

	case TokenKind.PRINT_TOKEN:
	parsePrintStatement();
	break;

	case TokenKind.GOTO_TOKEN:
	parseGotoStatement();
	break;

	case TokenKind.GOSUB_TOKEN:
	parseGosubStatement();
	break;

	case TokenKind.RETURN_TOKEN:
	parseReturnStatement();
	break;

	case TokenKind.MUL_TOKEN:
	parseLabelStatement();
	break;

	case TokenKind.IDENTIFIER_TOKEN:
	parseAssignStatement(token.identifier);
	break;

	default:
	parseError("bad statement.");
	break;
      }
    }

    /** { }のブロックをパース */
    private function parseBlock():void {
      var token:Token;
      checkExpectedToken(TokenKind.LEFT_BRACE_TOKEN);
      while (true) {
	token = getToken();
	if (token.kind == TokenKind.RIGHT_BRACE_TOKEN) {
	  break;
	}
	ungetToken(token);
	parseStatement();
      }
    }

    /**
    ジャンプ先の実アドレスを書き込む
    (パース時にバイトコードに入れたアドレスは_labelTableのインデックス)
    */
    private function fixLabels():void {
      var i:int;
      for (i = 0; i < _bytecode.length; i++) {
	if (_bytecode[i] == OpCode.OP_PUSH_INT
	  || _bytecode[i] == OpCode.OP_PUSH_STRING
	  || _bytecode[i] == OpCode.OP_PUSH_VAR
	  || _bytecode[i] == OpCode.OP_ASSIGN_TO_VAR) {
	  i++;
	}
	else if (_bytecode[i] == OpCode.OP_JUMP
	  || _bytecode[i] == OpCode.OP_JUMP_IF_ZERO
	  || _bytecode[i] == OpCode.OP_GOSUB) {
	  _bytecode[i + 1] = _labelTable[_bytecode[i + 1]].address;
	  i++;
	}
      }
    }

    private function parse():void {
      var token:Token;
      while (true) {
	token = getToken();
	if (token.kind == TokenKind.END_OF_FILE_TOKEN) {
	  break;
	}
	else {
	  ungetToken(token);
	  parseStatement();
	}
      }
    }
  }
}


