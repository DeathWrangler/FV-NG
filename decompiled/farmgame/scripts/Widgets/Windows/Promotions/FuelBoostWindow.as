package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TSubscribeToEmail;
   import Widgets.Buttons.SocialMissions.SMButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Icons.ZwAbstractIcon;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class FuelBoostWindow extends FarmWindow
   {
      
      public static const SEEN_FLAG:String = "fuelBoostWindowPermanent";
      
      public static const LEVEL_GATE_VALUE:int = 12;
      
      private const LINK_OPENING_TAG:String = "<a href=\'http://www.zynga.com/about/email-program.php\' target=\'_blank\'>";
      
      private const LINK_CLOSING_TAG:String = "</a>";
      
      public function FuelBoostWindow()
      {
         FarmStatsManager.count("dailyFuelBonusPrompt","promptImpressions");
         super("assets/dialogs/FV_FuelBoost.swf");
      }
      
      public static function canShow() : Boolean
      {
         var result:Boolean = false;
         if(!Global.player.getSeenFlag(FuelBoostWindow.SEEN_FLAG))
         {
            result = true;
         }
         return result;
      }
      
      public static function showStatic() : void
      {
         UI.displayPopup(new FuelBoostWindow());
      }
      
      override protected function postLoadComplete() : void
      {
         var mainFrame:ZwFrame = new ZwFrame(m_window.popupBox_mc);
         addWidget(mainFrame);
         mainFrame.addWidget(new ZwAbstractIcon(m_window.popupBox_mc.icon_mc));
         mainFrame.addWidget(new ZwTextField(m_window.popupBox_mc.title_tf,ZLocUtils.t("Dialogs","fuel_boost_title")));
         mainFrame.addWidget(new ZwTextField(m_window.popupBox_mc.generic_tf,ZLocUtils.t("Dialogs","fuel_boost_body")));
         mainFrame.addWidget(new ZwTextField(m_window.popupBox_mc.cta_tf,ZLocUtils.t("Dialogs","fuel_boost_cta")));
         mainFrame.addWidget(new SMButton(m_window.popupBox_mc.accept_bt,ZLocUtils.t("FarmGame","Yes"),this.onAccept));
         mainFrame.addWidget(new SMButton(m_window.popupBox_mc.cancel_bt,ZLocUtils.t("FarmGame","NoThanks"),this.onCancel));
         var emailLink:String = this.LINK_OPENING_TAG;
         emailLink += ZLocUtils.t("Dialogs","fuel_boost_email_program");
         emailLink += this.LINK_CLOSING_TAG;
         mainFrame.addWidget(new ZwTextField(m_window.popupBox_mc.emailInfo_tf,emailLink,true));
      }
      
      private function onAccept(event:Event) : void
      {
         FarmStatsManager.count("dailyFuelBonusPrompt","featureOptIn");
         TransactionManager.addTransaction(new TSubscribeToEmail("fuelBoostEmail"),false);
         UI.displayMessage(ZLocUtils.t("Dialogs","fuel_boost_info"),GenericPopup.TYPE_OK,null,"",true);
         this.close();
      }
      
      private function onCancel(event:Event) : void
      {
         FarmStatsManager.count("dailyFuelBonusPrompt","featureOptOut");
         this.close();
      }
      
      override public function close() : void
      {
         Global.player.setSeenFlag(FuelBoostWindow.SEEN_FLAG,true);
         super.close();
      }
   }
}

