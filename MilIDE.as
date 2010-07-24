package {
  import flash.display.Sprite;
  import milParser.Parser;
  import milMvm.Mvm;
  import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  import com.bit101.components.PushButton;
  import com.bit101.components.RadioButton;
  import flash.events.MouseEvent;
  
  [SWF(width="400", height="300", backgroundColor="#ccccff")] 
  /** MILのIDE */
  public class MilIDE extends Sprite {
    private var editor:TextField;
    private var stdout:TextField;
    private var format:TextFormat;
    private var button:PushButton;
    private var radio1:RadioButton;
    private var radio2:RadioButton;
    private const FIBONACCI:String = "f0 = 0;\nf1 = 1;\nf2 = 0;\nprint(f0);\nprint(f1);\nwhile(f2 < 10) {\n    f2 = f0 + f1;\n    print(f2);\n    f0 = f1;\n    f1 = f2;\n}\n";
    
    public function MilIDE() {
      format = new TextFormat();
      format.font ="_等幅";
      format.size = 10;

      editor = new TextField();
      editor.width = 200;
      editor.height = 200;
      editor.x = 0;
      editor.y = 20;
      editor.background = true;
      editor.backgroundColor = 0xffffff;
      editor.type = TextFieldType.INPUT;
      editor.multiline = true;
      editor.border = true;
      editor.defaultTextFormat = format;
      editor.text = FIBONACCI;
      addChild(editor);

      stdout = new TextField();
      stdout.width = 200;
      stdout.height = 200;
      stdout.x = editor.x + editor.width + 20;
      stdout.y = editor.y;
      stdout.background = true;
      stdout.backgroundColor = 0xffffff;
      stdout.multiline = true;
      stdout.border = true;
      stdout.defaultTextFormat = format;
      addChild(stdout);

      button = new PushButton(this, editor.x, editor.y + editor.height + 20, "Run",
	function(e:MouseEvent):void {
	  stdout.text = "";
	  run(editor.text, radio2.selected);
	});
      button.width = 50;

      radio1 = new RadioButton(this, button.x + button.width + 20, button.y)
      radio1.label = "Run Bytecode";
      radio1.selected = true;
      radio2 = new RadioButton(this, radio1.x, radio1.y + radio1.height + 5);
      radio2.label = "Dump Assembly Code";
    }

    /**
    MILのコードを実行
    @param sourceCode ソースコード
    @param dumpAssemblyCodeMode バイトコードを実行するかわりにアセンブリコードを出力
    */
    private function run(sourceCode:String, dumpAssemblyCodeMode:Boolean = false):void {
      try {
	var parser:Parser = new Parser(sourceCode);
	var mvm:Mvm = new Mvm(parser.bytecode, parser.strPool, function(msg:String):void {
	    stdout.appendText(msg + "\n");
	  });
	
	if (dumpAssemblyCodeMode) {
	  stdout.appendText(mvm.dumpAsmCode().join("\n"));
	}
	else {
	  mvm.execute();
	}
      }
      catch (e:Error) {
	stdout.appendText(e.toString());
      }
    }
  }
}

