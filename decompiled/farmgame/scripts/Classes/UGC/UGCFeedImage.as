package Classes.UGC
{
   import Classes.FarmGameObject;
   
   public class UGCFeedImage extends UGCImage
   {
      
      public function UGCFeedImage(farmObject:FarmGameObject, featureName:String)
      {
         var width:Number = UGCImage.FEED_PREFERRED_WIDTH;
         var height:Number = UGCImage.FEED_PREFERRED_HEIGHT;
         if(Global.flashHotParams["CHANGE_STREAMPUBLISH_ICONS_200"])
         {
            width = UGCImage.DEFAULT_PREFERRED_WIDTH;
            height = UGCImage.DEFAULT_PREFERRED_HEIGHT;
         }
         super(farmObject,featureName,width,height);
      }
   }
}

