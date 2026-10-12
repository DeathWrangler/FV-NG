package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.Constants.MFSConstants;
   import Classes.ConstructionBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getQualifiedClassName;
   
   public class ConstructionBuildingWithdrawal extends StorageWithdrawal
   {
      
      protected const ASK_MATERIALS_URL:String = "askmats.php";
      
      protected const CONSTRUCTABLE_STATS_COUNTER:String = "Constructable";
      
      protected const WINDOWCONTEXT_CHOOSEVISUAL:String = "choosevisual";
      
      private const NUM_SLOTS:int = 6;
      
      protected var m_windowContext:String = "default";
      
      protected var m_cashNeeded:int = 0;
      
      protected var m_discount:int = 0;
      
      protected var m_itemToBuy:FarmItem = null;
      
      protected var m_whatIsThisBtn:GenericButton;
      
      protected var NUM_BUILDINGVISUALS:int = 4;
      
      protected var m_chooseVisualBtns:Array = new Array();
      
      protected var m_isBuyPartsFrictionless:Boolean = false;
      
      public function ConstructionBuildingWithdrawal(storage:StorageBuilding)
      {
         if(!m_dialogAsset)
         {
            m_dialogAsset = "assets/dialogs/FV_ConstructionBuilding.swf";
            m_dialogType = "construction";
         }
         super(storage);
      }
      
      public static function getClassName(object:Object) : String
      {
         var splitString:Array = getQualifiedClassName(object).split("::");
         return splitString.pop();
      }
      
      public function getFeatureReadyState() : Boolean
      {
         return false;
      }
      
      public function doReadyState() : void
      {
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function onLoadComplete() : void
      {
         var cancelBtn:GenericButton = null;
         var panelIndex:int = 0;
         var compIdx:int = 0;
         if(!m_building.isFullyBuilt())
         {
            m_window = m_loader.content as MovieClip;
            cancelBtn = new GenericButton(m_window.cancel_bt,this.onClickClose);
            cancelBtn.m_overlay.name = "Cancel";
            cancelBtn.text = ZLocUtils.t("Dialogs","ReturnToFarm");
            ZLocUtils.setTextAsTitle(m_window,"giftsTitle_tf",m_building.getItemFriendlyName());
            if(m_window.hasOwnProperty("whatisthis_mc") && Boolean(m_window.whatisthis_mc))
            {
               this.m_whatIsThisBtn = new GenericButton(m_window.whatisthis_mc,this.onClickHowDoesThisWork);
               this.m_whatIsThisBtn.m_overlay.name = "WhatIsThisBtn";
               this.m_whatIsThisBtn.text = ZLocUtils.t("Dialogs","WhatIsThis");
            }
            panelIndex = 1;
            m_tiles = new Array();
            while(m_window["giftPanel" + panelIndex])
            {
               m_tiles.push(m_window["giftPanel" + panelIndex]);
               panelIndex++;
            }
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
         this.takeDefaultAction();
      }
      
      override protected function takeDefaultAction() : void
      {
         switch(m_defaultAction)
         {
            case ConstructionBuilding.MENU_ASK_FOR_PARTS:
               this.askForPartsHandler(m_building.getMostNeededItem());
               break;
            case ConstructionBuilding.MENU_COMPLETE_NOW:
               this.onFinishConstructionCallback(null);
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
                     object.localizedName = giftItem.friendlyName;
                     object.cost = giftItem.cost;
                     object.cash = giftItem.cash;
                     object.currentCount = giftNum;
                     object.need = partItem.qtyNeeded;
                     object.needCount = partItem.qtyNeeded;
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
         var getThis:AskForMoreButton = null;
         var sendGifts:GenericButton = null;
         var finishButton:GenericButton = null;
         if(!m_building.isFullyBuilt())
         {
            if(Boolean(m_tiles) && Boolean(m_data[index + compId] != null) && m_usedTypes != null)
            {
               m_tiles[compId].visible = true;
               m_tiles[compId].use_bt.visible = false;
               if(m_tiles[compId].buy_bt)
               {
                  m_tiles[compId].buy_bt.visible = false;
               }
               if(m_tiles[compId].completeNow_bt)
               {
                  m_tiles[compId].completeNow_bt.visible = false;
               }
               if(m_data[index + compId].sendGiftsToFriends == false)
               {
                  m_tiles[compId].itemTitle_tf.visible = true;
                  m_tiles[compId].itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].localizedName);
                  m_tiles[compId].alive_tf.visible = true;
                  m_tiles[compId].alive_tf.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
                     "quantity":m_usedTypes[m_data[index + compId].code],
                     "maximum":m_data[index + compId].need
                  });
                  m_tiles[compId].iconBox_mc.visible = true;
                  if(m_usedTypes[m_data[index + compId].code] == m_data[index + compId].need)
                  {
                     ZLocUtils.setText(m_tiles[compId],"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
                     m_tiles[compId].completeIcon_mc.visible = true;
                     m_tiles[compId].getThis_bt.visible = false;
                  }
                  else
                  {
                     m_tiles[compId].completeIcon_mc.visible = false;
                     m_tiles[compId].getThis_bt.visible = true;
                     getThis = new AskForMoreButton(m_tiles[compId].getThis_bt,this.onGetThisCallback);
                     getThis.m_overlay.name = "GetThis_" + m_data[index + compId].code;
                     getThis.text = ZLocUtils.t("Dialogs","AskForMore");
                     if(this.getThisGreyOut() || !this.isAskSendEnabled())
                     {
                        getThis.greyOut();
                     }
                  }
                  m_tiles[compId].sendMaterials_tf.visible = false;
                  m_tiles[compId].present_bt.visible = false;
                  addIcon(m_data[index + compId].name,"icon",m_tiles[compId],m_tiles[compId].icon);
               }
               else
               {
                  m_tiles[compId].itemTitle_tf.visible = false;
                  m_tiles[compId].alive_tf.visible = false;
                  m_tiles[compId].completeIcon_mc.visible = false;
                  m_tiles[compId].getThis_bt.visible = false;
                  m_tiles[compId].iconBox_mc.visible = false;
                  m_tiles[compId].sendMaterials_tf.visible = true;
                  m_tiles[compId].present_bt.visible = true;
                  if(this.isAskSendEnabled())
                  {
                     m_tiles[compId].sendMaterials_tf.text = ZLocUtils.t("Dialogs","SendMaterials");
                     sendGifts = new GenericButton(m_tiles[compId].present_bt,this.onSendPresentsCallback);
                     sendGifts.m_overlay.name = "SendGifts";
                     sendGifts.text = ZLocUtils.t("Dialogs","SendGiftsBig");
                  }
                  else
                  {
                     m_tiles[compId].sendMaterials_tf.text = ZLocUtils.t("Dialogs","FinishConstructionNow",{"cashQuantity":this.m_cashNeeded});
                     finishButton = new GenericButton(m_tiles[compId].present_bt,this.onFinishConstructionCallback);
                     finishButton.m_overlay.name = "FinishNow";
                     finishButton.text = ZLocUtils.t("Dialogs","FinishNowBig");
                  }
               }
            }
         }
         else
         {
            super.addComponent(compId,index);
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
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup,"",true);
         m_defaultAction = "";
      }
      
      protected function onFrictionlessFinishConstructionCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Finish_construction_click");
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"frictionless_complete_now");
         var buildingName:String = m_building.getItemFriendlyName();
         var cBuilding:ConstructionBuilding = m_building as ConstructionBuilding;
         if(cBuilding != null)
         {
            cBuilding.frictionlessCompleteNow();
         }
         m_defaultAction = "";
         this.close();
      }
      
      protected function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         var cBuilding:ConstructionBuilding = null;
         if(event.button == GenericPopup.YES)
         {
            cBuilding = m_building as ConstructionBuilding;
            if(cBuilding != null)
            {
               cBuilding.frictionlessCompleteNow();
            }
            this.close();
         }
      }
      
      private function askForPartsHandler(storagePartItem:PartItem) : void
      {
         if(null != storagePartItem)
         {
            MFSRequestManager.getInstance().makeAskMatsRequest(m_building.getItem().name,storagePartItem.item.name,"m_building.getItem().name","",MFSConstants.SOURCE_CONTEXT_MENU,this.CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name,"ask_for_more");
         }
      }
      
      protected function onGetThisCallback(event:MouseEvent) : void
      {
         MFSRequestManager.getInstance().makeAskMatsRequest(m_building.getItem().name,getItemNameFromEvent(event),m_building.getItem().name,"",MFSConstants.SOURCE_DIALOG_CLICKED,this.CONSTRUCTABLE_STATS_COUNTER,"ui_button_click",m_building.getItem().name,"ask_for_more");
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
         return m_building.getItem().limitedEndDate;
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
         if(m_howDoesThisWorkPopup == null)
         {
            msg = this.getText_WhatIsThisDialog();
            m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,onHowDoesThisWorkClose,this.getWhatIsThisDialogFileName());
            m_howDoesThisWorkPopup.setAcceptTextName("Okay");
            UI.displayPopup(m_howDoesThisWorkPopup,false,"whatIsThisPopup",true);
         }
      }
      
      public function getText_WhatIsThisDialog() : String
      {
         var dialogKey:String = null;
         var fallbackDialogKey:String = null;
         var text:String = "";
         if(m_building.isFullyBuilt())
         {
            if(ZLocUtils.hasString("Dialogs",m_building.getItem().name + "_chooseVisualWhatIsThis"))
            {
               text = ZLocUtils.t("Dialogs",m_building.getItem().name + "_chooseVisualWhatIsThis");
            }
         }
         if(text == "")
         {
            dialogKey = m_building.getItem().name + "_WhatIsThis";
            fallbackDialogKey = ConstructionBuilding.FALLBACK_KEY + "WhatIsThis";
            text = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackDialogKey)],{
               "building":m_building.getItem().friendlyTitle,
               "building2":m_building.getItem().friendlyTitle
            });
         }
         return text;
      }
      
      public function getWhatIsThisDialogFileName() : String
      {
         return GenericPopup.GENERIC_ASSET;
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
                  result += ", ";
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
      
      protected function onBuyCallback(event:MouseEvent) : void
      {
         var messageText:String = null;
         this.m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         if(this.m_isBuyPartsFrictionless)
         {
            this.buyItem(this.m_itemToBuy);
         }
         else
         {
            messageText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
               "item":ZLocUtils.tk_pk(this.m_itemToBuy.friendlyName),
               "cashQuantity":this.m_itemToBuy.cash
            });
            UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.buyConfirmationHandler),false);
         }
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"buy_part",this.m_itemToBuy.name);
      }
      
      protected function buyItem(itemToBuy:FarmItem) : void
      {
         if(Global.player.canBuyCash(itemToBuy.cash,true))
         {
            BuildingItemUseMediator.getInstance().mediate(itemToBuy.name,false,m_building);
            close();
         }
      }
      
      protected function buyConfirmationHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_itemToBuy != null)
         {
            this.buyItem(this.m_itemToBuy);
         }
      }
      
      public function useChooseVisualDialog() : void
      {
         this.m_windowContext = this.WINDOWCONTEXT_CHOOSEVISUAL;
      }
   }
}

