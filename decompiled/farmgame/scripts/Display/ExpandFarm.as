package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TSeenExpandFarm;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ExpandFarm extends Dialog
   {
      
      private var m_farmName:String;
      
      private var m_seenExpandFarm:int = 0;
      
      private var m_accept:GenericButton;
      
      private const EXPANSION_POPUP:String = "expansion_popup";
      
      public function ExpandFarm(farmSize:int, seenExpandFarm:int, modal:Boolean = true)
      {
         m_dialogAsset = "assets/dialogs/FV_ExpandFarm.swf";
         this.m_farmName = "farm" + farmSize;
         this.m_seenExpandFarm = seenExpandFarm;
         super(modal);
      }
      
      override protected function onLoadComplete() : void
      {
         var farmItem:FarmItem;
         var cost:String;
         var url:String;
         var icon:Loader = null;
         super.onLoadComplete();
         farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_farmName);
         m_window.expandFarm_mc.congratulations_tf.text = ZLocUtils.t("Dialogs","Congratulations");
         m_window.expandFarm_mc.youCan_tf.text = ZLocUtils.t("Dialogs","YouCanExpand");
         m_window.expandFarm_mc.youNeed_tf.text = ZLocUtils.t("Dialogs","YouNeedNeighbors",{"quantity":farmItem.minNeighbors});
         cost = Utilities.formatNumber(farmItem.cost);
         m_window.expandFarm_mc.cost_tf.text = ZLocUtils.t("Dialogs","Cost",{
            "coinQuantity":cost,
            "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",int(cost))
         });
         url = farmItem.icon;
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               Utilities.removeAllChildren(m_window.expandFarm_mc.expandFarmImage_mc);
               dispObj = icon.content;
               dispObj.width = 80;
               dispObj.height = 80;
               m_window.expandFarm_mc.expandFarmImage_mc.addChild(dispObj);
            }
         });
         this.m_accept = new GenericButton(m_window.expandFarm_mc.add_bt,this.onAddClick);
         this.m_accept.text = ZLocUtils.t("Dialogs","Expand");
         m_window.expandFarm_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.expandFarm_mc.skip_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         FarmStatsManager.count(this.EXPANSION_POPUP,"view");
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         event.stopPropagation();
         close();
         m_window.expandFarm_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.expandFarm_mc.skip_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         ++this.m_seenExpandFarm;
         TransactionManager.addTransaction(new TSeenExpandFarm(this.m_seenExpandFarm));
      }
      
      private function onAddClick(event:MouseEvent) : void
      {
         ++this.m_seenExpandFarm;
         this.onCloseClick(event);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_farmName);
         var canBuy:Boolean = Global.player.canBuy(farmItem.cost,false);
         var hasNeighbors:Boolean = Global.player.checkNeighbors(farmItem.minNeighbors);
         if(canBuy == false && hasNeighbors == false)
         {
            FarmStatsManager.count(this.EXPANSION_POPUP,"click_add","fail_all");
         }
         else if(canBuy == false)
         {
            FarmStatsManager.count(this.EXPANSION_POPUP,"click_add","fail_coins");
         }
         else if(hasNeighbors == false)
         {
            FarmStatsManager.count(this.EXPANSION_POPUP,"click_add","fail_neighbors");
         }
         else
         {
            FarmStatsManager.count(this.EXPANSION_POPUP,"click_add","success");
         }
         MFSRequestManager.getInstance().displayR2AddNeighborWindow("neighborsExpansionPage");
      }
   }
}

