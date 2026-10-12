package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.SimpleHarvestableResource;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmVillageManager;
   import flash.events.Event;
   
   public class FarmVillageResourceBuildingHarvestFManager extends HarvestFManager implements IHarvestComponent
   {
      
      private const FONT_COLOR:uint = 16776960;
      
      private const PLUS_ONE:String = "GenericPlusOne";
      
      public function FarmVillageResourceBuildingHarvestFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function canAcceptHarvestReward() : Boolean
      {
         var result:Boolean = super.canAcceptHarvestReward();
         if(Global.player.craftingState.inventoryState.isVillageStorageFull)
         {
            result = false;
         }
         return result;
      }
      
      override public function displayMessageForUnclaimableHarvestReward() : void
      {
         super.displayMessageForUnclaimableHarvestReward();
         FarmVillageManager.instance.onExpandStorage();
      }
      
      override public function getHarvestArrow() : Class
      {
         return SimpleHarvestableResource.YELLOW_ARROW;
      }
      
      override public function onPreHarvest() : void
      {
         super.onPreHarvest();
         Global.player.avatar.displayStatus(ZLocUtils.t("Dialogs",this.PLUS_ONE,{"item":ZLocUtils.tk_pk_asTitle(harvestReward.friendlyName)}),harvestReward.icon,null,UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,this.FONT_COLOR);
         Global.stage.dispatchEvent(new Event(FarmVillageManager.ORDER_BOARD_REFRESH_EVENT));
      }
   }
}

