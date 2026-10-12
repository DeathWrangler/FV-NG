package Classes.Doobers
{
   import Classes.Constants.XMLKeys;
   import Classes.FarmGameObject;
   import Classes.Quest.PrerequisiteUtility;
   
   public class DooberChance
   {
      
      private var m_weight:Number = 0;
      
      private var m_rewards:Vector.<DooberReward>;
      
      private var m_experimentName:String = "";
      
      private var m_experimentVariant:int = 0;
      
      private var m_dailyLimit:Number = 0;
      
      private var m_firstTimeUserExpKey:String = null;
      
      private var m_firstTimeUserWeight:Number = 0;
      
      private var m_prereqName:String = "";
      
      public function DooberChance(dooberChanceXml:XML, actionObject:FarmGameObject)
      {
         var reward:XML = null;
         var dooberReward:DooberReward = null;
         super();
         if(dooberChanceXml.hasOwnProperty(XMLKeys.ATTR_WEIGHT))
         {
            this.m_weight = dooberChanceXml[XMLKeys.ATTR_WEIGHT];
         }
         if(dooberChanceXml.hasOwnProperty(XMLKeys.ATTR_EXPERIMENT))
         {
            this.m_experimentName = dooberChanceXml[XMLKeys.ATTR_EXPERIMENT];
            this.m_experimentVariant = 1;
            if(dooberChanceXml.hasOwnProperty(XMLKeys.ATTR_EXPERIMENT_VARIANT))
            {
               this.m_experimentVariant = int(dooberChanceXml[XMLKeys.ATTR_EXPERIMENT_VARIANT]);
            }
         }
         if(dooberChanceXml.hasOwnProperty(XMLKeys.ATTR_DAILY_LIMIT))
         {
            this.m_dailyLimit = dooberChanceXml[XMLKeys.ATTR_DAILY_LIMIT];
         }
         if(dooberChanceXml.hasOwnProperty(XMLKeys.ATTR_FTUE_KEY))
         {
            this.m_firstTimeUserExpKey = dooberChanceXml[XMLKeys.ATTR_FTUE_KEY];
         }
         if(dooberChanceXml.hasOwnProperty(XMLKeys.ATTR_FTUE_WEIGHT))
         {
            this.m_firstTimeUserWeight = dooberChanceXml[XMLKeys.ATTR_FTUE_WEIGHT];
         }
         if(dooberChanceXml.hasOwnProperty(XMLKeys.ATTR_PREREQUISITE))
         {
            this.m_prereqName = dooberChanceXml[XMLKeys.ATTR_PREREQUISITE];
         }
         this.m_rewards = new Vector.<DooberReward>();
         for each(reward in dooberChanceXml.reward)
         {
            dooberReward = DooberReward.factory(reward,actionObject);
            if(dooberReward.isAvailable())
            {
               this.m_rewards.push(dooberReward);
            }
         }
      }
      
      public function isAvailable() : Boolean
      {
         var result:Boolean = this.getRewards().length > 0;
         if(this.m_experimentName != "" && Global.experimentManager.getExperimentVariant(this.m_experimentName) != this.m_experimentVariant)
         {
            result = false;
         }
         if(this.m_prereqName != "")
         {
            result &&= PrerequisiteUtility.checkPrereqByName(this.m_prereqName);
         }
         return result;
      }
      
      public function getFtueWeight() : Number
      {
         return this.m_firstTimeUserWeight;
      }
      
      public function getDailyLimit() : Number
      {
         return this.m_dailyLimit;
      }
      
      public function getExperiment() : String
      {
         return this.m_experimentName;
      }
      
      public function isFtueAvailable() : Boolean
      {
         var result:Boolean = false;
         if(null != this.m_firstTimeUserExpKey && "" != this.m_firstTimeUserExpKey)
         {
            if(!Global.player.getSeenFlag(this.m_firstTimeUserExpKey))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getFtueKey() : String
      {
         return this.m_firstTimeUserExpKey;
      }
      
      public function getWeight() : Number
      {
         return this.m_weight;
      }
      
      public function getRewards() : Vector.<DooberReward>
      {
         return this.m_rewards;
      }
   }
}

