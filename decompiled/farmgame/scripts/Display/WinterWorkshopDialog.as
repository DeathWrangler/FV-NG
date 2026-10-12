package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.Constants.MFSConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TCompleteNow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class WinterWorkshopDialog extends ConstructionBuildingWithdrawal
   {
      
      private static const STORAGE_LEVEL_1:int = 1;
      
      private static const STORAGE_LEVEL_2:int = 2;
      
      private static const BAR_WIDTH:int = 120;
      
      private var m_genericButtons:Object = new Object();
      
      private var m_storage:FeatureBuilding;
      
      public function WinterWorkshopDialog(storage:StorageBuilding)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","WinterWorkshopDialog","called");
         this.m_storage = storage as FeatureBuilding;
         m_dialogAsset = "assets/dialogs/FV_Construct_4cell_WinterShopS2.swf";
         super(storage);
         m_dialogType = "WinterWorkshop_complete";
      }
      
      override protected function onLoadComplete() : void
      {
         var gb:GenericButton = null;
         m_window = m_loader.content as MovieClip;
         var main_mc:MovieClip = m_window.main_mc;
         var cancelBtn:GenericButton = new GenericButton(main_mc.close_bt,onClickClose);
         cancelBtn.m_overlay.name = "Cancel";
         cancelBtn.text = ZLocUtils.t("Dialogs","ReturnToFarm");
         main_mc.title_tf.text = ZLocUtils.tk_pk_asTitle(m_building.getItemFriendlyName());
         main_mc.description_tf.text = ZLocUtils.t("Dialogs","WinterWorkshop_description");
         if(main_mc.hasOwnProperty("whatisthis_mc") && Boolean(main_mc.whatisthis_mc))
         {
            gb = new GenericButton(main_mc.whatisthis_mc,onClickHowDoesThisWork);
            gb.m_overlay.name = "WhatIsThisBtn";
            gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
         }
         m_tiles = new Array(main_mc.slot_0_mc,main_mc.slot_1_mc,main_mc.slot_2_mc,main_mc.slot_3_mc);
         removeTiles();
         this.pushNewData();
         m_cashNeeded = this.calculateCashNeeded();
         var compIdx:int = 0;
         while(compIdx < getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         addChild(main_mc);
         this.shareExpansion();
      }
      
      override protected function pushNewData() : void
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
         m_data = [];
         m_tileSet = 0;
         var sumOfParts:int = 0;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = m_building.getNextBuildingExpansionData();
            if(Boolean(buildingExpansionData) && Boolean(buildingExpansionData.parts))
            {
               m_data = buildingExpansionData.generateWithdrawalUIData(m_building,true);
            }
            sumOfParts = buildingExpansionData.getTotalPartsOnHand(m_building);
            this.setUpProgressBars(sumOfParts,buildingExpansionData.matsNeeded);
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
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
                  this.setUpProgressBars(sumOfParts,upgradeDataSource.getInt("matsNeeded"));
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
               this.setUpProgressBars(sumOfParts,int(upgradeData.@matsNeeded));
            }
         }
      }
      
      private function setUpProgressBars(sumOfParts:int, matsNeeded:int) : void
      {
         if(this.m_storage.storageLevel == STORAGE_LEVEL_1)
         {
            m_window.main_mc.decorationSnow_mc.visible = false;
            if(matsNeeded)
            {
               m_window.main_mc.meter_0_mc.bar_mc.width = sumOfParts * BAR_WIDTH / matsNeeded;
               m_window.main_mc.meter_1_mc.bar_mc.width = 0;
            }
         }
         if(this.m_storage.storageLevel == STORAGE_LEVEL_2)
         {
            m_window.main_mc.decorationSnow_mc.visible = true;
            if(matsNeeded)
            {
               m_window.main_mc.meter_0_mc.bar_mc.width = BAR_WIDTH;
               m_window.main_mc.meter_1_mc.bar_mc.width = sumOfParts * BAR_WIDTH / matsNeeded;
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
               tile.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(data.friendlyName);
               tile.alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
                  "quantity":data.currentCount,
                  "maximum":data.needCount
               });
               addIcon(data.name,"icon",tile,tile.icon);
               if(data.currentCount >= data.needCount)
               {
                  ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
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
               sendGifts = new GenericButton(tile.present_bt,this.onSendPresentsCallback);
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
               this.m_storage.refreshStorageDialog();
            }
         }
         else
         {
            FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"buy_part","cancel");
         }
      }
      
      override protected function onSendPresentsCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"send_gift");
         close();
         FreeGiftSelectionWindow.popWindow();
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
         onClickClose(event);
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
      
      protected function onAskMoreCallback(event:MouseEvent) : void
      {
         var item:FarmItem = null;
         item = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name + m_building.storageLevel.toString(),"ask_for_more");
         MFSRequestManager.getInstance().makeAskMatsRequest(m_building.getItem().name,item.name,"","",MFSConstants.SOURCE_DIALOG_CLICKED);
      }
      
      private function shareExpansion() : void
      {
         var message:String = null;
         var dialog:GenericIconPopup = null;
         var featureFlag:String = "expand" + m_dialogType + m_building.storageLevel;
         var lastShown:Number = Global.player.getFeatureLastShown(featureFlag);
         var featureFrequency:Number = Global.farmGameSettingsManager.getNumber("WinterWorkshopExpandStartFeedFeatureFrequency",86400);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         if(!m_building.getTotalExpansionPartCount() && currentTime > lastShown + featureFrequency)
         {
            message = ZLocUtils.t("Dialogs",m_dialogType + "ExpandMessage");
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onShareExpansion,this.getExpandFeedImage());
            UI.displayPopup(dialog,false);
            dialog.setTrackerKey("feed-winter_workshop-upgrade_started");
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
            GlobalEngine.socialNetwork.publishFeedStory("WinterWorkshopExpandAsk",bundleData,[],false);
         }
      }
      
      private function getExpandFeedImage() : String
      {
         var level:String = String(m_building.storageLevel + 1);
         return Global.getAssetURL("assets/buildings/building_winterworkshop" + level + "_icon.png");
      }
   }
}

