package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TBuySeedPackage;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.GenericNumberSelectionWindow;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   
   public class BuySeedPackages extends GenericNumberSelectionWindow
   {
      
      public static const GET_GIFTABLE_SEEDS_ASSET_URL:String = "assets/dialogs/FV_GiftableSeeds_Get.swf";
      
      protected var m_itemName:String;
      
      protected var m_buttonName:String;
      
      private var MIN_SEED_PACKAGES:Number = 1;
      
      private var MAX_SEED_PACKAGES:Number = 50;
      
      private var m_seedPackageCost:int = 1;
      
      protected var m_selectedItems:Number;
      
      protected var m_amountTextField:ZwTextField;
      
      protected var m_ask:GenericButton;
      
      protected var m_closeCallback:Function = null;
      
      public function BuySeedPackages(itemName:String, buttonName:String, closeCallback:Function = null)
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_itemName = itemName;
         this.m_buttonName = buttonName;
         this.m_selectedItems = this.MIN_SEED_PACKAGES;
         var seed:FarmItem = getSeedFromSeedPackageName(itemName);
         if(item)
         {
            if(item.isCash)
            {
               this.m_seedPackageCost = item.cash;
            }
            else
            {
               this.m_seedPackageCost = item.cost;
            }
         }
         this.m_closeCallback = closeCallback;
         super({
            "icon":Global.getAssetURL(item.icon),
            "friendlyName":seed.friendlyName,
            "code":item.code
         },this.onCloseBuySeedPackages,ZLocUtils.t("Dialogs","BuySeedPackages_Request",{"items":ZLocUtils.tk_pk(item.friendlyName)}),this.MAX_SEED_PACKAGES,GET_GIFTABLE_SEEDS_ASSET_URL);
      }
      
      public static function getSeedFromSeedPackageName(seedPackageName:String) : FarmItem
      {
         var endPosition:int = seedPackageName.indexOf("_seedpackage");
         var seedName:String = "";
         if(endPosition > 0)
         {
            seedName = seedPackageName.substr(0,endPosition);
         }
         var seed:FarmItem = null;
         if(seedName != "")
         {
            seed = Global.farmGameSettingsManager.getFarmItemByName(seedName);
         }
         return seed;
      }
      
      override protected function postLoadComplete() : void
      {
         var ingredient_tf:ZwTextField = null;
         var seedName:String = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         LoadingManager.load(item.icon,onIconLoaded);
         addWidget(new ZwFrame(m_window.popupBox_mc));
         var bodyTextField:ZwTextField = new ZwTextField(m_window.popupBox_mc.popupBox_tf,m_bodyText);
         var textFormat:TextFormat = bodyTextField.getTextFormat();
         textFormat.align = "center";
         bodyTextField.setTextFormat(textFormat);
         addWidget(bodyTextField);
         var idx:int = 1;
         ingredient_tf = new ZwTextField(m_window.popupBox_mc.getChildByName("crop1_tf"),ZLocUtils.t("Dialogs","BuySeedPackages_Cash",{
            "cashQuantity":this.m_seedPackageCost,
            "quantity":Global.farmGameSettingsManager.getDefaultSeedPackageSize()
         }));
         var bodyFormat:TextFormat = bodyTextField.getTextFormat();
         bodyFormat.align = "left";
         bodyFormat.size = 16;
         ingredient_tf.setTextFormat(bodyFormat);
         addWidget(ingredient_tf);
         addWidget(new ZwFrame(m_window.popupBox_mc.farmCashIcon_mc));
         m_iconFrame = new ZwFrame(m_window.popupBox_mc.icon_mc);
         addWidget(m_iconFrame);
         m_iconFrame.y -= 20;
         addWidget(new ZwFrame(m_window.popupBox_mc.bouquets_mc));
         this.m_amountTextField = new ZwTextField(m_window.popupBox_mc.bouquets_mc.bouquets_tf,m_units);
         addWidget(this.m_amountTextField);
         m_quantityTextField = new ZwTextField(m_window.popupBox_mc.amount_tf,"");
         addWidget(m_quantityTextField);
         addWidget(new ZwButton(m_window.popupBox_mc.bouquets_mc.arrowUp_bt,this.onUpArrowClick));
         addWidget(new ZwButton(m_window.popupBox_mc.bouquets_mc.arrowDown_bt,this.onDownArrowClick));
         this.displayQuantity(1);
         var seedPackage:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         m_window.ask_bt.visible = true;
         this.m_ask = new GenericButton(m_window.ask_bt,this.onAskClicked);
         if(!seedPackage.checkDateGate())
         {
            this.m_ask.useGrayOnDisabled = true;
            this.m_ask.disabled = true;
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            seedName = seedPackage.getStringFromDataSource("seed");
         }
         else
         {
            seedName = seedPackage.xml.seed;
         }
         var seed:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(seedName);
         m_window.popupBox_mc.okay_bt.visible = true;
         m_accept = new GenericButton(m_window.popupBox_mc.okay_bt,this.onShareClicked);
         if(!seed.checkDateGate())
         {
            m_accept.useGrayOnDisabled = true;
            m_accept.disabled = true;
         }
         m_window.popupBox_mc.cancel_bt.visible = true;
         m_reject = new GenericButton(m_window.popupBox_mc.cancel_bt,this.onCancelClicked);
      }
      
      override protected function onCancelClicked(e:MouseEvent) : void
      {
         FarmStatsManager.count("giftable_seeds",this.m_itemName,"click_" + this.m_buttonName,"click_cancel");
         super.onCancelClicked(e);
      }
      
      override protected function onShareClicked(e:MouseEvent) : void
      {
         FarmStatsManager.count("giftable_seeds",this.m_itemName,"click_" + this.m_buttonName,"click_buy");
         super.onShareClicked(e);
      }
      
      protected function onAskClicked(e:MouseEvent) : void
      {
         var bundleData:Object = null;
         FarmStatsManager.count("giftable_seeds",this.m_itemName,"click_" + this.m_buttonName,"click_askformore");
         var seed:FarmItem = getSeedFromSeedPackageName(this.m_itemName);
         var seedWishTimeLimit:int = Global.farmGameSettingsManager.getInt("CSeedPackageWishlistTimelimit",14400);
         if(Global.player.seedWishData.hasOwnProperty(seed.name) && (!Global.player.seedWishData[seed.name].timestamp || GlobalEngine.serverTime > Global.player.seedWishData[seed.name].timestamp + seedWishTimeLimit))
         {
            bundleData = Global.player.seedWishData[seed.name];
            bundleData["images"] = [{
               "href":"{SN_APP_URL}" + bundleData.wish_granted_link,
               "src":Global.getAssetURL(bundleData.image)
            }];
            GlobalEngine.socialNetwork.publishFeedStory("Wishlist_Giftableseeds_Market",bundleData,[],false,null);
            Global.player.seedWishData[seed.name].timestamp = GlobalEngine.serverTime;
            Global.player.setFeatureLastShown(seed.name + "_wishlist",GlobalEngine.serverTime,true);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","BuySeedPackages_WishTooSoon",{"quantity":seedWishTimeLimit / 60 / 60}),0,null,"",true);
         }
         this.close();
      }
      
      override protected function displayQuantity(value:int) : void
      {
         m_quantityTextField.text = String(value * this.m_seedPackageCost);
         this.m_amountTextField.text = ZLocUtils.t("Dialogs","BuySeedPackages_SeedPackageCount",{"quantity":value});
      }
      
      override protected function onUpArrowClick(e:MouseEvent) : void
      {
         var amount:int = this.currentQuantitySelected + 1 <= this.MAX_SEED_PACKAGES ? int(this.currentQuantitySelected + 1) : int(this.MAX_SEED_PACKAGES);
         this.displayQuantity(amount);
      }
      
      override protected function onDownArrowClick(e:MouseEvent) : void
      {
         var amount:int = this.currentQuantitySelected - 1 > this.MIN_SEED_PACKAGES ? int(this.currentQuantitySelected - 1) : int(this.MIN_SEED_PACKAGES);
         this.displayQuantity(amount);
      }
      
      override protected function get currentQuantitySelected() : int
      {
         return int(m_quantityTextField.text) / this.m_seedPackageCost;
      }
      
      private function onCloseBuySeedPackages(itemCode:String, itemAmount:Number) : void
      {
         var seed:FarmItem = null;
         var seedsPurchased:Number = NaN;
         var storedSeed:StorageItem = null;
         var seedPackageItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var cost:int = seedPackageItem.cash * itemAmount;
         if(Global.player.cash >= cost)
         {
            Global.player.cash -= cost;
            seed = BuySeedPackages.getSeedFromSeedPackageName(seedPackageItem.name);
            seedsPurchased = itemAmount * Global.farmGameSettingsManager.getDefaultSeedPackageSize();
            storedSeed = StorageItem.getStorageItem(seedPackageItem.code,[seedsPurchased]);
            if(Boolean(storedSeed && !storedSeed.isEmpty() && storedSeed.item) && Boolean(storedSeed.item.className) && storedSeed.item.className == "CSeedPackage")
            {
               Global.player.addSeedItem(storedSeed);
            }
            TransactionManager.addTransaction(new TBuySeedPackage(seedPackageItem.name,itemAmount));
            UI.displayMessage(ZLocUtils.t("Dialogs","BuySeedPackages_Thanks",{
               "quantity":itemAmount,
               "item":ZLocUtils.tk_pk(seedPackageItem.friendlyName),
               "quantityTotal":Global.player.seeds[seedPackageItem.code].quantity,
               "item_same":ZLocUtils.tk_pk(seedPackageItem.friendlyName,"",Global.player.seeds[seedPackageItem.code].quantity)
            }),0,null,"",true);
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",cost,seedPackageItem.type);
         }
      }
      
      override public function close() : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         super.close();
      }
   }
}

