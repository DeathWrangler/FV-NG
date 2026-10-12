package Widgets.HUD
{
   import Engine.Managers.LoadingManager;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   
   public class FarmHUDElement extends ZwAbstractWindow
   {
      
      protected var m_shown:Boolean = false;
      
      protected var m_showOnLoad:Boolean = false;
      
      public function FarmHUDElement(windowAssetRelUrl:String)
      {
         super(Global.getAssetURL(windowAssetRelUrl));
      }
      
      override public function close() : void
      {
         this.onHide();
         Global.stage.removeChild(this);
         release();
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         return LoadingManager.load(url,onLoadCallback,LoadingManager.PRIORITY_HIGH);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_showOnLoad)
         {
            this.m_showOnLoad = false;
            this.show();
         }
      }
      
      override protected function postLoadComplete() : void
      {
      }
      
      public function show() : void
      {
         if(m_isLoaded)
         {
            Global.ui.addChild(this);
            visible = true;
            this.onShow();
         }
         else
         {
            this.m_showOnLoad = true;
         }
      }
      
      public function hide() : void
      {
         this.onHide();
         visible = false;
      }
      
      protected function onShow() : void
      {
         if(!this.m_shown)
         {
            this.m_shown = true;
            Global.stage.addEventListener(FullScreenEvent.FULL_SCREEN,this.fullScreenCallback);
            Global.stage.addEventListener(Event.RESIZE,this.resizeCallback);
         }
         else
         {
            this.m_showOnLoad = true;
         }
      }
      
      protected function onHide() : void
      {
         if(this.m_shown)
         {
            this.m_shown = false;
            Global.stage.removeEventListener(FullScreenEvent.FULL_SCREEN,this.fullScreenCallback);
            Global.stage.removeEventListener(Event.RESIZE,this.resizeCallback);
         }
         this.m_showOnLoad = false;
      }
      
      private function fullScreenCallback(event:FullScreenEvent) : void
      {
         this.onFullScreen();
      }
      
      protected function onFullScreen() : void
      {
      }
      
      private function resizeCallback(event:Event = null) : void
      {
         this.onResize();
      }
      
      protected function onResize() : void
      {
      }
   }
}

