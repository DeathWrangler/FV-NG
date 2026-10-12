package Classes.FeatureComponents
{
   import Classes.Constants.Experiments;
   import Classes.Constants.XMLKeys;
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   import Engine.Classes.World;
   import Engine.Utilities;
   import Events.FarmGameWorldEvent;
   import Managers.FarmGameSettingsManager;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.getDefinitionByName;
   
   public class FeaturedRenderFManager extends FeatureManager implements IRenderComponent
   {
      
      public static const FEATURED_ITEM_DEFAULT:String = "default";
      
      public static const MAX_ITEMS_DEFAULT:Number = 5;
      
      public static const FEATURED_ITEM_MOST_RECENT:String = "most_recent";
      
      public static const PROGRESS_COUNT_MASTERY:String = "mastery";
      
      public static const PROGRESS_COUNT_CONTENTS:String = "contents";
      
      public static const PROGRESS_COUNT_LEVEL:String = "levels";
      
      private const DEFAULT_FONT:String = "Merkin2";
      
      private const DEFAULT_FONT_SIZE:int = 12;
      
      private const DEFAULT_FONT_COLOR:int = 16777215;
      
      private const TEXTFIELD_WIDTH:int = 32;
      
      private const TEXTFIELD_HEIGHT:int = 16;
      
      private const TEXTFIELD_Y_OFFSET:int = -5;
      
      protected var m_maxItems:Number = 0;
      
      protected var m_insertionMode:String = "";
      
      protected var m_propPointPrefix:String = "";
      
      protected var m_itemSwf:String = "";
      
      protected var m_itemScale:Number = 1;
      
      protected var m_renderObjectClass:String = "Classes.FeatureComponents.FeaturedRenderFObject";
      
      protected var m_textRenderMethod:String = "";
      
      private var m_deferredCall:Boolean = false;
      
      protected var m_featuredObjects:Array;
      
      private var m_objectTypes:Array;
      
      public function FeaturedRenderFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var featureMaxItems:Number = NaN;
         var renderObjectData:BaseDataSource = null;
         var textRenderFieldData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var renderFeature:XMLList = null;
         var maxItems:Number = NaN;
         this.m_featuredObjects = [];
         this.m_objectTypes = [FeaturedRenderFObject,FeaturedRenderFMutableObject,FeaturedRenderFUGCObject,FeaturedRenderFBloomObject,FeatureRenderFTreasureObject];
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.RENDERING_FEATURE_NAME);
            if(featureData)
            {
               featureMaxItems = featureData.getNumber("maxItems");
               if(featureMaxItems <= 0)
               {
                  this.m_maxItems = MAX_ITEMS_DEFAULT;
               }
               else
               {
                  this.m_maxItems = featureMaxItems;
               }
               this.m_insertionMode = featureData.getString("insertionMode");
               this.m_propPointPrefix = featureData.getString("propPointPrefix");
               this.m_itemSwf = featureData.getString("itemSwf");
               this.m_itemScale = featureData.getNumber("itemScale");
               renderObjectData = featureData.getData("renderObject");
               if(renderObjectData)
               {
                  this.m_renderObjectClass = renderObjectData.getString("className");
               }
               textRenderFieldData = featureData.getData("textRenderField");
               if(textRenderFieldData)
               {
                  this.m_textRenderMethod = textRenderFieldData.getString("type");
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            renderFeature = featuresXML.(@name == FeatureManager.RENDERING_FEATURE_NAME);
            if(renderFeature != null)
            {
               maxItems = Number(renderFeature.maxItems);
               this.m_maxItems = maxItems <= 0 ? MAX_ITEMS_DEFAULT : maxItems;
               this.m_insertionMode = String(renderFeature.insertionMode);
               this.m_propPointPrefix = String(renderFeature.propPointPrefix);
               this.m_itemSwf = String(renderFeature.itemSwf);
               this.m_itemScale = Number(renderFeature.itemScale);
               if(renderFeature.hasOwnProperty("renderObject"))
               {
                  this.m_renderObjectClass = String(renderFeature.renderObject[XMLKeys.ATTR_CLASS_NAME]);
               }
               if(renderFeature.hasOwnProperty("textRenderField"))
               {
                  this.m_textRenderMethod = String(renderFeature.textRenderField[XMLKeys.ATTR_TYPE]);
               }
            }
         }
      }
      
      private function isTileAsset(item:FarmItem) : Boolean
      {
         var result:Boolean = false;
         switch(item && item.className)
         {
            case "MultiRewardTreasureConstructionBuilding":
            case "MultiRewardTreasurePayerConstructionBuilding":
            case "MultiRewardTreasurePayerBundleConstructionBuilding":
            case "MultiRewardTreasurePayerLandBundleConstructionBuilding":
            case "LandBundleUnlockFeatureTreasureConstructionBuilding":
               result = true;
               break;
            default:
               result = false;
         }
         return result;
      }
      
      private function updateBuildingDisplay() : void
      {
         var featuredSlotIndex:String = null;
         var featuredSlot:Object = null;
         var itemName:String = null;
         var metaData:Object = null;
         var objClass:Class = null;
         var renderedObj:FeaturedRenderFObject = null;
         var featuredItems:Object = owner.getFeaturedItems();
         for(featuredSlotIndex in featuredItems)
         {
            featuredSlot = featuredItems[featuredSlotIndex];
            if(featuredSlot != null)
            {
               itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(featuredSlot.itemCode);
               metaData = owner.getStorageMetaDataForHash(featuredSlot.metaHash);
               objClass = getDefinitionByName(this.m_renderObjectClass) as Class;
               renderedObj = new objClass(itemName,owner,String(metaData));
               renderedObj.itemSwf = this.m_itemSwf;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TILE_MEMORY_REDUCTION) > 0 && this.isTileAsset(owner.getFarmItem()))
               {
                  renderedObj.itemScale = this.m_itemScale / (Global.flashHotParams.hasOwnProperty("TILE_ASSET_SCALE") ? Number(Global.flashHotParams["TILE_ASSET_SCALE"]) : 0.5);
               }
               else
               {
                  renderedObj.itemScale = this.m_itemScale;
               }
               renderedObj.setOuter(owner.getOuter() as World);
               this.m_featuredObjects[featuredSlotIndex] = renderedObj;
            }
         }
      }
      
      public function setState(state:String, featuredItems:Object = null) : void
      {
         var featuredObj:FeaturedRenderFObject = null;
         var featuredObject:FeaturedRenderFObject = null;
         if(featuredItems != null)
         {
            for each(featuredObject in this.m_featuredObjects)
            {
               featuredObject = null;
            }
            this.m_featuredObjects = [];
            this.updateBuildingDisplay();
         }
         for each(featuredObj in this.m_featuredObjects)
         {
            featuredObj.setState(state);
         }
      }
      
      public function updateTransforms() : void
      {
         var featuredObject:FeaturedRenderFObject = null;
         for each(featuredObject in this.m_featuredObjects)
         {
            featuredObject.updateDisplayObjectTransform();
         }
      }
      
      public function updateDisplay() : void
      {
         var propIndex:int = 0;
         var propPointName:String = null;
         var propPoint:MovieClip = null;
         var featuredObject:FeaturedRenderFObject = null;
         if(owner.content is MovieClip)
         {
            for(propIndex = 0; propIndex < this.m_maxItems; propIndex++)
            {
               propPointName = this.m_propPointPrefix + "PropPoint_" + propIndex;
               if(owner.content.hasOwnProperty(propPointName))
               {
                  propPoint = owner.content[this.m_propPointPrefix + "PropPoint_" + propIndex];
                  if(propPoint)
                  {
                     while(propPoint.numChildren > 0)
                     {
                        propPoint.removeChildAt(0);
                     }
                     if(this.m_featuredObjects.hasOwnProperty(propIndex))
                     {
                        featuredObject = this.m_featuredObjects[propIndex];
                        propPoint.addChild(featuredObject.itemDisplayWrapper);
                     }
                  }
               }
            }
            this.updateBuildingTextField();
         }
         owner.conditionallyRedraw(true);
      }
      
      public function updateFeaturedObjects(delta:Number) : void
      {
         var featuredObject:FeaturedRenderFObject = null;
         for(var propIndex:int = 0; propIndex < this.m_maxItems; propIndex++)
         {
            if(this.m_featuredObjects.hasOwnProperty(propIndex))
            {
               if(this.m_featuredObjects[propIndex] is FeaturedRenderFObject)
               {
                  featuredObject = this.m_featuredObjects[propIndex];
                  if(featuredObject is FeaturedRenderFMutableObject)
                  {
                     if(featuredObject.isVisible())
                     {
                        featuredObject.onUpdate(delta);
                     }
                  }
               }
            }
         }
      }
      
      protected function updateBuildingTextField() : void
      {
         if(Boolean(Global.player) && Global.player.isDataLoaded)
         {
            this.attachTextField();
         }
         else if(!this.m_deferredCall)
         {
            this.m_deferredCall = true;
            Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.deferredAttachTextField,false,0,true);
         }
      }
      
      public function deferredAttachTextField(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,this.deferredAttachTextField);
         this.m_deferredCall = false;
         this.attachTextField();
      }
      
      protected function attachTextField() : void
      {
         var propPoint:MovieClip = null;
         var textString:String = null;
         var renderTextField:TextField = null;
         var txtFormat:TextFormat = null;
         var masteryType:String = null;
         var propPointName:String = "textPropPoint_0";
         if(Boolean(this.m_textRenderMethod) && Boolean(this.m_textRenderMethod != "") && owner.content.hasOwnProperty(propPointName))
         {
            propPoint = owner.content[propPointName];
            renderTextField = new TextField();
            txtFormat = new TextFormat(this.DEFAULT_FONT,this.DEFAULT_FONT_SIZE,this.DEFAULT_FONT_COLOR);
            Utilities.removeAllChildren(propPoint);
            txtFormat.align = TextFormatAlign.CENTER;
            renderTextField.embedFonts = true;
            renderTextField.width = this.TEXTFIELD_WIDTH;
            renderTextField.height = this.TEXTFIELD_HEIGHT;
            renderTextField.defaultTextFormat = txtFormat;
            renderTextField.setTextFormat(txtFormat);
            renderTextField.y = this.TEXTFIELD_Y_OFFSET;
            propPoint.addChild(renderTextField);
            switch(this.m_textRenderMethod)
            {
               case PROGRESS_COUNT_CONTENTS:
                  textString = String(owner.count);
                  break;
               case PROGRESS_COUNT_MASTERY:
                  masteryType = Global.farmGameSettingsManager.getString(owner.featureName + "MasteryType");
                  textString = String(Global.player.getMasteredCountByType(masteryType));
                  break;
               default:
                  textString = "X";
            }
            renderTextField.text = textString;
            owner.conditionallyRedraw(true);
         }
      }
      
      public function updateCulling() : void
      {
         var featuredObject:FeaturedRenderFObject = null;
         for each(featuredObject in this.m_featuredObjects)
         {
            featuredObject.updateCulling();
         }
      }
      
      public function get maxItems() : Number
      {
         return this.m_maxItems;
      }
      
      public function get insertionMode() : String
      {
         return this.m_insertionMode;
      }
      
      public function render() : void
      {
         var featuredObject:FeaturedRenderFObject = null;
         if(this.m_featuredObjects.length == 0 && owner.getFeaturedItems() != null)
         {
            this.updateBuildingDisplay();
         }
         for each(featuredObject in this.m_featuredObjects)
         {
            if(featuredObject is FeaturedRenderFUGCObject)
            {
               this.updateBuildingDisplay();
               break;
            }
         }
         for each(featuredObject in this.m_featuredObjects)
         {
            featuredObject.drawDisplayObject();
         }
      }
      
      public function findEmptyFeatureSlot() : int
      {
         var i:int = 0;
         var slot:int = -1;
         var insertionMode:String = "";
         var featuredItems:Object = owner.getFeaturedItems();
         switch(this.m_insertionMode)
         {
            case FeaturedRenderFManager.FEATURED_ITEM_MOST_RECENT:
               slot = this.m_maxItems - 1;
               break;
            default:
               for(i = 0; i < this.m_maxItems; i++)
               {
                  if(!(featuredItems.hasOwnProperty(i.toString()) && featuredItems[i.toString()] != null))
                  {
                     slot = i;
                     break;
                  }
               }
         }
         return slot;
      }
      
      public function addItem(resource:MapResource) : void
      {
         var lastSlot:int = 0;
         var iAvailable:* = 0;
         var i:int = 0;
         var emptySlot:Number = NaN;
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(resource.getItemName());
         var item:FarmItem = resource.getItem();
         var featuredItems:Object = owner.featuredItems;
         var metaKey:String = resource.getMetadataKey();
         if(metaKey == "" || metaKey == null)
         {
            metaKey = FeatureBuilding.buildMetaDataHash(itemCode,"");
         }
         if(!item.isBuildingPart())
         {
            switch(this.insertionMode)
            {
               case FeaturedRenderFManager.FEATURED_ITEM_MOST_RECENT:
                  lastSlot = this.maxItems - 1;
                  if(featuredItems[lastSlot] != null)
                  {
                     for(iAvailable = lastSlot; iAvailable > 0; iAvailable--)
                     {
                        if(featuredItems[iAvailable] == null)
                        {
                           break;
                        }
                     }
                     for(i = iAvailable; i < lastSlot; i++)
                     {
                        if(featuredItems[i] != null)
                        {
                           owner.setFeaturedItem(i,featuredItems[i].itemCode,featuredItems[i].metaHash,false,false);
                        }
                        if(featuredItems[i + 1] != null)
                        {
                           owner.setFeaturedItem(i,featuredItems[i + 1].itemCode,featuredItems[i + 1].metaHash,true,false);
                        }
                     }
                     owner.setFeaturedItem(lastSlot,featuredItems[lastSlot].itemCode,featuredItems[lastSlot].metaHash,false,false);
                  }
                  owner.setFeaturedItem(lastSlot,itemCode,metaKey,true,false);
                  owner.saveFeaturedItems();
                  break;
               default:
                  emptySlot = this.findEmptyFeatureSlot();
                  if(emptySlot >= 0)
                  {
                     owner.setFeaturedItem(emptySlot,itemCode,metaKey,true,true);
                  }
            }
         }
      }
      
      public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0, metaHashRemoved:String = "") : void
      {
         var featuredSlot:Number = this.findFeaturedItem(itemCode,metaHashRemoved);
         if(featuredSlot >= 0)
         {
            owner.setFeaturedItem(featuredSlot,itemCode,metaHashRemoved,false,false);
            this.refillFeaturedSlot(featuredSlot);
            owner.saveFeaturedItems();
         }
      }
      
      private function findFeaturedItem(itemCode:String, metaHash:String) : Number
      {
         var featuredItem:Object = null;
         var invalidHash:Boolean = false;
         if(metaHash == "" || metaHash == null)
         {
            metaHash = FeatureBuilding.buildMetaDataHash(itemCode,metaHash);
         }
         var index:Number = -1;
         var featuredItems:Object = owner.getFeaturedItems();
         for(var i:int = 0; i < this.maxItems; i++)
         {
            featuredItem = featuredItems[i];
            if(featuredItem != null)
            {
               invalidHash = featuredItem.metaHash == featuredItem.itemCode || itemCode == metaHash;
               if(featuredItem.itemCode == itemCode && (featuredItem.metaHash == metaHash || invalidHash))
               {
                  index = i;
                  break;
               }
            }
         }
         return index;
      }
      
      private function refillFeaturedSlot(featuredSlot:Number) : void
      {
         var storageDataForCode:Array = null;
         var metaArray:Array = null;
         var lookUpSlot:Number = NaN;
         var parsedHash:Array = null;
         var qty:Number = NaN;
         var metaData:Object = null;
         var foundResult:Boolean = false;
         var key:String = null;
         var j:int = 0;
         if(this.insertionMode == FeaturedRenderFManager.FEATURED_ITEM_MOST_RECENT && featuredSlot >= 0 && featuredSlot < this.maxItems)
         {
            storageDataForCode = null;
            metaArray = null;
            lookUpSlot = 0;
            parsedHash = null;
            qty = 0;
            metaData = {};
            foundResult = false;
            for(key in owner.contents)
            {
               if(foundResult)
               {
                  break;
               }
               qty = Number(owner.contents[key]);
               storageDataForCode = owner.getStorageMetaDataForCode(key);
               for(j = 0; j < qty; j++)
               {
                  metaData = null;
                  if(storageDataForCode != null && storageDataForCode.length > 0)
                  {
                     metaData = storageDataForCode.pop();
                  }
                  if(metaData == null || metaData.key == null)
                  {
                     metaData = {};
                     metaData.key = FeatureBuilding.buildMetaDataHash(key,"");
                  }
                  lookUpSlot = this.findFeaturedItem(key,metaData.key);
                  if(lookUpSlot < 0)
                  {
                     owner.setFeaturedItem(featuredSlot,key,metaData.key,true,false);
                     foundResult = true;
                     break;
                  }
               }
            }
         }
      }
   }
}

