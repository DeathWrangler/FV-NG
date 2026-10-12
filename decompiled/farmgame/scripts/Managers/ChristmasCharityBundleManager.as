package Managers
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TBuyCharityBundle;
   import Widgets.Windows.ChristmasCharityBundleCongratsWindow;
   
   public class ChristmasCharityBundleManager
   {
      
      private static var m_instance:ChristmasCharityBundleManager;
      
      private var m_activeItemName:String = "";
      
      private var m_price:int;
      
      public function ChristmasCharityBundleManager(enforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : ChristmasCharityBundleManager
      {
         if(!m_instance)
         {
            m_instance = new ChristmasCharityBundleManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      public function showCongratulationsWindow(itemName:String) : void
      {
         var congratsWindow:ChristmasCharityBundleCongratsWindow = new ChristmasCharityBundleCongratsWindow(itemName);
         UI.displayPopup(congratsWindow);
      }
      
      private function onPaymentSuccess(result:Object) : void
      {
         if(result != null)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.CHRISTMAS_CHARITY_BUNDLES,this.m_activeItemName,1);
            this.showCongratulationsWindow(this.m_activeItemName);
            this.m_activeItemName = "";
         }
      }
      
      public function startBuyTransaction(itemName:String, price:int) : void
      {
         this.m_activeItemName = itemName;
         this.m_price = price;
         if(Global.player.canBuyCash(price,true))
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":price}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmation,"Expand_Farm_Complete_Now_Confirmation",true,true);
         }
      }
      
      public function onConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            TransactionManager.addTransaction(new TBuyCharityBundle(this.m_activeItemName,{"price":this.m_price},this.onPaymentSuccess));
         }
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
