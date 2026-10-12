package Display.HUD.HUDWidgets
{
   import Display.UI;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class HUDZoomWidget extends HUDWidget
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/Angler/zoom_Angler.swf";
      
      public function HUDZoomWidget(parentElement:Sprite)
      {
         super(ASSET_PATH,parentElement);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         m_loader.y = Global.stage.stageHeight - 43;
         m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 + 760;
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty("zoomIn_bt"))
         {
            addWidget(new FarmButton(m_element.zoomIn_bt,UI.onZoomInClick));
         }
         if(m_element.hasOwnProperty("zoomOut_bt"))
         {
            addWidget(new FarmButton(m_element.zoomOut_bt,UI.onZoomOutClick));
         }
      }
      
      public function setX(location:Number) : void
      {
         m_loader.x = location;
      }
      
      public function setY(location:Number) : void
      {
         m_loader.y = location;
      }
   }
}

