package by.blooddy.crypto.image
{
   import flash.display.BitmapData;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public final class PNGEncoder
   {
      
      public function PNGEncoder()
      {
         super();
         Error.throwError(ArgumentError,2012,getQualifiedClassName(this));
      }
      
      public static function encode(image:BitmapData, filter:uint = 0) : ByteArray
      {
         var size:uint = image.width * image.height;
         if(size >= 32 && size <= 64)
         {
            return PNG8Encoder.encode(image,null,filter);
         }
         return PNG24Encoder.encode(image,filter);
      }
   }
}

