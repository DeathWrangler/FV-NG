package com.troyer.widget.controller
{
   import com.troyer.widget.MT4DConfig;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class ImageController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_TYPE:String = "type";
      
      public static const ATTRIBUTE_MASK_CONTROLLER:String = "maskController";
      
      public static const ATTRIBUTE_SOURCE:String = "src";
      
      public static const ATTRIBUTE_EMBEDDED:String = "embedded";
      
      public static const ATTRIBUTE_LOCALIZED:String = "localized";
      
      public static const TYPE_MASK:String = "mask";
      
      public static const TYPE_STRETCH:String = "stretch";
      
      public static const TYPE_SCALE:String = "scale";
      
      public static const TYPE_TILED:String = "tiled";
      
      public static const TYPE_STAGE:String = "stage";
      
      private static const TILED_WIDTH:int = 900;
      
      private static const TILED_HEIGHT:int = 600;
      
      private var m_type:String = "scale";
      
      private var m_controllerPath:String;
      
      protected var m_loader:Loader = null;
      
      protected var m_activeIncrement:Boolean = false;
      
      protected var m_image:DisplayObject;
      
      protected var m_mask:Sprite;
      
      protected var m_imageSource:String;
      
      protected var m_tiledSource:BitmapData;
      
      protected var m_localized:Boolean;
      
      protected var m_stageWidth:Number = 0;
      
      protected var m_stageHeight:Number = 0;
      
      protected var m_baseWidth:Number;
      
      protected var m_baseHeight:Number;
      
      public function ImageController(param1:BaseWidgetView)
      {
         super(param1);
         addGlobalListener(WidgetControllerEvent.LOAD_CONTENT);
         addGlobalListener(WidgetControllerEvent.LOAD_COMPLETE);
      }
      
      override public function destroy() : void
      {
         this.cleanUp();
         super.destroy();
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_SOURCE)
         {
            _loc2_ = this.m_imageSource;
         }
         else if(param1 == ATTRIBUTE_EMBEDDED)
         {
            if(Boolean(this.m_image) && Boolean(this.m_imageSource == null) || this.m_imageSource == "")
            {
               _loc2_ = getQualifiedClassName(this.m_image);
            }
         }
         else if(param1 == ATTRIBUTE_TYPE)
         {
            _loc2_ = this.m_type;
         }
         else if(param1 == ATTRIBUTE_LOCALIZED)
         {
            _loc2_ = this.m_localized;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_TYPE,ATTRIBUTE_MASK_CONTROLLER,ATTRIBUTE_SOURCE,ATTRIBUTE_EMBEDDED);
         return _loc1_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         var name:String = param1;
         var value:* = param2;
         switch(name)
         {
            case ATTRIBUTE_FORCE_WIDTH:
               super.attribute(name,value);
               this.processImage();
               break;
            case ATTRIBUTE_FORCE_HEIGHT:
               super.attribute(name,value);
               this.processImage();
               break;
            case ATTRIBUTE_SOURCE:
               if(value is String)
               {
                  this.loadImage(value);
               }
               break;
            case ATTRIBUTE_EMBEDDED:
               if(value is String)
               {
                  this.loadEmbeddedImage(value);
               }
               else if(value is Class)
               {
                  this.cleanUp();
                  try
                  {
                     this.m_image = new value();
                     this.updateImageStats();
                     this.processImage();
                  }
                  catch(e:Error)
                  {
                     addError("Invalid embedded image class " + value);
                  }
               }
               break;
            case ATTRIBUTE_TYPE:
               this.m_type = value;
               break;
            case ATTRIBUTE_MASK_CONTROLLER:
               this.m_controllerPath = value;
               break;
            case ATTRIBUTE_LOCALIZED:
               if(value is String)
               {
                  this.m_localized = Utility.stringIsTrue(value);
               }
               else if(value is Boolean)
               {
                  this.m_localized = value;
               }
               break;
            case BaseWidgetView.ATTRIBUTE_STYLE:
               if(value is BaseStyle && Boolean(BaseStyle(value).getData(BaseStyle.DATA_IMAGE)))
               {
                  this.loadImage(BaseStyle(value).getData(BaseStyle.DATA_IMAGE));
               }
               super.attribute(name,value);
               break;
            default:
               super.attribute(name,value);
         }
      }
      
      protected function loadImage(param1:String) : void
      {
         this.cleanUp();
         this.m_imageSource = param1;
         var _loc2_:MT4DConfig = MT4DManager.getInstance().config;
         if(_loc2_)
         {
            if(this.m_localized)
            {
               param1 = _loc2_.onGetLocalizedAssetPath(param1);
            }
            else
            {
               param1 = _loc2_.onGetAssetPath(param1);
            }
         }
         this.incrementLoadCount();
         if(Boolean(_loc2_) && _loc2_.overridesLoadImage())
         {
            this.m_loader = _loc2_.loadImage(param1,this.onLoadError,this.onLoadComplete);
         }
         else
         {
            this.m_loader = new Loader();
            this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete);
            this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
            this.m_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
            this.m_loader.load(new URLRequest(param1));
         }
      }
      
      private function loadEmbeddedImage(param1:String) : void
      {
         var ClassName:Class = null;
         var name:String = param1;
         this.cleanUp();
         try
         {
            ClassName = getDefinitionByName(name) as Class;
            this.m_image = new ClassName();
            this.updateImageStats();
            this.processImage();
         }
         catch(e:Error)
         {
            addError("Couldn\'t find embedded image asset \'" + name + "\'.");
         }
      }
      
      private function removeListeners() : void
      {
         if(this.m_loader)
         {
            this.m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadComplete);
            this.m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
            this.m_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         }
      }
      
      private function cleanUp() : void
      {
         if(this.m_loader)
         {
            if(this.m_activeIncrement)
            {
               this.decrementLoadCount();
            }
            this.removeListeners();
            this.m_loader.unloadAndStop();
            this.m_loader = null;
         }
         Utility.removeDisplayObjectFromParent(this.m_mask);
         this.m_mask = null;
         Utility.removeDisplayObjectFromParent(this.m_image);
         this.m_image = null;
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         var _loc2_:Loader = null;
         var _loc3_:String = null;
         if(this.m_loader === param1.target.loader as Loader)
         {
            this.decrementLoadCount();
            this.removeListeners();
            _loc2_ = (param1.target as LoaderInfo).loader;
            if(_loc2_)
            {
               _loc3_ = _loc2_.contentLoaderInfo.url;
               this.m_image = _loc2_.content;
               if(null != this.m_image)
               {
                  this.updateImageStats();
                  this.processImage();
               }
               else
               {
                  addWarning("Image failed to load - ");
               }
               _loc2_.unload();
            }
         }
      }
      
      private function onLoadError(param1:ErrorEvent) : void
      {
         this.decrementLoadCount();
         this.removeListeners();
         addWarning("Image failed to load in controller \'" + m_name + "\': " + param1.toString());
      }
      
      private function updateImageStats() : void
      {
         if(this.m_image)
         {
            this.m_baseWidth = this.m_image.width;
            this.m_baseHeight = this.m_image.height;
            if(this.m_image.loaderInfo)
            {
               this.m_stageWidth = this.m_image.loaderInfo.width;
               this.m_stageHeight = this.m_image.loaderInfo.height;
            }
         }
      }
      
      override protected function incrementLoadCount() : void
      {
         this.m_activeIncrement = true;
         super.incrementLoadCount();
      }
      
      override protected function decrementLoadCount() : void
      {
         this.m_activeIncrement = false;
         super.decrementLoadCount();
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         var _loc3_:BaseWidgetController = null;
         var _loc4_:Rectangle = null;
         var _loc5_:BaseStyle = null;
         var _loc6_:Sprite = null;
         var _loc2_:Rectangle = m_view.getSize();
         if(this.m_image)
         {
            switch(this.m_type)
            {
               case TYPE_MASK:
                  if(Boolean(param1) && Boolean(param1.getView()))
                  {
                     _loc3_ = param1.getView().getController();
                     if(Boolean(_loc3_) && Boolean(this.m_controllerPath))
                     {
                        if(_loc3_.getName() == this.m_controllerPath)
                        {
                           _loc4_ = param1.getView().getSize();
                           if((Boolean(_loc4_)) && (_loc4_.height > this.m_image.height || _loc4_.width > this.m_image.width))
                           {
                              _loc5_ = m_view.getStyle();
                              if(_loc5_ == null || !Utility.stringIsTrue(_loc5_.getData(BaseStyle.DATA_TILED)))
                              {
                                 this.m_image.height = _loc4_.height;
                                 this.m_image.scaleX = this.m_image.scaleY;
                                 m_view.setSize(new Rectangle(0,0,this.m_image.width,this.m_image.height));
                              }
                           }
                        }
                     }
                  }
                  if(this.m_mask)
                  {
                     this.m_mask.graphics.copyFrom(m_view.graphics);
                  }
                  break;
               case TYPE_STRETCH:
                  if(_loc2_)
                  {
                     this.m_image.width = _loc2_.width;
                     this.m_image.height = _loc2_.height;
                  }
                  break;
               case TYPE_TILED:
                  if(Boolean(_loc2_) && Boolean(this.m_tiledSource))
                  {
                     _loc6_ = this.m_image as Sprite;
                     if(_loc6_)
                     {
                        _loc6_.graphics.clear();
                        _loc6_.graphics.beginBitmapFill(this.m_tiledSource);
                        _loc6_.graphics.drawRect(0,0,_loc2_.width,_loc2_.height);
                     }
                  }
                  break;
               case TYPE_STAGE:
                  this.m_image.width = this.m_stageWidth;
                  this.m_image.height = this.m_stageHeight;
            }
         }
      }
      
      public function setImageObject(param1:DisplayObject) : void
      {
         this.m_image = param1;
         this.processImage();
      }
      
      private function processImage() : void
      {
         var _loc1_:BaseStyle = null;
         var _loc2_:Sprite = null;
         var _loc3_:Rectangle = null;
         var _loc4_:BitmapData = null;
         var _loc5_:Sprite = null;
         var _loc6_:BaseWidgetView = null;
         var _loc7_:BaseWidgetController = null;
         if(this.m_image)
         {
            if(this.m_type)
            {
               switch(this.m_type)
               {
                  case TYPE_MASK:
                     Utility.removeDisplayObjectFromParent(this.m_mask);
                     this.m_mask = null;
                     _loc1_ = m_view.getStyle();
                     if(Boolean(_loc1_) && _loc1_.hasData(BaseStyle.DATA_TILED))
                     {
                        _loc4_ = new BitmapData(this.m_image.width,this.m_image.height,false);
                        _loc4_.draw(this.m_image);
                        _loc5_ = new Sprite();
                        _loc5_.graphics.beginBitmapFill(_loc4_,null,true,true);
                        _loc5_.graphics.drawRect(0,0,TILED_WIDTH,TILED_HEIGHT);
                        _loc5_.graphics.endFill();
                        this.m_image = _loc5_;
                     }
                     this.m_mask = new Sprite();
                     if(this.m_controllerPath)
                     {
                        _loc6_ = m_view.getChildByName(this.m_controllerPath) as BaseWidgetView;
                        if(_loc6_)
                        {
                           _loc7_ = _loc6_.getController();
                           _loc7_.setView(m_view);
                           m_view.onChildResized(_loc6_);
                        }
                     }
                     this.m_mask.graphics.copyFrom(m_view.graphics);
                     m_view.addChild(this.m_mask);
                     this.m_image.mask = this.m_mask;
                     m_view.setSize(new Rectangle(0,0,this.m_mask.width,this.m_mask.height));
                     break;
                  case TYPE_STRETCH:
                  case TYPE_SCALE:
                     if(m_view.hasFixedWidth())
                     {
                        this.m_image.scaleX = m_view.getSize().width / this.m_baseWidth;
                     }
                     else
                     {
                        this.m_image.scaleX = 1;
                     }
                     if(m_view.hasFixedHeight())
                     {
                        this.m_image.scaleY = m_view.getSize().height / this.m_baseHeight;
                     }
                     else
                     {
                        this.m_image.scaleY = 1;
                     }
                     if(this.m_type == TYPE_SCALE)
                     {
                        if(this.m_image.scaleY != 1)
                        {
                           this.m_image.scaleX = this.m_image.scaleY;
                        }
                        else if(this.m_image.scaleX != 1)
                        {
                           this.m_image.scaleY = this.m_image.scaleX;
                        }
                     }
                     break;
                  case TYPE_STAGE:
                     this.setAttribute(ATTRIBUTE_WIDTH,this.m_stageWidth);
                     this.setAttribute(ATTRIBUTE_HEIGHT,this.m_stageHeight);
                     break;
                  case TYPE_TILED:
                     if(this.m_tiledSource)
                     {
                        this.m_tiledSource.dispose();
                        this.m_tiledSource = null;
                     }
                     this.m_tiledSource = new BitmapData(this.m_image.width,this.m_image.height);
                     this.m_tiledSource.draw(this.m_image);
                     _loc2_ = new Sprite();
                     _loc3_ = m_view.getSize();
                     if(_loc3_)
                     {
                        _loc2_.graphics.beginBitmapFill(this.m_tiledSource);
                        _loc2_.graphics.drawRect(0,0,_loc3_.width,_loc3_.height);
                     }
                     this.m_image = _loc2_;
               }
               if(!(Boolean(this.m_controllerPath) || this.m_type == TYPE_STAGE))
               {
                  this.setAttribute(ATTRIBUTE_WIDTH,this.m_image.width);
                  this.setAttribute(ATTRIBUTE_HEIGHT,this.m_image.height);
               }
               if(this.m_image is Bitmap)
               {
                  (this.m_image as Bitmap).smoothing = true;
               }
            }
            m_view.graphics.clear();
            m_view.addChildAt(this.m_image,0);
            dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.LOAD_CONTENT,this));
            MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.LOAD_CONTENT,this));
         }
      }
   }
}

