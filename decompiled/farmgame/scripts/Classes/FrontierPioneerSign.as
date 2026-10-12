package Classes
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Windows.CrossPromo.FrontierPioneerCrossPromoWindow;
   
   public class FrontierPioneerSign extends CrossPromoSign
   {
      
      private const PROMO_SIGN_ASSET:String = "ftpioneerxpromosign";
      
      public function FrontierPioneerSign()
      {
         super(this.PROMO_SIGN_ASSET,"pioneertrail_xpromo",this.dialogPopCallback);
      }
      
      private function dialogPopCallback() : void
      {
         UI.displayPopup(new FrontierPioneerCrossPromoWindow(true,this),true,"FrontierPioneerPromo",true);
      }
      
      override protected function updateToolTipText() : void
      {
         var frName:String = null;
         if(isHighlighted() && Boolean(m_item))
         {
            if("" != m_toolTipOverride)
            {
               setToolTip(m_toolTipOverride);
            }
            else
            {
               frName = ZLocUtils.t("Dialogs","PromoFrontierPioneer_Toaster_Title");
               frName += "\n" + ZLocUtils.t("Dialogs","PromoFrontierPioneer_Toaster_SubTitle");
               setToolTip(frName);
            }
            updateToolTipPosition();
         }
      }
   }
}

