package Classes
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   
   public class CraftRewardGnome extends Gnome
   {
      
      private var m_rewardUrl:String;
      
      private var m_rewardCraftType:String;
      
      public function CraftRewardGnome(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         var message:String = null;
         this.m_rewardUrl = CraftingManager.getInstance().getAndResetPreorderRewardUrl();
         this.m_rewardCraftType = Global.player.craftingState.firstCraft;
         if(this.m_rewardUrl != null && this.m_rewardCraftType != null)
         {
            message = ZLocUtils.t("Crafting","ChooseCraftShareReward_" + this.m_rewardCraftType);
            UI.displayMessage(message,GenericPopup.TYPE_SHARECANCEL,this.onShareFeed,"",true);
            FarmStatsManager.count("crafting_cottages","bakery_lite","gnome_flow","place_gnome_first_time");
         }
      }
      
      private function onShareFeed(event:GenericPopupEvent) : void
      {
         var iconUrl:String = null;
         var images:Array = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            iconUrl = Global.getAssetURL(Global.farmGameSettingsManager.getString("craftingSignUpFeedIcon_" + this.m_rewardCraftType));
            images = [{
               "src":iconUrl,
               "href":"{SN_APP_URL}" + this.m_rewardUrl
            }];
            GlobalEngine.socialNetwork.publishFeedStory("CraftLight_" + this.m_rewardCraftType,{
               "first_name":Global.player.firstName,
               "images":images,
               "reward_link":this.m_rewardUrl
            },[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardUrl]));
         }
      }
   }
}

