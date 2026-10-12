package Classes
{
   import Classes.ZItem.ChangeFarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericFrictionlessBuyPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TExpandFarm;
   
   public class ExpansionAreaMapTrigger extends MapTrigger
   {
      
      private var m_nextExpansionChangeFarmItem:ChangeFarmItem;
      
      private var m_diffX:int = 0;
      
      private var m_diffY:int = 0;
      
      public function ExpansionAreaMapTrigger(itemName:String, diffX:int, diffY:int)
      {
         super(itemName);
         this.m_diffX = diffX;
         this.m_diffY = diffY;
         this.m_nextExpansionChangeFarmItem = Global.worldManager.getNextExpansion(true);
      }
      
      override public function loadObject(data:Object) : void
      {
         data["position"]["x"] += this.m_diffX;
         data["position"]["y"] += this.m_diffX;
         super.loadObject(data);
      }
      
      override public function onClick() : void
      {
         var buyAskPopup:GenericFrictionlessBuyPopup = null;
         var itemName:String = ZLocUtils.tk_pk_asTitle(this.getItemFriendlyName());
         var message:String = ZLocUtils.t("Dialogs","ExpansionAreaMapTrigger_message",{"treasure":itemName});
         if(this.m_nextExpansionChangeFarmItem.cash.toString() != "0")
         {
            buyAskPopup = new GenericFrictionlessBuyPopup(message,GenericPopup.TYPE_FRICTIONLESS_BUY,this.onWindowClose,this.m_nextExpansionChangeFarmItem.icon,false,true,"",true,GenericFrictionlessBuyPopup.GENERIC_FRICTIONLESS_BUY_ASSET,null,false,this.m_nextExpansionChangeFarmItem.cash.toString());
            buyAskPopup.setAcceptTextName("ExpandFarm");
            UI.displayPopup(buyAskPopup);
         }
         FarmStatsManager.count("fixed_treasure",this.getItemName(),"expansion","clicked",this.getTrackingId());
      }
      
      private function onWindowClose(event:GenericPopupEvent) : void
      {
         var cashCost:int = 0;
         if(event.button == GenericPopup.ACCEPT)
         {
            cashCost = this.m_nextExpansionChangeFarmItem.cash;
            if(Global.player.canBuyCash(cashCost,true,this.m_nextExpansionChangeFarmItem.type))
            {
               TransactionManager.addTransaction(new TExpandFarm(this.m_nextExpansionChangeFarmItem.cashName),true);
               FarmStatsManager.count("fixed_treasure",this.getItemName(),"expansion","buy_clicked",this.getTrackingId());
            }
         }
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         return false;
      }
      
      override public function isSellable() : Boolean
      {
         return false;
      }
      
      override public function isClearable() : Boolean
      {
         return false;
      }
      
      private function getTrackingId() : String
      {
         return this.m_position.x.toString() + "_" + this.m_position.y.toString() + "_" + this.m_outer.getGridWidth().toString();
      }
   }
}

