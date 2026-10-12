package Classes
{
   import Classes.util.UserRewardUtil;
   import DataSources.BaseDataSource;
   
   public class QuestRewardHarvestYield extends HarvestYield
   {
      
      private var m_rewardAttributes:Object;
      
      public function QuestRewardHarvestYield(harvestYieldXML:XML, harvestYieldDS:BaseDataSource = null)
      {
         var rewardAttributesObj:Object = null;
         var key:String = null;
         var rewardAttributesList:XMLList = null;
         var numAttributes:int = 0;
         var rewardIdx:int = 0;
         var rewardAttribute:XML = null;
         var name:String = null;
         var value:String = null;
         this.m_rewardAttributes = {};
         super(harvestYieldXML,harvestYieldDS);
         if(harvestYieldDS)
         {
            rewardAttributesObj = harvestYieldDS.getAttributesHash();
            for each(key in rewardAttributesObj)
            {
               this.m_rewardAttributes[key] = rewardAttributesObj[key];
            }
         }
         else
         {
            rewardAttributesList = harvestYieldXML.attributes();
            numAttributes = rewardAttributesList.length();
            for(rewardIdx = 0; rewardIdx < numAttributes; rewardIdx++)
            {
               rewardAttribute = XML(rewardAttributesList[rewardIdx]);
               if(rewardAttribute)
               {
                  name = rewardAttribute.name();
                  value = rewardAttribute.valueOf();
                  this.m_rewardAttributes[name] = value;
               }
            }
         }
      }
      
      override public function applyReward(quantity:int = 10, multiplier:Number = 1, payload:SimpleHarvestableResource = null) : void
      {
         var rewards:Vector.<Object> = new Vector.<Object>();
         for(var rewardCount:int = 0; rewardCount < quantity; rewardCount++)
         {
            rewards.push(this.m_rewardAttributes);
         }
         UserRewardUtil.grantUserRewards(rewards);
      }
   }
}

