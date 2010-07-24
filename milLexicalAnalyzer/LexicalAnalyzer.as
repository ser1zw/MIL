// -*- mode: actionscript; coding: utf-8-unix -*- 
package milLexicalAnalyzer {
  /** レキシカルアナライザ */
  public class LexicalAnalyzer {
    private var sourceCodeCharArray:Vector.<String>;
    private var currentLineNumber:int;
    private var operatorTable:Object;
    private var keywordTable:Object;
    public function get lineNumber():int { return currentLineNumber; }

    /**
    コンストラクタ
    @param sourceCode ソースコード
    */
    public function LexicalAnalyzer(sourceCode:String) {
      currentLineNumber = 1;
      operatorTable = {
	"==" : TokenKind.EQ_TOKEN,
	"!=" : TokenKind.NE_TOKEN,
	">=" : TokenKind.GE_TOKEN,
	"<=" : TokenKind.LE_TOKEN,
	"+" : TokenKind.ADD_TOKEN,
	"-" : TokenKind.SUB_TOKEN,
	"*" : TokenKind.MUL_TOKEN,
	"/" : TokenKind.DIV_TOKEN,
	"=" : TokenKind.ASSIGN_TOKEN,
	">" : TokenKind.GT_TOKEN,
	"<" : TokenKind.LT_TOKEN,
	"(" : TokenKind.LEFT_PAREN_TOKEN,
	")" : TokenKind.RIGHT_PAREN_TOKEN,
	"{" : TokenKind.LEFT_BRACE_TOKEN,
	"}" : TokenKind.RIGHT_BRACE_TOKEN,
	"," : TokenKind.COMMA_TOKEN,
	";" : TokenKind.SEMICOLON_TOKEN
      };
      
      keywordTable = {
	"if" : TokenKind.IF_TOKEN,
	"else" : TokenKind.ELSE_TOKEN,
	"while" : TokenKind.WHILE_TOKEN,
	"goto" : TokenKind.GOTO_TOKEN,
	"gosub" : TokenKind.GOSUB_TOKEN,
	"return" : TokenKind.RETURN_TOKEN,
	"print" : TokenKind.PRINT_TOKEN
      };

      sourceCode = sourceCode.replace(/\r\n?/g, "\n");
      sourceCodeCharArray = new Vector.<String>();
      for (var i:int = 0; i < sourceCode.length; i++) {
	sourceCodeCharArray.push(sourceCode.charAt(i));
      }
    }
    
    /**
    エラーを発生
    @param エラーメッセージ
    */
    private function lexError(message:String):void {
      throw new Error("lex error: " + message);
    }

    /**
    現在読み込み中のtoken(文字列)にletter(1文字)を追加した文字列(token + letter)が
    演算子の文字列と前方一致でマッチするかどうかを判定
    @param token 読み込み中のトークン
    @param letter 追加する文字
    @return token+letterが演算子の文字列と前方一致でマッチすればtrue, しなければfalse
    */
    private function inOperator(token:String, letter:String):Boolean {
      var newToken:String = token + letter;
      for (var op:String in operatorTable) {
	if (op.length >= newToken.length
	  && newToken == op.substring(0, newToken.length)) {
	  return true;
	}
      }
      return false;
    }

    /**
    演算子と区切り子を判定
    @param token トークン
    @return トークンの種類(TokenKind)
    */
    private function selectOperator(token:String):int {
      if (operatorTable[token] == null) {
	lexError("Invalid operator " + token);
	return 0;
      }
      return operatorTable[token];
    }

    /**
    与えられた文字が数字(0~9)であるかを判定
    @param ch 判定対象の文字
    @return chが数字であればtrue, 数字でなければfalse
    */
    private function isDigit(ch:String):Boolean {
      var charCode:Number = ch.charCodeAt(0);
      // "0" = 48, "9" = 57
      return charCode >= 48 && charCode <= 57;
    }

    /**
    与えられた文字が英字(A~Z, a~z)であるかを判定
    @param ch 判定対象の文字
    @return chが英字であればtrue, 英字でなければfalse
    */
    private function isAlpha(ch:String):Boolean {
      var charCode:Number = ch.charCodeAt(0);
      // "A" = 65, "Z" = 90, "a" = 97, "z" = 122
      return (charCode >= 65 && charCode <= 90) || (charCode >= 97 && charCode <= 122);
    }

    private function isSpace(ch:String):Boolean {
      var charCode:Number = ch.charCodeAt(0);
      // " " = 32, "\f" = 12, "\n" = 10, "\r" = 13, "\t" = 9, "\v" = 11
      return (charCode >= 9 && charCode <= 13) || (charCode == 32);
    }

    /**
    次のトークンを取得
    @return トークン
    */
    public function lexGetToken():Token {
      var ret:Token = new Token();
      var state:int = LexerState.INITIAL_STATE; // 読み取り中のトークンの種別を保持
      var token:String = "";
      var ch:String;
      
      // ソースコードから1文字ずつ読み取る
      LOOP: while ((ch = sourceCodeCharArray.shift()) != null) {
	switch (state) {
	  case LexerState.INITIAL_STATE:
	  if (isDigit(ch)) {
	    token = token.concat(ch);
	    state = LexerState.INT_VALUE_STATE;
	  }
	  else if (isAlpha(ch) || ch == "_") {
	    token = token.concat(ch);
	    state = LexerState.IDENTIFIER_STATE;
	  }
	  else if (ch == '"') {
	    state = LexerState.STRING_STATE;
	  }
	  else if (inOperator(token, ch)) {
	    token = token.concat(ch);
	    state = LexerState.OPERATOR_STATE;
	  }
	  else if (isSpace(ch)) {
	    if (ch == "\n") {
	      currentLineNumber++;
	    }
	  }
	  else if (ch == "#") {
	    state = LexerState.COMMENT_STATE;
	  }
	  else {
	    lexError("Bad charactor: " + ch);
	  }
	  break;

	  case LexerState.INT_VALUE_STATE:
	  if (isDigit(ch)) {
	    token = token.concat(ch);
	  }
	  else {
	    ret = Token.getIntToken(TokenKind.INT_VALUE_TOKEN, parseInt(token));
	    sourceCodeCharArray.unshift(ch);
	    break LOOP;
	  }
	  break;

	  case LexerState.IDENTIFIER_STATE:
	  if (isAlpha(ch) || ch == "_" || isDigit(ch)) {
	    token = token.concat(ch);
	  }
	  else {
	    ret = Token.getIdentifierToken(TokenKind.IDENTIFIER_TOKEN, token);
	    sourceCodeCharArray.unshift(ch);
	    break LOOP;
	  }
	  break;

	  case LexerState.STRING_STATE:
	  if (ch == '"') {
	    ret = Token.getStringToken(TokenKind.STRING_LITERAL_TOKEN, token);
	    break LOOP;
	  }
	  else {
	    token = token.concat(ch);
	  }
	  break;

	  case LexerState.OPERATOR_STATE:
	  if (inOperator(token, ch)) {
	    token = token.concat(ch);
	  }
	  else {
	    sourceCodeCharArray.unshift(ch);
	    break LOOP;
	  }
	  break;

	  case LexerState.COMMENT_STATE:
	  if (ch == "\n") {
	    state = LexerState.INITIAL_STATE;
	  }
	  break;
	  
	  default:
	  throw new Error("lex error");
	  break;
	}
      }
      
      if (ch == null) {
	if (state == LexerState.INITIAL_STATE || state == LexerState.COMMENT_STATE) {
	  ret.kind = TokenKind.END_OF_FILE_TOKEN;
	  return ret;
	}
      }
      if (state == LexerState.IDENTIFIER_STATE) {
	if (keywordTable[token] == null) {
	  ret = Token.getIdentifierToken(TokenKind.IDENTIFIER_TOKEN, token);
	}
	else {
	  ret = Token.getIdentifierToken(keywordTable[token], token);
	}
      }
      else if (state == LexerState.OPERATOR_STATE) {
	ret.kind = selectOperator(token);
      }
      
      return ret;
    }
  }
}


