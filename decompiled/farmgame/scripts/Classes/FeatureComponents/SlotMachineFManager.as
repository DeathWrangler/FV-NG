package Classes.FeatureComponents
{
   import Classes.Collections.Collection;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMCSlotMachineToken;
   import Managers.FarmGameSettingsManager;
   import Managers.MFSRequestManager;
   import Transactions.TBuyConsumables;
   import Transactions.TCancelFriendReward;
   import Transactions.TSlotMachineCollectionTradeIn;
   import Widgets.Windows.SlotMachineWindow;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class SlotMachineFManager extends FeatureManager
   {
      
      public static const STRING_ALLCOLLECTIONSCOMPLETE:String = "allCollectionsComplete";
      
      protected var m_lastTransactionResult:Object;
      
      protected var m_lastCollectionCountersUpdate:Array;
      
      private var m_dialogClassName:String;
      
      protected var m_dialogAssetPath:String;
      
      private var m_tokenItemName:String;
      
      private var m_disableDate:String;
      
      private var m_levels:Array;
      
      private var m_collectibleData:Array = null;
      
      private var m_rewardData:Array = null;
      
      private var m_itemPlaced:FarmItem = null;
      
      private var m_itemPlacedUrl:String = null;
      
      protected var m_tokenToBuy:FarmItem = null;
      
      protected var m_tokenToThrow:FarmItem = null;
      
      protected var m_tokenToShare:FarmItem = null;
      
      protected var m_window:SlotMachineWindow;
      
      private var m_consumableTypes:Array;
      
      public function SlotMachineFManager(owner:FeatureBuilding)
      {
         var ownerFarmItem:FarmItem = null;
         var featureData:BaseDataSource = null;
         var dialogData:BaseDataSource = null;
         var tokenData:BaseDataSource = null;
         var levelDataArray:Array = null;
         var levelObject:Object = null;
         var levelData:BaseDataSource = null;
         var featureXML:XML = null;
         var level:XML = null;
         this.m_lastTransactionResult = {};
         this.m_lastCollectionCountersUpdate = [];
         this.m_consumableTypes = [SlotMachineWindow];
         super(owner);
         this.m_levels = new Array();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            ownerFarmItem = m_owner.getFarmItem();
            featureData = ownerFarmItem.getFeatureDataByName(FeatureManager.SLOTMACHINE2_FEATURE_NAME);
            if(!featureData)
            {
               featureData = m_owner.getFarmItem().getFeatureDataByName(FeatureManager.SLOTMACHINE_FEATURE_NAME);
            }
            if(featureData)
            {
               dialogData = featureData.getData("dialog");
               tokenData = featureData.getData("token");
               this.m_dialogClassName = dialogData.getString("className");
               this.m_dialogAssetPath = dialogData.getString("path");
               this.m_tokenItemName = tokenData.getString("itemName");
               levelDataArray = featureData.getArray("levels","level");
               if(levelDataArray.length > 0)
               {
                  for each(levelData in levelDataArray)
                  {
                     levelObject = {};
                     levelObject.collection = levelData.getString("collection");
                     levelObject.duplicateXP = levelData.getString("duplicateXP");
                     levelObject.extraLootTable = levelData.getString("extraLootTable");
                     this.m_levels[levelData.getNumber("index")] = levelObject;
                  }
               }
               this.m_tokenToBuy = Global.farmGameSettingsManager.getFarmItemByName(tokenData.getString("toBuy"));
               this.m_disableDate = featureData.getString("disableDate");
            }
         }
         else
         {
            featureXML = m_owner.currentFeatureXML;
            this.m_dialogClassName = String(featureXML.dialog.@className);
            this.m_dialogAssetPath = String(featureXML.dialog.@path);
            this.m_tokenItemName = String(featureXML.token.@itemName);
            for each(level in featureXML.levels.level)
            {
               this.m_levels[Number(level.@index)] = new Object();
               this.m_levels[Number(level.@index)]["collection"] = String(level.@collection);
               this.m_levels[Number(level.@index)]["duplicateXP"] = String(level.@duplicateXP);
               this.m_levels[Number(level.@index)]["extraLootTable"] = String(level.@extraLootTable);
            }
            this.m_tokenToBuy = Global.farmGameSettingsManager.getFarmItemByName(String(featureXML.token.@toBuy));
            this.m_disableDate = featureXML.disableDate;
         }
         this.m_tokenToThrow = Global.farmGameSettingsManager.getFarmItemByName(this.m_tokenItemName);
         this.m_tokenToShare = Global.farmGameSettingsManager.getFarmItemByName(this.m_tokenItemName);
         this.parsePrizes();
      }
      
      public function displayWindow() : void
      {
         var className:Class = null;
         var displayWhatIsThisDialog:Boolean = false;
         if(this.m_window == null)
         {
            className = getDefinitionByName("Widgets.Windows." + this.m_dialogClassName) as Class;
            displayWhatIsThisDialog = MOTD.freeGiftUIOpenedFromMOTDAcceptance;
            this.m_window = new className(owner,this.m_dialogAssetPath,displayWhatIsThisDialog);
            UI.displayPopup(this.m_window);
         }
         else
         {
            this.m_window.refresh();
         }
      }
      
      public function onWindowClose() : void
      {
         if(this.m_window != null)
         {
            this.m_window = null;
         }
      }
      
      public function onAskTokens(event:MouseEvent) : void
      {
         MFSRequestManager.getInstance().makeAskItemsRequest("wishingwell",this.m_tokenItemName);
      }
      
      public function onBuyTokens(event:MouseEvent) : void
      {
         var messageText:String = null;
         var imageSize:Number = NaN;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         if(this.m_tokenToBuy != null)
         {
            messageText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
               "item":ZLocUtils.tk_pk(this.m_tokenToBuy.friendlyName),
               "cashQuantity":this.m_tokenToBuy.cash
            });
            imageSize = 100;
            centerIconUrl = Global.reverseAssetURL(this.m_tokenToBuy.icon,2);
            dialog = new GenericXMLDialog(null,"",null,centerIconUrl,imageSize,imageSize,messageText,this.onBuyTokensConfirmation,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
            UI.displayPopup(dialog,false);
         }
      }
      
      private function onBuyTokensConfirmation(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            if(Global.player.canBuyCash(this.m_tokenToBuy.cash,true))
            {
               TransactionManager.addTransaction(new TBuyConsumables(this.m_tokenToBuy.name,false,null,this.onBuyTokensComplete));
            }
         }
      }
      
      public function onBuyTokensComplete() : void
      {
         this.displayWindow();
      }
      
      public function onUseTokens(event:MouseEvent) : void
      {
         if(Global.player.hasGiftItem(this.m_tokenToThrow.code))
         {
            Global.world.addGameMode(new GMCSlotMachineToken(this.m_tokenToThrow.name));
         }
         if(this.m_window)
         {
            this.m_window.scrollToCurrentTier();
            this.m_window.playUseTokenAnim();
            this.m_window.refresh();
         }
      }
      
      public function onSharePlacement(result:Object) : void
      {
         var messageText:String = null;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         if(Boolean(result && result.hasOwnProperty("shareBuyItemName") && result.shareBuyItemName) && Boolean(result.hasOwnProperty("shareBuyUrl")) && Boolean(result.shareBuyUrl))
         {
            Global.player.addGift(this.m_tokenToShare.name);
            this.m_itemPlaced = Global.farmGameSettingsManager.getFarmItemByName(result.shareBuyItemName);
            this.m_itemPlacedUrl = result.shareBuyUrl;
            messageText = ZLocUtils.t("Dialogs","SharePurchaseItem_" + this.m_itemPlaced.name,{"item":ZLocUtils.tk_pk(this.m_itemPlaced.friendlyName)});
            centerIconUrl = Global.reverseAssetURL(this.m_itemPlaced.icon,2);
            dialog = new GenericXMLDialog(null,"",null,centerIconUrl,100,100,messageText,this.onSharePlacementConfirmation,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
            UI.displayPopup(dialog,false);
         }
      }
      
      private function onSharePlacementConfirmation(evt:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(evt.button == GenericPopup.ACCEPT && this.m_itemPlaced != null)
         {
            bundleData = {
               "reward_link":this.m_itemPlacedUrl,
               "item_name":this.m_itemPlaced.friendlyName,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_itemPlacedUrl,
                  "src":this.m_itemPlaced.icon
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("WishingWell2Placement",bundleData,[],false);
         }
         else if(this.m_itemPlacedUrl != null)
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_itemPlacedUrl]));
         }
         if(MOTD.freeGiftUIOpenedFromMOTDAcceptance)
         {
            this.displayWindow();
            MOTD.freeGiftUIOpenedFromMOTDAcceptance = false;
         }
      }
      
      public function onShareBonus(event:MouseEvent) : void
      {
         var bundleData:Object = null;
         if(Boolean(this.lastTransactionResult) && Boolean(this.lastTransactionResult.hasOwnProperty("lootRewardURL")) && Boolean(this.lastTransactionResult.lootRewardURL))
         {
            bundleData = {
               "reward_link":this.lastTransactionResult.lootRewardURL,
               "item_name":this.m_tokenToShare.friendlyName,
               "images":[{
                  "href":"{SN_APP_URL}" + this.lastTransactionResult.lootRewardURL,
                  "src":this.m_tokenToShare.icon
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("WishingWell2BonusTokens",bundleData,[],false);
            this.lastTransactionResult.lootRewardURL = null;
            this.lastTransactionResult.lootItemName = null;
            this.lastTransactionResult.lootItemAnimationPlayed = false;
            this.displayWindow();
         }
      }
      
      public function onClaimReward(event:MouseEvent) : void
      {
         var currentLevelCollection:Collection = new Collection(this.levelCollections[this.currentLevel]);
         currentLevelCollection.tradeIn();
         TransactionManager.addTransaction(new TSlotMachineCollectionTradeIn(currentLevelCollection.code,m_owner as FeatureBuilding,this.displayWindow),true);
      }
      
      public function onShareRedeemed(isAccept:Boolean, rewardData:Object) : void
      {
         var bundleData:Object = null;
         var rewardIcon:String = "assets/newsfeed/collecting.png";
         var rewardItem:FarmItem = null;
         if(rewardData.xp)
         {
            Global.player.xp += int(rewardData.xp);
         }
         if(rewardData.coins)
         {
            Global.player.gold += int(rewardData.coins);
         }
         if(rewardData.rewardItem)
         {
            Global.player.addGift(rewardData.rewardItem);
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardData.rewardItem);
            rewardIcon = rewardItem.iconRelativeUrl;
         }
         if(isAccept)
         {
            bundleData = {
               "prize":rewardItem.friendlyName,
               "reward_link":rewardData.rewardUrl,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardData.rewardUrl,
                  "src":Global.getAssetURL(rewardIcon)
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("WishingWell2PrizeClaimed",bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([rewardData.rewardUrl]));
         }
      }
      
      public function get isEnabled() : Boolean
      {
         var endTime:Number = NaN;
         var result:Boolean = true;
         if(Boolean(this.m_disableDate) && this.m_disableDate != "")
         {
            endTime = FarmGameUtil.synchronizedDateToNumber(this.m_disableDate);
            result = GlobalEngine.serverTime < endTime;
         }
         return result;
      }
      
      public function get levels() : Array
      {
         return this.m_levels;
      }
      
      public function get levelCollections() : Array
      {
         var collectionXML:XML = null;
         var level:Object = null;
         var levelCollections:Array = [];
         var allCollectionsXML:XMLList = Global.farmGameSettingsManager.getCollections();
         for each(collectionXML in allCollectionsXML)
         {
            for each(level in this.levels)
            {
               if(collectionXML.@name == level["collection"])
               {
                  levelCollections.push(collectionXML);
               }
            }
         }
         return levelCollections;
      }
      
      private function parsePrizes() : void
      {
         var collections:Array = null;
         var parsedCollectableData:Array = null;
         var parsedRewardData:Array = null;
         var i:Number = NaN;
         var entry:XML = null;
         var children:XMLList = null;
         var single:XML = null;
         if(this.m_collectibleData == null || this.m_rewardData == null)
         {
            collections = this.levelCollections;
            parsedCollectableData = new Array();
            parsedRewardData = new Array();
            for(i = 0; i < collections.length; i++)
            {
               entry = collections[i];
               children = entry.children();
               for each(single in children)
               {
                  if(single.name() == "collectable")
                  {
                     parsedCollectableData.push({
                        "item":Global.farmGameSettingsManager.getFarmItemByCode(String(single.@code)),
                        "rarity":String(single.@rarity),
                        "num":Global.player.collectionCounters[String(single.@code)]
                     });
                  }
                  else if(single.name() == "tradeInReward")
                  {
                     parsedRewardData.push({
                        "item":Global.farmGameSettingsManager.getFarmItemByName(String(single.@gift)),
                        "xp":String(single.@xp)
                     });
                  }
               }
            }
            this.m_collectibleData = parsedCollectableData;
            this.m_rewardData = parsedRewardData;
         }
      }
      
      public function scrollToCurrentTier() : void
      {
         if(this.m_window)
         {
            this.m_window.scrollToCurrentTier();
         }
      }
      
      public function addDisplayPennyStatusText(delta:Number) : void
      {
         if(this.m_window)
         {
            this.m_window.addDisplayPennyStatusText(delta);
         }
      }
      
      public function getCollectionLevelName(levelIndex:Number) : String
      {
         var nextLevelCollectionName:String = null;
         var result:String = "";
         if(this.levels[levelIndex] != null)
         {
            nextLevelCollectionName = this.levels[levelIndex]["collection"];
            result = "Collections:" + nextLevelCollectionName + "_friendlyName";
         }
         return result;
      }
      
      public function refreshPrizes() : void
      {
         var entry:Object = null;
         if(this.m_collectibleData != null)
         {
            for each(entry in this.m_collectibleData)
            {
               entry.num = Global.player.collectionCounters[entry.item.code];
            }
         }
      }
      
      public function get collectibleData() : Array
      {
         return this.m_collectibleData;
      }
      
      public function get rewardData() : Array
      {
         return this.m_rewardData;
      }
      
      public function get currentLevel() : String
      {
         var levelIdx:String = null;
         var levelCollection:Collection = null;
         var storedCollections:Object = Global.player.storedCollections;
         var currentLevel:String = SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE;
         var numCollectionsCompleted:int = this.currentCollectionsCompleted;
         for(levelIdx in this.levelCollections)
         {
            levelCollection = new Collection(this.levelCollections[levelIdx]);
            if(numCollectionsCompleted == 0)
            {
               if(!levelCollection.isCollectionStored() && currentLevel == SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE)
               {
                  currentLevel = levelIdx;
                  break;
               }
            }
            else if(parseInt(storedCollections[levelCollection.code]) < numCollectionsCompleted + 1)
            {
               currentLevel = levelIdx;
               break;
            }
         }
         return currentLevel;
      }
      
      public function get currentTotalLevelDisplayString() : String
      {
         var result:int = Global.player.getActionCount(SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE) * this.levelCollections.length + 1;
         if(!this.isComplete)
         {
            result += parseInt(this.currentLevel);
         }
         else
         {
            result += this.levelCollections.length;
         }
         return result.toString();
      }
      
      public function get currentCollectionsCompleted() : int
      {
         return Global.player.getActionCount(SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE);
      }
      
      public function get isComplete() : Boolean
      {
         return this.currentLevel == SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE;
      }
      
      public function get canCompleteCurrentLevel() : Boolean
      {
         var currentLevelCollection:Collection = null;
         var result:Boolean = false;
         if(!this.isComplete)
         {
            currentLevelCollection = new Collection(this.levelCollections[this.currentLevel]);
            result = currentLevelCollection.isCollectionComplete();
         }
         return result;
      }
      
      public function get lastCollectionCountersUpdate() : Array
      {
         return this.m_lastCollectionCountersUpdate;
      }
      
      public function set lastCollectionCountersUpdate(result:Array) : void
      {
         this.m_lastCollectionCountersUpdate = result;
         this.displayWindow();
      }
      
      public function get lastTransactionResult() : Object
      {
         return this.m_lastTransactionResult;
      }
      
      public function set lastTransactionResult(result:Object) : void
      {
         this.m_lastTransactionResult = result;
      }
      
      public function get tokenItemName() : String
      {
         return this.m_tokenItemName;
      }
      
      public function get tokenCount() : Number
      {
         var count:Number = 0;
         if(this.m_tokenItemName != null)
         {
            count = Global.player.getGiftCountForItem(this.m_tokenItemName);
         }
         return count;
      }
      
      public function clearPrizes() : void
      {
         var entry:Object = null;
         if(this.m_collectibleData != null)
         {
            for each(entry in this.m_collectibleData)
            {
               Global.player.collectionCounters[entry.item.code] = 0;
            }
         }
      }
   }
}

