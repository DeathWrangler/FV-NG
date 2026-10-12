package Transactions
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   
   public class TMove extends TWorldState
   {
      
      protected var m_params:Object;
      
      protected var m_item:FarmItem;
      
      public function TMove(object:MapResource, params:Object)
      {
         this.m_params = params;
         this.m_item = object.getItem();
         this.m_params.visiting = Global.worldManager.getVisiting().toString();
         super(object);
      }
      
      override public function perform() : void
      {
         signedWorldAction("move",this.m_params);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = "move";
         result.item = this.m_item;
         return result;
      }
   }
}

