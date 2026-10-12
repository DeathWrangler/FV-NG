package Classes.UGC
{
   import Classes.FarmGameObject;
   import com.adobe.images.PNGEncoder;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.utils.ByteArray;
   import mx.utils.Base64Encoder;
   
   public class UGCImage
   {
      
      public static const FEED_PREFERRED_WIDTH:Number = 100;
      
      public static const FEED_PREFERRED_HEIGHT:Number = 100;
      
      public static const DEFAULT_PREFERRED_WIDTH:Number = 200;
      
      public static const DEFAULT_PREFERRED_HEIGHT:Number = 200;
      
      protected var m_farmObject:FarmGameObject = null;
      
      protected var m_featureName:String = "";
      
      protected var m_width:Number;
      
      protected var m_height:Number;
      
      protected var m_bitmapData:BitmapData = null;
      
      protected var m_transformMatrix:Matrix = new Matrix();
      
      public function UGCImage(farmObject:FarmGameObject, featureName:String, preferredWidth:Number = 200, preferredHeight:Number = 200)
      {
         super();
         this.m_farmObject = farmObject;
         this.m_featureName = featureName;
         this.m_width = preferredWidth;
         this.m_height = preferredHeight;
      }
      
      public function createEncoded() : String
      {
         var encoder:Base64Encoder = null;
         var screenshotBase64:String = null;
         this.prepareBitmapData();
         var encodedImage:String = "";
         var pngBytes:ByteArray = PNGEncoder.encode(this.m_bitmapData);
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
      
      public function getBitmapData() : BitmapData
      {
         if(this.m_bitmapData == null)
         {
            this.prepareBitmapData();
         }
         return this.m_bitmapData;
      }
      
      protected function prepareBitmapData() : void
      {
         this.m_bitmapData = new BitmapData(this.width,this.height,true,16777215);
         this.resizeBitmapData();
         this.m_farmObject.showHighlight(false);
         var displayObj:DisplayObject = this.m_farmObject.getDisplayObject();
         this.m_bitmapData.draw(displayObj,this.m_transformMatrix);
      }
      
      protected function resizeBitmapData() : void
      {
         var displayObj:DisplayObject = this.m_farmObject.getDisplayObject();
         var newHeight:Number = 0;
         var newWidth:Number = 0;
         if(displayObj.height > displayObj.width)
         {
            newHeight = this.height;
            newWidth = newHeight * displayObj.width / displayObj.height;
         }
         else
         {
            newWidth = this.width;
            newHeight = newWidth * displayObj.height / displayObj.width;
         }
         var realWidth:Number = displayObj.width / displayObj.scaleX;
         var realHeight:Number = displayObj.height / displayObj.scaleY;
         var heightScale:Number = newHeight / realHeight;
         var widthScale:Number = newWidth / realWidth;
         this.m_transformMatrix.scale(widthScale,heightScale);
      }
      
      public function applyConfigTransforms(obj:Object) : void
      {
         var objName:String = null;
         var scaleData:Object = null;
         var translateData:Object = null;
         var rotateData:Object = null;
         if(null != obj)
         {
            for(objName in obj)
            {
               switch(objName)
               {
                  case "scale":
                     scaleData = obj[objName];
                     this.scale(Number(scaleData["scaleX"]),Number(scaleData["scaleY"]));
                     break;
                  case "translate":
                     translateData = obj[objName];
                     this.translate(Number(translateData["translateX"]),Number(translateData["translateY"]));
                     break;
                  case "rotate":
                     rotateData = obj[objName];
                     this.rotate(Number(rotateData["angle"]));
               }
            }
         }
      }
      
      public function scale(dx:Number, dy:Number) : void
      {
         this.m_transformMatrix.scale(dx,dy);
      }
      
      public function translate(dx:Number, dy:Number) : void
      {
         this.m_transformMatrix.translate(dx,dy);
      }
      
      public function rotate(angle:Number) : void
      {
         this.m_transformMatrix.rotate(angle);
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function get width() : Number
      {
         return this.m_width;
      }
      
      public function get height() : Number
      {
         return this.m_height;
      }
   }
}

