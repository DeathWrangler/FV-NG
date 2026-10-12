package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.LoyaltyProgramManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class LoyaltyProgramGoldenFarmerWindow extends FarmWindow
   {
      
      public function LoyaltyProgramGoldenFarmerWindow()
      {
         super("assets/dialogs/FV_LoyaltyProgram2013_Prize.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.share_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","LoyaltyGoldenWindow_share"),this.redeemStatusPoints));
         }
         if(m_window.generic4_tf)
         {
            addWidget(new ZwTextField(m_window.generic4_tf,ZLocUtils.t("Dialogs","LoyaltyGoldenWindow_woot")));
         }
         if(m_window.generic3_tf)
         {
            addWidget(new ZwTextField(m_window.generic3_tf,ZLocUtils.t("Dialogs","LoyaltyGoldenWindow_exclusive")));
         }
         if(m_window.generic2_tf)
         {
            addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Dialogs","LoyaltyGoldenWindow_status")));
         }
         if(m_window.generic_tf)
         {
            addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","LoyaltyGoldenWindow_woohoo")));
         }
         Global.hud.conditionallyRefreshHUD(true);
      }
      
      private function redeemStatusPoints(event:Event) : void
      {
         close();
         LoyaltyProgramManager.redeemStatusPoints();
      }
   }
}

