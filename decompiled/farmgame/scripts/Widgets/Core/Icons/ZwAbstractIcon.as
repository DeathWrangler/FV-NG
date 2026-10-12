package Widgets.Core.Icons
{
   import Classes.util.FitToDimensions;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Base.ZwEventWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Util.ZwWidgetUtils;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ZwAbstractIcon extends ZwWidget
   {
      
      protected var m_icon:DisplayObject = null;
      
      protected var m_iconUrl:String = null;
      
      protected var m_loader:Loader = null;
      
      protected var m_hasLoaded:Boolean = false;
      
      protected var m_width:Number = 0;
      
      protected var m_height:Number = 0;
      
      protected var m_scaleX:Number = 1;
      
      protected var m_scaleY:Number = 1;
      
      protected var m_fitToDimensions:Boolean;
      
      protected var m_loadId:Number = 0;
      
      protected var m_smoothing:Boolean = false;
      
      public function ZwAbstractIcon(element:DisplayObject, iconUrl:String = null)
      {
         super(element);
         this.loadIcon(iconUrl);
      }
      
      override public function release() : void
      {
         var iconMc:MovieClip = m_element as MovieClip;
         ZwWidgetUtils.removeAllChildren(iconMc);
         this.m_icon = null;
         if(null != this.m_loader)
         {
            this.m_loader.unload();
            this.m_loader = null;
         }
         super.release();
      }
      
      public function get iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function loadIcon(iconUrl:String, callback:Function = null) : void
      {
         var newId:Number = NaN;
         var callBackClosure:Function = null;
         if(null != iconUrl && "" != iconUrl && this.m_iconUrl != iconUrl)
         {
            this.m_icon = null;
            this.m_iconUrl = iconUrl;
            this.m_hasLoaded = false;
            newId = this.m_loadId + 1;
            this.m_loadId = newId;
            callBackClosure = function(e:Event):void
            {
               onLoadComplete(e,newId);
               if(callback != null)
               {
                  callback();
               }
            };
            this.m_loader = this.createLoader(this.m_iconUrl,callBackClosure);
         }
      }
      
      public function clearDimensions() : void
      {
         this.m_width = 0;
         this.m_height = 0;
         this.m_scaleX = 1;
         this.m_scaleY = 1;
      }
      
      public function getIconWidth() : Number
      {
         return this.m_width;
      }
      
      public function setIconWidth(value:Number) : void
      {
         this.m_width = value;
         if(this.m_hasLoaded)
         {
            this.m_icon.width = this.m_width;
            this.m_scaleX = this.m_icon.scaleX;
            this.centerIcon();
         }
      }
      
      public function getIconHeight() : Number
      {
         return this.m_height;
      }
      
      public function setIconHeight(value:Number) : void
      {
         this.m_height = value;
         if(this.m_hasLoaded)
         {
            this.m_icon.height = this.m_height;
            this.m_scaleY = this.m_icon.scaleY;
            this.centerIcon();
         }
      }
      
      public function setIconSize(width:Number, height:Number) : void
      {
         this.setIconWidth(width);
         this.setIconHeight(height);
      }
      
      public function getIconScaleX() : Number
      {
         return this.m_scaleX;
      }
      
      public function setIconScaleX(value:Number) : void
      {
         this.m_scaleX = value;
         if(this.m_hasLoaded)
         {
            this.m_icon.scaleX = this.m_scaleX;
            this.m_width = this.m_icon.width;
            this.centerIcon();
         }
      }
      
      public function getIconScaleY() : Number
      {
         return this.m_scaleY;
      }
      
      public function setIconScaleY(value:Number) : void
      {
         this.m_scaleY = value;
         if(this.m_hasLoaded)
         {
            this.m_icon.scaleY = this.m_scaleY;
            this.m_height = this.m_icon.height;
            this.centerIcon();
         }
      }
      
      public function setIconScale(scaleX:Number, scaleY:Number) : void
      {
         this.setIconScaleX(scaleX);
         this.setIconScaleY(scaleY);
      }
      
      public function fitIconInsideBounds(width:Number, height:Number) : void
      {
         var newDimensions:Object = null;
         if(this.m_hasLoaded)
         {
            newDimensions = FitToDimensions.fitToDimensions(this.m_icon.width,this.m_icon.height,width,height,FitToDimensions.CONSTRAIN_MAXIMUM);
            this.clearDimensions();
            this.setIconWidth(newDimensions.width);
            this.setIconHeight(newDimensions.height);
         }
         else
         {
            this.m_fitToDimensions = true;
            this.m_width = width;
            this.m_height = height;
         }
      }
      
      public function setSmoothing(value:Boolean) : void
      {
         this.m_smoothing = value;
         if(this.m_hasLoaded)
         {
            if(this.m_icon is Bitmap)
            {
               (this.m_icon as Bitmap).smoothing = this.m_smoothing;
            }
         }
      }
      
      protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         throw new Error("Error: Abstract Function: Need to override ZwAbstractIcon:createLoader.");
      }
      
      protected function onLoadComplete(event:Event, loadId:Number) : void
      {
         var currentTarget:LoaderInfo = event.currentTarget as LoaderInfo;
         if(Boolean(this.m_loader) && loadId == this.m_loadId)
         {
            this.m_icon = this.m_loader.content;
            if(this.m_icon)
            {
               if(this.m_icon is Bitmap)
               {
                  (this.m_icon as Bitmap).smoothing = this.m_smoothing;
               }
               if(this.m_fitToDimensions)
               {
                  this.m_hasLoaded = true;
                  if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.FARMICON)) && Boolean(m_element) && Boolean(m_element["bounds_mc"]))
                  {
                     this.fitIconInsideBounds(m_element.bounds_mc.width,m_element.bounds_mc.height);
                  }
                  else
                  {
                     this.fitIconInsideBounds(this.m_width,this.m_height);
                  }
               }
               else
               {
                  if(0 == this.m_width)
                  {
                     this.m_width = this.m_icon.width;
                  }
                  if(0 == this.m_height)
                  {
                     this.m_height = this.m_icon.height;
                  }
                  if(this.m_width != this.m_icon.width)
                  {
                     this.m_scaleX = this.m_width / this.m_icon.width;
                  }
                  if(this.m_height != this.m_icon.height)
                  {
                     this.m_scaleY = this.m_height / this.m_icon.height;
                  }
               }
               this.attachIcon();
               this.dispatchEvent(new Event(ZwEventWidget.ICON_PREVIEW_EVENT_LISTENER));
               this.m_hasLoaded = true;
            }
         }
      }
      
      protected function attachIcon() : void
      {
         var iconMc:MovieClip = m_element as MovieClip;
         ZwWidgetUtils.removeAllChildren(iconMc);
         this.m_icon.width = this.m_width;
         this.m_icon.height = this.m_height;
         this.m_icon.scaleX = this.m_scaleX;
         this.m_icon.scaleY = this.m_scaleY;
         iconMc.addChild(this.m_icon);
         this.centerIcon();
      }
      
      public function get icon() : DisplayObject
      {
         return this.m_icon;
      }
      
      protected function centerIcon() : void
      {
         this.m_icon.x = (m_element.width - this.m_icon.width) / 2;
         this.m_icon.y = (m_element.height - this.m_icon.height) / 2;
      }
   }
}

