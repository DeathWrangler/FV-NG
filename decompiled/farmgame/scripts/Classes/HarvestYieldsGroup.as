package Classes
{
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import flash.utils.Dictionary;
   
   public class HarvestYieldsGroup
   {
      
      private var m_yieldsGroup:Dictionary;
      
      public function HarvestYieldsGroup()
      {
         super();
         this.m_yieldsGroup = new Dictionary();
      }
      
      public function get harvestYields() : Dictionary
      {
         return this.m_yieldsGroup;
      }
      
      public function applyHarvestYieldsForItem(harvestableItem:HarvestableItem, quantity:int = 1, multiplier:Number = 1, payload:SimpleHarvestableResource = null) : void
      {
         var harvestYields:Vector.<HarvestYield> = null;
         var yieldIdx:int = 0;
         if(harvestableItem)
         {
            harvestYields = harvestableItem.harvestYields;
            for(yieldIdx = 0; yieldIdx < harvestYields.length; yieldIdx++)
            {
               this.applyHarvestYield(harvestYields[yieldIdx],quantity,multiplier,payload);
            }
         }
         else
         {
            ErrorManager.addError("HarvestYieldsGroup.applyHarvestYieldsForItem - invalid harvestableItem.");
         }
      }
      
      public function applyHarvestYield(harvestYield:HarvestYield, quantity:int = 1, multiplier:Number = 1, payload:SimpleHarvestableResource = null) : void
      {
         if(harvestYield)
         {
            harvestYield.applyReward(quantity,multiplier,payload);
            multiplier *= Global.player.getWorldCurrencyMultiplier(harvestYield.type);
            if(null == this.m_yieldsGroup[harvestYield.type])
            {
               this.m_yieldsGroup[harvestYield.type] = 0;
            }
            this.m_yieldsGroup[harvestYield.type] += Math.ceil(harvestYield.yield * quantity * multiplier);
         }
         else
         {
            ErrorManager.addError("HarvestYieldsGroup.applyHarvestYield - invalid harvestYield");
         }
      }
      
      public function getStatus() : String
      {
         var type:String = null;
         var result:String = "";
         for(type in this.m_yieldsGroup)
         {
            if(this.m_yieldsGroup[type] > 0)
            {
               result += Math.floor(this.m_yieldsGroup[type]);
               result += " ";
               result += ZLocUtils.t("FarmGame",type);
               result += ", ";
            }
         }
         return result;
      }
      
      public function getDooberStatus() : String
      {
         var type:String = null;
         var result:String = "";
         for(type in this.m_yieldsGroup)
         {
            if(this.m_yieldsGroup[type] > 0)
            {
               result += "+";
               result += Math.floor(this.m_yieldsGroup[type]);
               result += " ";
               result += ZLocUtils.t("FarmGame",type);
               result += " ";
            }
         }
         return ZLocUtils.t("FarmGame","Status_HarvestYieldStyling",{"status":result});
      }
      
      public function merge(groupToMerge:HarvestYieldsGroup) : void
      {
         var type:String = null;
         var yieldsToMerge:Dictionary = groupToMerge.harvestYields;
         for(type in yieldsToMerge)
         {
            this.m_yieldsGroup[type] = this.m_yieldsGroup[type] ? this.m_yieldsGroup[type] + yieldsToMerge[type] : yieldsToMerge[type];
         }
      }
   }
}

