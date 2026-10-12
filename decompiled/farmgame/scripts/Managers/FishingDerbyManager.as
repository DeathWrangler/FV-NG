package Managers
{
   import Classes.Collections.FishingCollectible;
   import Classes.Managers.HUDTutorialManager;
   import Classes.MiniGameDecoration;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUDWidgets.HUDFishingDerbyWidget;
   import Display.HUD.HUDWidgets.HUDHomeWidget;
   import Display.HUD.HUDWidgets.HUDTutorialButton;
   import Display.HUD.HUDWidgets.HUDZoomWidget;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import Transactions.TFishing;
   import Widgets.Windows.FishingDerby.FishingDerbyToasterWindow;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class FishingDerbyManager
   {
      
      public static const FEATURE_NAME:String = "fishingderby";
      
      public static const FEATURE_MASTERY:String = "mastery";
      
      public static const FEATURE_INVENTORY:String = "inventory";
      
      public static const FEATURE_BAIT:String = "bait";
      
      public static const FEATURE_BUFF:String = "buff";
      
      public static const INVENTORY_ROD:String = "rod";
      
      public static const ROD_BASIC:String = "rod_basic";
      
      public static const BAIT_WORM:String = "bait_worm";
      
      public static const MASTERY_COUNT_PREFIX:String = "fishingDerbyMastery";
      
      public static const CONFIG_RODS:String = "rods";
      
      public static const CONFIG_BAITS:String = "baits";
      
      public static const CONFIG_BUFFS:String = "buffs";
      
      public static const CONFIG_COLLECTIONS_PREREQ:String = "collections";
      
      public static const FISHING_SEEN_FLAG_FTUE_COMPLETE:String = "fishingftueseen";
      
      private static const RARITY_COMMON:String = "common";
      
      private static const RARITY_UNCOMMON:String = "uncommon";
      
      private static const RARITY_RARE:String = "rare";
      
      private static const HUD_ICON_ASSET_PATH:String = "assets/dialogs/Angler/FV_Fishing_Jessie.swf";
      
      private static const FTUE_TOOLTIP_KEY:String = "Restart_Fishing_FTUE";
      
      private static const m_instance:FishingDerbyManager = new FishingDerbyManager(SingletonLock);
      
      private var m_hudWidget:HUDFishingDerbyWidget;
      
      private var m_homeWidget:HUDHomeWidget;
      
      private var m_zoomWidget:HUDZoomWidget;
      
      private var m_toaster:FishingDerbyToasterWindow;
      
      private var m_gameMode:String = "";
      
      public var m_timer:Number;
      
      private var m_hudTutorialButton:HUDTutorialButton;
      
      public function FishingDerbyManager(lock:Class)
      {
         super();
         if(lock != SingletonLock)
         {
            throw new Error("Invalid FishingDerbyManager Singleton access. Use FishingDerbyManager.instance");
         }
      }
      
      public static function get instance() : FishingDerbyManager
      {
         return m_instance;
      }
      
      public static function conditionallyShowCollectionCompleteToaster(transactionResult:Object) : void
      {
         var collectionRewardName:String = null;
         var farmItem:FarmItem = null;
         var completedCollections:Object = null;
         if(transactionResult.hasOwnProperty("collectionCompleteGiftName"))
         {
            collectionRewardName = transactionResult.collectionCompleteGiftName as String;
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(collectionRewardName);
            if(farmItem)
            {
               completedCollections = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,"finishedfish");
               if(!completedCollections)
               {
                  completedCollections = new Object();
               }
               completedCollections[transactionResult.collection] = true;
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,"finishedfish",completedCollections);
               Global.player.addGift(farmItem.name);
               ToasterManager.getInstance().add(new FishingDerbyToasterWindow(transactionResult,FishingDerbyToasterWindow.COLLECTION_COMPLETE));
            }
         }
      }
      
      public static function conditionallyShowUnlockBootCollection(transactionResult:Object) : void
      {
         if(transactionResult.hasOwnProperty("unlockBoots"))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FeatureOptionsManager.FEATURE_BOOT,true);
            ToasterManager.getInstance().add(new FishingDerbyToasterWindow(transactionResult,FishingDerbyToasterWindow.UNLOCKED_BOOT));
         }
      }
      
      public static function awardMasteryForCollectible(collectionName:String, collectibleName:String) : void
      {
         var featureOption:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_MASTERY);
         featureOption = featureOption != null ? featureOption : {};
         if(!featureOption.hasOwnProperty(collectionName))
         {
            featureOption[collectionName] = {};
         }
         if(!featureOption[collectionName].hasOwnProperty(collectibleName))
         {
            featureOption[collectionName][collectibleName] = 1;
         }
         else
         {
            ++featureOption[collectionName][collectibleName];
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_MASTERY,featureOption);
      }
      
      public static function awardNumberMasteryForCollectible(collectionName:String, collectibleName:String, amount:int) : void
      {
         var featureOption:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_MASTERY);
         featureOption = featureOption != null ? featureOption : {};
         if(!featureOption.hasOwnProperty(collectionName))
         {
            featureOption[collectionName] = {};
         }
         if(!featureOption[collectionName].hasOwnProperty(collectibleName))
         {
            featureOption[collectionName][collectibleName] = amount;
         }
         else
         {
            featureOption[collectionName][collectibleName] += amount;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_MASTERY,featureOption);
      }
      
      public static function getMasteryDataObject(masteryData:Object, collectible:FishingCollectible) : Object
      {
         var result:Object = null;
         var levelRequirements:Number = NaN;
         var currentMasteryCount:int = masteryData.hasOwnProperty(collectible.name) ? int(masteryData[collectible.name]) : 0;
         var currentLevel:int = 0;
         var currentProgress:int = currentMasteryCount;
         var totCountRequired:int = 0;
         var previousLevelsCounter:int = 0;
         for(var i:int = 1; i <= 3; i++)
         {
            levelRequirements = Global.farmGameSettingsManager.getNumber(MASTERY_COUNT_PREFIX + i + "_" + collectible.rarity);
            if(currentMasteryCount < levelRequirements)
            {
               currentProgress -= previousLevelsCounter;
               totCountRequired = levelRequirements - previousLevelsCounter;
               break;
            }
            currentLevel = i;
            previousLevelsCounter += levelRequirements;
         }
         return {
            "currentLevel":currentLevel,
            "currentProgress":currentProgress,
            "totCountRequired":totCountRequired
         };
      }
      
      public static function getFishingInventory() : Object
      {
         var fishingInventory:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_INVENTORY);
         if(fishingInventory == null)
         {
            fishingInventory = {
               "rod":ROD_BASIC,
               "unlocked_rods":new Array(ROD_BASIC)
            };
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_INVENTORY,fishingInventory);
         }
         return fishingInventory;
      }
      
      public static function getFishingBaits() : Object
      {
         var fishingBaits:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_BAIT);
         if(fishingBaits == null)
         {
            fishingBaits = {
               "active":BAIT_WORM,
               "baits":{
                  "bait_worm":5,
                  "bait_marshmallow":5
               },
               "ts":GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND
            };
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_BAIT,fishingBaits);
         }
         return fishingBaits;
      }
      
      public static function addFishingBaits(itemName:String, baitsCount:int) : void
      {
         var fishingBaits:Object = getFishingBaits();
         if(!(fishingBaits["baits"] as Object).hasOwnProperty(itemName))
         {
            fishingBaits["baits"][itemName] = 0;
         }
         fishingBaits["baits"][itemName] += baitsCount;
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FishingDerbyManager.FEATURE_BAIT,fishingBaits);
         FishingDerbyManager.instance.refreshHUDBaits();
      }
      
      public static function getFishingBuffs() : Object
      {
         var fishingBuffs:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_BUFF);
         if(fishingBuffs == null)
         {
            fishingBuffs = {
               "active":"fishfinder",
               "buffs":{"fishfinder":0},
               "ts":GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND
            };
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_BUFF,fishingBuffs);
         }
         return fishingBuffs;
      }
      
      public static function detachAllFishingBobbers() : void
      {
         var bobber:MiniGameDecoration = null;
         var worldItems:Array = Global.world.getObjectsByCode("1lC");
         if(worldItems.length > 0)
         {
            for each(bobber in worldItems)
            {
               if(bobber as MiniGameDecoration != null)
               {
                  bobber.detach();
               }
            }
         }
      }
      
      public function init(event:Event = null, gameMode:String = "") : void
      {
         StatsManager.count(FeatureOptionsManager.FISHING_DERBY,"angler","travel");
         this.m_gameMode = gameMode;
         if(!Global.player.postInitFinished)
         {
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.init);
         }
         else
         {
            this.m_hudWidget = new HUDFishingDerbyWidget(Global.hud);
            this.m_homeWidget = new HUDHomeWidget(Global.hud);
            this.m_zoomWidget = new HUDZoomWidget(Global.hud);
            Global.hud.setFishingDerbyTackleBox(this.m_hudWidget);
            Global.hud.setHomeWidget(this.m_homeWidget);
            Global.hud.setZoomWidget(this.m_zoomWidget);
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.init);
            this.showFTUE();
            this.m_timer = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
      }
      
      public function getTimer() : Number
      {
         return this.m_timer;
      }
      
      public function showFTUE() : void
      {
         var gmClass:Class = null;
         var seenFlagVal:Boolean = Global.player.getSeenFlag(FISHING_SEEN_FLAG_FTUE_COMPLETE);
         if(!seenFlagVal)
         {
            HUDTutorialManager.instance.initialize(FEATURE_NAME);
         }
         else
         {
            Global.world.getTopGameMode().disableMode();
            Global.world.popGameMode();
            gmClass = getDefinitionByName("GameMode." + this.m_gameMode) as Class;
            Global.world.addGameMode(new gmClass());
            Global.world.addEventListener(HUDHomeWidget.TRAVEL_HOME,this.releaseTutorialButtonWidget);
            if(this.m_hudTutorialButton)
            {
               this.m_hudTutorialButton.release();
               this.m_hudTutorialButton = null;
            }
            this.m_hudTutorialButton = new HUDTutorialButton(HUD_ICON_ASSET_PATH,FTUE_TOOLTIP_KEY,FEATURE_NAME);
         }
      }
      
      private function releaseTutorialButtonWidget(event:Event) : void
      {
         Global.world.removeEventListener(HUDHomeWidget.TRAVEL_HOME,this.releaseTutorialButtonWidget);
         if(this.m_hudTutorialButton)
         {
            this.m_hudTutorialButton.release();
            this.m_hudTutorialButton = null;
         }
      }
      
      public function equipRod(rodName:String) : void
      {
         var farmItem:FarmItem = null;
         var rodCost:int = 0;
         var fishingInventory:Object = getFishingInventory();
         var unlockedRods:Array = fishingInventory["unlocked_rods"] as Array;
         if(unlockedRods.indexOf(rodName) < 0)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(rodName);
            if(farmItem)
            {
               rodCost = farmItem.realCashCost;
               if(Global.player.cash >= rodCost)
               {
                  Global.player.cash -= rodCost;
                  unlockedRods.push(rodName);
                  fishingInventory["rod"] = rodName;
               }
            }
         }
         fishingInventory["rod"] = rodName;
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_INVENTORY,fishingInventory);
         var equipTransaction:TFishing = new TFishing(TFishing.EQUIP_ROD,{"name":rodName},null);
         TransactionManager.addTransaction(equipTransaction);
         this.m_hudWidget.activeRod = rodName;
         Global.world.dispatchEvent(new Event("equipRod"));
      }
      
      public function equipBuff(buffName:String, buyItem:Boolean = true) : void
      {
         var farmItem:FarmItem = null;
         var buffCost:int = 0;
         var fishingBuffs:Object = getFishingBuffs();
         var buffRemaining:int = int(fishingBuffs["buffs"][buffName]);
         if(buyItem)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(buffName);
            if(farmItem)
            {
               buffCost = farmItem.realCashCost;
               if(Global.player.cash >= buffCost)
               {
                  Global.player.cash -= buffCost;
                  fishingBuffs["active"] = buffName;
                  fishingBuffs["buffs"][buffName] += 1;
               }
            }
         }
         else
         {
            fishingBuffs["active"] = buffName;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_BUFF,fishingBuffs);
         var equipTransaction:TFishing = new TFishing(TFishing.EQUIP_BUFF,{
            "name":buffName,
            "buyItem":buyItem
         },null);
         TransactionManager.addTransaction(equipTransaction);
         this.m_hudWidget.updateBuffs();
      }
      
      public function equipBait(baitName:String = "bait_worm") : void
      {
         var fishingBaits:Object = getFishingBaits();
         fishingBaits["active"] = baitName;
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_BAIT,fishingBaits);
         var equipTransaction:TFishing = new TFishing(TFishing.EQUIP_BAIT,{"name":baitName},null);
         TransactionManager.addTransaction(equipTransaction);
         this.refreshHUDBaits();
      }
      
      public function refreshHUDBaits() : void
      {
         if(this.m_hudWidget != null)
         {
            this.m_hudWidget.updateBaits();
         }
      }
      
      public function purchaseMasteryForCollectible(collectionName:String, collectible:FishingCollectible, onConfirmCallback:Function) : void
      {
         var purchased:Boolean = false;
         var frictionBuy:Boolean = collectible.rarity != RARITY_COMMON;
         var price:int = this.calculateCostForMastery(collectible.rarity);
         if(frictionBuy)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","FishingDerby_buyMastery",{
               "price":price,
               "item":ZLocUtils.tk_pk_asTitle("Items:" + collectible.name + "_friendlyName")
            }),GenericPopup.TYPE_ACCEPTCANCEL,this.generateFrictionedPurchaseMastery(collectionName,collectible.name,price,onConfirmCallback),"",true);
         }
         else
         {
            purchased = this.acceptMasteryPurchase(collectionName,collectible.name,price);
            if(onConfirmCallback != null)
            {
               onConfirmCallback(purchased);
            }
         }
      }
      
      private function generateFrictionedPurchaseMastery(collectionName:String, collectibleName:String, price:int, onConfirmCallback:Function) : Function
      {
         return function(event:GenericPopupEvent):void
         {
            var purchased:* = false;
            if(event.button == GenericPopup.YES)
            {
               purchased = acceptMasteryPurchase(collectionName,collectibleName,price);
            }
            if(onConfirmCallback != null)
            {
               onConfirmCallback(purchased);
            }
         };
      }
      
      private function acceptMasteryPurchase(collectionName:String, collectibleName:String, price:int) : Boolean
      {
         var purchased:Boolean = false;
         if(Global.player.canBuyCash(price,true))
         {
            Global.player.cash -= price;
            awardMasteryForCollectible(collectionName,collectibleName);
            TransactionManager.addTransaction(new TFishing(TFishing.BUY_MASTERY,{
               "collectibleName":collectibleName,
               "collectionName":collectionName
            },this.onMasteryPurchaseServerResponse),true);
            purchased = true;
         }
         return purchased;
      }
      
      private function onMasteryPurchaseServerResponse(transactionResult:Object) : void
      {
         if(transactionResult)
         {
            if(transactionResult["masterySign"])
            {
               ToasterManager.getInstance().add(new FishingDerbyToasterWindow(transactionResult));
            }
            conditionallyShowCollectionCompleteToaster(transactionResult);
            conditionallyShowUnlockBootCollection(transactionResult);
         }
      }
      
      public function calculateCostForMastery(rarity:String) : int
      {
         var featureConfig:FeatureConfigManager = FeatureConfigManager.getFeatureConfiguration(FishingDerbyManager.FEATURE_NAME);
         return featureConfig.getNumberConstant("rarityMasteryCost_" + rarity);
      }
      
      public function useFishingBait() : void
      {
         var fishingBaits:Object = FishingDerbyManager.getFishingBaits();
         if(fishingBaits["baits"][fishingBaits["active"]] > 0)
         {
            --fishingBaits["baits"][fishingBaits["active"]];
         }
         if(fishingBaits["baits"][fishingBaits["active"]] == 0)
         {
            fishingBaits["active"] = FishingDerbyManager.BAIT_WORM;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_BAIT,fishingBaits);
         this.refreshHUDBaits();
      }
      
      public function useFishingBuff() : void
      {
         var fishingBuffs:Object = FishingDerbyManager.getFishingBuffs();
         if(fishingBuffs["buffs"][fishingBuffs["active"]] > 0)
         {
            --fishingBuffs["buffs"][fishingBuffs["active"]];
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FEATURE_BUFF,fishingBuffs);
         if(this.m_hudWidget != null)
         {
            this.m_hudWidget.updateBuffs();
         }
      }
      
      public function getConfigArray(itemsType:String = "rods") : Array
      {
         var item:XML = null;
         var obj:Object = null;
         var attribute:XML = null;
         var attName:String = null;
         var attValue:String = null;
         var result:Array = new Array();
         var fishingDerbyFeature:XML = Global.farmGameSettingsManager.getFeatureXML(FEATURE_NAME);
         var itemsList:XMLList = fishingDerbyFeature[itemsType].item;
         for each(item in itemsList)
         {
            obj = {};
            for each(attribute in item.attributes())
            {
               attName = attribute.name();
               attValue = attribute.toXMLString();
               obj[attName] = attValue;
            }
            result.push(obj);
         }
         return result;
      }
      
      public function setMiniGamePrize(result:Object) : void
      {
         var farmItem:FarmItem = null;
         var message:String = null;
         if(result != null && result.hasOwnProperty("prize") && result.hasOwnProperty("count"))
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(result.prize);
            if(farmItem != null)
            {
               addFishingBaits(farmItem.name,1);
               if(this.m_toaster != null)
               {
                  this.m_toaster.addBonusItem(farmItem,result.count);
               }
               else
               {
                  message = ZLocUtils.t_pk("Dialogs","FishingToaster_mini_gamebonus",{"minigamebonus":ZLocUtils.tk_pk(farmItem.friendlyName)});
                  UI.showMessage(message,UI.BUTTON_LAYOUT_OK,null,null,true);
               }
            }
         }
      }
      
      public function get toaster() : FishingDerbyToasterWindow
      {
         return this.m_toaster;
      }
      
      public function set toaster(fishingDerbyToaster:FishingDerbyToasterWindow) : void
      {
         this.m_toaster = fishingDerbyToaster;
      }
   }
}

class SingletonLock
{
   
   public function SingletonLock()
   {
      super();
   }
}
