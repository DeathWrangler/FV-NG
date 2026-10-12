package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ConstructionBuilding;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.StorageBuilding;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMConstructBuilding;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureTrackingManager;
   import Managers.MFSRequestManager;
   import Managers.TemplateUIUtility;
   import Managers.WorldSeasonsManager;
   import Transactions.TGrantRetroactiveUpgradeAward;
   import Transactions.TStartExpansion;
   import Widgets.Buttons.FarmButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.CustomFreeGiftSelectionWindow;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.controller.ResizeController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gs.TweenLite;
   
   public class FeatureBuildingWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private static const STORAGE_LEVEL_1:int = 1;
      
      private static const STORAGE_LEVEL_2:int = 2;
      
      private static const MATERIAL_RISE_TWEEN_TIME:Number = 3;
      
      private static const BOOL_CONFIRM_DIALOG_ON_USE_BUTTON:Boolean = false;
      
      protected static var m_onStartExpansionRewardLinkCache:Array = new Array();
      
      private var m_genericButtons:Object = new Object();
      
      protected var m_storage:FeatureBuilding;
      
      protected var m_locPrefix:String;
      
      protected var m_buyButtons:Array = [];
      
      private var m_confirmDialog:FarmDynamicDialog = null;
      
      protected var m_showWhatIsThisOnLoad:Boolean = false;
      
      protected var m_isFrictionLessBuyPart:Boolean = false;
      
      protected var m_buildingPreloadingState:String = this.m_storage.getState();
      
      public function FeatureBuildingWithdrawal(dialogAssert:String, dialogType:String, locPrefix:String, storage:StorageBuilding)
      {
         this.m_storage = storage as FeatureBuilding;
         m_dialogAsset = dialogAssert;
         m_dialogType = dialogType;
         this.m_locPrefix = locPrefix;
         this.m_storage.setState(this.m_storage.STATE_BUSY);
         super(storage);
      }
      
      public function getOverlayTag() : String
      {
         return "overlay" + this.CurrentRegion.toString() + "_mc";
      }
      
      public function getSideCardTag() : String
      {
         return "sidecard" + this.CurrentRegion.toString();
      }
      
      override protected function onLoadComplete() : void
      {
         this.m_storage.setState(this.m_buildingPreloadingState);
         m_window = m_loader.content as MovieClip;
         if(m_windowContext != null && m_windowContext == WINDOWCONTEXT_CHOOSEVISUAL)
         {
            this.onLoadCompleteSetupWindowChooseVisual();
         }
         else
         {
            this.onLoadCompleteSetupWindowExpansion();
         }
         if(this.m_showWhatIsThisOnLoad)
         {
            this.m_showWhatIsThisOnLoad = false;
            onClickHowDoesThisWork();
         }
         var buildingName:String = this.m_building.getItemName();
         if(PrerequisiteUtility.checkPrereqByName(TGrantRetroactiveUpgradeAward.BUILDABLE_UPGRADE_AWARD_PREREQ_PREFIX + buildingName))
         {
            TransactionManager.addTransaction(new TGrantRetroactiveUpgradeAward(this.m_building));
         }
      }
      
      private function get CurrentRegion() : int
      {
         var result:int = -1;
         var worldType:String = Global.worldManager.currentWorldType;
         if(WorldSeasonsManager.getInstance().hasSeasons(worldType))
         {
            result = WorldSeasonsManager.getInstance().getCurrentSeason(worldType);
         }
         return result;
      }
      
      private function onLoadCompleteSetupWindowExpansion() : void
      {
         var main_mc:MovieClip = null;
         var cancelBtn:GenericButton = null;
         var closeBtn:FarmButton = null;
         var gb:GenericButton = null;
         main_mc = m_window.main_mc;
         if(main_mc.chooseVisual != null)
         {
            main_mc.chooseVisual.visible = false;
         }
         if(main_mc.hasOwnProperty("close_bt"))
         {
            cancelBtn = new GenericButton(main_mc.close_bt,onClickClose);
            cancelBtn.m_overlay.name = "Cancel";
            cancelBtn.text = ZLocUtils.t("Dialogs","ReturnToFarm");
         }
         if(main_mc.hasOwnProperty("close_x_bt"))
         {
            closeBtn = new FarmButton(main_mc.close_x_bt,onClickClose);
         }
         ZLocUtils.setTextAsTitle(main_mc,"title_tf",m_building.getItemFriendlyName());
         main_mc.description_tf.text = ZLocUtils.t("Dialogs",this.m_locPrefix + "_description");
         if(main_mc.hasOwnProperty("whatisthis_mc") && Boolean(main_mc.whatisthis_mc))
         {
            gb = new GenericButton(main_mc.whatisthis_mc,onClickHowDoesThisWork);
            gb.m_overlay.name = "WhatIsThisBtn";
            gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
         }
         m_tiles = new Array(main_mc.giftPanel1,main_mc.giftPanel2,main_mc.giftPanel3,main_mc.giftPanel4);
         this.m_isFrictionLessBuyPart = main_mc.giftPanel1.hasOwnProperty("fcPrice_mc");
         removeTiles();
         this.pushNewData();
         m_cashNeeded = this.calculateCashNeeded();
         var compIdx:int = 0;
         while(compIdx < getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         this.customizeDialog(main_mc);
         addChild(main_mc);
         if(Boolean(this.m_storage) && Boolean(this.m_storage.expand) && !m_building.isNextStageRegionLocked())
         {
            this.shareExpansion();
         }
      }
      
      protected function customizeDialog(main_mc:MovieClip) : void
      {
      }
      
      private function onLoadCompleteSetupWindowChooseVisual() : void
      {
         var main_mc:MovieClip = null;
         var cancelBtn:GenericButton = null;
         var lastAvailableVisual:int = 0;
         var i:int = 0;
         var gb:GenericButton = null;
         var genericButton:GenericButton = null;
         if(m_windowContext != null && m_windowContext == WINDOWCONTEXT_CHOOSEVISUAL)
         {
            main_mc = m_window.main_mc;
            if(main_mc.chooseVisual != null)
            {
               if(main_mc.progressBar_mc != null)
               {
                  main_mc.progressBar_mc.visible = false;
               }
               if(main_mc.meter_0_mc)
               {
                  main_mc.meter_0_mc.visible = false;
               }
               if(main_mc.meter_1_mc)
               {
                  main_mc.meter_1_mc.visible = false;
               }
               if(main_mc.meter_2_mc)
               {
                  main_mc.meter_2_mc.visible = false;
               }
               if(main_mc.progress1_mc)
               {
                  main_mc.progress1_mc.visible = false;
               }
               if(main_mc.progress2_mc)
               {
                  main_mc.progress2_mc.visible = false;
               }
               if(main_mc.progress3_mc)
               {
                  main_mc.progress3_mc.visible = false;
               }
               if(main_mc.decorationStage1_mc)
               {
                  main_mc.decorationStage1_mc.visible = false;
               }
               if(main_mc.decorationStage1_mc.mc_BigBuildable)
               {
                  main_mc.decorationStage1_mc.mc_BigBuildable.visible = false;
               }
               if(main_mc.questionMark_mc)
               {
                  main_mc.questionMark_mc.visible = false;
               }
               cancelBtn = new GenericButton(main_mc.close_bt,onClickClose);
               cancelBtn.m_overlay.name = "Cancel";
               cancelBtn.text = ZLocUtils.t("Dialogs","ReturnToFarm");
               main_mc.title_tf.text = ZLocUtils.tk_pk_asTitle(m_building.getItemFriendlyName());
               main_mc.description_tf.text = ZLocUtils.t("Dialogs",this.m_locPrefix + "_chooseVisualDescription",{"item":ZLocUtils.tk_pk(m_building.getItemFriendlyName())});
               if(main_mc.hasOwnProperty("whatisthis_mc") && Boolean(main_mc.whatisthis_mc))
               {
                  gb = new GenericButton(main_mc.whatisthis_mc,onClickHowDoesThisWork);
                  gb.m_overlay.name = "WhatIsThisBtn";
                  gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
               }
               lastAvailableVisual = this.m_storage.storageLevel + 1;
               for(i = 1; i <= this.NUM_BUILDINGVISUALS; i++)
               {
                  genericButton = new GenericButton(main_mc.chooseVisual["choose" + i.toString() + "_bt"],this.onClickChooseVisual);
                  if(i > lastAvailableVisual)
                  {
                     genericButton.useGrayOnDisabled = true;
                     genericButton.disabled = true;
                  }
                  genericButton.m_overlay.name = "Choose";
                  genericButton.text = ZLocUtils.t("Dialogs",this.m_locPrefix + "_chooseVisualButton");
                  m_chooseVisualBtns[i] = genericButton;
               }
               addChild(m_window);
            }
         }
      }
      
      protected function onClickChooseVisual(event:MouseEvent) : void
      {
         for(var i:int = 1; i <= NUM_BUILDINGVISUALS; i++)
         {
            if(m_chooseVisualBtns[i] == event.target.buttonPointer)
            {
               this.m_storage.onSelectOverlay(i - 1);
               break;
            }
         }
         onClickClose(event);
      }
      
      override protected function takeDefaultAction() : void
      {
         var mostNeededItem:String = null;
         var action:String = m_defaultAction;
         m_defaultAction = "";
         switch(action)
         {
            case "complete_now":
               if(m_building.storageLevel == 0)
               {
                  onFinishConstructionCallback(new MouseEvent(MouseEvent.CLICK));
               }
               else
               {
                  this.onCompleteNowCallback();
               }
               break;
            case "ask_for_parts":
               if(m_building.getMostNeededItem())
               {
                  mostNeededItem = m_building.getMostNeededItem().item.name;
                  this.onAskMoreCallback(null,mostNeededItem);
               }
         }
      }
      
      private function setButtonState(buttonId:String, state:String) : void
      {
         var button:GenericButton = this.m_genericButtons[buttonId] as GenericButton;
         if(button)
         {
            button.state = state;
         }
      }
      
      override protected function pushNewData() : void
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var upgradeData:XML = null;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = m_building.getNextBuildingExpansionData();
            this.pushBuildingExpansionData(buildingExpansionData);
         }
         else
         {
            upgradeDataSource = null;
            upgradeData = null;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = m_building.getNextExpansionDataSource();
            }
            else
            {
               upgradeData = m_building.getNextExpansionData();
            }
            this.pushUpgradeData(upgradeData,upgradeDataSource);
         }
      }
      
      protected function pushBuildingExpansionData(buildingExpansionData:BuildingExpansionData) : void
      {
         m_tileSet = 0;
         m_data = [];
         if(Boolean(buildingExpansionData) && Boolean(buildingExpansionData.parts))
         {
            m_data = buildingExpansionData.generateWithdrawalUIData(m_building,true);
            this.refreshProgressMeter();
         }
      }
      
      protected function pushUpgradeData(upgradeData:XML, upgradeDataSource:BaseDataSource = null) : void
      {
         var partDataArray:Array = null;
         var partDataSource:BaseDataSource = null;
         var partFarmItem:FarmItem = null;
         var partObject:Object = null;
         var partXml:XML = null;
         var object:Object = null;
         var partItem:FarmItem = null;
         var partData:Object = null;
         m_data = [];
         m_tileSet = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
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
                        partObject = {};
                        partObject.sendGiftsToFriends = false;
                        partObject.itemCode = partFarmItem.code;
                        partObject.name = partFarmItem.name;
                        partObject.needCount = partDataSource.getInt("need");
                        partObject.currentCount = m_building.getExpansionPartCount(partFarmItem.code);
                        partObject.friendlyName = partFarmItem.friendlyName;
                        partObject.icon = partFarmItem.icon;
                        m_data.push(partObject);
                     }
                  }
               }
            }
         }
         else if(Boolean(upgradeData) && Boolean(upgradeData.part))
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
                  partData.friendlyName = partItem.friendlyName;
                  partData.icon = partItem.icon;
                  m_data.push(partData);
               }
            }
            object = new Object();
            object.sendGiftsToFriends = true;
            m_data.push(object);
            this.refreshProgressMeter();
         }
      }
      
      protected function refreshProgressMeter() : void
      {
         var curLevel:int = 0;
         var nextLevel:int = 0;
         var completedLevelIdx:int = 0;
         var unreachedLevel:int = 0;
         var completionRatio:Number = NaN;
         var level:int = 0;
         var levelForImage:int = 0;
         var levelIcon:FarmIcon = null;
         var inventoryCount:Object = this.getCurVsTotalPartsNeeded();
         if(this.m_storage)
         {
            curLevel = this.m_storage.storageLevel;
            nextLevel = curLevel + 1;
            for(completedLevelIdx = 0; completedLevelIdx < curLevel; completedLevelIdx++)
            {
               if(m_window.main_mc.hasOwnProperty("meter_" + completedLevelIdx + "_mc"))
               {
                  m_window.main_mc["meter_" + completedLevelIdx + "_mc"].bar_mc.scaleX = 1;
               }
               this.setVisibility(m_window.main_mc,"decorationStage" + completedLevelIdx + "_mc",false);
               this.setVisibility(m_window.main_mc,"decorationStage" + completedLevelIdx + "_FG_mc",false);
            }
            if(m_window.main_mc.hasOwnProperty("meter_" + curLevel + "_mc"))
            {
               completionRatio = inventoryCount.currentTotal / inventoryCount.neededTotal;
               m_window.main_mc["meter_" + curLevel + "_mc"].bar_mc.scaleX = inventoryCount.currentTotal / inventoryCount.neededTotal;
            }
            unreachedLevel = nextLevel;
            while(Boolean(m_window.main_mc.hasOwnProperty("decorationStage" + unreachedLevel + "_mc")) || Boolean(m_window.main_mc.hasOwnProperty("decorationStage" + unreachedLevel + "_FG_mc")) || Boolean(m_window.main_mc.hasOwnProperty("meter_" + unreachedLevel + "_mc")))
            {
               this.setVisibility(m_window.main_mc,"decorationStage" + unreachedLevel + "_mc",false);
               this.setVisibility(m_window.main_mc,"decorationStage" + unreachedLevel + "_FG_mc",false);
               if(m_window.main_mc.hasOwnProperty("meter_" + unreachedLevel + "_mc"))
               {
                  m_window.main_mc["meter_" + unreachedLevel + "_mc"].bar_mc.width = 0;
               }
               unreachedLevel++;
            }
            if(m_building.isNextStageRegionLocked())
            {
               level = curLevel;
               while(m_window.main_mc.hasOwnProperty("decorationStage" + level + "_mc"))
               {
                  this.setVisibility(m_window.main_mc,"decorationStage" + level + "_mc",false);
                  level++;
               }
            }
            else
            {
               levelForImage = 0;
               if(m_window.main_mc.hasOwnProperty("decorationStage" + nextLevel + "_mc"))
               {
                  this.setVisibility(m_window.main_mc,"decorationStage" + nextLevel + "_mc",true);
                  this.setVisibility(m_window.main_mc,"decorationStage" + nextLevel + "_FG_mc",true);
                  levelForImage = nextLevel;
                  this.setVisibility(m_window.main_mc,"decorationStage" + curLevel + "_mc",false);
                  this.setVisibility(m_window.main_mc,"decorationStage" + curLevel + "_FG_mc",false);
               }
               else if(m_window.main_mc.hasOwnProperty("decorationStage" + curLevel + "_mc"))
               {
                  this.setVisibility(m_window.main_mc,"decorationStage" + curLevel + "_mc",true);
                  this.setVisibility(m_window.main_mc,"decorationStage" + curLevel + "_FG_mc",true);
                  levelForImage = curLevel;
               }
               if(m_window["main_mc"]["decorationStage" + levelForImage + "_mc"].hasOwnProperty("mc_BigBuildable"))
               {
                  levelIcon = new FarmIcon(m_window["main_mc"]["decorationStage" + levelForImage + "_mc"].mc_BigBuildable) as FarmIcon;
                  levelIcon.setIconSize(300,300);
                  levelIcon.setSmoothing(true);
                  levelIcon.loadIcon(Global.getAssetURL("assets/buildings/building_" + m_building.getItem().name + "_" + (levelForImage - 1) + "_icon_300.png"));
               }
            }
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var data:Object = null;
         var askForMoreButton:AskForMoreButton = null;
         var expandAskType:String = null;
         var buyButton:GenericButton = null;
         var askButtonText:String = null;
         var useMatButton:GenericButton = null;
         var sendGifts:GenericButton = null;
         var completeNowCallback:Function = null;
         var completeNow:GenericButton = null;
         var isFrictionLess:Boolean = false;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            tile = m_tiles[compId] as MovieClip;
            data = m_data[index + compId];
            tile.visible = true;
            this.setVisibility(tile,"use_bt",false);
            if(data.sendGiftsToFriends == false)
            {
               tile.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(data.friendlyName);
               tile.matName = data.name;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(tile.itemTitle_tf);
               }
               addIcon(data.name,"icon",tile,tile.icon);
               if(data.currentCount < data.needCount)
               {
                  askForMoreButton = new AskForMoreButton(tile.getThis_bt,this.onAskMoreCallback);
                  tile.askForMoreButton = askForMoreButton;
                  expandAskType = this.m_storage.expand.getPartAskMethod(data.itemCode);
                  if(expandAskType == FeatureBuilding.PART_ASK_METHOD_FEED && !this.m_storage.canRequestPartFeed(data.itemCode) || getThisGreyOut())
                  {
                     askForMoreButton.text = ZLocUtils.t("Dialogs","AskForMore_asfeed_posted");
                     askForMoreButton.greyOut();
                  }
                  else
                  {
                     askButtonText = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs","AskForMore_as" + expandAskType),new ZLocFailoverEntry("Dialogs","AskForMore")]);
                     askForMoreButton.text = askButtonText;
                     if(getThisGreyOut())
                     {
                        askForMoreButton.greyOut();
                     }
                  }
                  buyButton = new GenericButton(tile.buy_bt,this.onBuyPartCallback);
                  this.m_buyButtons.push(buyButton);
                  buyButton.useGrayOnDisabled = true;
                  buyButton.text = ZLocUtils.t("Dialogs","Buy");
                  tile.buyButton = buyButton;
                  if(tile.use_mat_bt)
                  {
                     useMatButton = new GenericButton(tile.use_mat_bt,this.onUsePartCallback);
                     tile.useMatButton = useMatButton;
                  }
               }
               this.refreshMaterialTileButtons(tile,data);
            }
            else
            {
               this.setVisibility(tile,"itemTitle_tf",false);
               this.setVisibility(tile,"alive_tf",false);
               this.setVisibility(tile,"completeIcon_mc",false);
               this.setVisibility(tile,"getThis_bt",false);
               this.setVisibility(tile,"buy_bt",false);
               this.setVisibility(tile,"use_mat_bt",false);
               this.setVisibility(tile,"available_tf",false);
               tile.sendMaterials_tf.text = ZLocUtils.t("Dialogs","SendMaterials");
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(tile.sendMaterials_tf);
               }
               sendGifts = new GenericButton(tile.present_bt,this.onSendPresentsCallback);
               sendGifts.m_overlay.name = "SendGifts";
               sendGifts.text = ZLocUtils.t("Dialogs","SendGiftsBig");
               completeNowCallback = m_building.storageLevel == 0 ? onFinishConstructionCallback : this.onCompleteNowCallback;
               completeNow = new GenericButton(tile.completeNow_bt,completeNowCallback);
               completeNow.text = ZLocUtils.t("Dialogs","CompleteNow");
               isFrictionLess = this.m_storage.isFrictionLessExpansionCompleteFlow(FeatureBuilding.ACTION_SOURCE_LOOK_INSIDE_UI);
               if(this.setVisibility(tile,"fcPrice_mc",isFrictionLess))
               {
                  if(isFrictionLess)
                  {
                     completeNow.text = ZLocUtils.t("Dialogs","Complete");
                     tile.fcPrice_mc.FCPrice_tf.text = this.m_storage.nextExpansionCashNeeded().toString();
                     if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
                     {
                        TemplateUIUtility.applyExpansionGlowFilter(tile.fcPrice_mc.FCPrice_tf);
                     }
                  }
               }
               tile.completeNowBtn = completeNow;
            }
            this.customizeTile(tile);
         }
      }
      
      protected function customizeTile(tile:MovieClip) : void
      {
      }
      
      private function refreshMaterialTiles(index:int = 0, showChangeFX:Boolean = false) : void
      {
         var compId:int = 0;
         var tile:MovieClip = null;
         var data:Object = null;
         var prevCurrentCount:Number = NaN;
         var matItemCode:String = null;
         var deltaCount:Number = NaN;
         if(Boolean(m_tiles) && m_data != null)
         {
            compId = 0;
            while(compId < getNumSlots() && compId < m_data.length)
            {
               if(Boolean(m_tiles) && m_data[index + compId] != null)
               {
                  tile = m_tiles[compId] as MovieClip;
                  data = m_data[index + compId];
                  if(data.sendGiftsToFriends == false)
                  {
                     prevCurrentCount = Number(data.currentCount);
                     if(m_building as ConstructionBuilding)
                     {
                        matItemCode = data.code;
                     }
                     else
                     {
                        matItemCode = data.itemCode;
                     }
                     data.currentCount = m_building.getCurrentLevelConstructionItemCount(matItemCode);
                     deltaCount = 0;
                     if(showChangeFX)
                     {
                        deltaCount = data.currentCount - prevCurrentCount;
                     }
                     this.refreshMaterialTileButtons(tile,data,deltaCount);
                  }
                  else if(this.m_storage.isFrictionLessExpansionCompleteFlow(FeatureBuilding.ACTION_SOURCE_LOOK_INSIDE_UI))
                  {
                     if(tile.fcPrice_mc)
                     {
                        tile.fcPrice_mc.FCPrice_tf.text = this.m_storage.nextExpansionCashNeeded().toString();
                     }
                  }
               }
               compId++;
            }
         }
      }
      
      private function refreshMaterialTileButtons(tile:MovieClip, data:Object, deltaCount:Number = 0) : void
      {
         var item:FarmItem = null;
         var amountToBuy:int = 0;
         var costToBuy:int = 0;
         var buildingPart:BuildingPart = null;
         var message:String = null;
         var iconFilter:Array = null;
         var iconUrl:String = null;
         var tweenDuration:Number = NaN;
         var expandAskType:String = null;
         var totalInventory:Number = Global.player.getGiftCountForItem(tile.matName);
         if(this.allowFrictionlessBuy())
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(data.name);
            amountToBuy = 1;
            if(this.allowBulkBuy())
            {
               amountToBuy = this.calculateRequirePartAmount(item);
            }
            costToBuy = item.cash * amountToBuy;
            tile.fcPrice_mc.FCPrice_tf.text = costToBuy.toString();
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionGlowFilter(tile.fcPrice_mc.FCPrice_tf);
            }
         }
         tile.alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
            "quantity":data.currentCount,
            "maximum":data.needCount
         });
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionSubTextColor(tile.alive_tf);
         }
         this.refreshProgressMeter();
         if(deltaCount > 0 && Boolean(tile.useMatButton))
         {
            buildingPart = new BuildingPart(tile.matName);
            message = "+" + deltaCount + " " + ZLocUtils.tk_pk_asTitle(data.friendlyName);
            iconFilter = [BuildingPart.newStandardGlowFilter()];
            iconUrl = buildingPart.getItem().icon;
            tweenDuration = UI.DEFAULT_STATUS_TWEEN_DURATION * 2;
            this.displayMaterialStatusChange(message,tile,iconUrl,iconFilter);
         }
         if(data.currentCount >= data.needCount)
         {
            ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
            this.setVisibility(tile,"completeIcon_mc",true);
            this.setVisibility(tile,"completeNow_bt",false);
            this.setVisibility(tile,"getThis_bt",false);
            this.setVisibility(tile,"buy_bt",false);
            this.setVisibility(tile,"fcPrice_mc",false);
            this.setVisibility(tile,"sendMaterials_tf",false);
            this.setVisibility(tile,"present_bt",false);
            if(tile.askForMoreButton)
            {
               tile.askForMoreButton.turnOff();
            }
            if(tile.buyButton)
            {
               tile.buyButton.turnOff();
            }
            if(tile.useMatButton)
            {
               tile.useMatButton.turnOff();
            }
            this.setVisibility(tile,"use_mat_bt",false);
            this.setVisibility(tile,"available_tf",false);
         }
         else
         {
            this.setVisibility(tile,"sendMaterials_tf",false);
            this.setVisibility(tile,"present_bt",false);
            this.setVisibility(tile,"completeIcon_mc",false);
            this.setVisibility(tile,"completeNow_bt",false);
            if(getThisGreyOut())
            {
               tile.askForMoreButton.greyOut();
            }
            if(totalInventory > 0 && Boolean(tile.useMatButton))
            {
               tile.askForMoreButton.turnOff();
               tile.buyButton.turnOff();
               this.setVisibility(tile,"fcPrice_mc",false);
               if(tile.useMatButton)
               {
                  tile.useMatButton.turnOn();
               }
               if(tile.available_tf)
               {
                  tile.available_tf.visible = true;
                  tile.available_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatAvailable",{"quantity":totalInventory});
               }
            }
            else
            {
               if(tile.askForMoreButton)
               {
                  expandAskType = this.m_storage.expand.getPartAskMethod(data.itemCode);
                  if(getThisGreyOut() || expandAskType == FeatureBuilding.PART_ASK_METHOD_FEED && !this.m_storage.canRequestPartFeed(data.itemCode))
                  {
                     tile.askForMoreButton.greyOut();
                  }
                  else
                  {
                     tile.askForMoreButton.turnOn();
                  }
               }
               if(tile.buyButton)
               {
                  tile.buyButton.turnOn();
               }
               this.setVisibility(tile,"fcPrice_mc",true);
               if(tile.useMatButton)
               {
                  tile.useMatButton.turnOff();
               }
               if(tile.available_tf)
               {
                  tile.available_tf.visible = false;
               }
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
      
      protected function getCurVsTotalPartsNeeded() : Object
      {
         var result:Object = new Object();
         result.neededTotal = 0;
         result.currentTotal = 0;
         for(var index:int = 0; index < m_data.length; index++)
         {
            if(!m_data[index].sendGiftsToFriends)
            {
               result.neededTotal += m_data[index].needCount;
               result.currentTotal += m_data[index].currentCount;
            }
         }
         return result;
      }
      
      protected function getCurVsTotalSpecificPartsNeeded(matItemCode:String) : Object
      {
         var result:Object = new Object();
         result.neededTotal = 0;
         result.currentTotal = 0;
         for(var index:int = 0; index < m_data.length; index++)
         {
            if(!m_data[index].sendGiftsToFriends)
            {
               if(m_data[index].itemCode == matItemCode || m_data[index].code == matItemCode)
               {
                  result.neededTotal = m_data[index].needCount;
                  result.currentTotal = m_data[index].currentCount;
                  break;
               }
            }
         }
         return result;
      }
      
      protected function onBuyPartCallback(event:MouseEvent) : void
      {
         var messageText:String = null;
         var amountToBuy:int = 0;
         var costToBuy:int = 0;
         var titleText:String = null;
         var buttonText:String = null;
         var closeButtonView:BaseWidgetView = null;
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         if(this.allowFrictionlessBuy())
         {
            this.fricionLessBuyPart(m_itemToBuy,this.allowBulkBuy());
         }
         else
         {
            if(this.allowBulkBuy())
            {
               amountToBuy = this.calculateRequirePartAmount(m_itemToBuy);
               costToBuy = m_itemToBuy.cash * amountToBuy;
               titleText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyBulkConfirmation_Title");
               messageText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyBulkConfirmation_Message",{
                  "quantity":amountToBuy,
                  "item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName,"",amountToBuy),
                  "cost":costToBuy
               });
               buttonText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyBulkConfirmation_ConfirmButton",{"quantity":costToBuy});
               this.m_confirmDialog = FarmDynamicDialog.createDialog("GenericBuyWithCashConfirmDialog",FarmDynamicDialog);
               this.m_confirmDialog.setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,titleText);
               this.m_confirmDialog.setShortcutAttribute("itemImage",ImageController.ATTRIBUTE_SOURCE,m_itemToBuy.iconUrl);
               this.m_confirmDialog.setShortcutAttribute("belowImageText",TextFieldView.ATTRIBUTE_TEXT,messageText);
               this.m_confirmDialog.setShortcutAttribute("text",TextFieldView.ATTRIBUTE_TEXT,buttonText);
               this.m_confirmDialog.getShortcutController("buyButton").listen(WidgetControllerEvent.BUTTON_PRESSED,this.onBuyBulkPartAcceptCallback);
               closeButtonView = this.m_confirmDialog.getShortcutAttribute("outside",ResizeController.ATTRIBUTE_VIEW_TO_PIN);
               closeButtonView.getController().listen(WidgetControllerEvent.BUTTON_PRESSED,this.onCancelBuyPartAcceptCallback);
               this.m_confirmDialog.show();
               FarmStatsManager.count(CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","view");
            }
            else
            {
               messageText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
                  "item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName),
                  "cashQuantity":m_itemToBuy.cash
               });
               UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPartAcceptCallback),false);
            }
            this.setBuyButtonsDisable(true);
         }
      }
      
      protected function onBuyPartAcceptCallback(event:GenericPopupEvent) : void
      {
         this.setBuyButtonsDisable(false);
         if(event.button == GenericPopup.ACCEPT && m_itemToBuy != null)
         {
            FarmStatsManager.count(CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","accept");
            if(Global.player.canBuyCash(m_itemToBuy.cash,true))
            {
               this.buyPartAndUpdateUI();
            }
         }
         else
         {
            FarmStatsManager.count(CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","cancel");
         }
      }
      
      protected function buyPartAndUpdateUI() : void
      {
         BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,this.m_storage);
         close();
         TweenLite.to(this,MATERIAL_RISE_TWEEN_TIME,{"onComplete":function():void
         {
            m_storage.refreshStorageDialog();
         }});
      }
      
      private function calculateRequirePartAmount(item:FarmItem) : int
      {
         var counts:Object = this.getCurVsTotalSpecificPartsNeeded(item.code);
         return counts.neededTotal - counts.currentTotal;
      }
      
      private function onBuyBulkPartAcceptCallback(event:WidgetControllerEvent) : void
      {
         this.setBuyButtonsDisable(false);
         this.fricionLessBuyPart(m_itemToBuy,this.allowBulkBuy());
         this.m_confirmDialog.destroy();
         this.m_confirmDialog = null;
      }
      
      private function fricionLessBuyPart(item:FarmItem, bulkBuy:Boolean = true) : void
      {
         var inventoryCount:Object = null;
         StatsManager.count(CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","accept");
         var amountToBuy:int = 1;
         if(bulkBuy)
         {
            amountToBuy = this.calculateRequirePartAmount(m_itemToBuy);
         }
         var costToBuy:int = m_itemToBuy.cash * amountToBuy;
         if(Global.player.canBuyCash(costToBuy,true))
         {
            inventoryCount = this.getCurVsTotalPartsNeeded();
            if(inventoryCount.neededTotal > 0 && inventoryCount.currentTotal + amountToBuy >= inventoryCount.neededTotal)
            {
               Global.world.addGameMode(new GMConstructBuilding(m_itemToBuy.name,m_building,false,true,false,amountToBuy),false);
               close();
            }
            else
            {
               Global.world.addGameMode(new GMConstructBuilding(m_itemToBuy.name,m_building,false,false,false,amountToBuy),false);
               this.refreshMaterialTiles(0,true);
            }
         }
      }
      
      private function onCancelBuyPartAcceptCallback(event:WidgetControllerEvent) : void
      {
         this.setBuyButtonsDisable(false);
         StatsManager.count(CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","cancel");
      }
      
      protected function allowBulkBuy() : Boolean
      {
         var result:Boolean = false;
         var farmItem:FarmItem = this.m_building.getItem();
         if(farmItem != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               result = farmItem.getBoolFromDataSource("matsAllowBulkBuy");
            }
            else if(farmItem.xml.hasOwnProperty("matsAllowBulkBuy"))
            {
               result = farmItem.xml.matsAllowBulkBuy.toString() == "true";
            }
         }
         return result;
      }
      
      private function allowFrictionlessBuy() : Boolean
      {
         var farmItem:FarmItem = null;
         var result:Boolean = false;
         if(this.m_isFrictionLessBuyPart)
         {
            result = true;
            farmItem = this.m_building.getItem();
            if(farmItem != null)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  if(farmItem.hasPropertyInDataSource("matsAllowFrictionlessBuy"))
                  {
                     result = farmItem.getBoolFromDataSource("matsAllowFrictionlessBuy");
                  }
               }
               else if(farmItem.xml.hasOwnProperty("matsAllowFrictionlessBuy"))
               {
                  result = farmItem.xml.matsAllowFrictionlessBuy.toString() == "true";
               }
            }
         }
         return result;
      }
      
      protected function onUsePartCallback(event:MouseEvent) : void
      {
         var messageText:String = null;
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         if(m_itemToBuy != null)
         {
            if(BOOL_CONFIRM_DIALOG_ON_USE_BUTTON)
            {
               messageText = ZLocUtils.t("Dialogs","ConstructionBuilding_UseMaterialConfirmation",{"item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName)});
               UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onUseGiftboxPartAcceptCallback),false);
            }
            else
            {
               this.execUseGiftboxPart();
            }
         }
      }
      
      protected function onUseGiftboxPartAcceptCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && m_itemToBuy != null)
         {
            StatsManager.count(CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"use_part","accept");
            this.execUseGiftboxPart();
         }
         else
         {
            StatsManager.count(CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"use_part","cancel");
         }
      }
      
      protected function execUseGiftboxPart() : void
      {
         var inventoryCount:Object = null;
         if(m_itemToBuy)
         {
            inventoryCount = this.getCurVsTotalPartsNeeded();
            if(inventoryCount.neededTotal > 0 && inventoryCount.currentTotal + 1 == inventoryCount.neededTotal)
            {
               Global.world.addGameMode(new GMConstructBuilding(m_itemToBuy.name,m_building,true,true,false),false);
               close();
               TweenLite.to(this,MATERIAL_RISE_TWEEN_TIME,{"onComplete":function():void
               {
                  m_building.displayStorageDialog();
               }});
            }
            else
            {
               Global.world.addGameMode(new GMConstructBuilding(m_itemToBuy.name,m_building,true,false,false),false);
               this.refreshMaterialTiles(0,true);
            }
         }
      }
      
      public function displayMaterialStatusChange(message:String, tile:MovieClip, iconUrl:String = "", iconFilters:Array = null, tweenDuration:Number = 1.5, tweenDisplacement:int = 32, fontSize:int = 16, fontColor:uint = 16777215) : void
      {
         var anchorObj:DisplayObject = null;
         var localPos:Point = null;
         var screen:Point = null;
         if(tile.iconBox_mc)
         {
            anchorObj = tile.iconBox_mc;
            localPos = new Point(anchorObj.x + anchorObj.width * 0.5,anchorObj.y - anchorObj.height);
            screen = anchorObj.localToGlobal(localPos);
            UI.displayStatus(message,screen.x,screen.y,iconUrl,iconFilters,tweenDuration,tweenDisplacement,fontSize,fontColor);
         }
      }
      
      override protected function onSendPresentsCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count(CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"send_gift");
         close();
         UI.displayPopup(new CustomFreeGiftSelectionWindow(this.getPartsArray()));
      }
      
      protected function getPartsString() : String
      {
         if(this.m_storage)
         {
            return this.m_storage.getPartsString();
         }
         return m_building.getPartsString();
      }
      
      protected function getPartsArray() : Array
      {
         if(this.m_storage)
         {
            return this.m_storage.getPartsArray();
         }
         return m_building.getPartsArray();
      }
      
      protected function onCompleteNowCallback(event:MouseEvent = null) : void
      {
         if(!event)
         {
            event = new MouseEvent(MouseEvent.CLICK);
         }
         var expansionCashNeeded:Number = this.m_storage.nextExpansionCashNeeded();
         if(Boolean(Global.flashHotParams["MP_BIGBUILDABLE_FC_CONFIRMATION"]) && expansionCashNeeded > 10)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":expansionCashNeeded}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmationFinished,"Feature_Building_Complete_Now_Confirmation",true,true);
         }
         else
         {
            this.m_storage.beginCompleteExpansionFlow(FeatureBuilding.ACTION_SOURCE_LOOK_INSIDE_UI);
         }
         onClickClose(event);
      }
      
      protected function onConfirmationFinished(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.m_storage.beginCompleteExpansionFlow(FeatureBuilding.ACTION_SOURCE_LOOK_INSIDE_UI);
         }
      }
      
      protected function onAskMoreCallback(event:MouseEvent, partName:String = "") : void
      {
         var expandAskType:String = null;
         var buildingItem:BuildingItem = null;
         var itemName:String = event ? getItemNameFromEvent(event) : partName;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var askType:String = FeatureBuilding.DEFAULT_PART_ASK_METHOD;
         if(this.m_storage.expand)
         {
            expandAskType = this.m_storage.expand.getPartAskMethod(item.code);
            if(expandAskType)
            {
               askType = expandAskType;
            }
         }
         switch(askType)
         {
            case FeatureBuilding.PART_ASK_METHOD_FEED:
               event.currentTarget.buttonPointer.text = ZLocUtils.t("Dialogs","AskForMore_asfeed_posted");
               event.currentTarget.buttonPointer.greyOut();
               this.m_storage.requestExpansionPart(item);
               break;
            case FeatureBuilding.PART_ASK_METHOD_R4R:
            default:
               MFSRequestManager.getInstance().makeAskMatsRequest(m_building.getItem().name,itemName,"","",MFSConstants.SOURCE_DIALOG_CLICKED,CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"ask_for_more");
               buildingItem = m_building.getItem() as BuildingItem;
               if(buildingItem)
               {
                  FeatureTrackingManager.instance.sendR4R(buildingItem.buildingName);
               }
         }
      }
      
      private function shareExpansion() : void
      {
         if(this.canStartExpansionFeed())
         {
            if(Boolean(this.m_storage) && Boolean(this.m_storage.expand) && this.m_storage.expand.getFriendRewardNameByType(StatsTrackingConstants.DIALOG_STATE_EXPANSION_START_KINGDOM) != null)
            {
               if(this.isStartExpansionRewardLinkCache())
               {
                  this.shareStartExpansionWithMats(this.popStartExpansionRewardLinkCache());
               }
               else
               {
                  TransactionManager.addTransaction(new TStartExpansion(this.m_building,this.onStartExpansionResult));
               }
            }
            else
            {
               this.shareStartExpansion(ZLocUtils.t("Dialogs",m_dialogType + "ExpandMessage"),StatsTrackingConstants.DIALOG_STATE_START_UPGRADE_KINGDOM,this.m_locPrefix + "ExpandAsk");
            }
         }
      }
      
      private function onStartExpansionResult(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("rewardLink"))
         {
            if(this.m_shown && this.canStartExpansionFeed())
            {
               this.shareStartExpansionWithMats(result.rewardLink);
            }
            else
            {
               this.saveStartExpansionRewardLinkCache(result.rewardLink);
               if(!Global.flashHotParams["FIX_START_BUILDING_EXPANSION_FEED_TMPRT"])
               {
                  this.setExpansionFeatureLastShown();
               }
            }
         }
      }
      
      private function shareStartExpansionWithMats(rewardLink:String) : void
      {
         var feedBundleName:String = null;
         if(Boolean(this.m_storage) && Boolean(this.m_storage.expand))
         {
            feedBundleName = this.m_storage.expand.getFriendRewardNameByType(StatsTrackingConstants.DIALOG_STATE_EXPANSION_START_KINGDOM);
         }
         this.shareStartExpansion(ZLocUtils.t("Dialogs",this.m_building.getItemName() + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_START_KINGDOM),StatsTrackingConstants.DIALOG_STATE_EXPANSION_START_KINGDOM,feedBundleName,rewardLink);
      }
      
      private function saveStartExpansionRewardLinkCache(rewardLink:String) : void
      {
         m_onStartExpansionRewardLinkCache[this.m_building.getItemName()] = rewardLink;
      }
      
      private function isStartExpansionRewardLinkCache() : Boolean
      {
         var result:Boolean = false;
         if(m_onStartExpansionRewardLinkCache.hasOwnProperty(this.m_building.getItemName()) && m_onStartExpansionRewardLinkCache[this.m_building.getItemName()] != null)
         {
            result = true;
         }
         return result;
      }
      
      private function popStartExpansionRewardLinkCache() : String
      {
         var result:String = null;
         if(m_onStartExpansionRewardLinkCache.hasOwnProperty(this.m_building.getItemName()) && m_onStartExpansionRewardLinkCache[this.m_building.getItemName()] != null)
         {
            result = m_onStartExpansionRewardLinkCache[this.m_building.getItemName()];
            m_onStartExpansionRewardLinkCache[this.m_building.getItemName()] = null;
         }
         return result;
      }
      
      private function shareStartExpansion(message:String, feedType:String, bundleName:String = null, rewardLink:String = null) : void
      {
         var kingdom:String = null;
         kingdom = m_building.getItem().resourcePrefix + "_" + feedType;
         var onShareStartExpansion:Function = function(event:GenericPopupEvent):void
         {
            var bundleData:Object = null;
            if(event.button == GenericPopup.ACCEPT)
            {
               if(rewardLink == null)
               {
                  rewardLink = "gifts.php?giftRecipient=" + Global.player.snUser.uid;
               }
               bundleData = {
                  "reward_link":rewardLink,
                  "images":[{
                     "href":"{SN_APP_URL}" + rewardLink,
                     "src":getExpandFeedImage()
                  }]
               };
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,kingdom,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
               GlobalEngine.socialNetwork.publishFeedStory(bundleName,bundleData,[],false);
            }
            else
            {
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,kingdom,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
            }
         };
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,onShareStartExpansion,this.getExpandFeedImage());
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,kingdom,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         if(UI.getEnablePopups())
         {
            UI.displayPopup(dialog,false);
         }
         else
         {
            UI.displayPopup(dialog,true);
         }
         this.setExpansionFeatureLastShown();
      }
      
      protected function setExpansionFeatureLastShown(updateServer:Boolean = true) : void
      {
         var featureFlag:String = this.getStartExpansionFeatureFreqFlag();
         var currentTime:int = GlobalEngine.serverTime / 1000;
         Global.player.setFeatureLastShown(featureFlag,currentTime,updateServer);
      }
      
      private function getStartExpansionFeatureFreqFlag() : String
      {
         return "expand" + m_building.getItemName() + m_building.storageLevel;
      }
      
      private function getStartExpansionFeatureFreqIntervalName() : String
      {
         return m_building.getItemName() + "ExpandStartFeedFeatureFrequency";
      }
      
      private function canStartExpansionFeed() : Boolean
      {
         var featureFlag:String = this.getStartExpansionFeatureFreqFlag();
         var lastShown:Number = Global.player.getFeatureLastShown(featureFlag);
         var featureFrequency:Number = Global.farmGameSettingsManager.getNumber(this.getStartExpansionFeatureFreqIntervalName(),86400);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         var result:Boolean = false;
         var startingPartCount:int = 0;
         var isFeedFixTurnedOn:Boolean = Boolean(Global.flashHotParams["FIX_START_BUILDING_EXPANSION_FEED_TMPRT"]);
         if(isFeedFixTurnedOn)
         {
            startingPartCount = this.m_storage.getStageStartingPartCount();
         }
         if(Boolean(m_building.storageLevel && m_building.getTotalExpansionPartCount() == startingPartCount) && Boolean(currentTime > lastShown + featureFrequency) && m_building.hasNextExpansion())
         {
            result = true;
            if(!isFeedFixTurnedOn)
            {
               this.setExpansionFeatureLastShown(false);
            }
         }
         return result;
      }
      
      protected function getExpandFeedImage() : String
      {
         var level:String = String(m_building.storageLevel + 1);
         return Global.getAssetURL("assets/buildings/building_" + m_building.getItem().name + "_" + level + "_icon.png");
      }
      
      protected function setVisibility(obj:Object, name:String, visible:Boolean) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(obj && name) && Boolean(obj.hasOwnProperty(name)) && Boolean(obj[name]) && Boolean(obj[name].hasOwnProperty("visible")))
         {
            obj[name].visible = visible;
            result = true;
         }
         return result;
      }
      
      private function setBuyButtonsDisable(isDisabled:Boolean) : void
      {
         var buyButton:GenericButton = null;
         for(var btnIdx:int = 0; btnIdx < this.m_buyButtons.length; btnIdx++)
         {
            buyButton = this.m_buyButtons[btnIdx];
            if(null != buyButton)
            {
               buyButton.disabled = isDisabled;
            }
         }
      }
   }
}

