package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Managers.Requests2InterstitialManager;
   import Transactions.TGetFreeGiftsFriendsList;
   import Transactions.TSendRequest2Gifts;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   
   public class MFSFreeGiftsRoulette extends MFSSendGiftBase
   {
      
      private static const STATS_CATEGORY:String = "free_gifts_mfs";
      
      private static const DEFAULT_ITEM_CODE:String = "Zg";
      
      private var m_feedItem:FarmItem;
      
      public function MFSFreeGiftsRoulette(giftItems:Array, feedItem:FarmItem, source:String, completeCallback:Function, showFeedDialog:Boolean = false)
      {
         super(null,source,true,completeCallback,"FreeGiftWindow");
         m_giftItems = giftItems;
         this.m_feedItem = feedItem;
         if(m_giftItems == null || m_giftItems.length == 0)
         {
            ErrorManager.addError("Invalid giftItems passed to MFSFreeGifts!");
            m_giftItems.push(Global.farmGameSettingsManager.getFarmItemByCode(DEFAULT_ITEM_CODE));
         }
         if(showFeedDialog)
         {
            setFeedInterstitialExperiment(STATS_FLOW_NAME);
         }
      }
      
      override protected function addCornerContents() : void
      {
         addGiftSelector(m_giftItems);
      }
      
      override protected function addBackgroundScene() : void
      {
         var scene:ZwFrame = null;
         if(m_window.mc_scene)
         {
            scene = new ZwFrame(m_window.mc_scene);
            if(scene.element.mc_bg1)
            {
               scene.addWidget(new ZwWidget(scene.element.mc_bg1));
            }
            addWidget(scene);
         }
      }
      
      override protected function setWindowDescription() : void
      {
         var numFriends:int = 0;
         if(Boolean(m_window) && m_window.hasOwnProperty("txt_body"))
         {
            numFriends = int(m_friends[m_tabNames[m_currentTab]].length);
            m_descriptionTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_Message",{"friendCount":numFriends});
         }
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetFreeGiftsFriendsList(onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendRequest2Gifts(m_item.code,requestIds,Requests2InterstitialManager.R2INTERSTITIAL_TYPE_FREE_GIFTS,this.getStatsFlowName(),m_serverTime),true);
      }
      
      override protected function getStatsFlowName() : String
      {
         return STATS_CATEGORY;
      }
      
      override protected function switchFromMFSToFeed() : void
      {
         m_item = this.m_feedItem;
         switchFromMFSToFeedHelper();
         addCornerAvatar();
      }
   }
}

