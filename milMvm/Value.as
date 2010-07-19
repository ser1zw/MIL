package milMvm {
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

    public static function createIntValue(intValue:int):Value {
      var value:Value = new Value();
      value._type = ValueType.INT_VALUE_TYPE;
      value._intValue = intValue;
      value._stringValue = null;
      return value;
    }

    public static function createStringValue(stringValue:String):Value {
      var value:Value = new Value();
      value._type = ValueType.STRING_VALUE_TYPE;
      value._intValue = 0;
      value._stringValue = stringValue;
      return value;
    }
  }
}

