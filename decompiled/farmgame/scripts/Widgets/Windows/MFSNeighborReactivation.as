package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Engine.Managers.TransactionManager;
   import Managers.Requests2InterstitialManager;
   import Transactions.TGetReactivateFriends;
   import Transactions.TSendRequest2Gifts;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   
   public class MFSNeighborReactivation extends MFSSendGiftBase
   {
      
      private static const STATS_CATEGORY:String = "neighbor_react_mfs";
      
      public function MFSNeighborReactivation(giftItem:FarmItem, source:String, completeCallback:Function)
      {
         super(giftItem,source,true,completeCallback,"NeighborReactWindow");
      }
      
      override protected function addCornerContents() : void
      {
         if(m_window.mc_reactivation)
         {
            addWidget(new ZwWidget(m_window.mc_reactivation));
         }
      }
      
      override protected function addBackgroundScene() : void
      {
         var scene:ZwFrame = null;
         if(m_window.mc_scene)
         {
            scene = new ZwFrame(m_window.mc_scene);
            if(scene.element.mc_bg3)
            {
               scene.addWidget(new ZwWidget(scene.element.mc_bg3));
            }
            addWidget(scene);
         }
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetReactivateFriends(onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendRequest2Gifts(m_item.code,requestIds,Requests2InterstitialManager.R2INTERSTITIAL_TYPE_REACTIVATION,this.getStatsFlowName(),m_serverTime),true);
      }
      
      override protected function getStatsFlowName() : String
      {
         return STATS_CATEGORY;
      }
   }
}

