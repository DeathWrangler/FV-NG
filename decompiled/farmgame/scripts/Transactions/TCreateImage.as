package Transactions
{
   public class TCreateImage extends TFarmTransaction
   {
      
      protected var m_featureName:String = null;
      
      protected var m_encodedImage:String = null;
      
      protected var m_imageType:String = null;
      
      protected var m_callback:Function = null;
      
      public function TCreateImage(featureName:String, encodedImage:String, imageType:String, callback:Function = null)
      {
         this.m_featureName = featureName;
         this.m_encodedImage = encodedImage;
         this.m_imageType = imageType;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserContentService.onCreateImage",this.m_featureName,this.m_encodedImage,this.m_imageType);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

