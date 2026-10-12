package Display.HUD.HUDWidgets
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomGenericButton extends HUDWidget
   {
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const X_OFFSET:int = 80;
      
      private static const Y_OFFSET:int = 130;
      
      private var m_featureName:String;
      
      private var m_acceptCallback:Function;
      
      private var m_hudButton:FarmAnimatedButton;
      
      public function HudBottomGenericButton(assetPath:String, featureName:String, acceptCallback:Function = null)
      {
         super(assetPath,Global.hud);
         this.m_featureName = featureName;
         this.m_acceptCallback = acceptCallback;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var description:String = null;
         super.onLoadComplete(event);
         m_element.filters = [new DropShadowFilter()];
         this.setXY();
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty(HUD_MC))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.m_acceptCallback),true);
            description = ZLocUtils.t("Dialogs",this.m_featureName + "_title");
            this.m_hudButton.attachTooltip(new FarmTextTooltip(description));
         }
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - X_OFFSET;
            m_loader.y = Global.stage.stageHeight - Y_OFFSET;
         }
      }
   }
}

