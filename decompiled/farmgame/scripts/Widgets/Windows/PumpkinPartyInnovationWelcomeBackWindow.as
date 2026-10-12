package Widgets.Windows
{
   import Managers.PumpkinPartyInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PumpkinPartyInnovationWelcomeBackWindow extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "PumpkinPartyInnovation";
      
      private var m_featureName:String;
      
      private var m_progress:int;
      
      private var m_boost_icon_mc:FarmIcon;
      
      private var m_close_bt:FarmButton;
      
      private var m_welcomeback_brief_tf:ZwTextField;
      
      private var m_welcomeback_title_tf:ZwTextField;
      
      private var m_welcomeback_okay_bt:FarmAnimatedTextButton;
      
      public function PumpkinPartyInnovationWelcomeBackWindow(featureName:String = "PumpkinPartyInnovation", assetUrl:String = null, progress:int = 0)
      {
         this.m_featureName = featureName;
         this.m_progress = progress;
         super(featureName,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var brief:String = null;
         var title:String = null;
         super.postLoadComplete();
         this.visible = true;
         if(m_window)
         {
            if(m_window.hasOwnProperty("escapetoken_icon"))
            {
               this.m_boost_icon_mc = new FarmIcon(m_window["escapetoken_icon"]);
               this.m_boost_icon_mc.visible = true;
            }
            if(m_window.hasOwnProperty("close_bt"))
            {
               this.m_close_bt = new FarmButton(m_window["close_bt"],this.onCloseButtonClick);
               this.m_close_bt.visible = true;
            }
            if(m_window.hasOwnProperty("welcomebackbrief_tf"))
            {
               brief = "Welcome Back! You have earned " + this.m_progress + " Escape Tokens from Tropic Escape!";
               this.m_welcomeback_brief_tf = new ZwTextField(m_window["welcomebackbrief_tf"],brief);
               this.m_welcomeback_brief_tf.visible = true;
            }
            if(m_window.hasOwnProperty("welcomebackheader_tf"))
            {
               title = "Escape Tokens Earned!";
               this.m_welcomeback_title_tf = new ZwTextField(m_window["welcomebackheader_tf"],title);
               this.m_welcomeback_title_tf.visible = true;
            }
            if(m_window.hasOwnProperty("welcomebackok_bt"))
            {
               this.m_welcomeback_okay_bt = new FarmAnimatedTextButton(m_window["welcomebackok_bt"],"Okay",this.onCloseButtonClick);
            }
         }
         if(Boolean(this.manager) && Boolean(this.manager.mainWindow))
         {
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
         }
      }
      
      private function get manager() : PumpkinPartyInnovationManager
      {
         return PumpkinPartyInnovationManager.getInstance(FEATURE_NAME);
      }
      
      private function onCloseButtonClick(event:MouseEvent) : void
      {
         this.onClose(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(Boolean(this.manager) && Boolean(this.manager.mainWindow))
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.onClose(event);
      }
   }
}

