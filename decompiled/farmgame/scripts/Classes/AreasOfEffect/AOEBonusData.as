package Classes.AreasOfEffect
{
   public class AOEBonusData
   {
      
      protected var m_bonusMultiplierTypes:Object = {};
      
      protected var m_bonusCumulativeTypes:Object = {};
      
      protected var m_numSources:int = 0;
      
      protected var m_bonusToolTipType:String;
      
      protected var m_locKey:String;
      
      protected var m_possibleVisStates:Array;
      
      public function AOEBonusData(bonusMultiplierTypes:Object, bonusCumulativeTypes:Object, numSources:int, toolTipType:String, locKey:String)
      {
         super();
         this.m_bonusMultiplierTypes = bonusMultiplierTypes;
         this.m_bonusCumulativeTypes = bonusCumulativeTypes;
         this.m_numSources = numSources;
         this.m_bonusToolTipType = toolTipType;
         this.m_locKey = locKey;
         this.m_possibleVisStates = null;
      }
      
      public function get bonusMultiplierTypes() : Object
      {
         return this.m_bonusMultiplierTypes;
      }
      
      public function get bonusCumulativeTypes() : Object
      {
         return this.m_bonusCumulativeTypes;
      }
      
      public function get numSources() : int
      {
         return this.m_numSources;
      }
      
      public function get bonusToolTipType() : String
      {
         return this.m_bonusToolTipType;
      }
      
      public function get possibleStates() : Array
      {
         return this.m_possibleVisStates;
      }
      
      public function set possibleStates(possStates:Array) : void
      {
         this.m_possibleVisStates = possStates;
      }
      
      public function get locKey() : String
      {
         return this.m_locKey;
      }
   }
}

