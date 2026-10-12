package Classes.FeatureComponents
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   
   public class IrrigationWellTooltipFManager extends FeatureManager implements ITooltipComponent
   {
      
      public function IrrigationWellTooltipFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function getTooltip() : String
      {
         var waterHarvestCount:int = (m_owner.harvester as WaterHarvestFManager).getWaterHarvestAmountForCurrentLevel();
         var hourCount:int = Math.ceil(m_owner.getGrowTime() / FarmGameUtil.NUM_MSECS_IN_HOUR);
         var stageCount:int = m_owner.storageLevel - 1;
         var replacements:Object = {
            "stage":stageCount,
            "count":waterHarvestCount,
            "time":hourCount
         };
         return ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"irrigationWellTooltip_text",replacements);
      }
   }
}

