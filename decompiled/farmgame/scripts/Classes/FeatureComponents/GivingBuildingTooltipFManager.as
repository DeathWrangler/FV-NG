package Classes.FeatureComponents
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.BuildingItem;
   import Classes.util.ZLocUtils;
   
   public class GivingBuildingTooltipFManager extends FeatureManager implements ITooltipComponent
   {
      
      public function GivingBuildingTooltipFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function getTooltip() : String
      {
         var partName:String = owner.expand.getExpansionPartString();
         var partCount:int = Global.player.getGiftCountForItem(partName);
         var res:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,(m_owner.getItem() as BuildingItem).buildingName + "Tooltip",{"count":partCount});
         if(res == null || res == "")
         {
            res = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HollybrightTreeTooltip",{"count":partCount});
         }
         return res;
      }
   }
}

