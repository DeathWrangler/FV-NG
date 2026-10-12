package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.Constants.MFSConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.SimpleHarvestableResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.BreedingFeatureState;
   import Classes.breeding.BreedingState;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.BreedingProjects.TCompleteBreedingTutorial;
   import Transactions.TCancelFriendReward;
   import Transactions.TCompleteNow;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class GreenhouseWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private static const STORAGE_LEVEL_1:int = 1;
      
      private static const STORAGE_LEVEL_2:int = 2;
      
      private static const BAR_WIDTH:int = 120;
      
      private var m_genericButtons:Object = new Object();
      
      private var m_storage:FeatureBuilding;
      
      protected var m_bundleData:Object = null;
      
      protected var m_feedAction:String = "";
      
      private var m_expansionContainer:MovieClip;
      
      public var m_leaderboardContainer:MovieClip;
      
      private var m_genealogyContainer:MovieClip;
      
      private var m_nurseryContainer:MovieClip;
      
      private var m_tutorial:MovieClip;
      
      private var m_expansionBtn:FarmAnimatedTextButton;
      
      private var m_nurseryBtn:FarmAnimatedTextButton;
      
      private var m_genealogyBtn:FarmAnimatedTextButton;
      
      private var m_leaderboardBtn:FarmAnimatedTextButton;
      
      private var m_breedingState:BreedingState;
      
      private var m_nurseryTab:GreenhouseNurseryDialog;
      
      private var m_genealogyTab:GreenhouseGenealogyDialog;
      
      private var m_leaderboardTab:GreenhousePVPWithdrawal;
      
      private var m_initialTray:int;
      
      private var m_initialTab:String = "";
      
      private const BREEDING_FEATURE_NAME:String = "greenhousebuildable_finished";
      
      public function GreenhouseWithdrawal(storage:StorageBuilding)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","GreenhouseWithdrawal","called");
         this.m_storage = storage as FeatureBuilding;
         if(MFSRequestManager.isInR2Migration_b())
         {
            m_dialogAsset = "assets/dialogs/FV_Greenhouse2.swf";
         }
         else
         {
            m_dialogAsset = "assets/dialogs/FV_Greenhouse.swf";
         }
         super(storage);
         m_dialogType = "Greenhouse";
         this.m_breedingState = Global.player.breedingState;
         this.m_initialTray = 0;
         this.m_initialTab = "";
      }
      
      override public function getFeatureReadyState() : Boolean
      {
         var initBreedingState:BreedingState = Global.player.breedingState;
         var initFeatureState:BreedingFeatureState = initBreedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         var hasReady:Boolean = false;
         for(var idx:int = 0; idx < initFeatureState.trays.length; idx++)
         {
            if(initFeatureState.trays[idx])
            {
               if(initFeatureState.timeRemaining(idx) <= 0)
               {
                  hasReady = true;
                  break;
               }
            }
         }
         return hasReady;
      }
      
      override public function doReadyState() : void
      {
         this.showReadyArrow();
      }
      
      private function showReadyArrow() : void
      {
         var objects:Array = Global.world.getObjectsByName("greenhousebuildable_finished");
         var obj:SimpleHarvestableResource = objects[0] as SimpleHarvestableResource;
         obj.showArrowDisplay();
      }
      
      public function hideReadyArrow() : void
      {
         var objects:Array = null;
         var obj:SimpleHarvestableResource = null;
         var initBreedingState:BreedingState = Global.player.breedingState;
         var initFeatureState:BreedingFeatureState = initBreedingState.getBreedingFeatureState(this.BREEDING_FEATURE_NAME);
         var hasReady:Boolean = false;
         for(var idx:int = 0; idx < initFeatureState.trays.length; idx++)
         {
            if(initFeatureState.trays[idx])
            {
               if(initFeatureState.timeRemaining(idx) <= 0)
               {
                  hasReady = true;
                  break;
               }
            }
         }
         if(!hasReady)
         {
            objects = Global.world.getObjectsByName("greenhousebuildable_finished");
            obj = objects[0] as SimpleHarvestableResource;
            obj.hideArrowDisplay();
         }
      }
      
      override protected function onLoadComplete() : void
      {
         var compIdx:int = 0;
         m_window = m_loader.content as MovieClip;
         ZLocUtils.setText(m_window,"nursery_mc.seedTray_mc.crewSlot_0_mc.generic_tf","Dialogs","FV_Greenhouse.key1");
         ZLocUtils.setText(m_window,"tutorial_mc.crewSlot_0_mc.generic_tf","Dialogs","FV_Greenhouse.key1");
         ZLocUtils.setText(m_window,"expandGreenhouse_mc.giftPanel1.buy_bt.generic_tf","Dialogs","Buy");
         ZLocUtils.setText(m_window,"expandGreenhouse_mc.giftPanel2.buy_bt.generic_tf","Dialogs","Buy");
         ZLocUtils.setText(m_window,"expandGreenhouse_mc.giftPanel3.buy_bt.generic_tf","Dialogs","Buy");
         ZLocUtils.setText(m_window,"expandGreenhouse_mc.giftPanel4.buy_bt.generic_tf","Dialogs","Buy");
         ZLocUtils.setText(m_window,"expandGreenhouse_mc.giftPanel1.completeNow_bt.generic_tf","Dialogs","CompleteNow");
         ZLocUtils.setText(m_window,"expandGreenhouse_mc.giftPanel2.completeNow_bt.generic_tf","Dialogs","CompleteNow");
         ZLocUtils.setText(m_window,"expandGreenhouse_mc.giftPanel3.completeNow_bt.generic_tf","Dialogs","CompleteNow");
         ZLocUtils.setText(m_window,"expandGreenhouse_mc.giftPanel4.completeNow_bt.generic_tf","Dialogs","CompleteNow");
         this.m_tutorial = m_window.tutorial_mc;
         var array:Array = new Array();
         array = [ZLocUtils.t("Dialogs","GreenhouseTutorialWelcome"),ZLocUtils.t("Dialogs","GreenhouseTutorialClickPlace"),ZLocUtils.t("Dialogs","GreenhouseTutorialClickBuy"),ZLocUtils.t("Dialogs","GreenhouseTutorialNowPair"),ZLocUtils.t("Dialogs","GreenhouseTutorialRaspberries"),ZLocUtils.t("Dialogs","GreenhouseTutorialSeedsTakeTime"),ZLocUtils.t("Dialogs","GreenhouseTutorialFriendsHelp"),ZLocUtils.t("Dialogs","GreenhouseTutorialCongrats"),ZLocUtils.t("Dialogs","GreenhouseTutorialOKAY"),ZLocUtils.t("Dialogs","GreenhouseTutorialPlaceASeed"),ZLocUtils.t("Dialogs","GreenhouseTutorialHarvest")];
         this.m_tutorial.setStrings(array);
         this.m_tutorial.gotoAndStop(1);
         if(Global.player.getSeenFlag("GreenhouseTutorialSeedGift"))
         {
            this.m_tutorial.visible = false;
         }
         else
         {
            this.m_tutorial.visible = true;
            this.m_tutorial.addEventListener(Event.ENTER_FRAME,this.checkFrameCount);
         }
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClickClose);
         if(m_building)
         {
            ZLocUtils.setTextAsTitle(m_window,"title_mc.title_tf",m_building.getItemFriendlyName());
         }
         var gb:GenericButton = new GenericButton(m_window.howDoes_mc,onClickHowDoesThisWork);
         gb.m_overlay.name = "WhatIsThisBtn";
         gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
         this.m_expansionContainer = m_window.expandGreenhouse_mc;
         var description_tf:TextField = this.m_expansionContainer.description_tf;
         description_tf.text = ZLocUtils.t("Dialogs","GreenhouseWithdrawalDescription");
         this.m_expansionContainer.visible = false;
         this.m_leaderboardContainer = m_window.leaderboard_mc;
         this.m_leaderboardContainer.visible = false;
         this.m_genealogyContainer = m_window.genealogy_mc;
         this.m_genealogyContainer.visible = false;
         this.m_nurseryContainer = m_window.nursery_mc;
         this.m_nurseryContainer.visible = false;
         if(m_building)
         {
            this.m_nurseryTab = new GreenhouseNurseryDialog(this.m_storage,"FeatureBuilding",this,this.m_nurseryContainer,this.m_breedingState,this.m_initialTray);
            this.m_genealogyTab = new GreenhouseGenealogyDialog(this.m_storage,"FeatureBuilding",this,this.m_genealogyContainer,this.m_breedingState);
            this.m_leaderboardTab = new GreenhousePVPWithdrawal(this.m_storage,"FeatureBuilding",this);
            this.setTabButtons();
            if(this.m_initialTab == "expand")
            {
               this.onExpandClick();
            }
            else
            {
               this.onNurseryClick(null,this.m_initialTray);
            }
            m_tiles = new Array(this.m_expansionContainer.giftPanel1,this.m_expansionContainer.giftPanel2,this.m_expansionContainer.giftPanel3,this.m_expansionContainer.giftPanel4);
            removeTiles();
            this.pushNewData();
            m_cashNeeded = this.calculateCashNeeded();
            compIdx = 0;
            while(compIdx < getNumSlots() && compIdx < m_data.length)
            {
               this.addComponent(compIdx);
               compIdx++;
            }
            addChild(m_window);
         }
      }
      
      public function setInitialTrayIndex(index:int) : void
      {
         this.m_initialTray = index;
      }
      
      private function checkFrameCount(event:Event) : void
      {
         if(this.m_tutorial.currentFrame == this.m_tutorial.totalFrames)
         {
            this.m_tutorial.removeEventListener(Event.ENTER_FRAME,this.checkFrameCount);
            Global.player.setSeenFlag("GreenhouseTutorialSeedGift");
            TransactionManager.addTransaction(new TCompleteBreedingTutorial(this.BREEDING_FEATURE_NAME));
         }
      }
      
      override public function getWhatIsThisDialogFileName() : String
      {
         return GenericPopup.GENERIC_ASSET_MED;
      }
      
      private function setTabButtons() : void
      {
         this.m_expansionBtn = new FarmAnimatedTextButton(m_window.expand_bt,ZLocUtils.t("Dialogs","GreenhouseWithdrawalExpandButton"),this.onExpandClick);
         if(this.m_storage.storageLevel == 3)
         {
            this.m_expansionBtn.enabled = false;
            this.m_expansionBtn.visible = false;
         }
         this.m_nurseryBtn = new FarmAnimatedTextButton(m_window.nursery_bt,ZLocUtils.t("Dialogs","GreenhouseWithdrawalNurseryButton"),this.onNurseryClick);
         this.m_genealogyBtn = new FarmAnimatedTextButton(m_window.genealogy_bt,ZLocUtils.t("Dialogs","GreenhouseWithdrawalGenealogyButton"),this.onGenealogyClick);
         this.m_leaderboardBtn = new FarmAnimatedTextButton(m_window.leaderboard_bt,ZLocUtils.t("Dialogs","GreenhouseWithdrawalLeaderboardButton"),this.onLeaderboardClick);
      }
      
      public function openExpansion() : void
      {
         this.onExpandClick();
      }
      
      private function onExpandClick(event:MouseEvent = null) : void
      {
         FarmStatsManager.count("greenhouse","Open_expand_ui");
         this.hideAllTabs();
         this.shareExpansion();
         this.m_expansionContainer.visible = true;
      }
      
      public function openNursery(index:int = 0) : void
      {
         this.onNurseryClick(null,index);
      }
      
      private function onNurseryClick(event:MouseEvent = null, index:int = 0) : void
      {
         FarmStatsManager.count("greenhouse","Open_nursery_ui");
         this.hideAllTabs();
         this.m_nurseryTab.openFreshTab(this.m_breedingState,index);
         this.m_nurseryContainer.visible = true;
      }
      
      private function onGenealogyClick(event:MouseEvent = null) : void
      {
         FarmStatsManager.count("greenhouse","Open_genealogy_ui");
         this.hideAllTabs();
         this.m_genealogyContainer.visible = true;
      }
      
      private function onLeaderboardClick(event:MouseEvent = null) : void
      {
         FarmStatsManager.count("greenhouse","Open_comparison_ui");
         this.hideAllTabs();
         this.m_leaderboardBtn.enabled = false;
         this.m_leaderboardContainer.visible = true;
      }
      
      private function hideAllTabs() : void
      {
         this.m_expansionContainer.visible = false;
         if(this.m_storage.storageLevel == 3)
         {
            this.m_expansionBtn.enabled = false;
         }
         else
         {
            this.m_expansionBtn.enabled = true;
         }
         this.m_leaderboardContainer.visible = false;
         this.m_leaderboardBtn.enabled = true;
         this.m_genealogyContainer.visible = false;
         this.m_genealogyBtn.enabled = true;
         this.m_nurseryContainer.visible = false;
         this.m_nurseryBtn.enabled = true;
      }
      
      override protected function pushNewData() : void
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeMatsNeeded:int = 0;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partDataSource:BaseDataSource = null;
         var partFarmItem:FarmItem = null;
         var partDataObject:Object = null;
         var upgradeData:XML = null;
         var partXml:XML = null;
         var object:Object = null;
         var partItem:FarmItem = null;
         var partData:Object = null;
         m_data = [];
         m_tileSet = 0;
         var sumOfParts:int = 0;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = m_building.getNextBuildingExpansionData();
            if(Boolean(buildingExpansionData) && Boolean(buildingExpansionData.parts))
            {
               m_data = buildingExpansionData.generateWithdrawalUIData(m_building,true);
               sumOfParts = buildingExpansionData.getTotalPartsOnHand(m_building);
               if(this.m_storage.storageLevel == STORAGE_LEVEL_1)
               {
                  if(buildingExpansionData.matsNeeded)
                  {
                     m_window.expandGreenhouse_mc.meter_0_mc.bar_mc.width = sumOfParts * BAR_WIDTH / buildingExpansionData.matsNeeded;
                     m_window.expandGreenhouse_mc.meter_1_mc.bar_mc.width = 0;
                  }
               }
               if(this.m_storage.storageLevel == STORAGE_LEVEL_2)
               {
                  if(buildingExpansionData.matsNeeded)
                  {
                     m_window.expandGreenhouse_mc.meter_0_mc.bar_mc.width = BAR_WIDTH;
                     m_window.expandGreenhouse_mc.meter_1_mc.bar_mc.width = sumOfParts * BAR_WIDTH / buildingExpansionData.matsNeeded;
                  }
               }
            }
         }
         else
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = m_building.getNextExpansionDataSource();
               if(upgradeDataSource)
               {
                  partDataArray = upgradeDataSource.getArray("part");
                  if(partDataArray.length > 0)
                  {
                     for each(partDataSource in partDataArray)
                     {
                        partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(partDataSource.getString("name"));
                        if(partFarmItem)
                        {
                           partDataObject = {};
                           partDataObject.sendGiftsToFriends = false;
                           partDataObject.itemCode = partFarmItem.code;
                           partDataObject.name = partFarmItem.name;
                           partDataObject.needCount = partDataSource.getInt("need");
                           partDataObject.currentCount = m_building.getExpansionPartCount(partFarmItem.code);
                           sumOfParts += partDataObject.currentCount;
                           partDataObject.friendlyName = partFarmItem.friendlyName;
                           partDataObject.icon = partFarmItem.icon;
                           m_data.push(partDataObject);
                        }
                     }
                     m_data.push({"sendGiftsToFriends":true});
                     upgradeMatsNeeded = upgradeDataSource.getInt("matsNeeded");
                  }
               }
            }
            else
            {
               upgradeData = m_building.getNextExpansionData();
               if(Boolean(upgradeData) && Boolean(upgradeData.part))
               {
                  for each(partXml in upgradeData.part)
                  {
                     partItem = Global.farmGameSettingsManager.getFarmItemByName(partXml.@name);
                     if(partItem)
                     {
                        partData = new Object();
                        partData.sendGiftsToFriends = false;
                        partData.itemCode = partItem.code;
                        partData.name = partItem.name;
                        partData.needCount = parseInt(partXml.@need);
                        partData.currentCount = m_building.getExpansionPartCount(partItem.code);
                        sumOfParts += partData.currentCount;
                        partData.friendlyName = partItem.friendlyName;
                        partData.icon = partItem.icon;
                        m_data.push(partData);
                     }
                  }
                  object = new Object();
                  object.sendGiftsToFriends = true;
                  m_data.push(object);
                  upgradeMatsNeeded = int(upgradeData.@matsNeeded);
               }
            }
            if(this.m_storage.storageLevel == STORAGE_LEVEL_1)
            {
               if(upgradeMatsNeeded)
               {
                  m_window.expandGreenhouse_mc.meter_0_mc.bar_mc.width = sumOfParts * BAR_WIDTH / upgradeMatsNeeded;
                  m_window.expandGreenhouse_mc.meter_1_mc.bar_mc.width = 0;
               }
            }
            if(this.m_storage.storageLevel == STORAGE_LEVEL_2)
            {
               if(upgradeMatsNeeded)
               {
                  m_window.expandGreenhouse_mc.meter_0_mc.bar_mc.width = BAR_WIDTH;
                  m_window.expandGreenhouse_mc.meter_1_mc.bar_mc.width = sumOfParts * BAR_WIDTH / upgradeMatsNeeded;
               }
            }
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var data:Object = null;
         var getThis:AskForMoreButton = null;
         var buyButton:GenericButton = null;
         var sendGifts:GenericButton = null;
         var completeNow:GenericButton = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            tile = m_tiles[compId] as MovieClip;
            data = m_data[index + compId];
            tile.visible = true;
            tile.use_bt.visible = false;
            if(data.sendGiftsToFriends == false)
            {
               ZLocUtils.setTextAsTitle(tile,"itemTitle_tf",data.friendlyName);
               tile.alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
                  "quantity":data.currentCount,
                  "maximum":data.needCount
               });
               addIcon(data.name,"icon",tile,tile.icon);
               if(data.currentCount >= data.needCount)
               {
                  ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
                  tile.completeIcon_mc.visible = true;
                  tile.completeNow_bt.visible = false;
                  tile.getThis_bt.visible = false;
                  tile.buy_bt.visible = false;
                  tile.sendMaterials_tf.visible = false;
                  tile.present_bt.visible = false;
               }
               else
               {
                  tile.sendMaterials_tf.visible = false;
                  tile.present_bt.visible = false;
                  tile.completeIcon_mc.visible = false;
                  tile.completeNow_bt.visible = false;
                  getThis = new AskForMoreButton(tile.getThis_bt,this.onAskMoreCallback);
                  getThis.text = ZLocUtils.t("Dialogs","AskForMore");
                  if(getThisGreyOut())
                  {
                     getThis.greyOut();
                  }
                  buyButton = new GenericButton(tile.buy_bt,this.onBuyPartCallback);
                  buyButton.text = ZLocUtils.t("Dialogs","Buy");
               }
            }
            else
            {
               tile.itemTitle_tf.visible = false;
               tile.alive_tf.visible = false;
               tile.completeIcon_mc.visible = false;
               tile.getThis_bt.visible = false;
               tile.buy_bt.visible = false;
               tile.sendMaterials_tf.text = ZLocUtils.t("Dialogs","SendMaterials");
               sendGifts = new GenericButton(tile.present_bt,onSendPresentsCallback);
               sendGifts.m_overlay.name = "SendGifts";
               sendGifts.text = ZLocUtils.t("Dialogs","SendGiftsBig");
               completeNow = new GenericButton(tile.completeNow_bt,this.onCompleteNowCallback);
               completeNow.text = ZLocUtils.t("Dialogs","CompleteNow");
            }
         }
      }
      
      override protected function calculateCashNeeded(partcost:int = 1) : int
      {
         var result:int = 0;
         for(var index:int = 0; index < m_data.length; index++)
         {
            if(!m_data[index].sendGiftsToFriends)
            {
               result += (m_data[index].needCount - m_data[index].currentCount) * partcost;
            }
         }
         return result;
      }
      
      protected function onAskMoreCallback(event:MouseEvent) : void
      {
         var item:FarmItem = null;
         item = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"ask_for_more");
         MFSRequestManager.getInstance().makeAskMatsRequest(m_building.getItem().name,item.name,"","",MFSConstants.SOURCE_DIALOG_CLICKED);
      }
      
      protected function onBuyPartCallback(event:MouseEvent) : void
      {
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName),
            "cashQuantity":m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPartAcceptCallback),false);
      }
      
      protected function onBuyPartAcceptCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && m_itemToBuy != null)
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","accept");
            if(Global.player.canBuyCash(m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,m_building);
               this.m_storage.refreshStorageDialog("expand");
            }
         }
         else
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","cancel");
         }
      }
      
      public function setExpansionViewActive() : void
      {
         this.m_initialTab = "expand";
      }
      
      protected function onCompleteNowCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"complete_now");
         m_cashNeeded = this.calculateCashNeeded();
         var buildingName:String = m_building.getItemFriendlyName();
         UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
            "cashQuantity":m_cashNeeded,
            "item":ZLocUtils.tk_pk(buildingName)
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onCompleteNowAcceptCallback);
         this.onClickClose(event);
      }
      
      protected function onCompleteNowAcceptCallback(event:GenericPopupEvent) : void
      {
         var data:Object = null;
         var buildingPart:BuildingPart = null;
         var parts:int = 0;
         if(event.button == GenericPopup.ACCEPT && m_cashNeeded > 0)
         {
            if(Global.player.canBuyCash(m_cashNeeded))
            {
               for each(data in m_data)
               {
                  if(data.sendGiftsToFriends == false)
                  {
                     if(data.currentCount < data.needCount)
                     {
                        buildingPart = new BuildingPart(data.name);
                        for(parts = int(data.currentCount); parts < data.needCount; parts++)
                        {
                           m_building.addItem(buildingPart,0,false,false);
                        }
                     }
                  }
               }
               TransactionManager.addTransaction(new TCompleteNow(m_building));
               Global.player.cash -= m_cashNeeded;
            }
            close();
         }
         else
         {
            this.m_storage.displayStorageDialog();
         }
      }
      
      private function displaySeedReadyRewardSuccess(rewardLink:String, itemFriendlyName:String, itemRelativeIconUrl:String, itemRelativeFeedIconUrl:String) : void
      {
         this.m_feedAction = m_building.getItem().name + "_seedReadyRewardSuccess";
         var feedImage:String = Global.getAssetURL(itemRelativeFeedIconUrl);
         this.m_bundleData = {
            "item":itemFriendlyName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var title:String = ZLocUtils.t("Dialogs",m_building.getItem().name + "_rewardSeedSuccessTitle");
         var message:String = ZLocUtils.t("Dialogs",m_building.getItem().name + "_rewardSeedSuccessMessage",{"item":itemFriendlyName});
         UI.showMessage(message,UI.BUTTON_LAYOUT_SHARE,title,itemRelativeIconUrl,true,this.onShareSeedReadyRewardSuccess,"feed-greenhouse-Seed_share_extra");
      }
      
      private function onShareSeedReadyRewardSuccess(isAccept:Boolean) : void
      {
         if(isAccept)
         {
            GlobalEngine.socialNetwork.publishFeedStory(this.m_feedAction,this.m_bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_bundleData["reward_link"]]));
         }
      }
      
      private function displaySeedReadyRewardFail(rewardLink:String, itemFriendlyName:String, itemRelativeFeedIconUrl:String) : void
      {
         this.m_feedAction = m_building.getItem().name + "_seedReadyRewardFail";
         var feedImage:String = Global.getAssetURL(itemRelativeFeedIconUrl);
         this.m_bundleData = {
            "item":itemFriendlyName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":feedImage
            }]
         };
         var message:String = ZLocUtils.t("Dialogs",m_building.getItem().name + "_rewardSeedFailMessage");
         UI.showMessage(message,UI.BUTTON_LAYOUT_SHARE,null,null,true,this.onShareSeedReadyRewardFail);
      }
      
      private function onShareSeedReadyRewardFail(isAccept:Boolean) : void
      {
         if(isAccept)
         {
            GlobalEngine.socialNetwork.publishFeedStory(this.m_feedAction,this.m_bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_bundleData["reward_link"]]));
         }
      }
      
      private function garabeCollection() : void
      {
      }
      
      override protected function onClickClose(event:MouseEvent) : void
      {
         if(null != m_howDoesThisWorkPopup)
         {
            m_howDoesThisWorkPopup.close();
         }
         removeTiles(false);
         m_usedTypes = null;
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,onCloseClick);
         event.stopPropagation();
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      private function shareExpansion() : void
      {
         var message:String = null;
         var dialog:GenericIconPopup = null;
         var featureFlag:String = "expand" + m_dialogType + m_building.storageLevel;
         var lastShown:Number = Global.player.getFeatureLastShown(featureFlag);
         var featureFrequency:Number = Global.farmGameSettingsManager.getNumber("GreenhouseExpandStartFeedFeatureFrequency",86400);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         if(!m_building.getTotalExpansionPartCount() && currentTime > lastShown + featureFrequency)
         {
            message = ZLocUtils.t("Dialogs",m_dialogType + "ExpandMessage");
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onShareExpansion,this.getExpandFeedImage());
            dialog.setTrackerKey("feed-greenhouse-upgrade_started");
            UI.displayPopup(dialog,false);
            Global.player.setFeatureLastShown(featureFlag,currentTime,true);
         }
      }
      
      private function onShareExpansion(event:GenericPopupEvent) : void
      {
         var rewardLink:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            rewardLink = "gifts.php?giftRecipient=" + Global.player.snUser.uid;
            bundleData = {
               "reward_link":rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":this.getExpandFeedImage()
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("GreenhouseExpandAsk",bundleData,[],false);
         }
      }
      
      private function getExpandFeedImage() : String
      {
         var level:String = String(m_building.storageLevel + 1);
         return Global.getAssetURL("assets/buildings/building_greenhousebuildable_finished_" + level + "_icon.png");
      }
   }
}

