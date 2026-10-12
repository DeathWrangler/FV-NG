package Classes
{
   import flash.utils.Dictionary;
   
   public class CreditCostInfo
   {
      
      private var m_canAfford:Boolean;
      
      private var m_missingCredits:Dictionary;
      
      private var m_totalCreditCost:int;
      
      private var m_costToComplete:int;
      
      public function CreditCostInfo(canAfford:Boolean, missingCredits:Dictionary, totalCreditCost:int, costToComplete:int)
      {
         super();
         this.m_canAfford = canAfford;
         this.m_missingCredits = missingCredits;
         this.m_totalCreditCost = totalCreditCost;
         this.m_costToComplete = costToComplete;
      }
      
      public function get canAfford() : Boolean
      {
         return this.m_canAfford;
      }
      
      public function get missingCredits() : Dictionary
      {
         return this.m_missingCredits;
      }
      
      public function get totalCreditCost() : int
      {
         return this.m_totalCreditCost;
      }
      
      public function get costToComplete() : int
      {
         return this.m_costToComplete;
      }
   }
}

