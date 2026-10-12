package Transactions.NeighborActions
{
   import Classes.ZItem.FarmItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Events.GenericPopupEvent;
   import Managers.ToasterManager;
   import Transactions.TWorldState;
   import Widgets.Windows.GoodieBagToasterWindow;
   
   public class TBaseNeighborAction extends TWorldState
   {
      
      protected var m_actionType:String;
      
      protected var m_hostId:String;
      
      protected var m_extraParams:Object;
      
      public function TBaseNeighborAction(worldObj:WorldObject, extraParams:Object = null)
      {
         var hostId:String = Global.worldManager.getVisiting();
         if(Boolean(hostId) && hostId.length > 1)
         {
            this.m_hostId = hostId;
            canPerform = true;
         }
         else
         {
            canPerform = false;
         }
         this.m_extraParams = extraParams;
         super(worldObj);
      }
      
      override public function perform() : void
      {
         signedWorldAction("neighborAct",{
            "hostId":this.m_hostId,
            "actionType":this.m_actionType,
            "extraParams":this.m_extraParams
         });
      }
      
      override protected function onComplete(result:Object) : void
      {
         var giftItem:FarmItem = null;
         if(result.hasOwnProperty("staleFarm") && result.staleFarm == "true")
         {
            this.handleStaleFarm(result);
         }
         else if(Boolean(result.goodieBagRewardItemCode) && Boolean(result.fertilizeRewardLink))
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByCode(result.goodieBagRewardItemCode);
            if(giftItem)
            {
               Global.player.addGift(giftItem.name);
               ToasterManager.getInstance().add(new GoodieBagToasterWindow(this.m_hostId,giftItem,result.fertilizeRewardLink));
            }
         }
      }
      
      private function handleStaleFarm(result:Object) : void
      {
         if(result.hasOwnProperty("cash"))
         {
            Global.player.cash = result.cash;
         }
         if(result.hasOwnProperty("gold"))
         {
            Global.player.gold = result.gold;
         }
         if(result.hasOwnProperty("xp"))
         {
            Global.player.calculateAndAddXp(result.xp - Global.player.xp,false);
         }
         if(result.hasOwnProperty("level"))
         {
            Global.player.level = result.level;
         }
         if(Global.worldManager.isVisiting())
         {
            UI.displayPopup(new GenericPopup("Your neighbor is working on their farm right now. Come back soon when it\'s ready.",GenericPopup.TYPE_OK,this.handleStaleFarmCallback));
         }
      }
      
      public function handleStaleFarmCallback(event:GenericPopupEvent) : void
      {
         Global.worldManager.goHome();
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = "neighborAct";
         result.actionType = this.m_actionType;
         return result;
      }
   }
}

