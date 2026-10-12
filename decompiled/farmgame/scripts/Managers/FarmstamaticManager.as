package Managers
{
   import Classes.Farmstamatic.IFarmstamaticFeatureComponent;
   import Engine.Managers.TransactionManager;
   import Transactions.TCreateFarmstamaticPhoto;
   import by.blooddy.crypto.image.PNGEncoder;
   import flash.display.BitmapData;
   import flash.utils.ByteArray;
   import mx.utils.Base64Encoder;
   
   public class FarmstamaticManager
   {
      
      public function FarmstamaticManager()
      {
         super();
      }
      
      public static function getEncodedImage(bitmapData:BitmapData) : String
      {
         var encoder:Base64Encoder = null;
         var screenshotBase64:String = null;
         var encodedImage:String = "";
         var pngBytes:ByteArray = PNGEncoder.encode(bitmapData);
         if(pngBytes)
         {
            encoder = new Base64Encoder();
            encoder.encodeBytes(pngBytes);
            screenshotBase64 = encoder.toString();
            if(screenshotBase64)
            {
               encodedImage = screenshotBase64;
            }
         }
         return encodedImage;
      }
      
      public static function sendSnapshot(bitmapData:BitmapData, callback:Function = null, featureComponent:IFarmstamaticFeatureComponent = null) : void
      {
         var encodedImage:String = FarmstamaticManager.getEncodedImage(bitmapData);
         var featureName:String = featureComponent ? featureComponent.getFeatureName() : "farmstamatic";
         TransactionManager.addTransaction(new TCreateFarmstamaticPhoto(featureName,encodedImage,"feed_post",callback,featureComponent),true);
      }
   }
}

