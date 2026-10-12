package Display
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.CurrencyData;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class TurboPPHDialog extends FarmDynamicDialog
   {
      
      private static const STATE_OUTOFFUEL:String = "OutOfFuel";
      
      private static const STATE_OUTOFSEEDS:String = "OutOfSeeds";
      
      private static const STATE_OUTOFTURBO:String = "OutOfTurbo";
      
      private static const STATE_OUTOFCOINS:String = "OutOfCoins";
      
      private static const STATE_OUTOFWORLD_CURRENCY:String = "OutOfWorldCurrency";
      
      public static const ACTION_PLOW:String = "Plow";
      
      public static const ACTION_PLANT:String = "Plant";
      
      public static const ACTION_HARVEST:String = "Harvest";
      
      public static const ACTION_COMBINE:String = "Combine";
      
      private static const STRING_PREFIX:String = "TurboPPH_";
      
      private static const ICON_PATH_TURBO:String = "assets/consumables/consume_turboharvest_icon.png";
      
      private static const ICON_PATH_FUEL:String = "assets/equipment/equip_gas_can_icon.png";
      
      private static const ICON_PATH_COINS:String = "assets/consumables/consume_coins_icon.png";
      
      public static const RESULT_OK:int = 0;
      
      public static const RESULT_CANCEL:int = 1;
      
      private var m_callback:Function = null;
      
      public function TurboPPHDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function showOutOfFuelDialog(action:String, callback:Function) : void
      {
         var turboPPHDialog:TurboPPHDialog = FarmDynamicDialog.createDialog("turboPPHDialog",TurboPPHDialog) as TurboPPHDialog;
         if(turboPPHDialog != null)
         {
            turboPPHDialog.setupOutOfFuel(action,callback);
            turboPPHDialog.show();
         }
      }
      
      public static function showOutOfSeedsDialog(action:String, seed:FarmItem, callback:Function) : void
      {
         var turboPPHDialog:TurboPPHDialog = FarmDynamicDialog.createDialog("turboPPHDialog",TurboPPHDialog) as TurboPPHDialog;
         if(turboPPHDialog != null)
         {
            turboPPHDialog.setupOutOfSeeds(action,seed,callback);
            turboPPHDialog.show();
         }
      }
      
      public static function showOutOfTurbosDialog(action:String, callback:Function) : void
      {
         var turboPPHDialog:TurboPPHDialog = FarmDynamicDialog.createDialog("turboPPHDialog",TurboPPHDialog) as TurboPPHDialog;
         if(turboPPHDialog != null)
         {
            turboPPHDialog.setupOutOfTurbos(action,callback);
            turboPPHDialog.show();
         }
      }
      
      public static function showOutOfCoinsDialog(action:String, callback:Function) : void
      {
         var turboPPHDialog:TurboPPHDialog = FarmDynamicDialog.createDialog("turboPPHDialog",TurboPPHDialog) as TurboPPHDialog;
         if(turboPPHDialog != null)
         {
            turboPPHDialog.setupOutOfCoins(action,callback);
            turboPPHDialog.show();
         }
      }
      
      public static function showOutOfWorldCurrencyDialog(action:String, callback:Function) : void
      {
         var turboPPHDialog:TurboPPHDialog = FarmDynamicDialog.createDialog("turboPPHDialog",TurboPPHDialog) as TurboPPHDialog;
         if(turboPPHDialog != null)
         {
            turboPPHDialog.setupOutOfWorldCurrency(action,callback);
            turboPPHDialog.show();
         }
      }
      
      private function setupCommon(bodyText:String, iconPath:String, okText:String, cancelText:String, callback:Function) : void
      {
         this.m_callback = callback;
         this.setShortcutAttribute("messageText",TextFieldView.ATTRIBUTE_TEXT,bodyText);
         if(iconPath != "")
         {
            this.setShortcutAttribute("TurboPPHIconView",ImageController.ATTRIBUTE_SOURCE,iconPath);
         }
         this.setShortcutAttribute("okButton",ButtonController.ATTRIBUTE_TEXT,okText);
         this.setShortcutAttribute("cancelButton",ButtonController.ATTRIBUTE_TEXT,cancelText);
         this.setShortcutListener("okButton",WidgetControllerEvent.BUTTON_PRESSED,this.onOKPressed);
         this.setShortcutListener("cancelButton",WidgetControllerEvent.BUTTON_PRESSED,this.onCancelPressed);
         this.setShortcutListener("CloseButtonView",WidgetControllerEvent.BUTTON_PRESSED,this.onCancelPressed);
      }
      
      private function setupOutOfFuel(action:String, callback:Function) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outoffuel","view");
         var bodyTextToken:String = STRING_PREFIX + STATE_OUTOFFUEL + "_Body_" + action;
         var okTextToken:String = STRING_PREFIX + STATE_OUTOFFUEL + "_Ok_" + action;
         var cancelTextToken:String = STRING_PREFIX + STATE_OUTOFFUEL + "_Cancel_" + action;
         var bodyText:String = ZLocUtils.t("Dialogs",bodyTextToken);
         var iconPath:String = ICON_PATH_FUEL;
         var okText:String = ZLocUtils.t("Dialogs",okTextToken);
         var cancelText:String = ZLocUtils.t("Dialogs",cancelTextToken);
         this.setupCommon(bodyText,iconPath,okText,cancelText,callback);
      }
      
      private function setupOutOfSeeds(action:String, seed:FarmItem, callback:Function) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outofseeds","view");
         var bodyTextToken:String = STRING_PREFIX + STATE_OUTOFSEEDS + "_Body_" + action;
         var okTextToken:String = STRING_PREFIX + STATE_OUTOFSEEDS + "_Ok";
         var cancelTextToken:String = STRING_PREFIX + STATE_OUTOFSEEDS + "_Cancel";
         var bodyText:String = ZLocUtils.t("Dialogs",bodyTextToken,{"seed":ZLocUtils.tk_pk(seed.friendlyName)});
         var iconPath:String = seed.iconRelativeUrl;
         var okText:String = ZLocUtils.t("Dialogs",okTextToken);
         var cancelText:String = ZLocUtils.t("Dialogs",cancelTextToken);
         this.setupCommon(bodyText,iconPath,okText,cancelText,callback);
      }
      
      private function setupOutOfTurbos(action:String, callback:Function) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outofchargers","view");
         var bodyTextToken:String = STRING_PREFIX + STATE_OUTOFTURBO + "_Body_" + action;
         var okTextToken:String = STRING_PREFIX + STATE_OUTOFTURBO + "_Ok";
         var cancelTextToken:String = STRING_PREFIX + STATE_OUTOFTURBO + "_Cancel";
         var bodyText:String = ZLocUtils.t("Dialogs",bodyTextToken);
         var iconPath:String = ICON_PATH_TURBO;
         var okText:String = ZLocUtils.t("Dialogs",okTextToken);
         var cancelText:String = ZLocUtils.t("Dialogs",cancelTextToken);
         this.setupCommon(bodyText,iconPath,okText,cancelText,callback);
      }
      
      private function setupOutOfCoins(action:String, callback:Function) : void
      {
         var bodyTextToken:String = STRING_PREFIX + STATE_OUTOFCOINS + "_Body_" + action;
         var okTextToken:String = STRING_PREFIX + STATE_OUTOFCOINS + "_Ok";
         var cancelTextToken:String = STRING_PREFIX + STATE_OUTOFCOINS + "_Cancel";
         var bodyText:String = ZLocUtils.t("Dialogs",bodyTextToken);
         var iconPath:String = ICON_PATH_COINS;
         var okText:String = ZLocUtils.t("Dialogs",okTextToken);
         var cancelText:String = ZLocUtils.t("Dialogs",cancelTextToken);
         this.setupCommon(bodyText,iconPath,okText,cancelText,callback);
      }
      
      private function setupOutOfWorldCurrency(action:String, callback:Function) : void
      {
         var bodyTextToken:String = STRING_PREFIX + STATE_OUTOFWORLD_CURRENCY + "_Body_" + action;
         var okTextToken:String = STRING_PREFIX + STATE_OUTOFWORLD_CURRENCY + "_Ok";
         var cancelTextToken:String = STRING_PREFIX + STATE_OUTOFWORLD_CURRENCY + "_Cancel";
         var okText:String = ZLocUtils.t("Dialogs",okTextToken);
         var cancelText:String = ZLocUtils.t("Dialogs",cancelTextToken);
         var currencyUnit:String = Global.worldManager.getCurrencyForWorld(Global.worldManager.currentWorldType);
         var currency:CurrencyData = Global.farmGameSettingsManager.getCurrencyData(currencyUnit);
         var currencyName:String = null;
         if(currency != null)
         {
            currencyName = currency.friendlyName;
         }
         var bodyText:String = ZLocUtils.t("Dialogs",bodyTextToken,{"worldCurrency":currencyName});
         var iconPath:String = "assets/dialogs/4d_elements/inGamePayments/" + currencyUnit.toString() + "_wheelbarrow.png";
         this.setupCommon(bodyText,iconPath,okText,cancelText,callback);
      }
      
      private function onOKPressed(event:WidgetControllerEvent) : void
      {
         destroy();
         if(this.m_callback != null)
         {
            this.m_callback(RESULT_OK);
         }
      }
      
      private function onCancelPressed(event:WidgetControllerEvent) : void
      {
         destroy();
         if(this.m_callback != null)
         {
            this.m_callback(RESULT_CANCEL);
         }
      }
   }
}

