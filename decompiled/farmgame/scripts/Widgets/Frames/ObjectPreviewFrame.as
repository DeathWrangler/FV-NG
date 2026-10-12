package Widgets.Frames
{
   import Classes.GateDecoration;
   import Classes.InteractiveDecoration;
   import Classes.MapResource;
   import Classes.MaskedDecoration;
   import Classes.RotateableDecoration;
   import Classes.ZItem.FarmItem;
   import Classes.util.FitToDimensions;
   import Display.FarmGameSprite;
   import Engine.Events.LoaderEvent;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class ObjectPreviewFrame extends ZwFrame
   {
      
      protected var m_zoomLevels:Array;
      
      protected var m_zoomWidths:Array;
      
      protected var m_item:FarmItem = null;
      
      protected var m_mapResource:MapResource = null;
      
      protected var m_zoomCallback:Function = null;
      
      protected var m_maxWidth:Number = 300;
      
      protected var m_maxHeight:Number = 200;
      
      protected var m_sprite:FarmGameSprite = null;
      
      private var m_imageOffset:Point = null;
      
      public function ObjectPreviewFrame(element:MovieClip, item:FarmItem, zoomCallback:Function = null, zoomLevels:Array = null, zoomWidths:Array = null, imageState:String = "", metaData:String = "", mapResource:MapResource = null, offset:Point = null)
      {
         var imageLoader:Loader;
         var objClass:Class = null;
         var state:String = null;
         this.m_zoomLevels = [];
         this.m_zoomWidths = [];
         super(element);
         this.m_item = item;
         this.m_zoomCallback = zoomCallback;
         this.m_maxWidth = element.width;
         this.m_maxHeight = element.height;
         this.m_zoomLevels = zoomLevels;
         this.m_zoomWidths = zoomWidths;
         if(offset != null)
         {
            this.m_imageOffset = offset;
         }
         else
         {
            this.m_imageOffset = new Point(0,0);
         }
         if(mapResource == null)
         {
            objClass = this.m_item.getMapResourceClass();
            objClass = ObjectPreviewFrame.substituteClass(objClass);
            try
            {
               this.m_mapResource = new objClass(this.m_item.name,metaData);
            }
            catch(error:Error)
            {
               m_mapResource = new objClass(m_item.name);
            }
            this.m_mapResource.setItem(this.m_item);
            state = imageState == "" ? this.m_item.getPreviewState() : imageState;
            if(state != "")
            {
               this.m_mapResource.setState(state);
            }
            this.m_mapResource.createDisplayObject();
         }
         else
         {
            this.m_mapResource = mapResource;
         }
         this.m_item.addEventListener(LoaderEvent.LOADED,this.onItemEvent);
         this.m_mapResource.drawDisplayObject();
         imageLoader = this.m_mapResource.getImage() as Loader;
         if(imageLoader != null)
         {
            imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onItemEvent);
         }
         this.updateImageTransform();
         this.triggerAnimation();
      }
      
      protected static function substituteClass(type:Class) : Class
      {
         var result:Class = type;
         if(type == MaskedDecoration || type == GateDecoration)
         {
            result = RotateableDecoration;
         }
         return result;
      }
      
      public function set id(value:String) : void
      {
         this.m_sprite.id = value;
      }
      
      public function get id() : String
      {
         return this.m_sprite.id;
      }
      
      protected function onItemEvent(event:Event) : void
      {
         var ldr:Loader = null;
         if(this.m_mapResource)
         {
            this.m_mapResource.drawDisplayObject();
            if(this.m_mapResource.getImage() is Loader)
            {
               ldr = this.m_mapResource.getImage() as Loader;
               ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onItemEvent);
            }
            this.updateImageTransform();
            this.triggerAnimation();
         }
      }
      
      protected function updateImageTransform() : void
      {
         var display:DisplayObject = null;
         var xWidth:Number = NaN;
         var zoom:int = 0;
         var ind:int = 0;
         var len:int = 0;
         var maxZoom:Number = NaN;
         var maxVerticalZoom:Number = NaN;
         var zoomWidth:Number = NaN;
         var zoomScale:Number = NaN;
         var newDimensions:Object = null;
         if(this.m_sprite == null)
         {
            this.m_sprite = new FarmGameSprite();
            (m_element as MovieClip).addChild(this.m_sprite);
         }
         if(this.m_mapResource != null && m_element != null && m_element is MovieClip)
         {
            display = this.m_mapResource.getDisplayObject();
            if(display != null)
            {
               this.m_sprite.addChild(display);
               xWidth = 0;
               if(this.m_zoomLevels != null)
               {
                  zoom = this.m_zoomLevels.length - 1;
                  ind = 0;
                  len = int(this.m_zoomLevels.length);
                  if(this.m_zoomWidths == null || this.m_zoomWidths.length == 0)
                  {
                     maxZoom = Math.min(this.m_maxWidth / display.width,this.m_maxHeight / display.height);
                     for(xWidth = this.m_maxWidth; ind < len; )
                     {
                        if(maxZoom > this.m_zoomLevels[ind])
                        {
                           zoom = ind;
                           break;
                        }
                        ind++;
                     }
                  }
                  else
                  {
                     xWidth = Number(this.m_zoomWidths[this.m_zoomLevels.length - 1]);
                     for(maxVerticalZoom = this.m_maxHeight / display.height; ind < len; )
                     {
                        if(this.m_zoomLevels[ind] * display.width < this.m_zoomWidths[ind] && this.m_zoomLevels[ind] < maxVerticalZoom)
                        {
                           zoom = ind;
                           xWidth = Number(this.m_zoomWidths[ind]);
                           break;
                        }
                        ind++;
                     }
                  }
               }
               else if(this.m_zoomWidths != null && this.m_zoomWidths.length > 0)
               {
                  zoomWidth = Number(this.m_zoomWidths[0]);
                  zoomScale = zoomWidth / Math.max(display.width,display.height);
                  this.m_sprite.scaleX = zoomScale;
                  this.m_sprite.scaleY = zoomScale;
                  xWidth = zoomWidth;
               }
               if(this.m_zoomCallback != null)
               {
                  this.m_zoomCallback(zoom + 1);
               }
               if(this.m_zoomLevels != null)
               {
                  this.m_sprite.scaleX = this.m_zoomLevels[zoom];
                  this.m_sprite.scaleY = this.m_zoomLevels[zoom];
               }
               if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.FARMICON)) && Boolean(m_element) && Boolean(m_element["bounds_mc"]) && Boolean(this.m_sprite))
               {
                  newDimensions = FitToDimensions.fitToDimensions(this.m_sprite.width,this.m_sprite.height,m_element["bounds_mc"].width,m_element["bounds_mc"].height,FitToDimensions.CONSTRAIN_MAXIMUM);
                  this.m_sprite.width = newDimensions.width;
                  this.m_sprite.height = newDimensions.height;
                  this.m_imageOffset = this.computeImageOffset(newDimensions);
               }
               display.x = 0;
               display.y = 0;
               this.m_sprite.x = (xWidth - this.m_sprite.width) / 2 + this.m_imageOffset.x;
               this.m_sprite.y = (this.m_maxHeight - this.m_sprite.height) / 2 + this.m_imageOffset.y;
            }
         }
      }
      
      protected function computeImageOffset(newDimensions:Object) : Point
      {
         return new Point(0,newDimensions.height / -2);
      }
      
      override public function release() : void
      {
         super.release();
         if(this.m_mapResource.getImage() is Loader)
         {
            (this.m_mapResource.getImage() as Loader).contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onItemEvent);
         }
         if(this.m_item)
         {
            this.m_item.removeEventListener(LoaderEvent.LOADED,this.onItemEvent);
            this.m_item = null;
         }
         if(this.m_mapResource)
         {
            this.m_mapResource.deleteDisplayObject();
            this.m_mapResource.cleanUp();
            this.m_mapResource = null;
         }
      }
      
      private function triggerAnimation() : void
      {
         var interDecoration:InteractiveDecoration = null;
         if(this.m_mapResource is InteractiveDecoration)
         {
            interDecoration = this.m_mapResource as InteractiveDecoration;
            interDecoration.activate();
         }
      }
      
      public function get farmItem() : FarmItem
      {
         return this.m_item;
      }
      
      public function get mapResource() : MapResource
      {
         return this.m_mapResource;
      }
      
      public function get sprite() : FarmGameSprite
      {
         return this.m_sprite;
      }
   }
}

