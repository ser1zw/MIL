// -*- mode: actionscript; coding: utf-8-unix -*- 
package milIde {
  import flash.display.Sprite;
  import milParser.Parser;
  import milMvm.Mvm;
  import com.bit101.components.Style;
  import com.bit101.components.Label;
  import com.bit101.components.PushButton;
  import com.bit101.components.RadioButton;
  import com.bit101.components.TextArea;
  import flash.events.MouseEvent;
  
  /** MILのIDE */
  public class MilIDE extends Sprite {
    private var editorLabel:Label;
    private var stdoutLabel:Label;
    private var editor:TextArea;
    private var stdout:TextArea;
    private var button:PushButton;
    private var radio1:RadioButton;
    private var radio2:RadioButton;
    public function set editorText(src:String):void { editor.text = src; };
    
    /** コンストラクタ */
    public function MilIDE() {
      Style.embedFonts = false;
      Style.fontName = "_typewriter";
      editorLabel = new Label(this, 0, 5, "Editor");
      editor = new TextArea(this, 0, editorLabel.y + editorLabel.height);
      editor.width = 250;
      editor.height = 120;
      stdoutLabel = new Label(this, 0, editor.y + editor.height + 10, "Output");
      stdout = new TextArea(this, 0, stdoutLabel.y + stdoutLabel.height);
      stdout.width = editor.width;
      stdout.height = 100;
      button = new PushButton(this, editor.x + editor.width + 20, editor.y, "Run",
	function(e:MouseEvent):void {
	  stdout.text = "";
	  run(editor.text, radio2.selected);
	});
      button.width = 50;

      radio1 = new RadioButton(this, button.x, button.y + button.height + 20)
      radio1.label = "Run Bytecode";
      radio1.selected = true;
      radio2 = new RadioButton(this, radio1.x, radio1.y + radio1.height + 5);
      radio2.label = "Dump Assembly Code";
    }

    /**
    MILのコードを実行
    @param sourceCode ソースコード
    @param dumpAssemblyCodeMode trueならバイトコードを実行するかわりにアセンブリコードを出力
    */
    private function run(sourceCode:String, dumpAssemblyCodeMode:Boolean = false):void {
      try {
	var parser:Parser = new Parser(sourceCode);
	var mvm:Mvm = new Mvm(parser.bytecode, parser.strPool, function(msg:String):void {
	    stdout.text += msg + "\n";
	  });
	
	if (dumpAssemblyCodeMode) {
	  stdout.text = mvm.dumpAsmCode().join("\n");
	}
	else {
	  mvm.execute();
	}
      }
      catch (e:Error) {
	stdout.text = e.toString();
      }
    }
  }
}

