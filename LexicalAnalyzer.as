/**
TODO
・OperatorInfoクラスを作ってoperatorTableを変える
・リファクタリング
*/
package {
  import flash.display.Sprite;
  
  [SWF(width="400", height="300", backgroundColor="#eeffee")] 
  public class LexicalAnalyzer extends Sprite {
    private var sourceCode:String;
    private var sourceCodeCharArray:Vector.<String>;
    private var currentLineNumber:int;
    private var operatorTable:Object;
    private var keywordTable:Object;

    public function LexicalAnalyzer() {
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

      sourceCodeCharArray = new Vector.<String>();
      try {
	sourceCode = "if a == 0 print \"hoge\" # This is a comment";
	for (var i:int = 0; i < sourceCode.length; i++) {
	  sourceCodeCharArray.push(sourceCode.charAt(i));
	}
	sourceCodeCharArray.push("\n");
	main();
      }
      catch (e:Error) {
	log(e);
      }
    }

    private function main():void {
      var token:Token;
      currentLineNumber = 1;
      var n:int = 0;
      do {
	token = lexGetToken();
	if (token.tokenKind == TokenKind.INT_VALUE_TOKEN) {
	  log(token.intValue + " 整数");
	}
	else if (token.tokenKind == TokenKind.IDENTIFIER_TOKEN) {
	  log(token.identifier + " 識別子");
	}
	else if (token.tokenKind == TokenKind.STRING_LITERAL_TOKEN) {
	  log(token.stringValue + " 文字列リテラル");
	}
	else if (token.tokenKind >= TokenKind.EQ_TOKEN && token.tokenKind <= TokenKind.SEMICOLON_TOKEN) {
	  log(token.tokenKind + " 演算子または区切り子");
	}
	else if (token.tokenKind != TokenKind.END_OF_FILE_TOKEN && token.tokenKind >= TokenKind.IF_TOKEN) {
	  log(keywordTable[token.tokenKind - TokenKind.IF_TOKEN] + " 予約語");
	}

	/*
	if (token.tokenKind == TokenKind.END_OF_FILE_TOKEN) {
	log("EOF");
	}
	else {
	log("TokenKind = " + token.tokenKind);
	}
	if (++n > 5) {
	log("break");
	break;
	}
	*/
      } while(token.tokenKind != TokenKind.END_OF_FILE_TOKEN);
    }

    private function lexError(message:String):void {
      log("lex error: " + message);
      throw new Error("lex error");
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
      // log("selectOperator: " + token + " = " + operatorTable[token]);
      return operatorTable[token];
    }

    /**
    与えられた文字が数字(0~9)であるかを判定
    @param ch 判定対象の文字
    @return chが数字であればtrue, 数字でなければfalse
    */
    private function isDigit(ch:String):Boolean {
      var charCode:Number = ch.charCodeAt(0);
      // "0".charCodeAt(0) == 48, "9".charCodeAt(0) == 57
      return charCode >= 48 && charCode <= 57;
    }

    /**
    与えられた文字が英字(A~Z, a~z)であるかを判定
    @param ch 判定対象の文字
    @return chが英字であればtrue, 英字でなければfalse
    */
    private function isAlpha(ch:String):Boolean {
      var charCode:Number = ch.charCodeAt(0);
      // "A".charCodeAt(0) == 65, "Z".charCodeAt(0) == 90
      // "a".charCodeAt(0) == 97, "z".charCodeAt(0) == 122
      return (charCode >= 65 && charCode <= 90) || (charCode >= 97 && charCode <= 122);
    }

    private function isSpace(ch:String):Boolean {
      var charCode:Number = ch.charCodeAt(0);
      // " " : 32, "\f": 12, "\n": 10, "\r": 13, "\t": 9, "\v": 11
      return (charCode >= 9 && charCode <= 13) || (charCode == 32);
    }

    private function lexGetToken():Token {
      var ret:Token = new Token();
      var state:int = LexerState.INITIAL_STATE; // 読み取り中のトークンの種別を保持
      var token:String = "";
      var ch:String;
      
      // ソースコードから1文字ずつ読み取る
      LOOP: while ((ch = sourceCodeCharArray.shift()) != null) {
	// log("Rest of src: " + sourceCodeCharArray.length);
	switch (state) {
	  case LexerState.INITIAL_STATE:
	  if (isDigit(ch)) {
	    // log("INITIAL_STATE: Digit " + ch)
	    token = token.concat(ch);
	    // log("token = " + token);
	    state = LexerState.INT_VALUE_STATE;
	  }
	  else if (isAlpha(ch) || ch == "_") {
	    // log("INITIAL_STATE: Alphabet " + ch)
	    token = token.concat(ch);
	    // log("token = " + token);
	    state = LexerState.IDENTIFIER_STATE;
	  }
	  else if (ch == '"') {
	    state = LexerState.STRING_STATE;
	  }
	  else if (inOperator(token, ch)) {
	    token = token.concat(ch);
	    // log("OPERATOR: " + token);
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
	    // log("INT_VALUE_STATE: Digit " + ch)
	    token = token.concat(ch);
	    // log("token = " + token);
	  }
	  else {
	    // log("INT_VALUE_STATE: not Digit " + ch)
	    // log("token = " + token);
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
	    sourceCodeCharArray.unshift(ch);
	    break LOOP;
	  }
	  else {
	    token = token.concat(ch);
	  }
	  break;

	  case LexerState.OPERATOR_STATE:
	  if (inOperator(token, ch)) {
	    // log("OPERATOR_STATE: is operator " + ch);
	    token = token.concat(ch);
	  }
	  else {
	    // log("OPERATOR_STATE: is not operator " + ch);
	    // log("IS OPERATOR_STATE?: " + (state == LexerState.OPERATOR_STATE));
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
      // log("AFTER LOOP:");
      // log("ch = " + ch + " state = " + state);
      
      if (ch == null) {
	if (state == LexerState.INITIAL_STATE || state == LexerState.COMMENT_STATE) {
	  ret.tokenKind = TokenKind.END_OF_FILE_TOKEN;
	  return ret;
	}
      }
      if (state == LexerState.IDENTIFIER_STATE) {
	if (keywordTable[token] != ret.tokenKind) {
	  ret = Token.getIdentifierToken(TokenKind.IDENTIFIER_TOKEN, token);
	}
      }
      else if (state == LexerState.OPERATOR_STATE) {
	ret.tokenKind = selectOperator(token);
      }
      
      return ret;
    }
  }
}

class LexerState {
  public static const INITIAL_STATE:int = 1;
  public static const INT_VALUE_STATE:int = 2;
  public static const IDENTIFIER_STATE:int = 3;
  public static const STRING_STATE:int = 4;
  public static const OPERATOR_STATE:int = 5;
  public static const COMMENT_STATE:int = 6;
}

class TokenKind {
  public static const INT_VALUE_TOKEN:int = 1; // 整数
  public static const IDENTIFIER_TOKEN:int = 2; // 識別子
  public static const STRING_LITERAL_TOKEN:int = 3; // 文字列
  public static const EQ_TOKEN:int = 4; // ==
  public static const NE_TOKEN:int = 5; // !=
  public static const GE_TOKEN:int = 6; // >=
  public static const LE_TOKEN:int = 7; // <=
  public static const ADD_TOKEN:int = 8; // +
  public static const SUB_TOKEN:int = 9; // -
  public static const MUL_TOKEN:int = 10; // *
  public static const DIV_TOKEN:int = 11; // /
  public static const ASSIGN_TOKEN:int = 12; // =
  public static const GT_TOKEN:int = 13; // >
  public static const LT_TOKEN:int = 14; // <
  public static const LEFT_PAREN_TOKEN:int = 15; // (
  public static const RIGHT_PAREN_TOKEN:int = 16; // )
  public static const LEFT_BRACE_TOKEN:int = 17; // {
  public static const RIGHT_BRACE_TOKEN:int = 18; //  }
  public static const COMMA_TOKEN:int = 19; // ,
  public static const SEMICOLON_TOKEN:int = 20; // ;
  public static const IF_TOKEN:int = 21; // if
  public static const ELSE_TOKEN:int = 22; // else
  public static const WHILE_TOKEN:int = 23; // while
  public static const GOTO_TOKEN:int = 24; // goto
  public static const GOSUB_TOKEN:int = 25; // gosub
  public static const RETURN_TOKEN:int = 26; // return
  public static const PRINT_TOKEN:int = 27; // print
  public static const END_OF_FILE_TOKEN:int = 28; // EOF 
}

class Token {
  private var _kind:int;
  private var _intValue:int;
  private var _stringValue:String;
  private var _identifier:String;

  /**
  int型の値を表すトークンオブジェクトを作成
  @param tokenKind トークンの種類(TokenKind)
  @param intValue 値
  @return tokenKindとintValueがセットされたトークンオブジェクト
  */
  public static function getIntToken(tokenKind:int, intValue:int):Token {
    var token:Token = new Token();
    token._kind = tokenKind;
    token._intValue = intValue;
    return token;
  }

  /**
  String型の値を表すトークンオブジェクトを作成
  @param tokenKind トークンの種類(TokenKind)
  @param stringValue 値
  @return tokenKindとstringValueがセットされたトークンオブジェクト
  */
  public static function getStringToken(tokenKind:int, stringValue:String):Token {
    var token:Token = new Token();
    token._kind = tokenKind;
    token._stringValue = stringValue;
    return token;
  }

  /**
  識別子を表すトークンオブジェクトを作成
  @param tokenKind トークンの種類(TokenKind)
  @param identifier 値
  @return tokenKindとidentifierがセットされたトークンオブジェクト
  */
  public static function getIdentifierToken(tokenKind:int, identifier:String):Token {
    var token:Token = new Token();
    token._kind = tokenKind;
    token._identifier = identifier
    return token;
  }

  public function get tokenKind():int {
    return _kind;
  }
  public function set tokenKind(kind:int):void {
    _kind = kind;
  }

  public function get intValue():int {
    return _intValue;
  }
  public function get stringValue():String {
    return _stringValue;
  }
  public function get identifier():String {
    return _identifier;
  }
}


