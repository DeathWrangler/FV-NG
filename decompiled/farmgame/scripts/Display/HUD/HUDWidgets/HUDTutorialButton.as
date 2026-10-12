package Display.HUD.HUDWidgets
{
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HUDTutorialButton extends HUDWidget
   {
      
      private static const X_POSITION:int = 80;
      
      private static const Y_POSITION:int = 200;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_dialogKey:String;
      
      private var m_featureName:String;
      
      public function HUDTutorialButton(assetPath:String, dialogKey:String, featureName:String)
      {
         super(assetPath,Global.hud);
         this.m_dialogKey = dialogKey;
         this.m_featureName = featureName;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var description:String = null;
         super.onLoadComplete(event);
         m_loader.y = Y_POSITION;
         m_loader.x = X_POSITION;
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty("avatar_mc"))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element.avatar_mc,this.startFTUE));
            description = ZLocUtils.t_pk("Dialogs",this.m_dialogKey);
            this.m_hudButton.attachTooltip(new FarmTextTooltip(description));
         }
      }
      
      private function startFTUE(event:Event) : void
      {
         HUDTutorialManager.instance.initialize(this.m_featureName);
      }
   }
}

