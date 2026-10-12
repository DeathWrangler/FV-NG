package Managers
{
   import Classes.Building;
   import Classes.Decoration;
   import Classes.FeatureBuilding;
   import Classes.IOffboardResource;
   import Classes.MapResource;
   import Classes.RewardCreditsBuilding;
   import Classes.SimpleHarvestableResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.DeprecatorSettings;
   import Classes.ZItem.FarmItem;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Transactions.TDeprecateItem;
   import Transactions.TReplaceBuildingWithDeco;
   
   public class OffboardingManager
   {
      
      public function OffboardingManager()
      {
         super();
      }
      
      public static function createReplacementResource(decoName:String) : MapResource
      {
         var replacementItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(decoName);
         var itemClass:Class = replacementItem.getMapResourceClass();
         return new itemClass(decoName);
      }
      
      public static function handleOffBoarding(resource:MapResource, alreadyOffboard:Boolean, forceOffboard:Boolean = false, completeCallBack:Function = null, forceRetestOfPrereqs:Boolean = false) : Boolean
      {
         var offboardResource:IOffboardResource = null;
         var needsOffBoardingAndReplacement:Boolean = false;
         var replacementResource:MapResource = null;
         var position:Vector3 = null;
         var id:Number = NaN;
         var oldStorageBuilding:StorageBuilding = null;
         var newStorageBuilding:StorageBuilding = null;
         var result:Boolean = alreadyOffboard;
         if(!alreadyOffboard)
         {
            offboardResource = resource as IOffboardResource;
            needsOffBoardingAndReplacement = false;
            if(offboardResource)
            {
               needsOffBoardingAndReplacement = offboardResource.needsOffBoardingAndReplacement();
            }
            else
            {
               needsOffBoardingAndReplacement = OffboardingManager.needsOffBoardingAndReplacement(resource,forceRetestOfPrereqs);
            }
            result = true;
            if((needsOffBoardingAndReplacement || forceOffboard) && !Global.worldManager.isVisiting())
            {
               replacementResource = null;
               if(offboardResource)
               {
                  replacementResource = offboardResource.getOffboardingReplacementResource();
               }
               else
               {
                  replacementResource = OffboardingManager.getOffboardingReplacementResource(resource);
               }
               position = resource.getPosition();
               id = resource.getId();
               if(replacementResource)
               {
                  resource.detach();
                  if(resource.getItemName() == "snowmanbasket2011")
                  {
                     TransactionManager.addTransaction(new TReplaceBuildingWithDeco(resource as RewardCreditsBuilding),true);
                  }
                  else
                  {
                     TransactionManager.addTransaction(new TDeprecateItem(resource,replacementResource,completeCallBack),true);
                  }
                  replacementResource.setMetadata(resource.getMetadata());
                  replacementResource.attachToPersistentData(resource.persistentDataKey);
                  replacementResource.setOuter(Global.world);
                  replacementResource.setPosition(position.x,position.y,position.z);
                  replacementResource.setId(id);
                  if(replacementResource is Decoration)
                  {
                     (replacementResource as Decoration).setPlaced(true);
                  }
                  else if(resource is StorageBuilding && replacementResource is StorageBuilding)
                  {
                     oldStorageBuilding = resource as StorageBuilding;
                     newStorageBuilding = replacementResource as StorageBuilding;
                     if(newStorageBuilding.shouldCopyPartsWhenReplacing())
                     {
                        newStorageBuilding.copyParts(oldStorageBuilding);
                     }
                     if(newStorageBuilding.shouldCopyStorageWhenReplacing())
                     {
                        newStorageBuilding.copyStorage(oldStorageBuilding);
                     }
                     if(newStorageBuilding.shouldCopyPlantTimeWhenReplacing())
                     {
                        newStorageBuilding.plantTime = oldStorageBuilding.plantTime;
                     }
                     newStorageBuilding.setState(oldStorageBuilding.getState());
                  }
                  else if(replacementResource is Building)
                  {
                     (replacementResource as Building).setState(FeatureBuilding.STATE_BUILT);
                  }
                  else if(replacementResource is SimpleHarvestableResource)
                  {
                     (replacementResource as SimpleHarvestableResource).setState(FeatureBuilding.STATE_BARE);
                  }
                  replacementResource.conditionallyReattach(true);
                  replacementResource.update();
               }
               else
               {
                  result = false;
               }
            }
            else
            {
               result = false;
            }
         }
         return result;
      }
      
      public static function needsOffBoardingAndReplacement(resource:MapResource, forceRetestOfPrereqs:Boolean = false) : Boolean
      {
         var needOffboarding:Boolean = false;
         var deprecator:DeprecatorSettings = Global.farmGameSettingsManager.getDeprecatorSettings(resource.getItemName());
         if(Boolean(Global.player.isDataLoaded) && Boolean(deprecator) && deprecator.checkPrereqs(forceRetestOfPrereqs,resource))
         {
            needOffboarding = true;
         }
         return needOffboarding;
      }
      
      public static function getOffboardingReplacementResource(resource:MapResource) : MapResource
      {
         var resourceName:String = null;
         var newLevel:int = 0;
         var storageResource:StorageBuilding = null;
         var replacementFeatureBuilding:StorageBuilding = null;
         var replacementResource:MapResource = null;
         var deprecator:DeprecatorSettings = Global.farmGameSettingsManager.getDeprecatorSettings(resource.getItemName());
         if(deprecator != null)
         {
            resourceName = deprecator.getReplacement();
            if(resourceName != "")
            {
               replacementResource = OffboardingManager.createReplacementResource(resourceName);
               newLevel = deprecator.getReplacementLevel(resource.getCurrentImageName());
               storageResource = resource as StorageBuilding;
               if(newLevel == 0 && storageResource != null)
               {
                  newLevel = storageResource.storageLevel;
               }
               if(newLevel > 0)
               {
                  replacementFeatureBuilding = replacementResource as StorageBuilding;
                  if(replacementFeatureBuilding)
                  {
                     replacementFeatureBuilding.storageLevel = newLevel;
                  }
               }
            }
         }
         return replacementResource;
      }
   }
}

