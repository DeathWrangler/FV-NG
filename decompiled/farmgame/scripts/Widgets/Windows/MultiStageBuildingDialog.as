package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericButton;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BuildingDialogSlotFrame;
   import Widgets.Frames.CountdownObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class MultiStageBuildingDialog extends FarmWindow
   {
      
      private static const MATERIAL_RISE_TWEEN_TIME:Number = 3;
      
      protected static const DEFAULT_UI_BACKGROUND:String = "decorationStage1_mc";
      
      private var m_genericButtons:Object = new Object();
      
      protected var m_featureBuilding:FeatureBuilding;
      
      private var m_title:ZwTextField = null;
      
      private var m_capacity_tf:ZwTextField = null;
      
      private var m_description_tf:ZwTextField = null;
      
      private var m_howDoesThisWork:FarmAnimatedTextButton = null;
      
      private var m_data:Array = [];
      
      private var m_slot_mc:BuildingDialogSlotFrame = null;
      
      protected var m_locPrefix:String = this.m_featureBuilding.getItemName() + "Building";
      
      protected var m_buyButtons:Array = [];
      
      protected var m_showWhatIsThisOnLoad:Boolean = false;
      
      protected var m_howDoesThisWorkPopup:GenericPopup = null;
      
      private var m_dialogConfig:Object = this.m_featureBuilding.getDialogConfig();
      
      protected var m_dialogTemplateXML:Object = null;
      
      public function MultiStageBuildingDialog(building:StorageBuilding)
      {
         this.m_featureBuilding = building as FeatureBuilding;
         if(this.m_dialogConfig == null)
         {
            this.m_dialogConfig = this.m_featureBuilding.getItem().getDialogConfig("storage");
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.BUILDABLE))
         {
            this.m_dialogTemplateXML = this.m_featureBuilding.getDialogTemplateXML();
         }
         if(this.m_dialogConfig != null && this.m_dialogConfig.path != "")
         {
            if(Boolean(this.m_dialogTemplateXML) && Boolean("@template" in this.m_dialogTemplateXML) && this.m_dialogTemplateXML.@template == "true")
            {
               this.m_dialogConfig.path = TemplateUIUtility.BUILDABLE_TEMPLATE_SWF;
            }
            super(this.m_dialogConfig.path,true,true);
         }
         else
         {
            GlobalEngine.assert(false,"building is missing a dialog config");
         }
      }
      
      override public function getRect(movieClip:DisplayObject) : Rectangle
      {
         if(this.m_dialogConfig.width > 0 && this.m_dialogConfig.height > 0)
         {
            return new Rectangle(0,0,this.m_dialogConfig.width,this.m_dialogConfig.height);
         }
         return super.getRect(movieClip);
      }
      
      override protected function postLoadComplete() : void
      {
         var title_text:String = null;
         var titleWidget:ZwTextField = null;
         var descriptionWidget:ZwTextField = null;
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var upgradeData:XML = null;
         var levelIndex:int = 0;
         var frame:ZwFrame = null;
         addWidget(new ZwFrame(m_window.main_mc)) as ZwFrame;
         if(m_window.main_mc.hasOwnProperty("title_tf"))
         {
            title_text = ZLocUtils.tk_pk_asTitle(this.m_featureBuilding.getItemFriendlyName());
            titleWidget = addWidget(new ZwTextField(m_window.main_mc.title_tf,title_text)) as ZwTextField;
            if(Boolean(this.m_dialogTemplateXML) && this.m_dialogTemplateXML.textColor.length() > 0)
            {
               TemplateUIUtility.applyDropShadowFilter(titleWidget,TemplateUIUtility.BUILDABLE,this.m_dialogTemplateXML.textColor);
               TemplateUIUtility.applyTextScaling(titleWidget,TemplateUIUtility.BUILDABLE);
            }
         }
         if(m_window.main_mc.hasOwnProperty("description_tf"))
         {
            descriptionWidget = addWidget(new ZwTextField(m_window.main_mc.description_tf,this.getDescriptionText())) as ZwTextField;
            if(Boolean(Global.flashHotParams.hasOwnProperty("FIX_FARM_99883_TEMPRT") && Global.flashHotParams["FIX_FARM_99883_TEMPRT"] == "on") && Boolean(this.m_dialogTemplateXML) && this.m_dialogTemplateXML.textColor.length() > 0)
            {
               TemplateUIUtility.applyTextColor(descriptionWidget,TemplateUIUtility.BUILDABLE,this.m_dialogTemplateXML.textColor);
            }
         }
         if(Boolean(this.m_dialogTemplateXML) && this.m_dialogTemplateXML.dialogBackground.length() > 0)
         {
            addWidget(new FarmIcon(m_window.main_mc.background_mc,Global.getAssetURL(this.m_dialogTemplateXML.dialogBackground)));
         }
         if(Boolean(this.m_dialogTemplateXML) && this.m_dialogTemplateXML.titleBackground.length() > 0)
         {
            addWidget(new FarmIcon(m_window.main_mc.title_mc,Global.getAssetURL(this.m_dialogTemplateXML.titleBackground)));
         }
         if(Boolean(this.m_dialogTemplateXML) && this.m_dialogTemplateXML.dialogForeground.length() > 0)
         {
            addWidget(new FarmIcon(m_window.main_mc.foreground_mc,Global.getAssetURL(this.m_dialogTemplateXML.dialogForeground)));
         }
         if(Boolean(this.m_dialogTemplateXML) && this.m_dialogTemplateXML.dialogSlotsBackground.length() > 0)
         {
            addWidget(new FarmIcon(m_window.main_mc.slots_background_mc,Global.getAssetURL(this.m_dialogTemplateXML.dialogSlotsBackground)));
         }
         if(Boolean(this.m_dialogTemplateXML) && this.m_dialogTemplateXML.dialogFrame.length() > 0)
         {
            addWidget(new FarmIcon(m_window.main_mc.frame_mc,Global.getAssetURL(this.m_dialogTemplateXML.dialogFrame)));
         }
         if(m_window.main_mc.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.main_mc.whatisthis_mc,ZLocUtils.t("Dialogs","WhatIsThis"),this.howDoesThisWorkClick));
         }
         if(m_window.main_mc.hasOwnProperty("close_bt"))
         {
            addWidget(new FarmButton(m_window.main_mc.close_bt,this.onClickClose));
         }
         var needsParts:Boolean = false;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.m_featureBuilding.expand.getNextBuildingExpansionData();
            needsParts = Boolean(buildingExpansionData) && Boolean(buildingExpansionData.parts) && buildingExpansionData.parts.length > 0;
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.m_featureBuilding.expand.getNextExpansionDataSource();
            needsParts = upgradeDataSource != null && upgradeDataSource.getArray("part").length > 0;
         }
         else
         {
            upgradeData = this.m_featureBuilding.expand.getNextExpansionData();
            needsParts = upgradeData != null && upgradeData.part.length() > 0;
         }
         if(needsParts)
         {
            this.pushNewData();
            this.m_slot_mc = new BuildingDialogSlotFrame(m_window.main_mc.slots_mc,this.m_data,this,this.m_featureBuilding);
            addWidget(this.m_slot_mc);
         }
         if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.BUILDABLE)) && Boolean(this.m_dialogTemplateXML) && this.m_dialogTemplateXML.dialogBuilding.length() > 0)
         {
            addWidget(new CountdownObjectPreviewFrame(m_window.main_mc.buildable_mc,Global.farmGameSettingsManager.getFarmItemByName(this.m_dialogTemplateXML.dialogBuilding),null,null,null,"built_" + this.m_featureBuilding.storageLevel));
         }
         else
         {
            levelIndex = 0;
            while(m_window.main_mc.hasOwnProperty("stage_" + levelIndex + "_mc"))
            {
               frame = addWidget(new ZwFrame(m_window.main_mc["stage_" + levelIndex + "_mc"])) as ZwFrame;
               frame.addWidget(new ZwTextField(m_window.main_mc["stage_" + levelIndex + "_mc"].generic_tf,(levelIndex + 1).toString()));
               levelIndex++;
            }
         }
         this.refreshProgressMeter();
      }
      
      protected function getDescriptionText() : String
      {
         var dialogKey:String = this.m_locPrefix + "_description";
         var fallbackDialogKey:String = FeatureBuilding.FALLBACK_KEY + "description";
         var rewardName:String = this.m_featureBuilding.getHarvestRewardName();
         if(rewardName == "")
         {
            fallbackDialogKey += "_noReward";
         }
         return ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackDialogKey)],{
            "building":ZLocUtils.tk_pk(this.m_featureBuilding.getItem().friendlyName),
            "item":ZLocUtils.tk_pk(rewardName)
         });
      }
      
      override public function refreshWindow() : void
      {
         this.pushNewData();
         if(this.m_slot_mc)
         {
            this.m_slot_mc.refresh();
         }
         this.refreshProgressMeter();
      }
      
      private function onClickClose(event:Event) : void
      {
         close();
      }
      
      protected function howDoesThisWorkClick(event:Event) : void
      {
         var prefixUrl:String = null;
         var dialogKey:String = null;
         var fallbackDialogKey:String = null;
         var buildingFriendlyName:String = null;
         var rewardName:String = null;
         var message:String = null;
         if(this.m_howDoesThisWorkPopup == null)
         {
            prefixUrl = this.m_featureBuilding.getItem().prefixUrl;
            if(prefixUrl != null && this.m_featureBuilding.tutorial != null)
            {
               TutorialUI.displayBuildingTutorialWindow(this.m_featureBuilding,prefixUrl);
            }
            else
            {
               dialogKey = this.m_featureBuilding.getItem().name + "_WhatIsThis";
               fallbackDialogKey = FeatureBuilding.FALLBACK_KEY + "WhatIsThis";
               buildingFriendlyName = this.m_featureBuilding.getItem().friendlyName;
               rewardName = this.m_featureBuilding.getHarvestRewardName();
               if(rewardName == "")
               {
                  fallbackDialogKey += "_noReward";
               }
               message = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackDialogKey)],{
                  "building":ZLocUtils.tk_pk(buildingFriendlyName),
                  "building2":ZLocUtils.tk_pk(buildingFriendlyName),
                  "item":ZLocUtils.tk_pk(rewardName)
               });
               this.m_howDoesThisWorkPopup = new GenericPopup(message,GenericPopup.TYPE_OK,this.onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET);
               this.m_howDoesThisWorkPopup.setAcceptTextName("Okay");
               UI.displayPopup(this.m_howDoesThisWorkPopup,false,"whatIsThisPopup",true);
            }
         }
      }
      
      protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         this.m_howDoesThisWorkPopup = null;
      }
      
      protected function pushNewData() : void
      {
         var buildingExpansionData:BuildingExpansionData = null;
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
         this.m_data = [];
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.m_featureBuilding.getNextBuildingExpansionData();
            if(Boolean(buildingExpansionData) && Boolean(buildingExpansionData.parts))
            {
               this.m_data = buildingExpansionData.generateWithdrawalUIData(this.m_featureBuilding,true);
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.m_featureBuilding.getNextExpansionDataSource();
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
                        partDataObject.currentCount = this.m_featureBuilding.getExpansionPartCount(partFarmItem.code);
                        partDataObject.friendlyName = partFarmItem.friendlyName;
                        partDataObject.icon = partFarmItem.icon;
                        this.m_data.push(partDataObject);
                     }
                  }
                  this.m_data.push({"sendGiftsToFriends":true});
               }
            }
         }
         else
         {
            upgradeData = this.m_featureBuilding.getNextExpansionData();
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
                     partData.currentCount = this.m_featureBuilding.getExpansionPartCount(partItem.code);
                     partData.friendlyName = partItem.friendlyName;
                     partData.icon = partItem.icon;
                     this.m_data.push(partData);
                  }
               }
               object = new Object();
               object.sendGiftsToFriends = true;
               this.m_data.push(object);
            }
         }
      }
      
      protected function refreshProgressMeter() : void
      {
         var storageLevel:int = 0;
         var maxLevel:int = 0;
         var completedLevelIdx:int = 0;
         var curLevel:int = 0;
         var nextLevel:int = 0;
         var unreachedLevel:int = 0;
         var completionRatio:Number = NaN;
         var inventoryCount:Object = this.getCurVsTotalPartsNeeded();
         if(this.m_featureBuilding)
         {
            storageLevel = this.m_featureBuilding.storageLevel;
            maxLevel = this.m_dialogConfig.levelCount + 1;
            for(completedLevelIdx = 0; completedLevelIdx <= storageLevel; completedLevelIdx++)
            {
               if(m_window.main_mc.hasOwnProperty("meter_" + completedLevelIdx + "_mc"))
               {
                  m_window.main_mc["meter_" + completedLevelIdx + "_mc"].bar_mc.scaleX = 1;
                  m_window.main_mc["meter_" + completedLevelIdx + "_mc"].visible = true;
               }
               if(m_window.main_mc.hasOwnProperty("decorationStage" + completedLevelIdx + "_mc"))
               {
                  m_window.main_mc["decorationStage" + completedLevelIdx + "_mc"].visible = false;
               }
               if(m_window.main_mc.hasOwnProperty("progress" + completedLevelIdx + "reveal_mc"))
               {
                  m_window.main_mc["progress" + completedLevelIdx + "reveal_mc"].visible = true;
               }
            }
            curLevel = this.getDecorationLevel();
            if(m_window.main_mc.hasOwnProperty("meter_" + curLevel + "_mc"))
            {
               completionRatio = inventoryCount.currentTotal / inventoryCount.neededTotal;
               m_window.main_mc["meter_" + curLevel + "_mc"].bar_mc.scaleX = completionRatio;
               m_window.main_mc["meter_" + curLevel + "_mc"].visible = true;
            }
            this.setupDecorationStage(curLevel,maxLevel);
            if(m_window.main_mc.hasOwnProperty("progress" + curLevel + "reveal_mc"))
            {
               m_window.main_mc["progress" + curLevel + "reveal_mc"].visible = true;
            }
            nextLevel = curLevel + 1;
            unreachedLevel = nextLevel;
            while(Boolean(unreachedLevel <= maxLevel) || Boolean(m_window.main_mc.hasOwnProperty("decorationStage" + unreachedLevel + "_mc")) || Boolean(m_window.main_mc.hasOwnProperty("m_window.main_mc.meter_" + unreachedLevel + "_mc")) || Boolean(m_window.main_mc.hasOwnProperty("progress" + unreachedLevel + "_mc")))
            {
               if(m_window.main_mc.hasOwnProperty("decorationStage" + unreachedLevel + "_mc"))
               {
                  m_window.main_mc["decorationStage" + unreachedLevel + "_mc"].visible = false;
               }
               if(m_window.main_mc.hasOwnProperty("meter_" + unreachedLevel + "_mc"))
               {
                  m_window.main_mc["meter_" + unreachedLevel + "_mc"].bar_mc.width = 0;
               }
               if(m_window.main_mc.hasOwnProperty("progress" + unreachedLevel + "_mc"))
               {
                  m_window.main_mc["progress" + unreachedLevel + "_mc"].visible = true;
               }
               unreachedLevel++;
            }
         }
      }
      
      protected function setupDecorationStage(curLevel:int, maxLevel:int) : void
      {
         if(m_window.main_mc.hasOwnProperty("decorationStage" + curLevel + "_mc"))
         {
            m_window.main_mc["decorationStage" + curLevel + "_mc"].visible = true;
         }
         else if(m_window.main_mc.hasOwnProperty(DEFAULT_UI_BACKGROUND))
         {
            m_window.main_mc["decorationStage1_mc"].visible = true;
         }
      }
      
      protected function getDecorationLevel() : int
      {
         return this.m_featureBuilding.storageLevel + 1;
      }
      
      protected function calculateCashNeeded(partcost:int = 1) : int
      {
         var result:int = 0;
         for(var index:int = 0; index < this.m_data.length; index++)
         {
            if(!this.m_data[index].sendGiftsToFriends)
            {
               result += (this.m_data[index].needCount - this.m_data[index].currentCount) * partcost;
            }
         }
         return result;
      }
      
      protected function getCurVsTotalPartsNeeded() : Object
      {
         var result:Object = new Object();
         result.neededTotal = 0;
         result.currentTotal = 0;
         for(var index:int = 0; index < this.m_data.length; index++)
         {
            if(!this.m_data[index].sendGiftsToFriends)
            {
               result.neededTotal += this.m_data[index].needCount;
               result.currentTotal += this.m_data[index].currentCount;
            }
         }
         return result;
      }
      
      protected function getCurVsTotalSpecificPartsNeeded(matItemCode:String) : Object
      {
         var result:Object = new Object();
         result.neededTotal = 0;
         result.currentTotal = 0;
         for(var index:int = 0; index < this.m_data.length; index++)
         {
            if(!this.m_data[index].sendGiftsToFriends)
            {
               if(this.m_data[index].itemCode == matItemCode || this.m_data[index].code == matItemCode)
               {
                  result.neededTotal = this.m_data[index].needCount;
                  result.currentTotal = this.m_data[index].currentCount;
                  break;
               }
            }
         }
         return result;
      }
      
      private function onShareExpansion(event:GenericPopupEvent) : void
      {
         var rewardLink:String = null;
         var bundleData:Object = null;
         var fallbackKey:String = null;
         var fallbackStats:Object = null;
         var building:FarmItem = this.m_featureBuilding.getItem();
         var kingdom:String = building.resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_START_UPGRADE_KINGDOM;
         if(event.button == GenericPopup.ACCEPT)
         {
            rewardLink = "gifts.php?giftRecipient=" + Global.player.snUser.uid;
            bundleData = {
               "reward_link":rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":this.getExpandFeedImage()
               }],
               "building":building.friendlyName
            };
            fallbackKey = FeatureBuilding.FALLBACK_KEY + "ExpandAsk";
            fallbackStats = {"subcategory":building.name};
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,kingdom,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
            GlobalEngine.socialNetwork.publishFeedStory(this.m_locPrefix + "ExpandAsk",bundleData,[],false);
         }
         else
         {
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,kingdom,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
         }
      }
      
      protected function getExpandFeedImage() : String
      {
         var level:String = String(this.m_featureBuilding.storageLevel + 1);
         return Global.getAssetURL("assets/buildings/building_" + this.m_featureBuilding.getItem().name + "_" + level + "_icon.png");
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

