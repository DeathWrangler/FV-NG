package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CFBMode extends IVMode implements IMode
   {
      
      public function CFBMode(key:ISymmetricKey, padding:IPad = null)
      {
         super(key,null);
      }
      
      public function toString() : String
      {
         return key.toString() + "-cfb";
      }
      
      public function decrypt(src:ByteArray) : void
      {
         var l:uint = 0;
         var vector:ByteArray = null;
         var tmp:ByteArray = null;
         var i:uint = 0;
         var chunk:uint = 0;
         var j:uint = 0;
         l = src.length;
         vector = getIV4d();
         tmp = new ByteArray();
         for(i = 0; i < src.length; i += blockSize)
         {
            key.encrypt(vector);
            chunk = i + blockSize < l ? blockSize : uint(l - i);
            tmp.position = 0;
            tmp.writeBytes(src,i,chunk);
            for(j = 0; j < chunk; j++)
            {
               src[i + j] ^= vector[j];
            }
            vector.position = 0;
            vector.writeBytes(tmp);
         }
      }
      
      public function encrypt(src:ByteArray) : void
      {
         var l:uint = 0;
         var vector:ByteArray = null;
         var i:uint = 0;
         var chunk:uint = 0;
         var j:uint = 0;
         l = src.length;
         vector = getIV4e();
         for(i = 0; i < src.length; i += blockSize)
         {
            key.encrypt(vector);
            chunk = i + blockSize < l ? blockSize : uint(l - i);
            for(j = 0; j < chunk; j++)
            {
               src[i + j] ^= vector[j];
            }
            vector.position = 0;
            vector.writeBytes(src,i,chunk);
         }
      }
   }
}

