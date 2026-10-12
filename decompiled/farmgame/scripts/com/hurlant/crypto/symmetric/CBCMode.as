package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CBCMode extends IVMode implements IMode
   {
      
      public function CBCMode(key:ISymmetricKey, padding:IPad = null)
      {
         super(key,padding);
      }
      
      public function toString() : String
      {
         return key.toString() + "-cbc";
      }
      
      public function decrypt(src:ByteArray) : void
      {
         var vector:ByteArray = null;
         var tmp:ByteArray = null;
         var i:uint = 0;
         var j:uint = 0;
         vector = getIV4d();
         tmp = new ByteArray();
         for(i = 0; i < src.length; i += blockSize)
         {
            tmp.position = 0;
            tmp.writeBytes(src,i,blockSize);
            key.decrypt(src,i);
            for(j = 0; j < blockSize; j++)
            {
               src[i + j] ^= vector[j];
            }
            vector.position = 0;
            vector.writeBytes(tmp,0,blockSize);
         }
         padding.unpad(src);
      }
      
      public function encrypt(src:ByteArray) : void
      {
         var vector:ByteArray = null;
         var i:uint = 0;
         var j:uint = 0;
         padding.pad(src);
         vector = getIV4e();
         for(i = 0; i < src.length; i += blockSize)
         {
            for(j = 0; j < blockSize; j++)
            {
               src[i + j] ^= vector[j];
            }
            key.encrypt(src,i);
            vector.position = 0;
            vector.writeBytes(src,i,blockSize);
         }
      }
   }
}

