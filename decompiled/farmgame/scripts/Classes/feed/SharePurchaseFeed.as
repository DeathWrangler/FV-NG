package Classes.feed
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Transactions.TCancelFriendReward;
   
   public class SharePurchaseFeed extends FarmFeed
   {
      
      protected var m_item:FarmItem;
      
      public function SharePurchaseFeed(itemName:String, rewardUrl:String)
      {
         super();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         m_params.item = this.m_item.friendlyName;
         m_params.reward_link = rewardUrl;
      }
      
      public function startFeedFlow() : void
      {
         var message:String = null;
         if(this.m_item)
         {
            message = ZLocUtils.t("Dialogs","SharePurchaseItem_" + this.m_item.name);
            UI.displayMessage(message,GenericPopup.TYPE_SHARECANCEL,this.onSharePurchaseFeed);
         }
      }
      
      private function onSharePurchaseFeed(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         var icon:String = null;
         var startIcon:String = null;
         var featureBuilding:FeatureBuilding = null;
         var worldObjects:Array = null;
         var worldObject:FeatureBuilding = null;
         var showFeed:String = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            params = new Object();
            m_params.titleText = "Notifications:BuyItemShare_ShortStory_Title_" + this.m_item.name;
            m_params.item = this.m_item.friendlyName;
            m_params.bodyText = "Notifications:BuyItemShare_ShortStory_Body_" + this.m_item.name;
            m_params.actionText = "Notifications:BuyItemShare_Action_" + this.m_item.name;
            icon = this.m_item.icon;
            startIcon = this.m_item.getImageByName("startIcon");
            if(startIcon != null && startIcon != "")
            {
               icon = startIcon;
            }
            m_params.images = [{
               "src":icon,
               "href":"{SN_APP_URL}" + m_params.reward_link
            }];
            GlobalEngine.socialNetwork.publishFeedStory("BuyItemShare",m_params,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([m_params.reward_link]));
         }
         if(this.m_item.className == "FeatureBuilding")
         {
            featureBuilding = null;
            worldObjects = Global.world.getObjectsByName(this.m_item.name);
            var _loc9_:int = 0;
            var _loc10_:* = worldObjects;
            for each(worldObject in _loc10_)
            {
               featureBuilding = worldObject;
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               showFeed = this.m_item.getStringFromDataSource("shareFeed");
            }
            else
            {
               showFeed = this.m_item.xml.attribute("shareFeed");
            }
            if(showFeed == "true" && featureBuilding != null)
            {
               featureBuilding.displayStorageDialog();
            }
         }
      }
   }
}

