package Classes.UGC
{
   import Classes.Avatar.FarmAvatar;
   import Classes.FarmGameObject;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Rectangle;
   
   public class UGCAvatarFeedImage extends UGCFeedImage
   {
      
      private var m_imageClass:Class;
      
      private var BACKGROUND_TRANSLATION_Y:Number = 17;
      
      private var BACKGROUND_SCALE:Number = 0.8;
      
      public function UGCAvatarFeedImage(farmObject:FarmGameObject, featureName:String, imageClass:Class = null)
      {
         super(farmObject,featureName);
         this.m_imageClass = imageClass;
      }
      
      override protected function prepareBitmapData() : void
      {
         var background:Bitmap = null;
         var backgroundData:BitmapData = null;
         m_bitmapData = new BitmapData(width,height,true,16777215);
         var displayObj:DisplayObject = (m_farmObject as FarmAvatar).getAvatarClip() as DisplayObject;
         var bounds:Rectangle = displayObj.getBounds(displayObj.parent);
         displayObj.y -= bounds.top;
         displayObj.x -= bounds.left;
         m_farmObject.showHighlight(false);
         var mcWidth:Number = displayObj.width;
         var mcHeight:Number = displayObj.height;
         var scale:Number = 1;
         var xScale:Number = this.width / mcWidth;
         var yScale:Number = this.height / mcHeight;
         if(xScale < yScale)
         {
            scale = xScale;
         }
         else
         {
            scale = yScale;
         }
         var destWidth:Number = mcWidth * scale;
         var destHeight:Number = mcHeight * scale;
         var dx:Number = this.width - destWidth >> 1;
         var dy:Number = this.height - destHeight >> 1;
         m_transformMatrix.scale(scale,scale);
         m_transformMatrix.translate(dx,dy);
         if(this.m_imageClass != null)
         {
            background = new this.m_imageClass();
            backgroundData = background.bitmapData;
            m_bitmapData.draw(backgroundData);
            m_transformMatrix.translate(0,this.BACKGROUND_TRANSLATION_Y);
            m_transformMatrix.scale(this.BACKGROUND_SCALE,this.BACKGROUND_SCALE);
         }
         m_bitmapData.draw(displayObj.parent,m_transformMatrix,null,null,null,true);
         displayObj.y += bounds.top;
         displayObj.x += bounds.left;
      }
   }
}

