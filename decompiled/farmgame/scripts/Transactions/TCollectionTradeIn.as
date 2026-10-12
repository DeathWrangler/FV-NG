package Transactions
{
   import Classes.Collections.Collection;
   import Classes.Collections.Reward;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.CollectionsManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.Collections.CollectionsWindow;
   
   public class TCollectionTradeIn extends TFarmTransaction
   {
      
      protected var m_collectionName:String;
      
      protected var m_rewardData:Object;
      
      protected var m_mainDialog:CollectionsWindow;
      
      public function TCollectionTradeIn(collectionName:String, mainDialog:CollectionsWindow = null)
      {
         super();
         this.m_mainDialog = mainDialog;
         if(this.m_mainDialog)
         {
            this.m_mainDialog.close();
         }
         this.m_collectionName = collectionName;
      }
      
      override public function perform() : void
      {
         var collection:Collection = CollectionsManager.getInstance().getCollection(this.m_collectionName);
         if(collection == null || collection.type == Collection.TYPE_SLOTMACHINE)
         {
            signedCall("CollectionsService.onTradeIn",this.m_collectionName);
         }
         else
         {
            signedCall("CollectionsService.onClaimReward",this.m_collectionName);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var collection:Collection = null;
         var reward:Reward = null;
         var rewardItem:FarmItem = null;
         var rewardPopup:GenericIconPopup = null;
         if(result != null)
         {
            this.m_rewardData = result;
            collection = CollectionsManager.getInstance().getCollection(this.m_collectionName);
            reward = collection.getRewards()[(collection.getLevel() - 1) % collection.getRewards().length];
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(reward.gift);
            if(rewardItem != null)
            {
               Global.player.addGift(reward.gift);
            }
            if(this.m_rewardData.xp)
            {
               this.m_rewardData.xp = Global.player.calculateAndAddXp(int(this.m_rewardData.xp));
            }
            if(this.m_rewardData.coins)
            {
               Global.player.gold += int(this.m_rewardData.coins);
            }
            rewardPopup = new GenericIconPopup(ZLocUtils.t("Collections","TradeInReward",{
               "xpQuantity":this.m_rewardData.xp,
               "coinQuantity":this.m_rewardData.coins,
               "Coin_word":ZLocUtils.tk_pk("Dialogs:Coin_word","",this.m_rewardData.coins),
               "item":ZLocUtils.tk_pk(rewardItem.friendlyName)
            }),GenericPopup.TYPE_SHARECANCEL,this.onShare,rewardItem.icon,false,false);
            UI.displayPopup(rewardPopup);
         }
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         var collection:Collection = null;
         var bundleData:Object = null;
         var collection2:Collection = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("feed","collections","trade_in_collection","","",Global.worldManager.currentWorldType);
            collection = CollectionsManager.getInstance().getCollection(this.m_collectionName);
            bundleData = {
               "collection":collection.friendlyName,
               "reward_link":this.m_rewardData.rewardUrl,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_rewardData.rewardUrl,
                  "src":Global.getAssetURL("assets/newsfeed/collecting.png")
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("TradeIn",bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardData.rewardUrl]));
         }
         if(this.m_mainDialog)
         {
            collection2 = CollectionsManager.getInstance().getCollection(this.m_collectionName);
            UI.displayPopup(new CollectionsWindow(collection2));
         }
      }
   }
}

