package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.ConsumableBundleManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ConsumableBundleBuyWindow extends FarmWindow
   {
      
      public static const SERVICE_CLASS:String = "ConsumableBundleService";
      
      private var m_featureName:String = null;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_body2tf:ZwTextField;
      
      private var m_currentIcon1_mc:FarmIcon;
      
      private var m_currentIcon2_mc:FarmIcon;
      
      private var m_currentIcon3_mc:FarmIcon;
      
      private var m_slot_1_mc:MovieClip;
      
      private var m_slot_2_mc:MovieClip;
      
      private var m_slot_3_mc:MovieClip;
      
      private var m_item_tf:FarmTextField;
      
      private var m_count_tf:FarmTextField;
      
      private var m_loading_mc:MovieClip;
      
      private var m_loading_animation_mc:MovieClip;
      
      private var m_packageItem1:FarmItem;
      
      private var m_packageItem2:FarmItem;
      
      private var m_packageItem3:FarmItem;
      
      private var m_packageCost1:int;
      
      private var m_packageCost2:int;
      
      private var m_packageCost3:int;
      
      private var m_onGoingBuyTransactionSlot:int = -1;
      
      private var m_consumableWindow:ConsumableBundleBuyWindow;
      
      private var m_buyButton1:FarmAnimatedCashButton;
      
      private var m_buyButton2:FarmAnimatedCashButton;
      
      private var m_buyButton3:FarmAnimatedCashButton;
      
      private var m_getNewPackageBtn:FarmAnimatedTextButton;
      
      private var m_packageArray:Array = new Array();
      
      private var m_costArray:Array = new Array();
      
      public function ConsumableBundleBuyWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath,true,true);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"getPackagesFromRuntime",this.ongettingPackagesFromRuntime,[this.m_featureName]),true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window.title_tf,"Consumable Deals!"),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window.body_tf,"Hey Farmer, Here are some great offers for you!"),true);
         }
         if(m_window.hasOwnProperty("loading_mc"))
         {
            this.m_loading_mc = m_window["loading_mc"] as MovieClip;
            this.m_loading_mc.visible = true;
            if(this.m_loading_mc.hasOwnProperty("loading_tf"))
            {
               addWidget(this.m_titleTf = new ZwTextField(this.m_loading_mc.loading_tf,"Hey Farmer, we have some great deals on consumables!"),true);
            }
            if(this.m_loading_mc.hasOwnProperty("animation_mc"))
            {
               this.m_loading_animation_mc = this.m_loading_mc["animation_mc"] as MovieClip;
            }
            if(this.m_loading_mc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_getNewPackageBtn = new FarmAnimatedTextButton(this.m_loading_mc.okay_bt,"Get New Deals",this.onGetNewDeals));
               this.m_getNewPackageBtn.visible = false;
            }
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      public function ongettingPackagesFromRuntime(result:Object) : void
      {
         var countArray1:Array = null;
         var index1:int = 0;
         var count1:String = null;
         var imageurl1:String = null;
         var countArray2:Array = null;
         var index2:int = 0;
         var count2:String = null;
         var imageurl2:String = null;
         var countArray3:Array = null;
         var index3:int = 0;
         var count3:String = null;
         var imageurl3:String = null;
         if(result.package_name)
         {
            this.m_packageArray = result.package_name;
         }
         if(result.package_cost)
         {
            this.m_costArray = result.package_cost;
         }
         if(this.m_loading_mc)
         {
            this.m_loading_mc.visible = false;
         }
         if(m_closeButton)
         {
            m_closeButton.visible = true;
         }
         if(Boolean(m_window) && m_window.hasOwnProperty("slot1_mc"))
         {
            this.m_slot_1_mc = m_window["slot1_mc"] as MovieClip;
            this.m_packageItem1 = Global.farmGameSettingsManager.getFarmItemByName(this.m_packageArray[0]);
            countArray1 = this.m_packageArray[0].split("_");
            index1 = int(countArray1.length);
            count1 = countArray1[index1 - 1];
            imageurl1 = this.m_packageItem1.getImageByName("icon",false);
            if(this.m_slot_1_mc.hasOwnProperty("name_tf"))
            {
               this.m_item_tf = new FarmTextField(this.m_slot_1_mc.name_tf,this.m_packageItem1.friendlyTitle);
            }
            if(this.m_slot_1_mc.hasOwnProperty("count_tf"))
            {
               this.m_count_tf = new FarmTextField(this.m_slot_1_mc.count_tf,"x" + count1);
            }
            if(this.m_slot_1_mc.hasOwnProperty("icon_mc"))
            {
               this.m_currentIcon1_mc = new FarmIcon(this.m_slot_1_mc.icon_mc,imageurl1);
            }
            if(m_window.hasOwnProperty("buy1_bt") && !this.m_buyButton1)
            {
               this.m_packageCost1 = this.m_costArray[0];
               this.m_buyButton1 = new FarmAnimatedCashButton(m_window.buy1_bt,ZLocUtils.t("Dialogs","Buy"),this.m_packageCost1.toString(),this.onBuyPackage1Callback);
            }
            else
            {
               this.m_packageCost1 = this.m_costArray[0];
               this.m_buyButton1.setAmountText(this.m_costArray[0]);
            }
            this.m_slot_1_mc.visible = true;
            this.m_buyButton1.visible = true;
         }
         if(Boolean(m_window) && m_window.hasOwnProperty("slot2_mc"))
         {
            this.m_slot_2_mc = m_window["slot2_mc"] as MovieClip;
            this.m_packageItem2 = Global.farmGameSettingsManager.getFarmItemByName(this.m_packageArray[1]);
            countArray2 = this.m_packageArray[1].split("_");
            index2 = int(countArray2.length);
            count2 = countArray2[index2 - 1];
            imageurl2 = this.m_packageItem2.getImageByName("icon",false);
            if(this.m_slot_2_mc.hasOwnProperty("name_tf"))
            {
               this.m_item_tf = new FarmTextField(this.m_slot_2_mc.name_tf,this.m_packageItem2.friendlyTitle);
            }
            if(this.m_slot_2_mc.hasOwnProperty("count_tf"))
            {
               this.m_count_tf = new FarmTextField(this.m_slot_2_mc.count_tf,"x" + count2);
            }
            if(this.m_slot_2_mc.hasOwnProperty("icon_mc"))
            {
               this.m_currentIcon2_mc = new FarmIcon(this.m_slot_2_mc.icon_mc,imageurl2);
            }
            if(m_window.hasOwnProperty("buy2_bt") && !this.m_buyButton2)
            {
               this.m_packageCost2 = this.m_costArray[1];
               this.m_buyButton2 = new FarmAnimatedCashButton(m_window.buy2_bt,ZLocUtils.t("Dialogs","Buy"),this.m_packageCost2.toString(),this.onBuyPackage2Callback);
            }
            else
            {
               this.m_packageCost2 = this.m_costArray[1];
               this.m_buyButton2.setAmountText(this.m_costArray[1]);
            }
            this.m_slot_2_mc.visible = true;
            this.m_buyButton2.visible = true;
         }
         if(Boolean(m_window) && m_window.hasOwnProperty("slot3_mc"))
         {
            this.m_slot_3_mc = m_window["slot3_mc"] as MovieClip;
            this.m_packageItem3 = Global.farmGameSettingsManager.getFarmItemByName(this.m_packageArray[2]);
            countArray3 = this.m_packageArray[2].split("_");
            index3 = int(countArray3.length);
            count3 = countArray3[index3 - 1];
            imageurl3 = this.m_packageItem3.getImageByName("icon",false);
            if(this.m_slot_3_mc.hasOwnProperty("name_tf"))
            {
               this.m_item_tf = new FarmTextField(this.m_slot_3_mc.name_tf,this.m_packageItem3.friendlyTitle);
            }
            if(this.m_slot_3_mc.hasOwnProperty("count_tf"))
            {
               this.m_count_tf = new FarmTextField(this.m_slot_3_mc.count_tf,"x" + count3);
            }
            if(this.m_slot_3_mc.hasOwnProperty("icon_mc"))
            {
               this.m_currentIcon3_mc = new FarmIcon(this.m_slot_3_mc.icon_mc,imageurl3);
            }
            if(m_window.hasOwnProperty("buy3_bt") && !this.m_buyButton3)
            {
               this.m_packageCost3 = this.m_costArray[2];
               this.m_buyButton3 = new FarmAnimatedCashButton(m_window.buy3_bt,ZLocUtils.t("Dialogs","Buy"),this.m_packageCost3.toString(),this.onBuyPackage3Callback);
            }
            else
            {
               this.m_packageCost3 = this.m_costArray[2];
               this.m_buyButton3.setAmountText(this.m_costArray[2]);
            }
            this.m_slot_3_mc.visible = true;
            this.m_buyButton3.visible = true;
         }
         if(Boolean(m_window) && m_window.hasOwnProperty("body2_tf"))
         {
            this.m_body2tf = new ZwTextField(m_window.body2_tf,"Find your consumables in the gift box. Happy Farming!");
            this.m_body2tf.visible = false;
         }
      }
      
      private function onGetNewDeals(event:MouseEvent) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"getPackagesFromRuntime",this.ongettingPackagesFromRuntime,[this.m_featureName]),true);
         FarmStatsManager.count("ConsumableDeals","DealExpiry","click_ok");
      }
      
      private function onBuyPackage1Callback(event:MouseEvent) : void
      {
         tintWindow();
         enableInput = false;
         UI.displayMessage("Do you want to spend " + this.m_packageCost1.toString() + " Farm Cash to buy this Consumable??",GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPackage1,"",true);
      }
      
      private function onBuyPackage2Callback(event:MouseEvent) : void
      {
         tintWindow();
         enableInput = false;
         UI.displayMessage("Do you want to spend " + this.m_packageCost2.toString() + " Farm Cash to buy this Consumable??",GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPackage2,"",true);
      }
      
      private function onBuyPackage3Callback(event:MouseEvent) : void
      {
         tintWindow();
         enableInput = false;
         UI.displayMessage("Do you want to spend " + this.m_packageCost3.toString() + " Farm Cash to buy this Consumable??",GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPackage3,"",true);
      }
      
      private function onBuyPackage1(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            if(this.canBuyCashOrNot(this.m_packageCost1))
            {
               this.m_onGoingBuyTransactionSlot = 0;
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"buyPackage",this.onBuyComplete,[this.m_featureName,this.m_packageItem1.name,this.m_packageCost1]));
            }
         }
         else
         {
            FarmStatsManager.count("ConsumableDeals","CancelPurchase",this.m_packageItem1.name);
            this.unTintWindow();
         }
      }
      
      private function onBuyPackage2(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            if(this.canBuyCashOrNot(this.m_packageCost2))
            {
               this.m_onGoingBuyTransactionSlot = 1;
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"buyPackage",this.onBuyComplete,[this.m_featureName,this.m_packageItem2.name,this.m_packageCost2]));
            }
         }
         else
         {
            FarmStatsManager.count("ConsumableDeals","CancelPurchase",this.m_packageItem2.name);
            this.unTintWindow();
         }
      }
      
      private function onBuyPackage3(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            if(this.canBuyCashOrNot(this.m_packageCost3))
            {
               this.m_onGoingBuyTransactionSlot = 2;
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"buyPackage",this.onBuyComplete,[this.m_featureName,this.m_packageItem3.name,this.m_packageCost3]));
            }
         }
         else
         {
            FarmStatsManager.count("ConsumableDeals","CancelPurchase",this.m_packageItem3.name);
            this.unTintWindow();
         }
      }
      
      private function canBuyCashOrNot(cash:int) : Boolean
      {
         var popupObj:DisplayObject = null;
         var canBuy:Boolean = Global.player.cash - cash >= 0;
         if(!canBuy)
         {
            this.unTintWindow();
            popupObj = Global.stage.getChildByName("impulseBuyPopup");
            if(popupObj == null)
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",cash,"Other");
            }
         }
         return canBuy;
      }
      
      private function get manager() : ConsumableBundleManager
      {
         return ConsumableBundleManager.getInstance();
      }
      
      private function unTintWindow() : void
      {
         untintWindow();
         enableInput = true;
      }
      
      private function onBuyComplete(result:Object) : void
      {
         var getCost:int = 0;
         var pcgName:String = null;
         if(result.success)
         {
            if(this.m_onGoingBuyTransactionSlot > -1)
            {
               getCost = int(this.m_costArray[this.m_onGoingBuyTransactionSlot]);
               pcgName = this.m_packageArray[this.m_onGoingBuyTransactionSlot];
               Global.player.cash -= getCost;
               Global.player.addGift(pcgName);
               this.m_body2tf.visible = true;
            }
            this.unTintWindow();
         }
         else if(result.package_not_found)
         {
            this.unTintWindow();
            this.m_loading_mc.visible = true;
            this.m_getNewPackageBtn.visible = true;
            this.m_loading_animation_mc.visible = false;
            if(this.m_loading_mc.hasOwnProperty("loading_tf"))
            {
               this.m_titleTf.text = "Hey Farmer, we’re sorry! The deal you chose has expired.";
            }
            this.m_slot_1_mc.visible = false;
            this.m_slot_2_mc.visible = false;
            this.m_slot_3_mc.visible = false;
            this.m_buyButton1.visible = false;
            this.m_buyButton2.visible = false;
            this.m_buyButton3.visible = false;
            this.m_body2tf.visible = false;
         }
      }
      
      override protected function release() : void
      {
         this.m_titleTf = null;
         this.m_bodyTf = null;
         this.m_slot_1_mc = null;
         this.m_slot_2_mc = null;
         this.m_slot_3_mc = null;
         this.m_buyButton1 = null;
         this.m_buyButton2 = null;
         this.m_buyButton3 = null;
         this.m_body2tf = null;
         super.release();
      }
      
      override public function close() : void
      {
         FarmStatsManager.count("ConsumableDeals","buy_window","buy_window_closed");
         super.close();
      }
   }
}

