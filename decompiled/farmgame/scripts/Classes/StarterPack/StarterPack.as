package Classes.StarterPack
{
   public class StarterPack
   {
      
      private var m_name:String;
      
      private var m_cost:Number;
      
      private var m_gifts:Array;
      
      private var m_value:Number;
      
      private var m_purchaseCode:String;
      
      public function StarterPack(name:String, cost:Number, value:Number, purchaseCode:String, gifts:Array = null)
      {
         super();
         this.m_name = name;
         this.m_cost = cost;
         this.m_value = value;
         this.m_purchaseCode = purchaseCode;
         if(gifts == null)
         {
            this.m_gifts = new Array();
         }
         else
         {
            this.m_gifts = gifts;
         }
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get cost() : Number
      {
         return this.m_cost;
      }
      
      public function get value() : Number
      {
         return this.m_value;
      }
      
      public function get purchaseCode() : String
      {
         return this.m_purchaseCode;
      }
      
      public function get gifts() : Array
      {
         return this.m_gifts;
      }
      
      public function addGift(gift:Object) : void
      {
         this.m_gifts.push(gift);
      }
   }
}

