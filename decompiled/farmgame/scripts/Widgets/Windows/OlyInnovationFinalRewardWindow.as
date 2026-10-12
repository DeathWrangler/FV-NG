package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OlyInnovationFinalRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const ACCEPT_BT:String = "accept_bt";
      
      private const TRANSITION_MC:String = "transition_mc";
      
      private const TEXT_TITLE:String = "_finaltitle";
      
      private const TEXT_BUTTON:String = "_finalwindowbutton";
      
      protected var m_featureName:String;
      
      private var m_transitionFrame:ZwFrame;
      
      public function OlyInnovationFinalRewardWindow(assetUrl:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window[this.ACCEPT_BT])
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.ACCEPT_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BUTTON),this.onAccept));
         }
         if(m_window[this.TRANSITION_MC])
         {
            addWidget(this.m_transitionFrame = new ZwFrame(m_window[this.TRANSITION_MC]));
            (m_window[this.TRANSITION_MC] as MovieClip).play();
         }
         FarmStatsManager.count(this.m_featureName,"feature_ui","final_reward_window","open");
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
      }
      
      private function onAccept(event:Event) : void
      {
         this.close();
         UI.displayPopup(new OlyInnovationMapTriggerWindow(null,"assets/dialogs/mount/EscapeToOlympus2016/FV_EscapeToOlympus2016_HeromenesFTUE.swf"));
      }
   }
}

