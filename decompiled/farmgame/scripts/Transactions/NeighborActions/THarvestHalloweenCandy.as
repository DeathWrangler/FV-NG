package Transactions.NeighborActions
{
   import Classes.HalloweenHauntedHouseBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   
   public class THarvestHalloweenCandy extends TBaseNeighborAction
   {
      
      protected var m_rewardObj:Object = new Object();
      
      public function THarvestHalloweenCandy(hauntedHouse:HalloweenHauntedHouseBuilding)
      {
         m_actionType = "harvesthalloweencandy";
         super(hauntedHouse);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var message:String = null;
         var m_congratsWindow:GenericPopup = null;
         super.onComplete(result);
         if(result.candyYield != null)
         {
            this.m_rewardObj.levelNum = result.candyYield;
            if(result.rewardLink != null)
            {
               this.m_rewardObj.rewardUrl = result.rewardLink;
               message = ZLocUtils.t("Dialogs","HalloweenHauntedHouse_completeHarvestNeighbors",{
                  "quantity":result.candyYield,
                  "wordcandy":ZLocUtils.tk("Dialogs","HalloweenHauntedHouse_word_candy","",result.candyYield),
                  "item":ZLocUtils.tk_pk((this.m_object as HalloweenHauntedHouseBuilding).getItemFriendlyName())
               });
               m_congratsWindow = new GenericPopup(message,GenericPopup.TYPE_SHARE,this.onShare);
               UI.displayPopup(m_congratsWindow,false);
            }
            Global.player.addGift("halloween_candy","0",int(result.candyYield));
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
            feedStoryBundleID = "HalloweenHarvestNeighbor";
            GlobalEngine.socialNetwork.publishFeedStory(feedStoryBundleID,bundleData,[],false);
         }
         else
         {
            TCancelFriendReward([this.m_rewardObj.rewardUrl]);
         }
      }
   }
}

