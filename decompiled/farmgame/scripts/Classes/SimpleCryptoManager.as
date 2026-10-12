package Classes
{
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.crypto.symmetric.IPad;
   import com.hurlant.crypto.symmetric.PKCS5;
   import com.hurlant.util.Base64;
   import com.hurlant.util.Hex;
   import flash.display.Sprite;
   import flash.utils.ByteArray;
   
   public class SimpleCryptoManager extends Sprite
   {
      
      private var type:String = "simple-des-ecb";
      
      private var key:ByteArray;
      
      public function SimpleCryptoManager()
      {
         super();
      }
      
      public function init() : void
      {
         this.key = Hex.toArray(Hex.fromString("HaCkMeNt"));
      }
      
      public function encrypt(txt:String = "") : String
      {
         var data:ByteArray = Hex.toArray(Hex.fromString(txt));
         var pad:IPad = new PKCS5();
         var mode:ICipher = Crypto.getCipher(this.type,this.key,pad);
         pad.setBlockSize(mode.getBlockSize());
         mode.encrypt(data);
         return Base64.encodeByteArray(data);
      }
      
      public function decrypt(txt:String = "") : String
      {
         var data:ByteArray = Base64.decodeToByteArray(txt);
         var pad:IPad = new PKCS5();
         var mode:ICipher = Crypto.getCipher(this.type,this.key,pad);
         pad.setBlockSize(mode.getBlockSize());
         mode.decrypt(data);
         return Hex.toString(Hex.fromArray(data));
      }
   }
}

