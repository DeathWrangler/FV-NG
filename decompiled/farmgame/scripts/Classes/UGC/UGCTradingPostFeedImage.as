package Classes.UGC
{
   import Classes.FarmGameObject;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   
   public class UGCTradingPostFeedImage extends UGCFeedImage
   {
      
      private var m_imageClass:Class;
      
      private var BACKGROUND_TRANSLATION_Y:Number = 17;
      
      private var BACKGROUND_SCALE:Number = 0.8;
      
      private var m_cropImage:DisplayObject = null;
      
      public function UGCTradingPostFeedImage(farmObject:FarmGameObject, featureName:String, cropImage:DisplayObject)
      {
         super(farmObject,featureName);
         this.m_cropImage = cropImage;
      }
      
      override protected function prepareBitmapData() : void
      {
         var cropTransformMatrix:Matrix = null;
         m_bitmapData = new BitmapData(width,height,true,16777215);
         resizeBitmapData();
         m_farmObject.showHighlight(false);
         var displayObj:DisplayObject = m_farmObject.getDisplayObject();
         m_bitmapData.draw(displayObj,m_transformMatrix);
         if(this.m_cropImage != null)
         {
            cropTransformMatrix = new Matrix();
            cropTransformMatrix.scale(0.5,0.5);
            cropTransformMatrix.translate(0,50);
            m_bitmapData.draw(this.m_cropImage,cropTransformMatrix);
         }
      }
   }
}

