package Classes.UGC
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Managers.UserContentManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   
   public class UGCTwoIconImage extends UGCFeedImage
   {
      
      private var m_imageClass:Class;
      
      private var BACKGROUND_TRANSLATION_Y:Number = 17;
      
      private var BACKGROUND_SCALE:Number = 0.8;
      
      private var m_mainImageLoader:ImageLoader = null;
      
      private var m_secondImageLoader:ImageLoader = null;
      
      private var m_tempData:Object = {};
      
      public function UGCTwoIconImage(featureName:String, mainItem:FarmItem, secondItem:FarmItem, autoCallback:Function)
      {
         this.m_mainImageLoader = ImageLoader.getInstance(mainItem.icon);
         this.m_mainImageLoader.getContent(this.onMainImageLoaded);
         this.m_secondImageLoader = ImageLoader.getInstance(secondItem.icon);
         this.m_secondImageLoader.getContent(this.onSecondImageLoaded);
         this.m_tempData.autoCallback = autoCallback;
         super(null,featureName);
      }
      
      protected function onMainImageLoaded(content:DisplayObject, info:Object = null) : void
      {
         if(content != null)
         {
            this.m_tempData.mainImage = content;
            this.createFeedIcon();
         }
      }
      
      protected function onSecondImageLoaded(content:DisplayObject, info:Object = null) : void
      {
         if(content != null)
         {
            this.m_tempData.secondImage = content;
            this.createFeedIcon();
         }
      }
      
      private function createFeedIcon() : void
      {
         if(this.m_tempData.mainImage != null && this.m_tempData.secondImage != null)
         {
            UserContentManager.getInstance().createFeedImage(this,this.m_tempData.autoCallback);
         }
      }
      
      override protected function resizeBitmapData() : void
      {
      }
      
      override protected function prepareBitmapData() : void
      {
         var transformMatrix:Matrix = null;
         m_bitmapData = new BitmapData(width,height,true,16777215);
         this.resizeBitmapData();
         var displayObj:DisplayObject = this.m_tempData.mainImage;
         m_bitmapData.draw(displayObj,m_transformMatrix);
         if(this.m_tempData.secondImage != null)
         {
            transformMatrix = new Matrix();
            transformMatrix.scale(0.7,0.7);
            transformMatrix.translate(40,35);
            m_bitmapData.draw(this.m_tempData.secondImage,transformMatrix);
         }
      }
   }
}

