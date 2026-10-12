package Display
{
   import Classes.PriceFormulaSettings;
   import Classes.Quest.FarmQuestManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import Transactions.TPurchaseUnwither;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class UnwitherDialog extends FarmDynamicDialog
   {
      
      public static const UNWITHER_ITEM_NAME:String = "consume_unwither";
      
      private static const PRICE_TEST_NAME:String = "fv_unwither_optimization";
      
      protected static var m_textDialogPrefix:String = "";
      
      public function UnwitherDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function getUnwitherCost() : int
      {
         var kValue:Number = NaN;
         var cap:Number = NaN;
         var cost:int = 0;
         var witherCount:int = Global.world.getNumWitheredPlots();
         var formulaSettings:PriceFormulaSettings = Global.priceFormulaSettings;
         if(formulaSettings != null)
         {
            kValue = Global.priceFormulaSettings.getMultipleForTest(PRICE_TEST_NAME);
            cap = Global.priceFormulaSettings.getCapForTest(PRICE_TEST_NAME);
            cost = Math.round(witherCount * kValue);
            if(Boolean(cap) && cost > cap)
            {
               cost = cap;
            }
         }
         return cost < 5 ? 5 : cost;
      }
      
      public static function hasUnwither() : Boolean
      {
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(UnwitherDialog.UNWITHER_ITEM_NAME);
         return Global.player.hasGiftItem(itemCode);
      }
      
      public static function showUnwitherDialogIfAppropriate() : Boolean
      {
         var unwitherDialogShown:Boolean = false;
         var unwitherDialog:UnwitherDialog = null;
         var witherCount:int = Global.world.getNumWitheredPlots();
         var isOnFirstEnglandUnwitherQuest:Boolean = FarmQuestManager.getInstance().isQuestActive("england-02-001");
         if(!Global.player.hasSeenUnwitherPopupWorlds[Global.worldManager.currentWorldType] && witherCount > 0 && isOnFirstEnglandUnwitherQuest == false)
         {
            unwitherDialog = FarmDynamicDialog.createDialog("purchaseUnwitherDialog",UnwitherDialog) as UnwitherDialog;
            if(unwitherDialog != null)
            {
               unwitherDialog.initDialog();
               unwitherDialog.show();
               unwitherDialogShown = true;
               FarmStatsManager.count("unwither","dialog",witherCount.toString());
            }
         }
         return unwitherDialogShown;
      }
      
      public function initDialog() : void
      {
         Global.player.hasSeenUnwitherPopupWorlds[Global.worldManager.currentWorldType] = true;
         m_textDialogPrefix = "";
         Global.hud.iconQueue.removeIconByName("UnwitherOptimization");
         this.setup();
      }
      
      override public function setup() : void
      {
         var unwitherCost:int = UnwitherDialog.getUnwitherCost();
         var numWitheredPlots:int = Global.world.getNumWitheredPlots();
         var aboveImageText:String = ZLocUtils.t("Dialogs","unwither_" + m_textDialogPrefix + "optimization_aboveImageText");
         var belowImageText:String = "";
         var titleText:String = ZLocUtils.t("Dialogs","unwither_" + m_textDialogPrefix + "optimization_titleText");
         var unwitherButtonText:String = ZLocUtils.t("Dialogs","unwither_" + m_textDialogPrefix + "optimization_buttonText");
         var hasUnwither:Boolean = UnwitherDialog.hasUnwither();
         if(hasUnwither)
         {
            belowImageText = ZLocUtils.t("Dialogs","unwither_" + m_textDialogPrefix + "optimization_belowImageTextHasCredits",{"quantity":numWitheredPlots});
            this.setShortcutAttribute("farmCashIconImage",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
            this.setShortcutAttribute("farmCashCostText",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         }
         else
         {
            belowImageText = ZLocUtils.t("Dialogs","unwither_" + m_textDialogPrefix + "optimization_belowImageText",{
               "quantity":numWitheredPlots,
               "cashQuantity":unwitherCost
            });
            this.setShortcutAttribute("farmCashCostText",TextFieldView.ATTRIBUTE_TEXT,new String(unwitherCost));
         }
         this.setShortcutAttribute("aboveImageText",TextFieldView.ATTRIBUTE_TEXT,aboveImageText);
         this.setShortcutAttribute("belowImageText",TextFieldView.ATTRIBUTE_TEXT,belowImageText);
         this.setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,titleText);
         this.setShortcutAttribute("unwitherButton",TextFieldView.ATTRIBUTE_TEXT,unwitherButtonText);
         this.setShortcutListener("unwitherButton",WidgetControllerEvent.BUTTON_PRESSED,this.onUnwitherPressed);
      }
      
      private function onUnwitherPressed(event:WidgetControllerEvent) : void
      {
         var unwitherCost:int = 0;
         var hasEnoughCash:Boolean = false;
         var hasUnwither:Boolean = UnwitherDialog.hasUnwither();
         if(hasUnwither)
         {
            this.useUnwitherConsumable();
         }
         else
         {
            unwitherCost = UnwitherDialog.getUnwitherCost();
            hasEnoughCash = Global.player.cash >= unwitherCost;
            if(!hasEnoughCash)
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",unwitherCost,UNWITHER_ITEM_NAME);
            }
            else
            {
               this.buyUnwither();
               if(InGamePaymentsManager.inNoMoneyFlow())
               {
                  destroy();
               }
            }
         }
         if(!InGamePaymentsManager.inNoMoneyFlow())
         {
            destroy();
         }
      }
      
      public function useUnwitherConsumable() : void
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(UNWITHER_ITEM_NAME);
         var extraData:Object = {"allowReshopping":false};
         farmItem.onUse(Global.world.GIFTBOX_ID,extraData);
         destroy();
      }
      
      public function buyUnwither() : void
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(UNWITHER_ITEM_NAME);
         var unwitherCost:int = UnwitherDialog.getUnwitherCost();
         TransactionManager.addTransaction(new TPurchaseUnwither(unwitherCost));
         Global.player.addGift(UNWITHER_ITEM_NAME);
         var extraData:Object = {"allowReshopping":false};
         farmItem.onUse(Global.world.GIFTBOX_ID,extraData);
      }
   }
}

