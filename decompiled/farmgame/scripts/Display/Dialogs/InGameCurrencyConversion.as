package Display.Dialogs
{
   import Classes.ZItem.CurrencyData;
   import Classes.ZItem.ExchangeCurrencyItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.CurrencyConversionUtil;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.FarmVillageManager;
   import Widgets.Windows.GetVillageCurrencyWindow;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.utils.Dictionary;
   
   public class InGameCurrencyConversion extends InGamePayment
   {
      
      public static const STRING_KEY_PREFIX:String = "InGameCurrencyConversion";
      
      public static const IMAGE_BASE_PATH:String = "assets/dialogs/4d_elements/inGamePayments/";
      
      private static var m_isShowing:Boolean = false;
      
      private var m_currencyData:CurrencyData;
      
      private var m_currencyConversionItems:Array = [];
      
      public function InGameCurrencyConversion(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function showImpulseBuy(currencyUnit:String) : void
      {
         var dialogName:String = null;
         var dialog:FarmDynamicDialog = null;
         if(currencyUnit == FarmVillageManager.CURRENCY_NAME)
         {
            UI.displayPopup(new GetVillageCurrencyWindow(),false);
         }
         else if(!m_isShowing)
         {
            dialogName = "inGamePayment";
            dialogName = "inGameCurrencyConversion";
            dialog = FarmDynamicDialog.createDialog(dialogName,InGameCurrencyConversion);
            if(dialog is InGameCurrencyConversion)
            {
               (dialog as InGameCurrencyConversion).currencyUnit = currencyUnit;
            }
            dialog.setup();
            dialog.show();
            m_isShowing = true;
            FarmStatsManager.count("dialog","buy_" + currencyUnit,"view");
         }
      }
      
      override public function setup() : void
      {
         var currencyExchangeItems:Array = Global.farmGameSettingsManager.getFarmItemsArrayByType("aide","othercurrency_exchange");
         var index:int = 0;
         var currencyExchangeItem:FarmItem = null;
         var isValidCurrencyExchangeItem:Boolean = false;
         for(index = 0; index < currencyExchangeItems.length; index++)
         {
            currencyExchangeItem = currencyExchangeItems[index] as FarmItem;
            if(null != currencyExchangeItem && CurrencyConversionUtil.isCurrencyExchangeItem(currencyExchangeItem.name) && CurrencyConversionUtil.isValidCurrencyExchangeItem(currencyExchangeItem.name,Global.worldManager.currentWorldCurrency))
            {
               this.m_currencyConversionItems.push(currencyExchangeItem);
            }
         }
         this.m_currencyConversionItems.sortOn("cash",Array.NUMERIC);
         super.setup();
         this.setShortcutAttribute("contentBgMask",ImageController.ATTRIBUTE_SOURCE,IMAGE_BASE_PATH + this.currencyUnit + "_bg.jpg");
         this.setShortcutAttribute("currency_npc",ImageController.ATTRIBUTE_SOURCE,IMAGE_BASE_PATH + this.currencyUnit + "_npc.png");
         this.setShortcutAttribute("currency_wheelbarrow",ImageController.ATTRIBUTE_SOURCE,IMAGE_BASE_PATH + this.currencyUnit + "_bottomRight.png");
      }
      
      override public function onCellCreate(controllerName:String, index:int, newCell:BaseWidgetController) : BaseWidgetController
      {
         var controller:BaseWidgetController = null;
         var style:BaseStyle = null;
         var styleData:Dictionary = null;
         var payment:Object = this.getPackageByIndex(index);
         newCell = super.onCellCreate(controllerName,index,newCell);
         if(newCell != null)
         {
            controller = newCell.findChildControllerByName("image");
            if(controller != null)
            {
               controller.setAttribute(ImageController.ATTRIBUTE_SOURCE,IMAGE_BASE_PATH + this.currencyUnit + "_cellIcon.png");
            }
            controller = newCell.findChildControllerByName("buyButton");
            if(controller != null)
            {
               controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
               controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
            }
            controller = newCell.findChildControllerByName("price");
            if(controller != null)
            {
               controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
               controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
            }
            controller = newCell.findChildControllerByName("farmCashBuyButton");
            if(controller != null)
            {
               controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,true);
               controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,true);
               controller.index = index;
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onClickBuy);
            }
            controller = newCell.findChildControllerByName("farmCashBuyText");
            if(controller != null)
            {
               controller.setAttribute(ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Buy"));
            }
            controller = newCell.findChildControllerByName("farmCashText");
            if(controller != null)
            {
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",this.getStringKeyPrefix() + "Cost",{"quantity":payment["cost"]}));
            }
            if(Math.floor(this.getPackageCount() / 2) === index)
            {
               controller = newCell.findChildControllerByName("greatDeal");
               if(controller != null)
               {
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,true);
               }
               controller = newCell.findChildControllerByName("base");
               if(controller != null)
               {
                  style = new BaseStyle();
                  styleData = new Dictionary();
                  styleData.colors = [15966025,16377721];
                  style.deserialize(styleData);
                  controller.getView().setStyle(style);
               }
            }
         }
         return newCell;
      }
      
      override protected function onClickBuy(event:WidgetControllerEvent) : void
      {
         var index:int = event.getController().index;
         var currencyConversionItem:ExchangeCurrencyItem = this.m_currencyConversionItems[index];
         if(Boolean(currencyConversionItem) && Global.player.canBuyCash(currencyConversionItem.cash))
         {
            currencyConversionItem.onBuy(currencyConversionItem.name,{"source":"impulse_buy"});
         }
         this.destroy();
      }
      
      override protected function getPackageCount() : int
      {
         return this.m_currencyConversionItems.length;
      }
      
      override protected function getPackageByIndex(index:int) : Object
      {
         var result:Object = null;
         var currencyConversionItem:ExchangeCurrencyItem = this.m_currencyConversionItems[index];
         if(currencyConversionItem != null)
         {
            result = new Object();
            result.amount = currencyConversionItem.count;
            result.cost = currencyConversionItem.cash;
         }
         return result;
      }
      
      override protected function getStringKeyPrefix() : String
      {
         return STRING_KEY_PREFIX;
      }
      
      override protected function getCurrencyFriendlyName() : String
      {
         return this.m_currencyData.friendlyName;
      }
      
      public function set currencyUnit(aCurrencyUnit:String) : void
      {
         this.m_currencyData = Global.farmGameSettingsManager.getCurrencyData(aCurrencyUnit);
      }
      
      public function get currencyUnit() : String
      {
         return this.m_currencyData.name;
      }
      
      override public function destroy() : void
      {
         m_isShowing = false;
         super.destroy();
      }
   }
}

