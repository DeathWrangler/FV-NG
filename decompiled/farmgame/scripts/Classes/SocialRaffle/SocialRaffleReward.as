package Classes.SocialRaffle
{
   public class SocialRaffleReward
   {
      
      protected var m_itemName:String = "";
      
      protected var m_chance:Number = 0;
      
      protected var m_qty:Number = 0;
      
      protected var m_friendUid:String = "";
      
      protected var m_wonPrize:Boolean = false;
      
      protected var m_rewardLink:String = "";
      
      protected var m_hasProcessed:Boolean = false;
      
      public function SocialRaffleReward(itemName:String, chance:Number, qty:Number, friendUid:String = "", wonPrize:Boolean = false, rewardLink:String = "", hasProcessed:Boolean = false)
      {
         super();
         this.m_itemName = itemName;
         this.m_chance = chance;
         this.m_qty = qty;
         this.m_friendUid = friendUid;
         this.m_wonPrize = wonPrize;
         this.m_rewardLink = rewardLink;
         this.m_hasProcessed = hasProcessed;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get chance() : Number
      {
         return this.m_chance;
      }
      
      public function get qty() : Number
      {
         return this.m_qty;
      }
      
      public function get friendUid() : String
      {
         return this.m_friendUid;
      }
      
      public function get wonPrize() : Boolean
      {
         return this.m_wonPrize;
      }
      
      public function get rewardLink() : String
      {
         return this.m_rewardLink;
      }
      
      public function get hasProcessed() : Boolean
      {
         return this.m_hasProcessed;
      }
      
      public function set hasProcessed(hasProcessed:Boolean) : void
      {
         this.m_hasProcessed = hasProcessed;
      }
   }
}

