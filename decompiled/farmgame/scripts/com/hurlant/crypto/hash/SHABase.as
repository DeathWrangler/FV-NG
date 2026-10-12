package com.hurlant.crypto.hash
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   public class SHABase implements IHash
   {
      
      public function SHABase()
      {
         super();
      }
      
      public function getHashSize() : uint
      {
         return 0;
      }
      
      public function toString() : String
      {
         return "sha";
      }
      
      public function getInputSize() : uint
      {
         return 64;
      }
      
      public function hash(src:ByteArray) : ByteArray
      {
         var savedLength:uint = 0;
         var savedEndian:String = null;
         var len:uint = 0;
         var a:Array = null;
         var i:uint = 0;
         var h:Array = null;
         var out:ByteArray = null;
         var words:uint = 0;
         savedLength = src.length;
         savedEndian = src.endian;
         src.endian = Endian.BIG_ENDIAN;
         len = savedLength * 8;
         while(src.length % 4 != 0)
         {
            src[src.length] = 0;
         }
         src.position = 0;
         a = [];
         for(i = 0; i < src.length; i += 4)
         {
            a.push(src.readUnsignedInt());
         }
         h = core(a,len);
         out = new ByteArray();
         words = getHashSize() / 4;
         for(i = 0; i < words; i++)
         {
            out.writeUnsignedInt(h[i]);
         }
         src.length = savedLength;
         src.endian = savedEndian;
         return out;
      }
      
      protected function core(x:Array, len:uint) : Array
      {
         return null;
      }
   }
}

