package Display
{
   import Classes.Building;
   import Classes.BuildingItemUseMediator;
   import Classes.Constants.MFSConstants;
   import Classes.ConstructionBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TTransformBuilding;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getQualifiedClassName;
   
   public class BaseConstructionBuildingWithdrawal extends StorageWithdrawal
   {
      
      private static const DEFAULT_UI_ASSET:String = "assets/dialogs/FV_Garage_Incomplete.swf";
      
      protected const ASK_MATERIALS_URL:String = "askmats.php";
      
      private const NUM_SLOTS:int = 4;
      
      protected var m_cashNeeded:int = 0;
      
      private var m_discount:int = 0;
      
      private var m_itemToBuy:FarmItem = null;
      
      public function BaseConstructionBuildingWithdrawal(storage:StorageBuilding)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","BaseConstructionBuildingWithdrawal","called");
         if(!m_dialogAsset)
         {
            m_dialogAsset = this.getUI(storage);
            m_dialogType = "construction";
         }
         super(storage);
      }
      
      public static function getClassName(object:Object) : String
      {
         var splitString:Array = getQualifiedClassName(object).split("::");
         return splitString.pop();
      }
      
      private function getUI(storage:StorageBuilding) : String
      {
         var ui:String = storage.getItem().constructionUI;
         if(!ui)
         {
            ui = DEFAULT_UI_ASSET;
         }
         return ui;
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function onLoadComplete() : void
      {
         var cancelBtn:GenericButton = null;
         var compIdx:int = 0;
         var gb:GenericButton = null;
         if(!m_building.isFullyBuilt())
         {
            m_window = m_loader.content as MovieClip;
            cancelBtn = new GenericButton(m_window.cancel_bt,this.onClickClose);
            cancelBtn.m_overlay.name = "Cancel";
            cancelBtn.text = ZLocUtils.t("Dialogs","ReturnToFarm");
            ZLocUtils.setTextAsTitle(m_window,"giftsTitle_tf",m_building.getItemFriendlyName());
            if(m_window.hasOwnProperty("whatisthis_mc") && Boolean(m_window.whatisthis_mc))
            {
               gb = new GenericButton(m_window.whatisthis_mc,this.onClickHowDoesThisWork);
               gb.m_overlay.name = "WhatIsThisBtn";
               gb.text = ZLocUtils.t("Dialogs","WhatIsThis");
            }
            m_tiles = new Array(m_window.giftPanel1,m_window.giftPanel2,m_window.giftPanel3,m_window.giftPanel4);
            removeTiles();
            this.pushNewData();
            this.m_cashNeeded = this.calculateCashNeeded();
            compIdx = 0;
            while(compIdx < this.getNumSlots() && compIdx < m_data.length)
            {
               this.addComponent(compIdx);
               compIdx++;
            }
            addChild(m_window);
         }
         else
         {
            super.onLoadComplete();
         }
      }
      
      override protected function pushNewData() : void
      {
         var objects:Array = null;
         var object:Object = null;
         var partItem:PartItem = null;
         var giftItem:FarmItem = null;
         var giftNum:Number = NaN;
         if(!m_building.isFullyBuilt())
         {
            m_data = [];
            m_tileSet = 0;
            m_usedTypes = new Object();
            objects = m_building.getConstructionItems();
            if(objects)
            {
               for each(partItem in objects)
               {
                  object = new Object();
                  giftItem = partItem.item;
                  giftNum = partItem.onHand;
                  if(m_usedTypes[giftItem.code] == null)
                  {
                     object.sendGiftsToFriends = false;
                     object.name = giftItem.name;
                     object.code = giftItem.code;
                     object.type = giftItem.type;
                     object.localizedName = Global.farmGameSettingsManager.getFarmItemByName(object.name).friendlyName;
                     object.cost = giftItem.cost;
                     object.need = partItem.qtyNeeded;
                     m_usedTypes[giftItem.code] = giftNum;
                     m_data.push(object);
                  }
                  else
                  {
                     m_usedTypes[giftItem.code] += 1;
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
         var finishButton:GenericButton = null;
         var sendGifts:GenericButton = null;
         if(!m_building.isFullyBuilt())
         {
            if(Boolean(m_tiles) && m_data[index + compId] != null)
            {
               tile = m_tiles[compId] as MovieClip;
               data = m_data[index + compId];
               tile.visible = true;
               tile.use_bt.visible = false;
               if(data.sendGiftsToFriends == false)
               {
                  tile.itemTitle_tf.visible = true;
                  tile.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(data.localizedName);
                  tile.alive_tf.visible = true;
                  tile.alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
                     "quantity":m_usedTypes[data.code],
                     "maximum":data.need
                  });
                  tile.iconBox_mc.visible = true;
                  if(m_usedTypes[data.code] == data.need)
                  {
                     ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
                     tile.completeIcon_mc.visible = true;
                     tile.completeNow_bt.visible = false;
                     tile.getThis_bt.visible = false;
                     tile.buy_bt.visible = false;
                  }
                  else
                  {
                     tile.completeIcon_mc.visible = false;
                     tile.completeNow_bt.visible = false;
                     tile.getThis_bt.visible = true;
                     getThis = null;
                     getThis = new AskForMoreButton(tile.getThis_bt,this.onGetThisCallback);
                     getThis.m_overlay.name = "GetThis_" + data.code;
                     getThis.text = ZLocUtils.t("Dialogs","AskForMore");
                     if(this.getThisGreyOut() || !this.isAskSendEnabled())
                     {
                        getThis.greyOut();
                     }
                     buyButton = new GenericButton(tile.buy_bt,this.onBuyCallback);
                     buyButton.text = ZLocUtils.t("Dialogs","Buy");
                     if(!this.isAskSendEnabled())
                     {
                        buyButton.turnOff();
                     }
                  }
                  tile.sendMaterials_tf.visible = false;
                  tile.present_bt.visible = false;
                  addIcon(data.name,"icon",tile,tile.icon);
               }
               else
               {
                  tile.itemTitle_tf.visible = false;
                  tile.alive_tf.visible = false;
                  tile.completeIcon_mc.visible = false;
                  tile.getThis_bt.visible = false;
                  tile.sendMaterials_tf.visible = false;
                  tile.present_bt.visible = false;
                  tile.buy_bt.visible = false;
                  tile.completeNow_bt.visible = true;
                  tile.iconBox_mc.visible = true;
                  if(this.isAskSendEnabled())
                  {
                     tile.sendMaterials_tf.text = ZLocUtils.t("Dialogs","SendMaterials");
                     sendGifts = new GenericButton(tile.present_bt,this.onSendPresentsCallback);
                     sendGifts.m_overlay.name = "SendGifts";
                     sendGifts.text = ZLocUtils.t("Dialogs","SendGiftsBig");
                     tile.present_bt.visible = true;
                  }
                  else
                  {
                     tile.present_bt.visible = false;
                  }
                  finishButton = new GenericButton(tile.completeNow_bt,this.onFinishConstructionCallback);
                  finishButton.text = ZLocUtils.t("Dialogs","CompleteNow");
                  addIcon(m_building.getItem().getFinishedName(),"icon",tile,tile.icon);
               }
            }
         }
         else
         {
            super.addComponent(compId,index);
         }
      }
      
      protected function onBuyCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"buy_part");
         this.m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(this.m_itemToBuy.friendlyName),
            "cashQuantity":this.m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.buyConfirmationHandler),false);
      }
      
      private function buyConfirmationHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_itemToBuy != null)
         {
            if(Global.player.canBuyCash(this.m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(this.m_itemToBuy.name,false,m_building);
               close();
            }
         }
      }
      
      protected function calculateCashNeeded(partcost:int = 1) : int
      {
         var result:int = 0;
         for(var index:int = 0; index < m_data.length; index++)
         {
            if(!m_data[index].sendGiftsToFriends)
            {
               result += (m_data[index].need - m_usedTypes[m_data[index].code]) * partcost;
            }
         }
         return result;
      }
      
      protected function onFinishConstructionCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Finish_construction_click");
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"complete_now");
         var buildingName:String = m_building.getItemFriendlyName();
         UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
            "cashQuantity":this.m_cashNeeded,
            "item":ZLocUtils.tk_pk(buildingName)
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup);
         this.onClickClose(event);
      }
      
      protected function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         var cBuilding:ConstructionBuilding = null;
         var newBuilding:Building = null;
         if(event.button == GenericPopup.YES)
         {
            cBuilding = m_building as ConstructionBuilding;
            if(cBuilding != null && Global.player.canBuyCash(this.m_cashNeeded))
            {
               newBuilding = cBuilding.transformBuilding() as Building;
               if(newBuilding)
               {
                  this.m_discount = newBuilding.getItem().cash - this.m_cashNeeded;
                  Global.player.tryBuy(newBuilding,false,newBuilding.getItem(),this.m_discount);
                  TransactionManager.addTransaction(new TTransformBuilding(cBuilding));
               }
            }
         }
         else
         {
            m_building.displayStorageDialog();
         }
      }
      
      protected function onGetThisCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"ask_for_more");
         MFSRequestManager.getInstance().makeAskMatsRequest(m_building.getItem().name,getItemNameFromEvent(event),m_building.getItem().name,"",MFSConstants.SOURCE_DIALOG_CLICKED);
      }
      
      protected function getThisGreyOut() : Boolean
      {
         var result:Boolean = false;
         var flagName:String = getClassName(this);
         var timeSinceAsk:Number = GlobalEngine.serverTime / 1000 - Global.player.getFeatureLastShown(flagName);
         if(timeSinceAsk < Global.farmGameSettingsManager.getNumber("constructionMaterialAskDelay"))
         {
            result = true;
         }
         return result;
      }
      
      protected function isAskSendEnabled() : Boolean
      {
         var endTime:Number = NaN;
         var result:Boolean = true;
         var disableDate:String = this.getAskSendDisableDate();
         if(disableDate)
         {
            endTime = FarmGameUtil.synchronizedDateToNumber(disableDate);
            result = GlobalEngine.getTimer() < endTime;
         }
         return result;
      }
      
      protected function getAskSendDisableDate() : String
      {
         return m_building.getItem().getLimitedEndDate();
      }
      
      override protected function fixArrows() : void
      {
         if(m_building.isFullyBuilt())
         {
            super.fixArrows();
         }
      }
      
      protected function onSendPresentsCallback(event:MouseEvent) : void
      {
         close();
         FreeGiftSelectionWindow.popWindow();
      }
      
      protected function onClickClose(event:MouseEvent) : void
      {
         if(null != m_howDoesThisWorkPopup)
         {
            m_howDoesThisWorkPopup.close();
         }
         removeTiles(false);
         m_usedTypes = null;
         event.stopPropagation();
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      override protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         var msg:String = null;
         var dialog:GenericXMLDialog = null;
         if(m_howDoesThisWorkPopup == null)
         {
            msg = this.getText_WhatIsThisDialog();
            dialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,onHowDoesThisWorkClose,false,"Okay",null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_LARGE);
            UI.displayPopup(dialog,false);
         }
      }
      
      public function getText_WhatIsThisDialog() : String
      {
         return ZLocUtils.t("Dialogs",m_building.getItem().name + "_WhatIsThis");
      }
      
      protected function generateNeedList() : String
      {
         var type:Object = null;
         var needed:int = 0;
         var remaining:int = 0;
         var i:int = 0;
         var result:String = "";
         var contents:Array = m_building.getStorageTypes();
         var needItems:Array = new Array();
         var needAmounts:Array = new Array();
         for each(type in contents)
         {
            needed = m_building.getItemLimit(type.item);
            remaining = needed - type.num;
            if(remaining > 0)
            {
               needItems.push(type.item.friendlyName);
               needAmounts.push(remaining);
            }
         }
         result = "";
         if(needItems.length > 0)
         {
            for(i = 0; i < needItems.length; i++)
            {
               result += ZLocUtils.tk_pk_asTitlePlural(needItems[i]) + " (";
               result += needAmounts[i] + ")";
               if(i < needItems.length - 1)
               {
                  result += ",";
               }
            }
         }
         return result;
      }
      
      protected function onAskForMaterials() : void
      {
         var flagName:String = getClassName(this);
         Global.player.setFeatureLastShown(flagName,GlobalEngine.serverTime,true);
         refreshLayout(true);
      }
   }
}

