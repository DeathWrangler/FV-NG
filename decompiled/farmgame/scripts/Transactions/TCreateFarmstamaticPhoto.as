package Transactions
{
   import Classes.Farmstamatic.IFarmstamaticFeatureComponent;
   
   public class TCreateFarmstamaticPhoto extends TCreateImage
   {
      
      private static const FARM_QUEST_METHOD:String = "onCreateFarmstamaticPhoto";
      
      private var m_featureComponent:IFarmstamaticFeatureComponent;
      
      public function TCreateFarmstamaticPhoto(featureName:String, encodedImage:String, imageType:String, callback:Function = null, featureComponent:IFarmstamaticFeatureComponent = null)
      {
         super(featureName,encodedImage,imageType,callback);
         this.m_featureComponent = featureComponent;
      }
      
      override public function perform() : void
      {
         var params:Object = this.m_featureComponent ? this.m_featureComponent.getSubmitPhotoParams() : null;
         signedCall("UserContentService.onCreateFarmstamaticPhoto",m_featureName,m_encodedImage,m_imageType,params);
      }
      
      override public function getTransactionData() : Object
      {
         var transactionData:Object = null;
         var key:String = null;
         var result:Object = new Object();
         result.method = FARM_QUEST_METHOD;
         if(this.m_featureComponent)
         {
            transactionData = this.m_featureComponent.getSubmitPhotoTransactionData();
            if(transactionData)
            {
               for(key in transactionData)
               {
                  result[key] = transactionData[key];
               }
            }
         }
         return result;
      }
   }
}

