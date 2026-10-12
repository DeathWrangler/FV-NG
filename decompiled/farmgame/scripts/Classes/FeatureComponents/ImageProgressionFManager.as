package Classes.FeatureComponents
{
   import Classes.Constants.XMLKeys;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   import Engine.Managers.ErrorManager;
   import Managers.FarmGameSettingsManager;
   import flash.utils.getDefinitionByName;
   
   public class ImageProgressionFManager extends FeatureManager implements IImageProgressionComponent
   {
      
      private var m_imageProgressionObject:IImageProgressionObject;
      
      private var m_objectTypes:Array;
      
      public function ImageProgressionFManager(owner:FeatureBuilding)
      {
         var ownerFarmItem:FarmItem = null;
         var featureData:BaseDataSource = null;
         var imageProgressionData:BaseDataSource = null;
         var imageProgressionClassName:String = null;
         var imageProgressionClass:Class = null;
         var featuresXML:XMLList = null;
         var imageProgressionFeature:XMLList = null;
         var imageProgressionObjectClass:String = null;
         var objClass:Class = null;
         this.m_objectTypes = [ImageProgressionFObject,WishingFountainImageProgressionFObject,WishingFountainWithAnimImageProgressionFObject,ImageProgressionFHarvestStateObject,ImageProgressionFLevelObject,BloomProgressionFObject,AmexImageProgressionFStateObject,GopherImageProgressionFObject,BushelBabyImageProgessionFObject,ConstructionProgressionFObject,FeatureCraftingImageProgressionFObject,DeferredImageProgressionFObject,RuntimeDrivenImageProgressionFObject,FlowerShackProgressionFObject];
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            ownerFarmItem = owner.getFarmItem();
            featureData = ownerFarmItem.getFeatureDataByName(FeatureManager.IMAGE_ADAPTER_FEATURE_NAME);
            if(featureData)
            {
               imageProgressionData = featureData.getData("imageProgressionObject");
               if(imageProgressionData)
               {
                  imageProgressionClassName = imageProgressionData.getString("className");
                  try
                  {
                     imageProgressionClass = getDefinitionByName(imageProgressionClassName) as Class;
                     this.m_imageProgressionObject = new imageProgressionClass(owner);
                  }
                  catch(error:Error)
                  {
                     ErrorManager.addError("ImageProgressionFManager cannot instantiate imageProgressionObjectClass:" + imageProgressionClassName);
                  }
               }
               else
               {
                  ErrorManager.addError("ImageProgressionFManager is missing imageProgressionObject in xml data for " + ownerFarmItem.name);
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            imageProgressionFeature = featuresXML.(@name == FeatureManager.IMAGE_ADAPTER_FEATURE_NAME);
            if(imageProgressionFeature != null)
            {
               if(imageProgressionFeature.hasOwnProperty("imageProgressionObject"))
               {
                  imageProgressionObjectClass = String(imageProgressionFeature.imageProgressionObject[XMLKeys.ATTR_CLASS_NAME]);
                  try
                  {
                     objClass = getDefinitionByName(imageProgressionObjectClass) as Class;
                     this.m_imageProgressionObject = new objClass(owner);
                  }
                  catch(error:Error)
                  {
                     ErrorManager.addError("ImageProgressionFManager cannot instantiate imageProgressionObjectClass:" + imageProgressionObjectClass);
                  }
               }
               else
               {
                  ErrorManager.addError("ImageProgressionFManager is missing imageProgressionObject in data xml");
               }
            }
         }
      }
      
      public function setProgression() : void
      {
         if(this.m_imageProgressionObject != null)
         {
            this.m_imageProgressionObject.setProgression();
         }
      }
      
      override public function onDetatch() : void
      {
         if(this.m_imageProgressionObject != null)
         {
            this.m_imageProgressionObject.onDetatch();
         }
      }
   }
}

FeatureCraftingImageProgressionFObject;

