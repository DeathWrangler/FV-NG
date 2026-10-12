package Transactions
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.events.Event;
   
   public class TSlotMachineCollectionTradeIn extends TCollectionTradeIn
   {
      
      private var m_callback:Function;
      
      private var m_building:FeatureBuilding;
      
      public function TSlotMachineCollectionTradeIn(collectionCode:String, building:FeatureBuilding, callback:Function)
      {
         super(collectionCode);
         this.m_callback = callback;
         this.m_building = building;
         if(this.m_building.slotmachine == null)
         {
            throw new Error("TSlotMachineCollectionTradeIn is being used on a feature building that does not have a slotmachine component.");
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var title:String = null;
         var message:String = null;
         var rewardItem:FarmItem = null;
         var curLevelIndex:Number = NaN;
         var nextLevelIndex:Number = NaN;
         var dialog:GenericXMLDialog = null;
         var nextLevelName:String = null;
         if(result != null)
         {
            m_rewardData = result;
            title = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_PrizeClaimedPromptFeed_Title");
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(result.rewardItem);
            curLevelIndex = Number(this.m_building.slotmachine.currentLevel) + 1;
            nextLevelIndex = curLevelIndex + 1;
            if(this.m_building.slotmachine.levels[nextLevelIndex] != null)
            {
               nextLevelName = this.m_building.slotmachine.getCollectionLevelName(nextLevelIndex);
               message = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_PrizeClaimedPromptFeed_MessageAnotherTier",{
                  "itemA":ZLocUtils.tk_pk(rewardItem.friendlyName),
                  "itemB":ZLocUtils.tk_pk(nextLevelName)
               });
            }
            else
            {
               message = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_PrizeClaimedPromptFeed_MessageLastTier",{"item":ZLocUtils.tk_pk(rewardItem.friendlyName)});
            }
            dialog = new GenericXMLDialog(title,"",null,rewardItem.iconRelativeUrl,100,100,message,this.onShareRedeemed,true,ZLocUtils.t("Dialogs","Share"),null,null,this.onShareCancelled,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
            UI.displayPopup(dialog,false);
            FarmStatsManager.count(this.m_building.getItem().name,"reward_redeemed",rewardItem.name);
         }
      }
      
      override protected function updateCollectionCounters(result:Object) : void
      {
         super.updateCollectionCounters(result);
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
      
      private function onShareRedeemed(event:GenericPopupEvent) : void
      {
         if(GenericPopup.ACCEPT == event.button)
         {
            if(Boolean(this.m_building) && Boolean(this.m_building.slotmachine))
            {
               this.m_building.slotmachine.onShareRedeemed(true,m_rewardData);
            }
         }
         this.m_building.slotmachine.refreshPrizes();
         this.m_building.slotmachine.scrollToCurrentTier();
      }
      
      private function onShareCancelled(event:Event) : void
      {
         if(Boolean(this.m_building) && Boolean(this.m_building.slotmachine))
         {
            this.m_building.slotmachine.onShareRedeemed(false,m_rewardData);
         }
         this.m_building.slotmachine.refreshPrizes();
         this.m_building.slotmachine.scrollToCurrentTier();
      }
   }
}

