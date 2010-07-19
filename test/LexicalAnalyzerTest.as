
package test {
  import flash.display.Sprite;
  import milLexicalAnalyzer.*;
  
  [SWF(width="400", height="300", backgroundColor="#ccccff")] 
  public class LexicalAnalyzerTest extends Sprite {
    
    public function LexicalAnalyzerTest() {
      
    }

    public static function testTest():Boolean {
      var src:String = "1 * 2 + 8 / 2;";
      var expected:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 1),
	  Token.getIdentifierToken(TokenKind.MUL_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 2),
	  Token.getIdentifierToken(TokenKind.ADD_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 8),
	  Token.getIdentifierToken(TokenKind.DIV_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 2),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);
      return test(src, expected);
    }

    public static function testAdd():Boolean {
      var src1:String = "1 + 2;";
      var expected1:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 1),
	  Token.getIdentifierToken(TokenKind.ADD_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 2),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);
      var src2:String = "100 + 200;";
      var expected2:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 100),
	  Token.getIdentifierToken(TokenKind.ADD_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 200),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);

      return test(src1, expected1) && test(src2, expected2);
    }

    public static function testSub():Boolean {
      var src1:String = "1 - 2;";
      var expected1:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 1),
	  Token.getIdentifierToken(TokenKind.SUB_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 2),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);
      var src2:String = "100 - 200;";
      var expected2:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 100),
	  Token.getIdentifierToken(TokenKind.SUB_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 200),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);

      return test(src1, expected1) && test(src2, expected2);
    }

    public static function testMul():Boolean {
      var src1:String = "1 * 2;";
      var expected1:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 1),
	  Token.getIdentifierToken(TokenKind.MUL_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 2),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);
      var src2:String = "100 * 200;";
      var expected2:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 100),
	  Token.getIdentifierToken(TokenKind.MUL_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 200),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);

      return test(src1, expected1) && test(src2, expected2);
    }

    public static function testDiv():Boolean {
      var src1:String = "1 / 2;";
      var expected1:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 1),
	  Token.getIdentifierToken(TokenKind.DIV_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 2),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);
      var src2:String = "100 / 200;";
      var expected2:Vector.<Token> = Vector.<Token>([
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 100),
	  Token.getIdentifierToken(TokenKind.DIV_TOKEN, null),
	  Token.getIntToken(TokenKind.INT_VALUE_TOKEN, 200),
	  Token.getIdentifierToken(TokenKind.SEMICOLON_TOKEN, null),
	  Token.getIdentifierToken(TokenKind.END_OF_FILE_TOKEN, null)
	]);

      return test(src1, expected1) && test(src2, expected2);
    }

    private static function test(src:String, expected:Vector.<Token>):Boolean {
      var i:int;
      var token:Token;
      var lex:LexicalAnalyzer = new LexicalAnalyzer(src);
      var result:Vector.<Token> = new Vector.<Token>();
      do {
	token = lex.lexGetToken();
	result.push(token);
      } while (token.kind != TokenKind.END_OF_FILE_TOKEN);
      if (result.length != expected.length) {
	log("invalid size");
	return false;
      }
      for (i = 0; i < result.length; i++) {
	if (result[i].kind != expected[i].kind
	  || result[i].intValue != expected[i].intValue
	  || result[i].stringValue != expected[i].stringValue
	  || result[i].identifier != expected[i].identifier) {
	  log("at " + i + ": expected is " + expected[i] + " but was " + result[i]);
	  return false;
	}
      }
      return true;
    }
  }
}

