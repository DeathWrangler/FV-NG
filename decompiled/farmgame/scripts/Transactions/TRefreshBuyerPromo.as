package Transactions
{
   import Classes.BuyerPromo.BuyerPromoUtility;
   import Classes.Constants.ToasterIconPaths;
   import Classes.util.ZLocUtils;
   import Managers.FeatureOptionsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconToasterWindow;
   
   public class TRefreshBuyerPromo extends TFarmTransaction
   {
      
      public static const SERVER_METHOD:String = "refreshCurrentBuyerPromo";
      
      public function TRefreshBuyerPromo()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("BuyerPromoService." + SERVER_METHOD);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var code:String = null;
         if(Boolean(result) && Boolean(result.currentPromo))
         {
            for(code in result.currentPromo)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(BuyerPromoUtility.CURRENT_PROMO_FEATURE,code,result.currentPromo[code] as Object);
            }
            if(BuyerPromoUtility.shouldShowToaster())
            {
               ToasterManager.getInstance().add(new IconToasterWindow(ToasterIconPaths.CASH_MINI_ICON,ZLocUtils.t("Dialogs","BuyerPromo_ToasterMessage")));
            }
         }
      }
   }
}

