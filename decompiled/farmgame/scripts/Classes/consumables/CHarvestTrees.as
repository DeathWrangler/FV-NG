package Classes.consumables
{
   import Classes.Constants.ToasterIconPaths;
   import Classes.SimpleHarvestableResource;
   import Classes.Tree;
   import Classes.util.ZLocUtils;
   import Managers.ToasterManager;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.geom.Point;
   
   public class CHarvestTrees extends CHarvestAllOfType
   {
      
      public function CHarvestTrees(itemName:String)
      {
         super(itemName);
      }
      
      override public function onFailedPerform() : void
      {
         var titleMsg:String = ZLocUtils.t("Dialogs","Consumable_Use_Fail_Title");
         var msg:String = ZLocUtils.t("Dialogs","Consumable_Harvest_Trees_Fail");
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.ARBOTRIST_ICON,"",ToasterIconPaths.DIALOG_ASSET,0.6,0.7,new Point(8,8),null,null));
      }
      
      override protected function getHarvestables() : Array
      {
         return Global.world.getObjectsByClass(Tree);
      }
      
      override protected function displayHarvestResults(totalCoinYield:uint, totalMasteryYield:int = 0) : void
      {
         var msg:String = null;
         var titleMsg:String = ZLocUtils.t("Dialogs","Consumable_Use_Title",{"coinQuantity":totalCoinYield});
         if(totalMasteryYield)
         {
            msg = ZLocUtils.t("Dialogs","Consumable_Harvest_Trees_Use_Mastery",{
               "coinQuantity":totalCoinYield,
               "quantity":totalMasteryYield
            });
         }
         else
         {
            msg = ZLocUtils.t("Dialogs","Consumable_Harvest_Trees_Use",{"coinQuantity":totalCoinYield});
         }
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.CONSUMECOIN_ICON,ToasterIconPaths.ARBOTRIST_ICON,ToasterIconPaths.DIALOG_ASSET,0.6,0.7,new Point(8,8),new Point(15,0),null));
      }
      
      override protected function canHarvest(harvestableResource:SimpleHarvestableResource) : Boolean
      {
         return harvestableResource.isHarvestable();
      }
   }
}

