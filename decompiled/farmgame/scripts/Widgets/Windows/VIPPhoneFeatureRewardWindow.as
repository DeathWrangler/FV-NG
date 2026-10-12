package Widgets.Windows
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class VIPPhoneFeatureRewardWindow extends FarmWindow
   {
      
      public static const VIP_PHONE_FEATURE_COUNT:String = "r6ca";
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private const SERVICE_NAME:String = "VIPPhoneFeatureWindowService";
      
      public function VIPPhoneFeatureRewardWindow(dialogPath:String)
      {
         super(dialogPath);
      }
      
      public static function launchVIPphoneRewardfeature() : void
      {
         UI.displayPopup(new VIPPhoneFeatureRewardWindow("assets/dialogs/FV_VIP_PhoneNumberCollection_2020/FV_PhoneNumberCollection_Prize_2020.swf"),false);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"VIP CONTACT CONFIRMED"));
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            addWidget(new ZwTextField(m_window["subtext_tf"],"The VIP team will be in contact shortly. Thank you for connecting! Enjoy your Snowy Pegacorn."));
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Okay!",this.closeWindow));
         }
      }
      
      public function closeWindow(evt:MouseEvent) : void
      {
         StatsManager.count("VIP_PhoneCollection","Reward_Accept","","","",Global.worldManager.currentWorldType);
         close();
      }
   }
}

