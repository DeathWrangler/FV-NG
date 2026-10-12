package Classes.storage
{
   import Classes.ZItem.FarmItem;
   import Managers.HangingGardensManager;
   
   public class PartItem
   {
      
      private var m_item:FarmItem;
      
      private var m_qtyNeeded:int = 0;
      
      private var m_requestType:String;
      
      public var onHand:int = 0;
      
      private var m_currency:String = null;
      
      private var m_friendlyName:String = null;
      
      public function PartItem(item:FarmItem, qtyNeeded:int, requestType:String = null)
      {
         super();
         this.m_item = item;
         this.m_qtyNeeded = qtyNeeded;
         this.m_requestType = requestType;
      }
      
      public function get requestType() : String
      {
         return this.m_requestType;
      }
      
      public function get item() : FarmItem
      {
         return this.m_item;
      }
      
      public function get qtyNeeded() : int
      {
         return this.m_qtyNeeded;
      }
      
      public function getCurrency() : String
      {
         return this.m_currency;
      }
      
      public function set currency(curr:String) : void
      {
         if(HangingGardensManager.isInHangingGardensExperiment())
         {
            this.m_currency = curr;
         }
      }
      
      public function get friendlyName() : String
      {
         if(this.m_friendlyName == null)
         {
            if(this.m_currency != null)
            {
               this.m_friendlyName = "Items:" + this.m_currency + "_friendlyName";
            }
            else
            {
               this.m_friendlyName = this.m_item.friendlyName;
            }
         }
         return this.m_friendlyName;
      }
      
      public function toString() : String
      {
         return "{name:" + this.item.name + " needed:" + this.m_qtyNeeded + " onHand:" + this.onHand + "}";
      }
   }
}

