package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.Constants.MFSConstants;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.NurseryBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TCompleteNow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class NurseryWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private const BUTTON_CANCEL:String = "cancel";
      
      private const BUTTON_STORAGE:String = "storage";
      
      private const BUTTON_EXPAND:String = "expand";
      
      private const BUTTON_WHATISTHIS:String = "whatis";
      
      private const WHAT_IS_THIS_DIALOG:String = "assets/dialogs/FV_GenericLrgPopUp.swf";
      
      private var m_genericButtons:Object = new Object();
      
      private var m_currentTab:String;
      
      public function NurseryWithdrawal(storage:StorageBuilding)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","NurseryWithdrawal","called");
         m_dialogAsset = "assets/dialogs/FV_NurseryBarn_expand.swf";
         super(storage);
         m_dialogType = "nursery_complete";
      }
      
      override protected function onLoadComplete() : void
      {
         var whatIsThisBtn:GenericButton = null;
         var cancelBtn:GenericButton = null;
         var storageBtn:GenericButton = null;
         var expandBtn:GenericButton = null;
         super.onLoadComplete();
         if(m_building.isFullyBuilt())
         {
            m_window.gifts_mc.sendParts_bt.visible = false;
            whatIsThisBtn = new GenericButton(m_window.gifts_mc.whatisthis_mc,this.onClickHowDoesThisWork);
            whatIsThisBtn.text = ZLocUtils.t("Dialogs","WhatIsThis");
            this.m_genericButtons[this.BUTTON_WHATISTHIS] = whatIsThisBtn;
            cancelBtn = new GenericButton(m_window.gifts_mc.cancel_bt,onClickClose);
            cancelBtn.text = ZLocUtils.t("Dialogs","ReturnToFarm");
            this.m_genericButtons[this.BUTTON_CANCEL] = cancelBtn;
            storageBtn = new GenericButton(m_window.gifts_mc.stable_bt,this.onClickStorage);
            storageBtn.text = ZLocUtils.t("Dialogs",m_dialogType + "StorageButton");
            storageBtn.enableHitState(true);
            this.m_genericButtons[this.BUTTON_STORAGE] = storageBtn;
            expandBtn = new GenericButton(m_window.gifts_mc.expand_bt,this.onClickExpand);
            expandBtn.text = ZLocUtils.t("Dialogs",m_dialogType + "ExpandButton");
            expandBtn.enableHitState(true);
            this.m_genericButtons[this.BUTTON_EXPAND] = expandBtn;
            this.m_currentTab = this.BUTTON_STORAGE;
            this.switchTabs();
            m_cashNeeded = this.calculateCashNeeded();
            if(m_building.hasReachedMaxExpansionLevel())
            {
               this.setButtonState(this.BUTTON_EXPAND,GenericButton.UPSTATE);
               this.m_genericButtons[this.BUTTON_EXPAND].toggleDisable(false);
               storageBtn.turnOff();
               expandBtn.turnOff();
            }
         }
      }
      
      private function onClickStorage(event:MouseEvent) : void
      {
         this.m_currentTab = this.BUTTON_STORAGE;
         this.switchTabs();
      }
      
      private function onClickExpand(event:MouseEvent) : void
      {
         var message:String = null;
         var dialog:GenericIconPopup = null;
         this.m_currentTab = this.BUTTON_EXPAND;
         this.switchTabs();
         var seenFlag:String = "expand" + m_dialogType + m_building.storageLevel;
         if(!Global.player.getSeenFlag(seenFlag))
         {
            message = ZLocUtils.t("Dialogs",m_dialogType + "ExpandMessage");
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onShareExpansion,this.getImageIconUrl());
            dialog.setTrackerKey("feed_share_nursery_expansion_started");
            UI.displayPopup(dialog,false);
            Global.player.setSeenFlag(seenFlag);
            FarmStatsManager.count("nursery_barn","nursery_expansion","expansion_started","time_" + m_building.storageLevel);
         }
      }
      
      private function onShareExpansion(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {"images":[{
               "href":"{SN_APP_URL}gifts.php?giftRecipient=" + Global.player.snUser.uid,
               "src":this.getImageIconUrl()
            }]};
            GlobalEngine.socialNetwork.publishFeedStory("NurseryBarnExpandAsk",bundleData,[],false);
         }
      }
      
      private function getImageIconUrl() : String
      {
         return Global.getAssetURL(NurseryBuilding.EXPAND_IMAGE_ICON_URL);
      }
      
      private function switchTabs() : void
      {
         m_tiles = new Array();
         if(this.BUTTON_STORAGE == this.m_currentTab)
         {
            this.showStorage(true);
            this.showExpand(false);
         }
         else
         {
            this.showStorage(false);
            this.showExpand(true);
         }
         this.pushNewData();
         addAllComponents(0);
      }
      
      private function showStorage(isShow:Boolean) : void
      {
         for(var tileIdx:int = 0; tileIdx <= getNumSlots(); tileIdx++)
         {
            this.setupTile(tileIdx,"giftPanel" + (tileIdx + 1),isShow);
         }
         if(isShow)
         {
            this.setButtonState(this.BUTTON_STORAGE,GenericButton.HITSTATE);
         }
         else
         {
            this.setButtonState(this.BUTTON_STORAGE,GenericButton.UPSTATE);
         }
      }
      
      private function showExpand(isShow:Boolean) : void
      {
         for(var tileIdx:int = 0; tileIdx <= getNumSlots(); tileIdx++)
         {
            this.setupTile(tileIdx,"expandPanel" + (tileIdx + 1) + "_mc",isShow);
         }
         if(isShow)
         {
            this.setButtonState(this.BUTTON_EXPAND,GenericButton.HITSTATE);
         }
         else
         {
            this.setButtonState(this.BUTTON_EXPAND,GenericButton.UPSTATE);
         }
      }
      
      override protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         var msg:String = null;
         if(m_howDoesThisWorkPopup == null)
         {
            msg = ZLocUtils.t("Dialogs","NurseryHowDowsThisWork");
            m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET_LRG,"",true);
            m_howDoesThisWorkPopup.setAcceptTextName("Okay");
            UI.displayPopup(m_howDoesThisWorkPopup,false,"howDoesThisWorkPopup",true);
         }
      }
      
      override protected function setupCapacityBox() : void
      {
         if(Boolean(m_window.gifts_mc.hasOwnProperty("capacity_tf")) && Boolean(m_window.gifts_mc.hasOwnProperty("current_tf")))
         {
            ZLocUtils.setText(m_window,"gifts_mc.capacity_tf","Dialogs","Capacity",{"quantity":m_building.capacity});
            ZLocUtils.setText(m_window,"gifts_mc.current_tf","Dialogs","Current",{"quantity":m_building.count});
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
         var partDataArray:Array = null;
         var partDataSource:BaseDataSource = null;
         var partFarmItem:FarmItem = null;
         var partDataObject:Object = null;
         var upgradeData:XML = null;
         var object:Object = null;
         var partXml:XML = null;
         var partItem:FarmItem = null;
         var partData:Object = null;
         if(this.BUTTON_EXPAND == this.m_currentTab)
         {
            m_data = [];
            m_tileSet = 0;
            if(StorageBuilding.isDynamicPartsExperimentOn())
            {
               buildingExpansionData = m_building.getNextBuildingExpansionData();
               if(Boolean(buildingExpansionData) && Boolean(buildingExpansionData.parts))
               {
                  m_data = buildingExpansionData.generateWithdrawalUIData(m_building,true);
               }
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
                           partDataObject.friendlyName = partFarmItem.friendlyName;
                           partDataObject.icon = partFarmItem.icon;
                           m_data.push(partDataObject);
                        }
                     }
                     m_data.push({"sendGiftsToFriends":true});
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
                        partData.friendlyName = partItem.friendlyName;
                        partData.icon = partItem.icon;
                        m_data.push(partData);
                     }
                  }
               }
               object = new Object();
               object.sendGiftsToFriends = true;
               m_data.push(object);
            }
         }
         else
         {
            super.pushNewData();
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
         var babyItem:FarmItem = null;
         var adultItem:FarmItem = null;
         var errorMessage:String = null;
         if(this.BUTTON_EXPAND == this.m_currentTab)
         {
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
                  tile.iconBox_mc.visible = false;
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
         else
         {
            if(Boolean(m_tiles) && m_data[index + compId] != null)
            {
               babyItem = Global.farmGameSettingsManager.getFarmItemByCode(m_data[index + compId].code);
               if(babyItem)
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     adultItem = Global.farmGameSettingsManager.getFarmItemByName(babyItem.getStringFromDataSource("adult"));
                  }
                  else
                  {
                     adultItem = Global.farmGameSettingsManager.getFarmItemByName(babyItem.xml.adult);
                  }
                  if(!adultItem)
                  {
                     errorMessage = "Missing adult item.";
                     errorMessage += ",stackRoot=NurseryWithdrawal.addComponent";
                     errorMessage += ",babyItemName=" + babyItem.name;
                     ErrorManager.addError(errorMessage);
                  }
                  if(!m_toolTips[compId])
                  {
                     m_toolTips[compId] = new ToolTip();
                     m_toolTips[compId].attachToolTip(m_tiles[compId].icon);
                  }
                  else
                  {
                     m_toolTips[compId].detachToolTip(m_tiles[compId].icon);
                     m_toolTips[compId].attachToolTip(m_tiles[compId].icon);
                  }
                  m_toolTips[compId].toolTip = ZLocUtils.t("Dialogs","nursery_toolTip",{
                     "itemA":ZLocUtils.tk_pk(babyItem.friendlyName),
                     "itemB":(adultItem ? ZLocUtils.tk_pk(adultItem.friendlyName) : "")
                  });
               }
            }
            super.addComponent(compId,index);
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
            if(Global.player.canBuyCash(m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,this.m_building);
               close();
            }
         }
      }
      
      override protected function onSendPresentsCallback(event:MouseEvent) : void
      {
         close();
         FreeGiftSelectionWindow.popWindow();
      }
      
      protected function onCompleteNowCallback(event:MouseEvent) : void
      {
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
               FarmStatsManager.count("fv_cash_buy","building","nurserybarn_expansion_finished",m_cashNeeded.toString());
               TransactionManager.addTransaction(new TCompleteNow(m_building));
               Global.player.cash -= m_cashNeeded;
            }
            close();
         }
      }
      
      protected function onAskMoreCallback(event:MouseEvent) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         MFSRequestManager.getInstance().makeAskMatsRequest(m_dialogType,item.name,"","",MFSConstants.SOURCE_DIALOG_CLICKED);
      }
      
      private function setupTile(tileIndex:int, tileName:String, isShow:Boolean) : void
      {
         var tile:MovieClip = null;
         tile = m_window.gifts_mc.getChildByName(tileName) as MovieClip;
         if(tile != null)
         {
            if(isShow)
            {
               m_tiles[tileIndex] = tile;
            }
            tile.visible = false;
            tile.enabled = false;
         }
      }
   }
}

