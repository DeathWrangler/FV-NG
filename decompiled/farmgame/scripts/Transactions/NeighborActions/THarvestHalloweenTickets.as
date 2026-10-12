package Transactions.NeighborActions
{
   import Classes.HalloweenCastleDuckulaBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   
   public class THarvestHalloweenTickets extends TBaseNeighborAction
   {
      
      protected var m_rewardObj:Object = new Object();
      
      public function THarvestHalloweenTickets(castleDuckula:HalloweenCastleDuckulaBuilding)
      {
         m_actionType = "harvesthalloweentickets";
         super(castleDuckula);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var message:String = null;
         var m_congratsWindow:GenericPopup = null;
         super.onComplete(result);
         if(result.ticketYield != null)
         {
            if(result.rewardLink != null)
            {
               this.m_rewardObj.rewardUrl = result.rewardLink;
               message = ZLocUtils.t("Dialogs","HalloweenCastleDuckula_completeHarvestNeighbors",{
                  "quantity":result.ticketYield,
                  "wordticket":ZLocUtils.tk("Dialogs","HalloweenCastleDuckula_word_ticket","",result.ticketYield),
                  "item":ZLocUtils.tk_pk((this.m_object as HalloweenCastleDuckulaBuilding).getItemFriendlyName())
               });
               m_congratsWindow = new GenericPopup(message,GenericPopup.TYPE_SHARE,this.onShare);
               UI.displayPopup(m_congratsWindow,false);
            }
            Global.player.addGift("halloweenbasket2011_ticket","0",int(result.ticketYield));
         }
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var feedStoryBundleID:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "user":Global.player.firstName,
               "levelNum":this.m_rewardObj.levelNum,
               "reward_link":this.m_rewardObj.rewardUrl,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_rewardObj.rewardUrl,
                  "src":Global.getAssetURL("assets/decorations/deco_halloweencandy_icon.png")
               }]
            };
            feedStoryBundleID = "HalloweenTicketHarvestNeighbor";
            GlobalEngine.socialNetwork.publishFeedStory(feedStoryBundleID,bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardObj.rewardUrl]));
         }
      }
   }
}

