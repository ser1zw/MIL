// -*- mode: actionscript; coding: undecided-unix -*- 
package milMvm {
  /** MVMで扱うデータ */
  public class Value {
    private var _type:int;
    private var _intValue:int;
    private var _stringValue:String;

    public function get type():int { return _type; }

    public function get intValue():int {
      if (_type == ValueType.INT_VALUE_TYPE) {
	return _intValue;
      }
      else {
	throw new Error("This is INT_VALUE.");
      }
    };

    public function get stringValue():String {
      if (_type == ValueType.STRING_VALUE_TYPE) {
	return _stringValue;
      }
      else {
	throw new Error("This is STRING_VALUE.");
      }
    };

    /**
    int型の値を表す値を作成
    @param intValue 値
    @return Valueオブジェクト
    */
    public static function createIntValue(intValue:int):Value {
      var value:Value = new Value();
      value._type = ValueType.INT_VALUE_TYPE;
      value._intValue = intValue;
      value._stringValue = null;
      return value;
    }

    /**
    String型の値を表す値を作成
    @param stringValue 値
    @return Valueオブジェクト
    */
    public static function createStringValue(stringValue:String):Value {
      var value:Value = new Value();
      value._type = ValueType.STRING_VALUE_TYPE;
      value._intValue = 0;
      value._stringValue = stringValue;
      return value;
    }
  }
}


