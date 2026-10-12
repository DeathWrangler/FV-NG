package Widgets.Windows.MOTD
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.events.MouseEvent;
   
   public class HCXPromoMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_xpromo_HC.swf";
      
      public function HCXPromoMOTDWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var buttonText:String = ZLocUtils.t("Dialogs","MOTD_HCIncentivizedPromoButtonText");
         var bodyText_Title:String = ZLocUtils.t("Dialogs","MOTD_HCIncentivizedPromoBody_notinstalled_title");
         var bodyText_Subtitle:String = ZLocUtils.t("Dialogs","MOTD_HCIncentivizedPromoBody_notinstalled_subtitle");
         var numRewards:String = ZLocUtils.t("Dialogs","MOTD_HCIncentivizedPromoBody_numrewards");
         if(Boolean(m_window.bannertitle_tf) && Boolean(m_window.bannersubtitle_tf) && Boolean(m_window.reward_tf))
         {
            addWidget(new FarmTextField(m_window.bannertitle_tf,bodyText_Title));
            addWidget(new FarmTextField(m_window.bannersubtitle_tf,bodyText_Subtitle));
            addWidget(new FarmTextField(m_window.reward_tf,numRewards));
         }
         if(Boolean(m_window.accept_bt) && Boolean(m_window.ticket_mc))
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,buttonText,this.onClickPlay));
            addWidget(new FarmIcon(m_window.ticket_mc,"assets/consumables/HC_Unwither_icon.png"));
         }
      }
      
      private function onClickPlay(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog","xpromo","click","115","launch_xpromo_from_farm_to_hc");
         GlobalEngine.socialNetwork.redirect(CrossPromoConstants.HC_XPROMO_URL,null,"_blank",false);
         super.onClose(event);
      }
   }
}

