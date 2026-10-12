package Classes.Minigames
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ParseXMLUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import flash.utils.Dictionary;
   
   public class TokenPlayFeatureData extends BaseFeatureData
   {
      
      private static const TAG_TOKEN_PREFIX:String = "tokenPrefix";
      
      private static const TAG_TOKEN_COST:String = "tokenCost";
      
      private static const TAG_MAX_TICKETS:String = "maxTickets";
      
      private static const DEFAULT_TOKEN_COST:uint = 1;
      
      private static const DEFAULT_MAX_TICKETS:uint = 99999;
      
      private static const TAG_FREE_TOKEN_DELAY:String = "freeTokenDelay";
      
      private static const DEFAULT_FREE_TOKEN_DELAY:uint = 0;
      
      private static const TAG_MAX_DIFFICULTY:String = "maxDifficulty";
      
      private static const TAG_TICKET_REWARDS:String = "ticketRewards";
      
      private static const TAG_TICKET_REWARD:String = "ticketReward";
      
      private static const ATTRIB_GET_THIS_OR_MORE:String = "@getThisOrMore";
      
      private static const ATTRIB_TICKETS:String = "@tickets";
      
      private static const TICKET_REWARD_TYPE_SCORE:String = "score";
      
      private static const TICKET_REWARD_TYPE_DIFFICULTY:String = "difficulty";
      
      public static const DEFAULT_MAX_DIFFICULTY:uint = 1;
      
      private static const TAG_POWERUPS:String = "powerups";
      
      private static const TAG_POWERUP:String = "powerup";
      
      private static const ATTRIB_TYPE:String = "@type";
      
      public static const TAG_CASH_COST:String = "cashCost";
      
      public static const TAG_EFFECT:String = "effect";
      
      private var m_tokenPrefix:String = null;
      
      private var m_tokenCost:uint = 1;
      
      private var m_maxTickets:uint = 99999;
      
      private var m_freeTokenDelay:uint = 0;
      
      private var m_maxDifficulty:uint = 1;
      
      private var m_powerupsHash:Dictionary = null;
      
      private var m_ticketRewardsHash:Dictionary = new Dictionary();
      
      public function TokenPlayFeatureData(xml:XML, parent:MinigameData)
      {
         super(xml,parent);
      }
      
      public function get tokenPrefix() : String
      {
         return this.m_tokenPrefix;
      }
      
      public function get tokenCost() : uint
      {
         return this.m_tokenCost;
      }
      
      public function get maxTickets() : uint
      {
         return this.m_maxTickets;
      }
      
      public function get freeTokenDelay() : uint
      {
         return this.m_freeTokenDelay;
      }
      
      public function hasFreeTokenDelay() : Boolean
      {
         return this.m_freeTokenDelay > 0;
      }
      
      public function get maxDifficulty() : uint
      {
         return this.m_maxDifficulty;
      }
      
      public function get powerups() : Dictionary
      {
         return this.m_powerupsHash;
      }
      
      override protected function parseXML() : void
      {
         var curElement:uint = 0;
         var mulitpleTicketRewardsArrays:XMLList = null;
         var mulitpleticketRewardsArrayLength:uint = 0;
         var powerups:XMLList = null;
         var powerupsLength:int = 0;
         var tmpType:String = null;
         var tmpObject:Object = null;
         super.parseXML();
         if(m_rawXml)
         {
            this.m_tokenPrefix = ParseXMLUtil.parseRequiredString(m_rawXml,TAG_TOKEN_PREFIX);
            this.m_tokenCost = ParseXMLUtil.parseOptionalUInt(m_rawXml,TAG_TOKEN_COST,DEFAULT_TOKEN_COST);
            this.m_maxTickets = ParseXMLUtil.parseOptionalUInt(m_rawXml,TAG_MAX_TICKETS,DEFAULT_MAX_TICKETS);
            this.m_freeTokenDelay = ParseXMLUtil.parseOptionalUInt(m_rawXml,TAG_FREE_TOKEN_DELAY,DEFAULT_FREE_TOKEN_DELAY);
            this.m_maxDifficulty = ParseXMLUtil.parseOptionalUInt(m_rawXml,TAG_MAX_DIFFICULTY,DEFAULT_MAX_DIFFICULTY);
            curElement = 0;
            mulitpleTicketRewardsArrays = m_rawXml[TAG_TICKET_REWARDS];
            if(mulitpleTicketRewardsArrays)
            {
               mulitpleticketRewardsArrayLength = uint(mulitpleTicketRewardsArrays.length());
               for(curElement = 0; curElement < mulitpleticketRewardsArrayLength; curElement++)
               {
                  if(mulitpleTicketRewardsArrays[curElement].hasOwnProperty(ATTRIB_TYPE))
                  {
                     this.parseRewardsFromScoringArray(mulitpleTicketRewardsArrays[curElement][ATTRIB_TYPE],mulitpleTicketRewardsArrays[curElement][TAG_TICKET_REWARD]);
                  }
                  else
                  {
                     ErrorManager.addError("TokenPlayFeatureData.as: <" + TAG_TICKET_REWARDS + "> index " + curElement + " missing type= in xml.");
                  }
               }
            }
            if(m_rawXml.hasOwnProperty(TAG_POWERUPS) && m_rawXml[TAG_POWERUPS].hasOwnProperty(TAG_POWERUP))
            {
               this.m_powerupsHash = new Dictionary();
               powerups = m_rawXml[TAG_POWERUPS][TAG_POWERUP];
               powerupsLength = powerups.length();
               tmpType = null;
               tmpObject = null;
               for(curElement = 0; curElement < powerupsLength; curElement++)
               {
                  if(powerups[curElement].hasOwnProperty(ATTRIB_TYPE))
                  {
                     tmpType = ParseXMLUtil.parseRequiredString(powerups[curElement],ATTRIB_TYPE);
                     tmpObject = new Object();
                     if(powerups[curElement].hasOwnProperty(TAG_CASH_COST))
                     {
                        tmpObject[TAG_CASH_COST] = ParseXMLUtil.parseRequiredUInt(powerups[curElement],TAG_CASH_COST);
                     }
                     if(powerups[curElement].hasOwnProperty(TAG_EFFECT))
                     {
                        tmpObject[TAG_EFFECT] = ParseXMLUtil.parseRequiredString(powerups[curElement],TAG_EFFECT);
                     }
                     this.m_powerupsHash[tmpType] = tmpObject;
                  }
                  else
                  {
                     ErrorManager.addError("TokenPlayFeatureData.as: <" + TAG_POWERUP + "> index " + curElement + " missing type= in xml.");
                  }
               }
            }
            return;
         }
         throw new Error("Error: no <feature name=\"tokenPlay\"> in xml");
      }
      
      private function parseRewardsFromScoringArray(type:String, rewardsXMLList:XMLList) : void
      {
         var result:Array = new Array();
         var tmpObject:Object = null;
         var curElement:int = 0;
         var rewardsXMLListLength:int = rewardsXMLList.length();
         for(curElement = 0; curElement < rewardsXMLListLength; curElement++)
         {
            if(rewardsXMLList[curElement].hasOwnProperty(ATTRIB_GET_THIS_OR_MORE) && rewardsXMLList[curElement].hasOwnProperty(ATTRIB_TICKETS))
            {
               tmpObject = new Object();
               tmpObject[ATTRIB_GET_THIS_OR_MORE] = ParseXMLUtil.parseRequiredUInt(rewardsXMLList[curElement],ATTRIB_GET_THIS_OR_MORE);
               tmpObject[ATTRIB_TICKETS] = ParseXMLUtil.parseRequiredUInt(rewardsXMLList[curElement],ATTRIB_TICKETS);
               result.push(tmpObject);
            }
            else
            {
               ErrorManager.addError("TokenPlayFeatureData.as: index " + curElement + " missing " + ATTRIB_GET_THIS_OR_MORE + "= or " + ATTRIB_TICKETS + "= in xml " + rewardsXMLList[curElement]);
            }
         }
         result.sort(this.sortByGetThisOrMore);
         this.m_ticketRewardsHash[type] = result;
      }
      
      public function sortByGetThisOrMore(a:Object, b:Object) : int
      {
         var result:int = 0;
         if(a[ATTRIB_GET_THIS_OR_MORE] < b[ATTRIB_GET_THIS_OR_MORE])
         {
            result = -1;
         }
         if(a[ATTRIB_GET_THIS_OR_MORE] > b[ATTRIB_GET_THIS_OR_MORE])
         {
            result = 1;
         }
         return result;
      }
      
      public function get difficultyRewards() : Array
      {
         var result:Array = null;
         if(this.m_ticketRewardsHash.hasOwnProperty(TICKET_REWARD_TYPE_DIFFICULTY))
         {
            result = this.m_ticketRewardsHash[TICKET_REWARD_TYPE_DIFFICULTY];
         }
         return result;
      }
      
      public function get scoreRewards() : Array
      {
         var result:Array = null;
         if(this.m_ticketRewardsHash.hasOwnProperty(TICKET_REWARD_TYPE_SCORE))
         {
            result = this.m_ticketRewardsHash[TICKET_REWARD_TYPE_SCORE];
         }
         return result;
      }
      
      public function hasDifficultyRewards() : Boolean
      {
         return this.difficultyRewards != null;
      }
      
      public function hasScoreRewards() : Boolean
      {
         return this.scoreRewards != null;
      }
      
      public function getDifficultyTicketReward(difficulty:uint) : uint
      {
         return this.getTicketRewardsTypeArray(this.difficultyRewards,difficulty);
      }
      
      public function getScoreTicketReward(score:uint) : uint
      {
         return this.getTicketRewardsTypeArray(this.scoreRewards,score);
      }
      
      public function getTicketRewardsTypeArray(sortedArray:Array, score:uint) : uint
      {
         var len:uint = 0;
         var i:uint = 0;
         var result:uint = 0;
         if(sortedArray)
         {
            len = sortedArray.length;
            for(i = len - 1; i >= 0; i--)
            {
               if(score >= sortedArray[i][ATTRIB_GET_THIS_OR_MORE])
               {
                  result = uint(sortedArray[i][ATTRIB_TICKETS]);
                  break;
               }
            }
         }
         return result;
      }
      
      public function hasPowerup(powerupType:String) : Boolean
      {
         return Boolean(this.m_powerupsHash) && this.m_powerupsHash.hasOwnProperty(powerupType);
      }
      
      public function hasPowerupValue(powerupType:String, valueName:String) : Boolean
      {
         return Boolean(this.m_powerupsHash) && this.m_powerupsHash.hasOwnProperty(powerupType) && Boolean(this.m_powerupsHash[powerupType].hasOwnProperty(valueName));
      }
      
      public function getStringPowerupValue(powerupType:String, valueName:String) : String
      {
         var result:String = null;
         if(this.hasPowerupValue(powerupType,valueName))
         {
            result = this.m_powerupsHash[powerupType][valueName];
         }
         return result;
      }
      
      public function getUintPowerupValue(powerupType:String, valueName:String) : uint
      {
         var tmpStrValue:String = this.getStringPowerupValue(powerupType,valueName);
         return tmpStrValue != null ? uint(uint(tmpStrValue)) : 0;
      }
      
      public function getNumberPowerupValue(powerupType:String, valueName:String) : Number
      {
         var tmpStrValue:String = this.getStringPowerupValue(powerupType,valueName);
         return tmpStrValue != null ? Number(Number(tmpStrValue)) : NaN;
      }
      
      public function getPowerupCountChangeText(powerupType:String, delta:int) : String
      {
         var locToken:String = "_PowerupCountChangeAdd";
         if(delta < 0)
         {
            locToken = "_PowerupCountChangeSub";
         }
         return getFailOverText(locToken,{
            "delta":delta,
            "unit_name":this.getPowerupFriendlyName(powerupType)
         });
      }
      
      protected function getPowerupFriendlyName(powerupType:String) : String
      {
         return getFailOverText("_" + FarmGameUtil.toUpperCaseFirst(powerupType) + "Name");
      }
      
      public function getPowerupCostChangeText(powerupType:String) : String
      {
         var delta:Number = this.getNumberPowerupValue(powerupType,TAG_CASH_COST);
         return getFailOverText("_PowerupCostChangeSub",{
            "delta":-delta,
            "unit_name":ZLocUtils.t("FarmGame","Currency_FarmCash")
         });
      }
      
      public function getMaxTicketsReachedText(ticketsName:String) : String
      {
         return getFailOverText("_MaxTicketsReachedMessage",{
            "ticketsName":ticketsName,
            "maxTickets":this.maxTickets
         });
      }
   }
}

