package Widgets.Windows.MOTD
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import flash.events.MouseEvent;
   
   public class SlingoXPromoMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/20120312_Slingo_InGame_xpromo_Farmville_Dialog2.swf";
      
      public function SlingoXPromoMOTDWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var buttonText:String = ZLocUtils.t("Dialogs","MOTD_SlingoIncentivizedPromoButtonText");
         var bodyText_Title:String = ZLocUtils.t("Dialogs","MOTD_SlingoIncentivizedPromoBody_notinstalled_title");
         var bodyText_Subtitle:String = ZLocUtils.t("Dialogs","MOTD_SlingoIncentivizedPromoBody_notinstalled_subtitle");
         var numRewards:String = ZLocUtils.t("Dialogs","MOTD_SlingoIncentivizedPromoBody_numrewards");
         if(m_window.mainWindow)
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.accept_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,buttonText,this.onClickPlay));
            }
         }
         else
         {
            if(Boolean(m_window.bannertitle_tf) && Boolean(m_window.bannersubtitle_tf) && Boolean(m_window.reward_tf))
            {
               addWidget(new FarmTextField(m_window.bannertitle_tf,bodyText_Title));
               addWidget(new FarmTextField(m_window.bannersubtitle_tf,bodyText_Subtitle));
               addWidget(new FarmTextField(m_window.reward_tf,numRewards));
            }
            if(m_window.accept_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.accept_bt,buttonText,this.onClickPlay));
            }
         }
      }
      
      private function onClickPlay(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog","xpromo","click","114","launch_xpromo_from_farm_to_bingo");
         GlobalEngine.socialNetwork.redirect(CrossPromoConstants.SLINGO_XPROMO_URL,null,"_blank",false);
         super.onClose(event);
      }
   }
}

