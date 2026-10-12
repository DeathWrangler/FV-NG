package Transactions
{
   import Classes.TicketPartyBuilding;
   import Managers.FarmStatsManager;
   import flash.utils.getQualifiedClassName;
   
   public class TTradeInTicketPartyBuilding extends TWorldState
   {
      
      protected var m_completeCallback:Function = null;
      
      public function TTradeInTicketPartyBuilding(building:TicketPartyBuilding, completeCallBack:Function = null)
      {
         this.m_completeCallback = completeCallBack;
         super(building);
      }
      
      override public function perform() : void
      {
         var className:String = null;
         if(m_object)
         {
            className = getQualifiedClassName(m_object);
            FarmStatsManager.count("TTradeInTicketPartyBuilding",className);
         }
         signedWorldAction("tradeInTicketPartyBuilding");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_completeCallback != null)
         {
            this.m_completeCallback();
         }
      }
   }
}

