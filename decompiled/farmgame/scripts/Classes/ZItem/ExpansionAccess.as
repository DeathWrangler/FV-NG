package Classes.ZItem
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   
   public class ExpansionAccess
   {
      
      public static const TYPE_EARLY:String = "earlyAccess";
      
      public static const TYPE_GENERAL:String = "generalAccess";
      
      public static const TYPE_CONTENT_EARLY:String = "contentEarlyAccess";
      
      public static const TYPE_ALL:String = "allAccess";
      
      public static const TYPE_ACCESS:String = "access";
      
      private static const ATTR_CASH_COST:String = "@cashCost";
      
      private static const ATTR_COIN_COST:String = "@coinCost";
      
      private static const ATTR_EXPANSION_TYPE:String = "@type";
      
      private static const ATTR_OPTION_ID:String = "@id";
      
      private static const ATTR_OPTION_CURRENCY:String = "@currency";
      
      private static const ATTR_OPTION_AMOUNT:String = "@amount";
      
      private var m_type:String;
      
      private var m_prereqs:Array;
      
      private var m_rewards:Vector.<Object>;
      
      private var m_cashCost:int;
      
      private var m_coinCost:int;
      
      private var m_motdSeenFlag:String;
      
      private var m_options:Object;
      
      private var m_EAEndDate:String;
      
      public function ExpansionAccess(xml:XML)
      {
         var optionList:XMLList = null;
         var option:XML = null;
         var optionData:Object = null;
         var optionRewardList:XMLList = null;
         var rewardList:XMLList = null;
         var prereq:Object = null;
         super();
         if(xml.name().toString() == TYPE_ACCESS)
         {
            this.m_options = new Object();
            if(xml.hasOwnProperty(ATTR_EXPANSION_TYPE))
            {
               this.m_type = String(xml[ATTR_EXPANSION_TYPE]);
            }
            if(xml.prereqs)
            {
               this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.children());
            }
            optionList = xml.options;
            for each(option in optionList.children())
            {
               optionData = {
                  "currency":option[ATTR_OPTION_CURRENCY],
                  "amount":option[ATTR_OPTION_AMOUNT]
               };
               optionRewardList = option.rewards;
               if(optionRewardList.length() > 0)
               {
                  optionData["rewards"] = this.processXMLList(optionRewardList.children());
               }
               if(option.prereqs)
               {
                  optionData["prereqs"] = PrerequisiteUtility.parseXmlNodePrereqs(option.prereqs.children());
               }
               this.m_options[option[ATTR_OPTION_ID]] = optionData;
            }
         }
         else
         {
            this.m_type = xml.name().toString();
            if(xml.prereqs)
            {
               this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.children());
               prereq = Global.farmGameSettingsManager.getPrereqByName(this.m_prereqs[0].value);
               this.m_EAEndDate = this.getDataFromPrereq(prereq,"end_time");
            }
            rewardList = xml.rewards;
            if(rewardList.length() > 0)
            {
               this.m_rewards = this.processXMLList(rewardList.children());
            }
            if(xml.hasOwnProperty(ATTR_CASH_COST))
            {
               this.m_cashCost = parseInt(xml[ATTR_CASH_COST]);
            }
            else
            {
               this.m_cashCost = 0;
            }
            if(xml.motdSeenFlag)
            {
               this.m_motdSeenFlag = xml.motdSeenFlag.toString();
            }
         }
      }
      
      public static function isAccessTypeNode(xml:XML) : Boolean
      {
         return xml.name() == TYPE_EARLY || xml.name() == TYPE_GENERAL || xml.name() == TYPE_ALL || xml.name() == TYPE_CONTENT_EARLY || xml.name() == TYPE_ACCESS;
      }
      
      public function get motdSeenFlag() : String
      {
         return this.m_motdSeenFlag;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get prereqs() : Array
      {
         return this.m_prereqs;
      }
      
      public function get rewards() : Vector.<Object>
      {
         return this.m_rewards;
      }
      
      public function get cashCost() : int
      {
         return this.m_cashCost;
      }
      
      public function get coinCost() : int
      {
         return this.m_coinCost;
      }
      
      public function getOptionCost(optionId:String = null) : int
      {
         var cost:int = 0;
         if(this.m_options.hasOwnProperty(optionId) && Boolean(this.m_options[optionId].hasOwnProperty("amount")))
         {
            cost = int(this.m_options[optionId].amount);
         }
         return cost;
      }
      
      public function getOptionCurrency(optionId:String = null) : String
      {
         var currency:String = "";
         if(this.m_options.hasOwnProperty(optionId) && Boolean(this.m_options[optionId].hasOwnProperty("currency")))
         {
            currency = this.m_options[optionId].currency;
         }
         return currency;
      }
      
      public function getOptionRewards(optionId:String = null) : Vector.<Object>
      {
         var rewards:Vector.<Object> = null;
         if(this.m_options.hasOwnProperty(optionId) && Boolean(this.m_options[optionId].hasOwnProperty("rewards")))
         {
            rewards = this.m_options[optionId].rewards;
         }
         return rewards;
      }
      
      public function checkOptionPrereqs(optionId:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_options.hasOwnProperty(optionId) && Boolean(this.m_options[optionId].hasOwnProperty("prereqs")))
         {
            result = PrerequisiteUtility.arePrerequisitesMet(this.m_options[optionId].prereqs);
         }
         return result;
      }
      
      public function checkPrereqs() : Boolean
      {
         return PrerequisiteUtility.arePrerequisitesMet(this.prereqs);
      }
      
      private function processXMLList(nodeList:XMLList) : Vector.<Object>
      {
         var node:XML = null;
         var objToAdd:Object = null;
         var attributes:XMLList = null;
         var attribute:XML = null;
         var result:Vector.<Object> = new Vector.<Object>();
         for each(node in nodeList)
         {
            objToAdd = new Object();
            attributes = node.attributes();
            for each(attribute in attributes)
            {
               objToAdd[String(attribute.name())] = String(attribute);
            }
            result.push(objToAdd);
         }
         return result;
      }
      
      private function getDataFromPrereq(prereq:Object, type:String) : String
      {
         var child:Object = null;
         var result:String = null;
         for each(child in prereq.children_from_xml)
         {
            if(child.type == type)
            {
               result = child.value;
               break;
            }
         }
         return result;
      }
      
      public function get daysLeft() : int
      {
         var timeLeftArr:Array = null;
         var daysLeft:int = -1;
         var startTimeMS:Number = FarmGameUtil.synchronizedDateToNumber(this.m_EAEndDate);
         var timeToUnlockMS:Number = (startTimeMS - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(timeToUnlockMS > 0)
         {
            timeLeftArr = FarmGameUtil.parseTimeLeft(timeToUnlockMS);
            daysLeft = int(timeLeftArr[0]);
         }
         return daysLeft;
      }
      
      public function getDaysLeft(numberOfDays:int = 7) : int
      {
         var result:Number = NaN;
         var startDate:String = this.getStartDate();
         var startDateEpoch:Number = FarmGameUtil.synchronizedDateToNumber(startDate);
         result = (numberOfDays * FarmGameUtil.NUM_MSECS_IN_DAY + startDateEpoch - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_DAY;
         return Math.floor(result);
      }
      
      public function getStartDate() : String
      {
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName(this.m_prereqs[0].value);
         return this.getDataFromPrereq(prereq,"start_time");
      }
   }
}

