package Transactions
{
   import Classes.Pet;
   
   public class TPetItemRequestEvent extends TWorldState
   {
      
      private var m_itemName:String = null;
      
      public function TPetItemRequestEvent(pet:Pet, itemName:String)
      {
         super(pet);
         this.m_itemName = itemName;
      }
      
      override public function perform() : void
      {
         signedWorldAction("askForFood",{"itemName":this.m_itemName});
      }
   }
}

