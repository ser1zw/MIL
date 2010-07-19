package {
  import flash.display.Sprite;
  import milLexicalAnalyzer.*;
  import milParser.*;
  import test.*;
  import milMvm.*;
  import flash.text.TextField;
  import com.bit101.components.*;
  import flash.events.*;

  [SWF(width="400", height="300", backgroundColor="#ccccff")] 
  public class Main extends Sprite {
    private var editor:TextField;
    private var button:PushButton;
    private const FIBONACCI:String = "f0 = 0;\nf1 = 1;\nf2 = 0;\nprint(f0);\nprint(f1);\nwhile(f2 < 10) {\n    f2 = f0 + f1;\n    print(f2);\n    f0 = f1;\n    f1 = f2;\n}\n";
    
    public function Main() {
      editor = new TextField();
      editor.width = 300;
      editor.height = 200;
      editor.x = 0;
      editor.y = 50;
      editor.background = true;
      editor.backgroundColor = 0xffffff;
      editor.type = "input";
      editor.multiline = true;
      editor.border = true;
      // editor.text = "a = 1;\nif (a == 1) {\n  b = 1;\n} else {\n  c = 1;\n}\n";
      // editor.text = FIBONACCI;
      editor.text = "print(\"miku\");";
      addChild(editor);

      button = new PushButton(this, 350, 50, "run", function(e:MouseEvent):void {
	  // lexSample2(editor.text);
	  // parserSample(editor.text);
	  mvmSample(editor.text);
	});
      // log(ParserTest.whileTest());
    }

    private function mvmSample(src:String):void {
      try {
	var parser:Parser = new Parser(src);
	var mvm:Mvm = new Mvm(parser.bytecode, parser.strPool);
	mvm.execute();
      }
      catch (e:Error) {
	log(e);
      }
    }

    private function parserSample(src:String):void {
      try {
	var parser:Parser = new Parser(src);
	for each (var c:int in parser.bytecode) {
	  log(c);
	}
      }
      catch (e:Error) {
	log(e);
      }
    }
    private function lexSample2(src:String):void {
      var token:Token;
      var lex:LexicalAnalyzer = new LexicalAnalyzer(src);
      var table:Array = ["dummy", "整数", "識別子", "文字列", "==", "!=", ">=", "<=", "+", "-", "*", "/", "=", ">", "<", "(", ")", "{", " }", ",", ";", "if", "else", "while", "goto", "gosub", "return", "print", "EOF"];
      do {
	token = lex.lexGetToken();
	if (token.kind == TokenKind.INT_VALUE_TOKEN) {
	  log(token.intValue + " 整数");
	}
	else if (token.kind == TokenKind.STRING_LITERAL_TOKEN) {
	  log(token.stringValue + " 文字列リテラル");
	}
	else if (token.kind == TokenKind.IDENTIFIER_TOKEN) {
	  log(token.identifier + " 識別子");
	}
	else {
	  log(table[token.kind]);
	}
      } while(token.kind != TokenKind.END_OF_FILE_TOKEN);
    }

    private function lexSample(src:String):void {
      var token:Token;
      var lex:LexicalAnalyzer = new LexicalAnalyzer(src);
      // log(src);
      do {
	token = lex.lexGetToken();
	
	if (token.kind == TokenKind.INT_VALUE_TOKEN) {
	  log(token.intValue + " 整数");
	}
	else if (token.kind == TokenKind.IDENTIFIER_TOKEN) {
	  // log(token.kind + " " + token.identifier + " 識別子");
	  log(token + " 識別子");
	}
	else if (token.kind == TokenKind.STRING_LITERAL_TOKEN) {
	  // log(token.stringValue + " 文字列リテラル");
	  log(token + " 文字列リテラル");
	}
	else if (token.kind >= TokenKind.EQ_TOKEN && token.kind <= TokenKind.SEMICOLON_TOKEN) {
	  // log(token.kind + " 演算子または区切り子");
	  log(token + " 演算子または区切り子");
	}
	else if (token.kind != TokenKind.END_OF_FILE_TOKEN && token.kind >= TokenKind.IF_TOKEN) {
	  // log(keywordTable[token.kind - TokenKind.IF_TOKEN] + " 予約語");
	  log(token + "予約語");
	}
      } while(token.kind != TokenKind.END_OF_FILE_TOKEN);
    }
  }
}

