package Display
{
   import Classes.OrchardFeatureBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OrchardConstructionWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      private static const NUM_SLOTS:int = 4;
      
      public function OrchardConstructionWithdrawal(storage:StorageBuilding)
      {
         if(PrerequisiteUtility.checkPrereqByName(OrchardFeatureBuilding.ORCHARD_FEATUREBUILDING_ENABLED_PREREQ))
         {
            m_dialogAsset = "assets/dialogs/FV_OrchardsConstruct2.swf";
            m_isBuyPartsFrictionless = true;
         }
         else
         {
            m_dialogAsset = "assets/dialogs/FV_OrchardsConstruct.swf";
         }
         m_dialogType = "construction";
         super(storage);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_whatIsThisBtn.text = ZLocUtils.t("Dialogs","HowDoesThisWork");
         if(m_window.hasOwnProperty("subheader_tf") && Boolean(m_window.subheader_tf))
         {
         }
      }
      
      override protected function getNumSlots() : int
      {
         return NUM_SLOTS;
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var getThis:AskForMoreButton = null;
         var buyButton:GenericButton = null;
         var finishButton:GenericButton = null;
         super.addComponent(compId,index);
         var tile:MovieClip = m_tiles[compId] as MovieClip;
         var data:Object = m_data[index + compId];
         if(m_usedTypes[data.code] == data.need)
         {
            ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
            tile.completeIcon_mc.visible = true;
            tile.completeNow_bt.visible = false;
            tile.getThis_bt.visible = false;
            tile.buy_bt.visible = false;
            if(tile.hasOwnProperty("fcPrice_mc"))
            {
               tile.fcPrice_mc.visible = false;
            }
         }
         else
         {
            tile.completeIcon_mc.visible = false;
            tile.completeNow_bt.visible = false;
            tile.getThis_bt.visible = true;
            tile.buy_bt.visible = true;
            getThis = null;
            getThis = new AskForMoreButton(tile.getThis_bt,onGetThisCallback);
            getThis.m_overlay.name = "GetThis_" + data.code;
            getThis.text = ZLocUtils.t("Dialogs","AskForMore");
            if(getThisGreyOut() || !isAskSendEnabled())
            {
               getThis.greyOut();
            }
            buyButton = new GenericButton(tile.buy_bt,onBuyCallback);
            buyButton.text = ZLocUtils.t("Dialogs","Buy");
            if(!isAskSendEnabled())
            {
               buyButton.turnOff();
            }
            if(tile.hasOwnProperty("fcPrice_mc") && Boolean(tile.fcPrice_mc.hasOwnProperty("FCPrice_tf")))
            {
               tile.fcPrice_mc.FCPrice_tf.text = data.cash;
            }
         }
         if(data.sendGiftsToFriends == true)
         {
            tile.completeNow_bt.visible = true;
            finishButton = new GenericButton(tile.completeNow_bt,onFinishConstructionCallback);
            finishButton.text = ZLocUtils.t("Dialogs","CompleteNow");
         }
      }
      
      override protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         TutorialUI.displayOrchardsTutorialWindow(m_building);
      }
   }
}

