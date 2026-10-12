package Display.HUD.HUDWidgets
{
   import Engine.Managers.LoadingManager;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Managers.ZwWidgetManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class HUDWidget extends EventDispatcher
   {
      
      protected var m_loader:Loader;
      
      protected var m_widgetManager:ZwWidgetManager;
      
      protected var m_wrapperNode:MovieClip;
      
      protected var m_parentElement:Sprite;
      
      protected var m_element:MovieClip;
      
      public function HUDWidget(assetName:String, parentElement:Sprite)
      {
         super();
         this.m_parentElement = parentElement;
         this.m_wrapperNode = new MovieClip();
         this.m_parentElement.addChild(this.m_wrapperNode);
         this.m_loader = LoadingManager.load(Global.getAssetURL(assetName),this.onLoadComplete,LoadingManager.PRIORITY_HIGH);
      }
      
      protected function onLoadComplete(event:Event) : void
      {
         if(Boolean(this.m_loader) && this.m_loader.content != null)
         {
            this.m_element = this.m_loader.content as MovieClip;
            this.m_widgetManager = new ZwWidgetManager();
            this.m_wrapperNode.addChild(this.m_loader);
         }
      }
      
      public function addWidget(widget:ZwBaseWidget, visible:Boolean = true) : ZwBaseWidget
      {
         return this.m_widgetManager.addWidget(widget,visible);
      }
      
      public function release() : void
      {
         if(Boolean(this.m_parentElement) && this.m_parentElement.contains(this.m_wrapperNode))
         {
            if(this.m_element)
            {
               this.m_element.visible = false;
            }
            this.m_parentElement.removeChild(this.m_wrapperNode);
         }
      }
      
      public function get element() : MovieClip
      {
         return this.m_element;
      }
   }
}

