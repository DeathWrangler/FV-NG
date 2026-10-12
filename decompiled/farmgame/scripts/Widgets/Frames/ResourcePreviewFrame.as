package Widgets.Frames
{
   import Engine.Managers.LoadingManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Util.ZwWidgetUtils;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ResourcePreviewFrame extends ZwWidget
   {
      
      protected var m_assetUrl:String;
      
      protected var m_exportName:String;
      
      protected var m_scale:Number = 1;
      
      protected var m_hasLoaded:Boolean = false;
      
      protected var m_loader:Loader;
      
      protected var m_loadId:Number = 0;
      
      protected var m_exportedMovieClip:MovieClip;
      
      protected var m_autoScalingEnabled:Boolean = false;
      
      protected var m_hackyAutoScaling:Boolean = true;
      
      protected var m_originalWidth:Number = 0;
      
      protected var m_originalHeight:Number = 0;
      
      protected var m_defaultScaling:Number = 1;
      
      public function ResourcePreviewFrame(element:DisplayObject, assetUrl:String = null, exportName:String = null, useAutoScaling:Boolean = false, useHackyAutoScaling:Boolean = true)
      {
         this.m_originalHeight = element.height;
         this.m_originalWidth = element.width;
         this.m_autoScalingEnabled = useAutoScaling;
         this.m_hackyAutoScaling = useHackyAutoScaling;
         super(element);
         this.load(assetUrl,exportName,null,useAutoScaling,useHackyAutoScaling);
      }
      
      override public function release() : void
      {
         ZwWidgetUtils.removeAllChildren(m_element as MovieClip);
         this.m_exportedMovieClip = null;
         if(this.m_loader)
         {
            this.m_loader.unload();
            this.m_loader = null;
         }
         super.release();
      }
      
      public function get assetUrl() : String
      {
         return this.m_assetUrl;
      }
      
      public function get exportName() : String
      {
         return this.m_exportName;
      }
      
      public function set exportName(value:String) : void
      {
         if(Boolean(value) && value != this.m_exportName)
         {
            ZwWidgetUtils.removeAllChildren(m_element as MovieClip);
            this.m_exportName = value;
            this.createMovieClip();
         }
      }
      
      public function get exportedMovieClip() : MovieClip
      {
         return this.m_exportedMovieClip;
      }
      
      public function get scale() : Number
      {
         return this.m_scale;
      }
      
      public function set scale(value:Number) : void
      {
         this.m_scale = value;
         if(this.m_hasLoaded && Boolean(this.m_exportedMovieClip))
         {
            this.m_exportedMovieClip.scaleX = this.m_exportedMovieClip.scaleY = this.m_scale;
         }
      }
      
      public function load(assetUrl:String, exportName:String, callback:Function = null, useAutoScaling:Boolean = false, hackyAutoScaling:Boolean = true) : void
      {
         var callBackClosure:Function = null;
         var loadUrl:String = null;
         this.m_autoScalingEnabled = useAutoScaling;
         this.m_hackyAutoScaling = hackyAutoScaling;
         if(Boolean(assetUrl) && assetUrl != this.m_assetUrl)
         {
            ZwWidgetUtils.removeAllChildren(m_element as MovieClip);
            this.m_exportedMovieClip = null;
            this.m_assetUrl = assetUrl;
            this.m_exportName = exportName;
            this.m_hasLoaded = false;
            ++this.m_loadId;
            callBackClosure = function(e:Event):void
            {
               onLoadComplete(e,m_loadId);
               if(callback != null)
               {
                  callback();
               }
            };
            loadUrl = this.m_assetUrl;
            if(loadUrl.indexOf("http://") != 0 && loadUrl.indexOf("https://") != 0)
            {
               loadUrl = Global.getAssetURL(loadUrl);
            }
            this.m_loader = LoadingManager.load(loadUrl,callBackClosure);
         }
      }
      
      protected function onLoadComplete(event:Event, loadId:Number) : void
      {
         if(loadId == this.m_loadId)
         {
            this.m_hasLoaded = true;
            this.createMovieClip();
         }
      }
      
      protected function scaleAndPopulateMC() : void
      {
         var heightScale:Number = NaN;
         var widthScale:Number = NaN;
         var finalScale:Number = NaN;
         var xOffset:Number = NaN;
         if(m_element.scaleX > 1)
         {
            m_element.scaleX = this.m_defaultScaling;
         }
         if(m_element.scaleY > 1)
         {
            m_element.scaleY = this.m_defaultScaling;
         }
         (m_element as MovieClip).addChild(this.m_exportedMovieClip);
         this.m_exportedMovieClip.scaleX = this.m_exportedMovieClip.scaleY = this.m_defaultScaling;
         if(this.m_exportedMovieClip.parent == m_element)
         {
            heightScale = this.m_originalHeight / this.m_exportedMovieClip.height;
            widthScale = this.m_originalWidth / this.m_exportedMovieClip.width;
            finalScale = Math.min(heightScale,widthScale);
            if(this.m_hackyAutoScaling)
            {
               if(finalScale >= 1.15)
               {
                  finalScale = (finalScale - 1) * 0.5 + 1.4;
               }
               else if(finalScale < 1.15 && finalScale > 0.9)
               {
                  finalScale = 1.15 + (1.15 - finalScale) * 1.8;
               }
               else if(finalScale > 0.8 && finalScale <= 0.9)
               {
                  finalScale = 1 + (1 - finalScale) * 2;
               }
               else
               {
                  finalScale = 1 + (1 - finalScale) * 0.1;
               }
               this.scale = finalScale;
               xOffset = (m_element.width - this.m_exportedMovieClip.width) / 2;
               this.m_exportedMovieClip.x -= xOffset;
            }
            else
            {
               this.scale = this.m_defaultScaling;
               if(this.m_exportedMovieClip.width > this.m_exportedMovieClip.height)
               {
                  this.m_exportedMovieClip.height = widthScale * this.m_exportedMovieClip.height;
                  this.m_exportedMovieClip.width = this.m_originalWidth;
                  this.m_exportedMovieClip.x = 5;
               }
               else
               {
                  this.m_exportedMovieClip.width = heightScale * this.m_exportedMovieClip.width;
                  this.m_exportedMovieClip.height = this.m_originalHeight;
                  this.m_exportedMovieClip.x = (this.m_originalWidth - this.m_exportedMovieClip.width) / 2;
               }
            }
         }
      }
      
      protected function createMovieClip() : void
      {
         var exportClass:Class = null;
         if(Boolean(this.m_loader) && this.m_hasLoaded)
         {
            ZwWidgetUtils.removeAllChildren(m_element as MovieClip);
            try
            {
               exportClass = this.m_loader.content.loaderInfo.applicationDomain.getDefinition(this.m_exportName) as Class;
               this.m_exportedMovieClip = new exportClass() as MovieClip;
            }
            catch(error:Error)
            {
               m_exportedMovieClip = null;
               GlobalEngine.assert(false,"Unable to find export class \"" + m_exportName + "\" in " + m_assetUrl);
            }
            if(this.m_exportedMovieClip)
            {
               if(this.m_autoScalingEnabled)
               {
                  this.scaleAndPopulateMC();
               }
               else
               {
                  (m_element as MovieClip).addChild(this.m_exportedMovieClip);
                  this.m_exportedMovieClip.scaleX = this.m_exportedMovieClip.scaleY = this.m_scale;
               }
               this.m_exportedMovieClip.play();
            }
         }
      }
   }
}

