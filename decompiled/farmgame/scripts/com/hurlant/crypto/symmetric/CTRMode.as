package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CTRMode extends IVMode implements IMode
   {
      
      public function CTRMode(key:ISymmetricKey, padding:IPad = null)
      {
         super(key,padding);
      }
      
      public function toString() : String
      {
         return key.toString() + "-ctr";
      }
      
      private function core(src:ByteArray, iv:ByteArray) : void
      {
         var X:ByteArray = null;
         var Xenc:ByteArray = null;
         var i:uint = 0;
         var j:uint = 0;
         X = new ByteArray();
         Xenc = new ByteArray();
         X.writeBytes(iv);
         for(i = 0; i < src.length; i += blockSize)
         {
            Xenc.position = 0;
            Xenc.writeBytes(X);
            key.encrypt(Xenc);
            for(j = 0; j < blockSize; j++)
            {
               src[i + j] ^= Xenc[j];
            }
            for(j = blockSize - 1; j >= 0; j--)
            {
               ++X[j];
               if(X[j] != 0)
               {
                  break;
               }
            }
         }
      }
      
      public function decrypt(src:ByteArray) : void
      {
         var vector:ByteArray = null;
         vector = getIV4d();
         core(src,vector);
         padding.unpad(src);
      }
      
      public function encrypt(src:ByteArray) : void
      {
         var vector:ByteArray = null;
         padding.pad(src);
         vector = getIV4e();
         core(src,vector);
      }
   }
}

