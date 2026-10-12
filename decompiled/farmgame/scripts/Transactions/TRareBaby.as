package Transactions
{
   public class TRareBaby extends TFarmTransaction
   {
      
      public static const TYPE_SEEDLING:String = "premiumseedling";
      
      public static const TYPE_BABY_ANIMAL:String = "premiumbaby";
      
      private var m_babyType:String;
      
      private var m_callback:Function;
      
      public function TRareBaby(type:String = "premiumseedling", callback:Function = null)
      {
         this.m_babyType = type;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("RareBabyService.buyMysteryBaby",this.m_babyType);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            Global.player.addGift(this.m_babyType);
            Global.world.enterForcePlaceMode(this.m_babyType,false,-1,false,true);
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

