package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.Constants.MFSConstants;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.PigpenBuilding;
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
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gs.TweenLite;
   
   public class PigpenExpansionWithdrawal extends BaseConstructionBuildingWithdrawal
   {
      
      private static const MAX_UPGRADE:int = 3;
      
      private static const MATERIAL_RISE_TWEEN_TIME:Number = 3;
      
      private const FEATURE_NAME:String = "Pigpen";
      
      private var m_itemToBuy:FarmItem;
      
      private var m_container:MovieClip;
      
      private var m_storage:PigpenBuilding;
      
      private var m_mainDialog:PigpenDialog;
      
      public function PigpenExpansionWithdrawal(storage:StorageBuilding, container:MovieClip, mainDialog:PigpenDialog)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","PigpenExpansionWithdrawal","called");
         super(storage);
         this.m_storage = storage as PigpenBuilding;
         this.m_container = container;
         this.m_mainDialog = mainDialog;
         m_dialogType = "Pigpen_complete";
         this.m_container.giftPanel1.visible = false;
         this.m_container.giftPanel2.visible = false;
         this.m_container.giftPanel3.visible = false;
         this.m_container.giftPanel4.visible = false;
         this.m_container.visible = true;
      }
      
      override protected function onLoadComplete() : void
      {
         m_window = this.m_container;
         m_tiles = new Array(m_window.giftPanel1,m_window.giftPanel2,m_window.giftPanel3,m_window.giftPanel4);
         removeTiles();
         this.pushNewData();
         m_cashNeeded = this.calculateCashNeeded();
         var compIdx:int = 0;
         while(compIdx < getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         this.shareExpansion();
      }
      
      private function shareExpansion() : void
      {
         var featureFlag:String = null;
         var lastShown:Number = NaN;
         var featureFrequency:Number = NaN;
         var currentTime:int = 0;
         var title:String = null;
         var subtitle:String = null;
         var message:String = null;
         var dialog:GenericXMLDialog = null;
         if(m_building.storageLevel < MAX_UPGRADE)
         {
            featureFlag = "expand" + m_dialogType + m_building.storageLevel;
            lastShown = Global.player.getFeatureLastShown(featureFlag);
            featureFrequency = Global.farmGameSettingsManager.getNumber("PigpenExpandStartFeedFeatureFrequency",86400);
            currentTime = GlobalEngine.serverTime / 1000;
            if(!m_building.getTotalExpansionPartCount() && currentTime > lastShown + featureFrequency)
            {
               title = ZLocUtils.t("Dialogs",m_dialogType + "ExpandTitle");
               subtitle = ZLocUtils.t("Dialogs",m_dialogType + "ExpandSubTitle");
               message = ZLocUtils.t("Dialogs",m_dialogType + "ExpandMessage");
               dialog = new GenericXMLDialog(title,subtitle,PigpenBuilding.SHARE_DIALOG_SUBTITLE_STYLE,this.getExpandFeedImage(false),PigpenBuilding.SHARE_DIALOG_ICON_SIZE,PigpenBuilding.SHARE_DIALOG_ICON_SIZE,message,this.onShareExpansion,true,ZLocUtils.t("Dialogs","ShareButton"));
               dialog.setTrackerKey("expand_pigpen-expansion_started");
               UI.displayPopup(dialog,false);
               Global.player.setFeatureLastShown(featureFlag,currentTime,true);
               FarmStatsManager.count("Constructable","constructible_state_change",this.m_storage.getItem().name + this.m_storage.storageLevel.toString(),"started");
            }
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
            GlobalEngine.socialNetwork.publishFeedStory("PigpenBuildingExpandAsk",bundleData,[],false);
         }
      }
      
      private function getExpandFeedImage(abs:Boolean = true) : String
      {
         var url:String = "assets/buildings/building_pigpen_icon.png";
         if(abs)
         {
            url = Global.getAssetURL(url);
         }
         return url;
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
            upgradeDataSource = this.m_storage.getNextExpansionDataSource();
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
                        partDataObject.currentCount = this.m_storage.getExpansionPartCount(partFarmItem.code);
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
            upgradeData = this.m_storage.getNextExpansionData();
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
                     partData.currentCount = this.m_storage.getExpansionPartCount(partItem.code);
                     partData.friendlyName = partItem.friendlyName;
                     partData.icon = partItem.icon;
                     m_data.push(partData);
                  }
               }
               object = new Object();
               object.sendGiftsToFriends = true;
               m_data.push(object);
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
               result += (m_data[index].needCount - this.m_storage.getExpansionPartCount(m_data[index].itemCode)) * partcost;
            }
         }
         return result;
      }
      
      override protected function fixArrows() : void
      {
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
               sendGifts = new GenericButton(tile.present_bt,this.onShowGiftingOverlay);
               sendGifts.m_overlay.name = "SendGifts";
               sendGifts.text = ZLocUtils.t("Dialogs","SendGiftsBig");
               completeNow = new GenericButton(tile.completeNow_bt,this.onCompleteNowCallback);
               completeNow.text = ZLocUtils.t("Dialogs","CompleteNow");
            }
            tile.visible = true;
         }
      }
      
      private function onShowGiftingOverlay(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",this.m_storage.getItem().name + this.m_storage.storageLevel.toString(),"send_gift");
         super.showGiftingOverlay();
      }
      
      private function onAskMoreCallback(evt:MouseEvent) : void
      {
         var itemName:String = null;
         var itemXML:XML = null;
         var item:FarmItem = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            itemName = getRelevantItemNameFromEvent(evt);
         }
         else
         {
            itemXML = getItemXMLFromEvent(evt);
            item = new FarmItem(itemXML);
            itemName = item.name;
         }
         FarmStatsManager.count("Constructable","ui_button_click",this.m_storage.getItem().name + this.m_storage.storageLevel.toString(),"ask_for_more");
         MFSRequestManager.getInstance().makeAskMatsRequest(this.m_storage.getItem().name,itemName,"","",MFSConstants.SOURCE_DIALOG_CLICKED);
      }
      
      protected function onBuyPartCallback(event:MouseEvent) : void
      {
         this.m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(this.m_itemToBuy.friendlyName),
            "cashQuantity":this.m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPartAcceptCallback),false);
      }
      
      protected function onBuyPartAcceptCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_itemToBuy != null)
         {
            FarmStatsManager.count("Constructable","ui_button_click",this.m_storage.getItem().name + this.m_storage.storageLevel.toString(),"buy_part","accept");
            if(Global.player.canBuyCash(this.m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(this.m_itemToBuy.name,false,m_building);
               this.m_mainDialog.onCloseClick(null);
               TweenLite.to(this,MATERIAL_RISE_TWEEN_TIME,{"onComplete":function():void
               {
                  m_storage.onExpandNowAccept();
               }});
            }
         }
         else
         {
            FarmStatsManager.count("Constructable","ui_button_click",this.m_storage.getItem().name + this.m_storage.storageLevel.toString(),"buy_part","cancel");
         }
      }
      
      protected function onCompleteNowCallback(evt:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",this.m_storage.getItem().name + this.m_storage.storageLevel.toString(),"complete_now");
         m_cashNeeded = this.calculateCashNeeded();
         var buildingName:String = this.m_storage.getItemFriendlyName();
         UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
            "cashQuantity":m_cashNeeded,
            "item":ZLocUtils.tk_pk(buildingName)
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onCompleteNowAcceptCallback,this.FEATURE_NAME + "CompleteNow",true);
         onClickClose(evt);
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
                           this.m_storage.addItem(buildingPart,0,false,false);
                        }
                     }
                  }
               }
               TransactionManager.addTransaction(new TCompleteNow(this.m_storage));
               Global.player.cash -= m_cashNeeded;
            }
            this.m_itemToBuy = null;
            this.m_container = null;
            this.m_storage = null;
            this.m_mainDialog.onCloseClick(null);
         }
      }
   }
}

