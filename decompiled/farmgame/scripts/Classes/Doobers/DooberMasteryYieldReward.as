package Classes.Doobers
{
   import Classes.FarmGameObject;
   
   public class DooberMasteryYieldReward extends DooberMasteryReward
   {
      
      public function DooberMasteryYieldReward(rewardXml:XML, actionObject:FarmGameObject)
      {
         super(rewardXml,actionObject);
         m_amount = NO_AMOUNT_SET;
      }
      
      override public function getAmount() : int
      {
         var result:int = super.getAmount();
         if(result == NO_AMOUNT_SET)
         {
            result = m_amount = m_itemMastery.calculateMasteryYield();
         }
         return result;
      }
   }
}

