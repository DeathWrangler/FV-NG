package Classes.util
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class DisplayObjectUtils
   {
      
      public function DisplayObjectUtils()
      {
         super();
      }
      
      public static function generateMaskedBitmap(content:DisplayObject, transparencyMask:DisplayObject) : Bitmap
      {
         var maskedBitmap:BitmapData = new BitmapData(content.width,content.height,true,0);
         var alphaMask:BitmapData = new BitmapData(transparencyMask.width,transparencyMask.height,true,0);
         alphaMask.draw(transparencyMask);
         maskedBitmap.lock();
         maskedBitmap.draw(content);
         maskedBitmap.copyChannel(alphaMask,new Rectangle(0,0,Math.min(transparencyMask.width,content.width),Math.min(transparencyMask.height,content.height)),new Point(0,0),1,8);
         maskedBitmap.unlock();
         alphaMask.dispose();
         return new Bitmap(maskedBitmap);
      }
      
      public static function grayOut(content:DisplayObject, onOff:Boolean) : void
      {
         var rc:Number = NaN;
         var gc:Number = NaN;
         var bc:Number = NaN;
         var cmf:ColorMatrixFilter = null;
         if(content)
         {
            if(onOff)
            {
               rc = 1 / 3;
               gc = 1 / 3;
               bc = 1 / 3;
               cmf = new ColorMatrixFilter([rc,gc,bc,0,0,rc,gc,bc,0,0,rc,gc,bc,0,0,0,0,0,1,0]);
               content.filters = [cmf];
            }
            else
            {
               content.filters = [];
            }
         }
      }
      
      public static function traceAllMovieClipInstanceNames(mc:MovieClip, traceUnnamed:Boolean = true, traceShapes:Boolean = false, indent:String = "") : void
      {
         var skipChildren:Boolean = false;
         var atRoot:Boolean = false;
         var iChild:* = 0;
         var obj:DisplayObject = null;
         if(mc)
         {
            skipChildren = false;
            atRoot = "" == indent;
            if(atRoot)
            {
            }
            if(!(atRoot || true == traceUnnamed || 0 != mc.name.indexOf("instance")))
            {
               skipChildren = true;
            }
            if(!skipChildren)
            {
               for(iChild = int(mc.numChildren - 1); 0 <= iChild; iChild--)
               {
                  obj = mc.getChildAt(iChild);
                  if(obj is MovieClip)
                  {
                     traceAllMovieClipInstanceNames(obj as MovieClip,traceUnnamed,traceShapes,indent + "\t");
                  }
                  else if(Boolean(obj.name) && (traceShapes || !traceShapes && !(obj is Shape)))
                  {
                  }
               }
            }
         }
      }
      
      public static function isChildOfElement(needleElement:DisplayObject, rootElement:DisplayObject) : Boolean
      {
         var result:Boolean = false;
         var iter:DisplayObject = needleElement;
         while(iter.parent != null)
         {
            if(iter.parent == rootElement)
            {
               result = true;
               break;
            }
            iter = iter.parent;
         }
         return result;
      }
      
      public static function fitDisplayObject(displayObject:DisplayObject, width:int, height:int, invert:Boolean = false) : void
      {
         var doRatio:Number = NaN;
         var fitRatio:Number = NaN;
         var widthOrder:Boolean = false;
         if(displayObject)
         {
            doRatio = displayObject.width / displayObject.height;
            fitRatio = width / height;
            widthOrder = invert != doRatio > fitRatio;
            if(widthOrder)
            {
               displayObject.scaleX = displayObject.scaleY = width / displayObject.width;
            }
            else
            {
               displayObject.scaleX = displayObject.scaleY = height / displayObject.height;
            }
         }
      }
   }
}

