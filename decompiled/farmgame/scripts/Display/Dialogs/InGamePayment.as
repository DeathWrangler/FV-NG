package Display.Dialogs
{
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.CellController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.interfaces.ICellController;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.external.ExternalInterface;
   
   public class InGamePayment extends FarmDynamicDialog implements ICellController
   {
      
      public static const STRING_KEY_PREFIX:String = "InGamePayments";
      
      public var m_attemptedSpend:int = 0;
      
      public var m_purchaseName:String = "Other";
      
      protected var m_type:String = "cash";
      
      public function InGamePayment(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         var text:String = null;
         super.setup();
         var controller:BaseWidgetController = null;
         this.setShortcutAttribute("paymentPackages",CellController.ATTRIBUTE_CREATE,this);
         this.setShortcutAttribute("paymentPackages",CellController.ATTRIBUTE_CELL_COUNT,this.getPackageCount());
         if(this.m_attemptedSpend > 0)
         {
            text = ZLocUtils.t("Dialogs",this.getStringKeyPrefix() + "NotEnough",{"currencyUnit":this.getCurrencyFriendlyName()});
         }
         else
         {
            text = ZLocUtils.t("Dialogs",this.getStringKeyPrefix() + "MoreCash",{"currencyUnit":this.getCurrencyFriendlyName()});
         }
         this.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,text);
      }
      
      public function onCellCreate(controllerName:String, index:int, newCell:BaseWidgetController) : BaseWidgetController
      {
         var controller:BaseWidgetController = null;
         var payment:Object = this.getPackageByIndex(index);
         if(payment == null)
         {
            newCell = null;
         }
         else
         {
            controller = null;
            controller = newCell.findChildControllerByName("farmCash");
            if(controller != null)
            {
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,payment["amount"].toString());
            }
            controller = newCell.findChildControllerByName("price");
            if(controller != null)
            {
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",this.getStringKeyPrefix() + "Cost",{"quantity":payment["cost"]}));
            }
            controller = newCell.findChildControllerByName("buyButton");
            if(controller != null)
            {
               controller.index = index;
               controller.setAttribute(ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Buy"));
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onClickBuy);
            }
         }
         return newCell;
      }
      
      protected function onClickBuy(event:WidgetControllerEvent) : void
      {
         var item:int = event.getController().index;
         var variant:int = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
         var payment:Object = InGamePaymentsManager.getPayment(item,this.m_attemptedSpend);
         InGamePaymentsManager.packageBuy = payment;
         var stats:String = "Not_enough_cash";
         switch(variant)
         {
            case InGamePaymentsManager.VARIANT_HUD:
            case InGamePaymentsManager.VARIANT_MARKET:
               stats = "Add_cash_payments_test";
         }
         FarmStatsManager.count(stats,"click_buy",variant.toString(),payment["amount"]);
         if(ExternalInterface.available)
         {
            ExternalInterface.call("newInGamePayment",payment["amount"],Global.getPlayer().uid);
         }
      }
      
      protected function getPackageCount() : int
      {
         return InGamePaymentsManager.getPaymentNum(this.m_attemptedSpend);
      }
      
      protected function getPackageByIndex(index:int) : Object
      {
         return InGamePaymentsManager.getPayment(index,this.m_attemptedSpend);
      }
      
      protected function getStringKeyPrefix() : String
      {
         return STRING_KEY_PREFIX;
      }
      
      protected function getCurrencyFriendlyName() : String
      {
         return null;
      }
   }
}

