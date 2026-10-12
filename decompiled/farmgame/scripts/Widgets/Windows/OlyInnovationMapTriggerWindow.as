package Widgets.Windows
{
   import Managers.OlyInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.Event;
   
   public class OlyInnovationMapTriggerWindow extends FarmWindow
   {
      
      public static const HEROMENES_TUTORIAL_SEEN:String = "heromenes_tutorial_seen";
      
      private var m_featureName:String;
      
      private const ACCEPT_BT:String = "accept_bt";
      
      public function OlyInnovationMapTriggerWindow(featureName:String = "olympus_innovation", dialogPath:String = "assets/dialogs/Japan/R4Feature/FV_xjp_R4Feature_Billboard_01.swf")
      {
         super(dialogPath);
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window[this.ACCEPT_BT])
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.ACCEPT_BT],"Okay",this.onAccept));
         }
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      private function onAccept(event:Event) : void
      {
         this.close();
         if(!Global.player.getSeenFlag(HEROMENES_TUTORIAL_SEEN))
         {
            OlyInnovationManager.getInstance().highlightItemsByName("heromenes");
            Global.player.setSeenFlag(HEROMENES_TUTORIAL_SEEN);
         }
      }
   }
}

