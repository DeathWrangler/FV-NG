package Display
{
   import Classes.BuildingItemUseMediator;
   import Classes.Constants.MFSConstants;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BotanicalGardenConstructionWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private const FEATURE_NAME:String = "BotanicalGarden";
      
      public function BotanicalGardenConstructionWithdrawal(storage:StorageBuilding)
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","BotanicalGardenConstructionWithdrawal","called");
         m_dialogAsset = "assets/dialogs/FV_BotanicalGarden.swf";
         m_dialogType = this.FEATURE_NAME;
         super(storage);
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var data:Object = null;
         var getThis:AskForMoreButton = null;
         var buyButton:GenericButton = null;
         var finishButton:GenericButton = null;
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
                  tile.present_bt.visible = false;
                  tile.buy_bt.visible = false;
                  tile.completeNow_bt.visible = true;
                  tile.iconBox_mc.visible = true;
                  finishButton = new GenericButton(tile.completeNow_bt,onFinishConstructionCallback);
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
      
      override protected function getThisGreyOut() : Boolean
      {
         return false;
      }
      
      override protected function onGetThisCallback(event:MouseEvent) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         MFSRequestManager.getInstance().makeAskMatsRequest(this.FEATURE_NAME,item.name,"","",MFSConstants.SOURCE_DIALOG_CLICKED);
      }
      
      override protected function onBuyCallback(event:MouseEvent) : void
      {
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
   }
}

