package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.Constants.MFSConstants;
   import Classes.PigpenBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PigpenConstructionWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private const WHATISTHISDIALOG_URL:String = "assets/dialogs/FV_GenericMedPopUp.swf";
      
      private const FEATURE_NAME:String = "Pigpen";
      
      private const NUM_SLOTS:int = 4;
      
      private const REF:String = "PigpenConstructionBuilding";
      
      public function PigpenConstructionWithdrawal(storage:StorageBuilding)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","PigpenConstructionWithdrawal","called");
         m_dialogAsset = "assets/dialogs/FV_Garage_Incomplete.swf";
         m_dialogType = this.FEATURE_NAME;
         super(storage);
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         var msg:String = null;
         if(m_howDoesThisWorkPopup == null)
         {
            msg = this.getText_WhatIsThisDialog();
            m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,onHowDoesThisWorkClose,this.WHATISTHISDIALOG_URL);
            m_howDoesThisWorkPopup.setAcceptTextName("Okay");
            UI.displayPopup(m_howDoesThisWorkPopup,false,"whatIsThisPopup",true);
         }
      }
      
      override protected function onLoadComplete() : void
      {
         var cancelBtn:GenericButton = null;
         var compIdx:int = 0;
         var gb:GenericButton = null;
         if(!m_building.isFullyBuilt())
         {
            m_window = m_loader.content as MovieClip;
            cancelBtn = new GenericButton(m_window.cancel_bt,onClickClose);
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
            pushNewData();
            m_cashNeeded = calculateCashNeeded();
            compIdx = 0;
            while(compIdx < this.getNumSlots() && compIdx < m_data.length)
            {
               this.addComponent(compIdx);
               compIdx++;
            }
            addChild(m_window);
            if(!PigpenBuilding.hasUserSeenWhatIsThisDialog())
            {
               PigpenBuilding.setUserSeenWhatIsThisDialog();
               this.onClickHowDoesThisWork();
            }
         }
         else
         {
            super.onLoadComplete();
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var data:Object = null;
         var getThis:AskForMoreButton = null;
         var buyButton:GenericButton = null;
         var finishButton:GenericButton = null;
         var sendButton:GenericButton = null;
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
                     if(this.getThisGreyOut() || !isAskSendEnabled())
                     {
                        getThis.greyOut();
                     }
                     buyButton = new GenericButton(tile.buy_bt,this.onBuyCallback);
                     buyButton.text = ZLocUtils.t("Dialogs","Buy");
                     if(!isAskSendEnabled())
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
                  tile.present_bt.visible = true;
                  tile.buy_bt.visible = false;
                  tile.completeNow_bt.visible = true;
                  tile.iconBox_mc.visible = true;
                  finishButton = new GenericButton(tile.completeNow_bt,onFinishConstructionCallback);
                  finishButton.text = ZLocUtils.t("Dialogs","CompleteNow");
                  sendButton = new GenericButton(tile.present_bt,this.onShowGiftingOverlay);
                  sendButton.text = ZLocUtils.t("Dialogs","SendGiftsBig");
                  addIcon(m_building.getItem().getFinishedName(),"icon",tile,tile.icon);
               }
            }
         }
         else
         {
            super.addComponent(compId,index);
         }
      }
      
      override protected function getThisGreyOut() : Boolean
      {
         return false;
      }
      
      override protected function onGetThisCallback(event:MouseEvent) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"ask_for_more");
         MFSRequestManager.getInstance().makeAskMatsRequest(m_building.getItem().name,item.name,this.REF,"",MFSConstants.SOURCE_DIALOG_CLICKED);
      }
      
      override protected function onBuyCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"buy_part");
         m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(m_itemToBuy.friendlyName),
            "cashQuantity":m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.buyConfirmationHandler),false);
      }
      
      override protected function buyConfirmationHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && m_itemToBuy != null)
         {
            if(Global.player.canBuyCash(m_itemToBuy.cash,true))
            {
               BuildingItemUseMediator.getInstance().mediate(m_itemToBuy.name,false,m_building);
               close();
            }
         }
      }
      
      protected function onShowGiftingOverlay(event:MouseEvent) : void
      {
         FarmStatsManager.count("Constructable","ui_button_click",m_building.getItem().name,"send_gift");
         super.showGiftingOverlay(true);
      }
      
      override public function getText_WhatIsThisDialog() : String
      {
         return ZLocUtils.t("Dialogs",m_building.getItem().name + "_WhatIsThis",{
            "listA":ZLocUtils.t("Dialogs","ListOneItem_Placeholder",{
               "quantity":m_data[0].need,
               "item":ZLocUtils.tk_pk(m_data[0].localizedName,"",m_data[0].need)
            }),
            "listB":ZLocUtils.t("Dialogs","ListOneItem_Placeholder",{
               "quantity":m_data[1].need,
               "item":ZLocUtils.tk_pk(m_data[1].localizedName,"",m_data[1].need)
            }),
            "listC":ZLocUtils.t("Dialogs","ListOneItem_Placeholder",{
               "quantity":m_data[2].need,
               "item":ZLocUtils.tk_pk(m_data[2].localizedName,"",m_data[2].need)
            })
         });
      }
   }
}

