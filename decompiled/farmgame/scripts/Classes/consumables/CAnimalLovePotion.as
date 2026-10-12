package Classes.consumables
{
   import Classes.Consumable;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   
   public class CAnimalLovePotion extends Consumable
   {
      
      public function CAnimalLovePotion(itemName:String)
      {
         super(itemName);
      }
      
      override public function canUse() : Boolean
      {
         var featureName:String = null;
         var worldBuildings:Array = null;
         var lovePotionItem:FarmItem = null;
         var message:GenericIconPopup = null;
         var lovePotionItem2:FarmItem = null;
         var message2:GenericIconPopup = null;
         var result:Boolean = false;
         var featureBuildings:Array = Global.world.getObjectsByClass(FeatureBuilding);
         var foundBuilding:Boolean = false;
         var validBreedBuildings:Array = Global.animalBreedingSettings.getFeatureNames();
         for each(featureName in validBreedBuildings)
         {
            worldBuildings = Global.world.getObjectsByName(featureName);
            if(worldBuildings.length > 0)
            {
               foundBuilding = true;
               break;
            }
         }
         if(foundBuilding)
         {
            lovePotionItem = Global.farmGameSettingsManager.getFarmItemByName("xuk_animal_love_potion");
            message = new GenericIconPopup(ZLocUtils.t("Dialogs","AnimalLovePotionUse_Success"),GenericPopup.TYPE_OK,null,lovePotionItem.icon,false,true,"",true,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,true);
            UI.displayPopup(message,false);
         }
         else
         {
            lovePotionItem2 = Global.farmGameSettingsManager.getFarmItemByName("xuk_animal_love_potion");
            message2 = new GenericIconPopup(ZLocUtils.t("Dialogs","AnimalLovePotionUse_Fail"),GenericPopup.TYPE_OK,null,lovePotionItem2.icon,false,true,"",true,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,true);
            UI.displayPopup(message2,false);
         }
         return result;
      }
      
      override public function onUse() : void
      {
      }
   }
}

