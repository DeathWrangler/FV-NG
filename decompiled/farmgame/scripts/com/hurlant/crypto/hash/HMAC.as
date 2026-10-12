package com.hurlant.crypto.hash
{
   import flash.utils.ByteArray;
   
   public class HMAC
   {
      
      private var bits:uint;
      
      private var hash:IHash;
      
      public function HMAC(hash:IHash, bits:uint = 0)
      {
         super();
         this.hash = hash;
         this.bits = bits;
      }
      
      public function getHashSize() : uint
      {
         if(bits != 0)
         {
            return bits / 8;
         }
         return hash.getHashSize();
      }
      
      public function dispose() : void
      {
         hash = null;
         bits = 0;
      }
      
      public function compute(key:ByteArray, data:ByteArray) : ByteArray
      {
         var hashKey:ByteArray = null;
         var innerKey:ByteArray = null;
         var outerKey:ByteArray = null;
         var i:uint = 0;
         var innerHash:ByteArray = null;
         var outerHash:ByteArray = null;
         if(key.length > hash.getInputSize())
         {
            hashKey = hash.hash(key);
         }
         else
         {
            hashKey = new ByteArray();
            hashKey.writeBytes(key);
         }
         while(hashKey.length < hash.getInputSize())
         {
            hashKey[hashKey.length] = 0;
         }
         innerKey = new ByteArray();
         outerKey = new ByteArray();
         for(i = 0; i < hashKey.length; i++)
         {
            innerKey[i] = hashKey[i] ^ 0x36;
            outerKey[i] = hashKey[i] ^ 0x5C;
         }
         innerKey.position = hashKey.length;
         innerKey.writeBytes(data);
         innerHash = hash.hash(innerKey);
         outerKey.position = hashKey.length;
         outerKey.writeBytes(innerHash);
         outerHash = hash.hash(outerKey);
         if(bits > 0 && bits < 8 * outerHash.length)
         {
            outerHash.length = bits / 8;
         }
         return outerHash;
      }
      
      public function toString() : String
      {
         return "hmac-" + (bits > 0 ? bits + "-" : "") + hash.toString();
      }
   }
}

