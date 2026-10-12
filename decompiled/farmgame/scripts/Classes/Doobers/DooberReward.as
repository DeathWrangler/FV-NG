package Classes.Doobers
{
   import Classes.Constants.DooberConstants;
   import Classes.Constants.XMLKeys;
   import Classes.FarmGameObject;
   
   public class DooberReward
   {
      
      protected static const NO_AMOUNT_SET:int = -1;
      
      protected var m_type:String = "";
      
      protected var m_actionObject:FarmGameObject;
      
      protected var m_amount:Number = 0;
      
      protected var m_itemCode:String = "";
      
      protected var m_iconUrl:String = "";
      
      private var m_action:String = "doober";
      
      public function DooberReward(rewardXml:XML, actionObject:FarmGameObject)
      {
         super();
         if(rewardXml.hasOwnProperty(XMLKeys.ATTR_TYPE))
         {
            this.m_type = rewardXml[XMLKeys.ATTR_TYPE];
         }
         if(actionObject)
         {
            this.m_actionObject = actionObject;
         }
         if(rewardXml.hasOwnProperty(XMLKeys.ATTR_AMOUNT))
         {
            this.m_amount = rewardXml[XMLKeys.ATTR_AMOUNT];
         }
         if(rewardXml.hasOwnProperty(XMLKeys.ATTR_ITEM_CODE))
         {
            this.m_itemCode = rewardXml[XMLKeys.ATTR_ITEM_CODE];
         }
         if(rewardXml.hasOwnProperty(XMLKeys.ATTR_ICON_URL))
         {
            this.m_iconUrl = rewardXml[XMLKeys.ATTR_ICON_URL];
         }
         if(rewardXml.hasOwnProperty(XMLKeys.ATTR_ACTION))
         {
            this.m_action = rewardXml[XMLKeys.ATTR_ACTION];
         }
      }
      
      public static function factory(rewardXml:XML, actionObject:FarmGameObject) : DooberReward
      {
         var result:DooberReward = null;
         if(rewardXml.hasOwnProperty("@type"))
         {
            switch(String(rewardXml.@type))
            {
               case DooberConstants.REWARD_ID_MASTERY:
                  result = new DooberMasteryReward(rewardXml,actionObject);
                  break;
               case DooberConstants.REWARD_ID_BUSHEL:
                  result = new DooberBushelReward(rewardXml,actionObject);
                  break;
               case DooberConstants.REWARD_ID_SWEEPSTAKES:
                  result = new DooberSweepstakesReward(rewardXml,actionObject);
                  break;
               case DooberConstants.REWARD_ID_COIN_YIELD:
                  result = new DooberCoinYieldReward(rewardXml,actionObject);
                  break;
               case DooberConstants.REWARD_ID_JADE_YIELD:
                  result = new DooberHarvestYieldReward(rewardXml,actionObject,DooberConstants.REWARD_ID_JADE_YIELD);
                  break;
               case DooberConstants.REWARD_ID_COCONUT_YIELD:
                  result = new DooberHarvestYieldReward(rewardXml,actionObject,DooberConstants.REWARD_ID_COCONUT_YIELD);
                  break;
               case DooberConstants.REWARD_ID_MASTERY_YIELD:
                  result = new DooberMasteryYieldReward(rewardXml,actionObject);
                  break;
               default:
                  result = new DooberReward(rewardXml,actionObject);
            }
         }
         return result;
      }
      
      public function isAvailable() : Boolean
      {
         return true;
      }
      
      public function applyReward() : void
      {
      }
      
      public function getIconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function getType() : String
      {
         return this.m_type;
      }
      
      public function getRewardView() : DooberRewardView
      {
         var result:DooberRewardView = null;
         switch(this.m_action)
         {
            case DooberConstants.ACTION_TYPE_HOOBER:
               result = new HooberRewardView(this.m_type,this.getAmount(),this.m_iconUrl);
               break;
            case DooberConstants.ACTION_TYPE_DOOBER:
            default:
               result = new DooberRewardView(this.m_type,this.getAmount(),this.m_iconUrl);
         }
         return result;
      }
      
      public function getAmount() : int
      {
         return this.m_amount;
      }
   }
}

