package Engine.Classes
{
   import Engine.Constants;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Matrix;
   
   public class Asset implements IEventDispatcher
   {
      
      public static const THUMBNAIL_DEFAULT_WIDTH:int = 64;
      
      public static const THUMBNAIL_DEFAULT_HEIGHT:int = 64;
      
      public static const THUMBNAIL_DEFAULT_BITMAP_WIDTH:int = 50;
      
      public static const THUMBNAIL_DEFAULT_BITMAP_HEIGHT:int = 50;
      
      protected var m_referenceCount:int = 0;
      
      protected var m_dispatcher:EventDispatcher;
      
      protected var m_imageFullPath:String = "";
      
      protected var m_id:Number = 0;
      
      protected var m_thumbnailBitmapData:BitmapData;
      
      public function Asset()
      {
         super();
         this.generateDefaultThumbnailBitmapData();
         this.m_dispatcher = new EventDispatcher(this);
      }
      
      public function dispose() : void
      {
         if(this.m_thumbnailBitmapData != null)
         {
            this.m_thumbnailBitmapData.dispose();
         }
      }
      
      protected function generateDefaultThumbnailBitmapData() : void
      {
         this.m_thumbnailBitmapData = new BitmapData(THUMBNAIL_DEFAULT_BITMAP_WIDTH,THUMBNAIL_DEFAULT_BITMAP_HEIGHT,true,0);
      }
      
      public function getType() : String
      {
         return Constants.ASSET_NONE;
      }
      
      public function getServiceName() : String
      {
         return "none";
      }
      
      public function parseData(param1:Object) : void
      {
         this.m_imageFullPath = param1.imageFullPath;
         this.m_id = param1.id;
      }
      
      public function loadThumbnail() : void
      {
      }
      
      public function isFullyLoaded() : Boolean
      {
         return this.m_id > 0;
      }
      
      public function getThumbnailURL() : String
      {
         return null;
      }
      
      public function getThumbnail() : DisplayObject
      {
         return null;
      }
      
      public function getThumbnailBitmapData() : BitmapData
      {
         return this.m_thumbnailBitmapData;
      }
      
      protected function drawThumbnailBitmapData(param1:DisplayObject) : void
      {
         var _loc2_:Matrix = new Matrix();
         _loc2_.scale(THUMBNAIL_DEFAULT_BITMAP_WIDTH / param1.width,THUMBNAIL_DEFAULT_BITMAP_HEIGHT / param1.height);
         this.m_thumbnailBitmapData.draw(param1,_loc2_,null,null,null,true);
      }
      
      public function getImageFullPath() : String
      {
         return this.m_imageFullPath;
      }
      
      public function getInstanceCount() : int
      {
         return 0;
      }
      
      public function equals(param1:Asset) : Boolean
      {
         return this.m_id == param1.m_id;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this.m_dispatcher.addEventListener(param1,param2,param3,param4);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this.m_dispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.m_dispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.m_dispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this.m_dispatcher.willTrigger(param1);
      }
   }
}

