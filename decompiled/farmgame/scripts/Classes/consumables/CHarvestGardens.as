package Classes.consumables
{
   import Classes.SimpleHarvestableResource;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   
   public class CHarvestGardens extends CHarvestBuildings
   {
      
      public function CHarvestGardens(itemName:String)
      {
         super(itemName);
      }
      
      override public function onFailedPerform() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","Consumable_Harvest_Blooms_Fail");
         UI.displayPopup(new GenericPopup(msg,GenericPopup.TYPE_YESNO,this.failedPerformCallback));
      }
      
      private function failedPerformCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            StatsManager.count("bloom","harvestAll","failed","AcceptInstantGrow");
            InstagrowUtils.tryShowInstagrowWindow("FailCHarvestBlooms");
         }
         else
         {
            StatsManager.count("bloom","harvestAll","failed","DenyInstantGrow");
         }
      }
      
      override protected function getHarvestables() : Array
      {
         return Global.world.getObjectsByCode("6aK");
      }
      
      override protected function canHarvest(harvestableResource:SimpleHarvestableResource) : Boolean
      {
         return harvestableResource.isHarvestable();
      }
   }
}

