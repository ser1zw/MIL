package milParser {
  /** ラベル */
  public class Label {
    public var identifier:String;
    public var address:int;
    
    /**
    コンストラクタ
    @param identifier 識別子
    @param address アドレス
    */
    public function Label(identifier:String, address:int) {
      this.identifier = identifier;
      this.address = address;
    }
  }
}

