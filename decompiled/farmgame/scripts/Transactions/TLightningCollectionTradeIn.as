package Transactions
{
   import Classes.Collections.Collection;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Windows.CongratsWindowLg;
   import flash.events.MouseEvent;
   
   public class TLightningCollectionTradeIn extends TFarmTransaction
   {
      
      protected var m_collectionCode:String;
      
      protected var m_rewardData:Object;
      
      protected var m_congratsWindow:CongratsWindowLg = null;
      
      public function TLightningCollectionTradeIn(collectionCode:String)
      {
         super();
         this.m_collectionCode = collectionCode;
      }
      
      override public function perform() : void
      {
         signedCall("LightningCollectionsService.onStoreCollection",this.m_collectionCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var collection:Collection = null;
         var title:String = null;
         var message:String = null;
         var giftPath:String = null;
         if(result != null)
         {
            this.m_rewardData = result;
            if(this.m_rewardData.rewardItem)
            {
               Global.player.addGift(result.rewardItem);
            }
            if(this.m_rewardData.xp)
            {
               Global.player.xp += int(this.m_rewardData.xp);
            }
            if(this.m_rewardData.coins)
            {
               Global.player.gold += int(this.m_rewardData.coins);
            }
            collection = Global.farmGameSettingsManager.getCollectionByCode(this.m_collectionCode);
            title = ZLocUtils.t("Dialogs","LightningCollectionsCongratulationsTitle");
            message = ZLocUtils.t("Dialogs","LightningCollectionsCongratulationsBody",{"item":ZLocUtils.tk_pk(collection.friendlyName)});
            giftPath = Global.farmGameSettingsManager.getImageByName(collection.xml.tradeInReward.@gift,"icon");
            this.m_congratsWindow = new CongratsWindowLg(title,message,giftPath,giftPath,this.onShare);
            FarmStatsManager.count("dialog","lightningcollections-trade_in_collection","View");
            UI.displayPopup(this.m_congratsWindow,false);
         }
      }
      
      protected function onShare(event:MouseEvent) : void
      {
         if(this.m_congratsWindow)
         {
            this.m_congratsWindow.close();
         }
         FarmStatsManager.count("dialog","lightningcollections-trade_in_collection","Share");
         var collection:Collection = Global.farmGameSettingsManager.getCollectionByCode(this.m_collectionCode);
         var bundleData:Object = {
            "user":Global.player.firstName,
            "collection":collection.friendlyName,
            "reward_link":this.m_rewardData.rewardUrl,
            "images":[{
               "href":"{SN_APP_URL}" + this.m_rewardData.rewardUrl,
               "src":Global.getAssetURL("assets/newsfeed/collecting.png")
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory("LightningCollectionTradeIn",bundleData,[],false);
      }
   }
}

