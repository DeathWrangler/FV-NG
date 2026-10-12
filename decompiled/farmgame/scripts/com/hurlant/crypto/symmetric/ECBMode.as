package com.hurlant.crypto.symmetric
{
   import com.hurlant.util.Memory;
   import flash.utils.ByteArray;
   
   public class ECBMode implements IMode, ICipher
   {
      
      private var key:ISymmetricKey;
      
      private var padding:IPad;
      
      public function ECBMode(key:ISymmetricKey, padding:IPad = null)
      {
         super();
         this.key = key;
         if(padding == null)
         {
            padding = new PKCS5(key.getBlockSize());
         }
         else
         {
            padding.setBlockSize(key.getBlockSize());
         }
         this.padding = padding;
      }
      
      public function encrypt(src:ByteArray) : void
      {
         var blockSize:uint = 0;
         var tmp:ByteArray = null;
         var dst:ByteArray = null;
         var i:uint = 0;
         padding.pad(src);
         src.position = 0;
         blockSize = key.getBlockSize();
         tmp = new ByteArray();
         dst = new ByteArray();
         for(i = 0; i < src.length; i += blockSize)
         {
            tmp.length = 0;
            src.readBytes(tmp,0,blockSize);
            key.encrypt(tmp);
            dst.writeBytes(tmp);
         }
         src.length = 0;
         src.writeBytes(dst);
      }
      
      public function decrypt(src:ByteArray) : void
      {
         var blockSize:uint = 0;
         var tmp:ByteArray = null;
         var dst:ByteArray = null;
         var i:uint = 0;
         src.position = 0;
         blockSize = key.getBlockSize();
         if(src.length % blockSize != 0)
         {
            throw new Error("ECB mode cipher length must be a multiple of blocksize " + blockSize);
         }
         tmp = new ByteArray();
         dst = new ByteArray();
         for(i = 0; i < src.length; i += blockSize)
         {
            tmp.length = 0;
            src.readBytes(tmp,0,blockSize);
            key.decrypt(tmp);
            dst.writeBytes(tmp);
         }
         padding.unpad(dst);
         src.length = 0;
         src.writeBytes(dst);
      }
      
      public function dispose() : void
      {
         key.dispose();
         key = null;
         padding = null;
         Memory.gc();
      }
      
      public function getBlockSize() : uint
      {
         return key.getBlockSize();
      }
      
      public function toString() : String
      {
         return key.toString() + "-ecb";
      }
   }
}

