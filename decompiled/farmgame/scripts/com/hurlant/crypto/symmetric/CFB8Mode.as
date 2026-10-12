package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CFB8Mode extends IVMode implements IMode
   {
      
      public function CFB8Mode(key:ISymmetricKey, padding:IPad = null)
      {
         super(key,null);
      }
      
      public function toString() : String
      {
         return key.toString() + "-cfb8";
      }
      
      public function decrypt(src:ByteArray) : void
      {
         var vector:ByteArray = null;
         var tmp:ByteArray = null;
         var i:uint = 0;
         var c:uint = 0;
         var j:uint = 0;
         vector = getIV4d();
         tmp = new ByteArray();
         for(i = 0; i < src.length; i++)
         {
            c = uint(src[i]);
            tmp.position = 0;
            tmp.writeBytes(vector);
            key.encrypt(vector);
            src[i] ^= vector[0];
            for(j = 0; j < blockSize - 1; j++)
            {
               vector[j] = tmp[j + 1];
            }
            vector[blockSize - 1] = c;
         }
      }
      
      public function encrypt(src:ByteArray) : void
      {
         var vector:ByteArray = null;
         var tmp:ByteArray = null;
         var i:uint = 0;
         var j:uint = 0;
         vector = getIV4e();
         tmp = new ByteArray();
         for(i = 0; i < src.length; i++)
         {
            tmp.position = 0;
            tmp.writeBytes(vector);
            key.encrypt(vector);
            src[i] ^= vector[0];
            for(j = 0; j < blockSize - 1; j++)
            {
               vector[j] = tmp[j + 1];
            }
            vector[blockSize - 1] = src[i];
         }
      }
   }
}

