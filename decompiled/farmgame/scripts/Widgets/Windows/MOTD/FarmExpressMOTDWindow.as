package Widgets.Windows.MOTD
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.MouseEvent;
   
   public class FarmExpressMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/fv_xpromo_mobile.swf";
      
      public static const FVWEB_HUD_FVXPROMO:String = "FarmExpressXpromo";
      
      public static const FVWEB_HUD_FVXPROMO_CLICK:String = "FVX_Xpromo_HUD_click";
      
      public static const FVWEB_FVXPROMO_REWARDED:String = "FVX_promo_rewarded";
      
      public function FarmExpressMOTDWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var buttonText:String = ZLocUtils.t("Dialogs","FarmExpressMOTD_ButtonText");
         if(m_window.generic_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.generic_bt,buttonText,this.onClickGo));
         }
      }
      
      private function onClickGo(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog","xpromo","click","63","launch_xpromo_from_farm_to_FVX");
         Global.hud.rightSideIconQueue.removeIconByName(FVWEB_HUD_FVXPROMO);
         GlobalEngine.socialNetwork.redirect(CrossPromoConstants.FARMEXPRESS_XPROMO_URL,null,"_blank",false);
         super.onClose(event);
      }
   }
}

