package Transactions.NeighborActions
{
   import Transactions.TFarmTransaction;
   
   public class TClearNeighborAction extends TFarmTransaction
   {
      
      private var m_neighborId:String;
      
      private var m_actionType:String;
      
      private var m_objectId:int;
      
      public function TClearNeighborAction(neighborId:String, actionType:String, objectId:int)
      {
         this.m_neighborId = neighborId;
         this.m_actionType = actionType;
         this.m_objectId = objectId;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("NeighborActionService.clearNeighborAction",this.m_neighborId,this.m_actionType,this.m_objectId);
      }
   }
}

