package Transactions
{
   public class TFishing extends TFarmTransaction
   {
      
      public static const CAST_BOBBER:String = "castBobber";
      
      public static const EQUIP_ROD:String = "equipRod";
      
      public static const EQUIP_BAIT:String = "equipBait";
      
      public static const EQUIP_BUFF:String = "equipBuff";
      
      public static const MINIGAME_BONUS:String = "minigameBonus";
      
      public static const BUY_MASTERY:String = "buyMastery";
      
      private var m_type:String;
      
      private var m_callback:Function;
      
      private var m_extraData:Object;
      
      public function TFishing(type:String, extraData:Object, callback:Function = null)
      {
         super();
         this.m_type = type;
         this.m_extraData = extraData;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("FishingService." + this.m_type,this.m_extraData);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

