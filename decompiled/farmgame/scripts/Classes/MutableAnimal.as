package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.DefconManager;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Windows.Breeding.BreedingRenameWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   
   public class MutableAnimal extends Animal
   {
      
      protected static const DEFAULT_PATTERN_NAME:String = "plain";
      
      protected var m_assetName:String = "";
      
      protected var m_baseHSV:Array = [];
      
      protected var m_patternHSV:Array = [];
      
      protected var m_animateBase:Boolean = false;
      
      protected var m_animatePattern:Boolean = false;
      
      protected var m_lastTime:int;
      
      protected var m_contentReplaced:Boolean = false;
      
      protected var m_mutableAnimalState:MutableAnimalState = null;
      
      private var m_useAnimalBase:Boolean = false;
      
      public function MutableAnimal(animalType:String = null, metadata:String = null)
      {
         super(animalType);
         if(Boolean(metadata) && metadata != "null")
         {
            this.setMutableAnimalStateFromMetaData(metadata);
         }
         else
         {
            this.setDefaultMutableAnimalState();
         }
         this.fromMarket = !Global.animalBreedingSettings.isLimitedItem(animalType);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.hasOwnProperty("mutableAnimalState") && data.mutableAnimalState != null)
         {
            this.m_mutableAnimalState = new MutableAnimalState("",data.mutableAnimalState.dna,"");
         }
         if(Boolean(this.m_mutableAnimalState) && this.m_mutableAnimalState.isValid())
         {
            this.setAnimalState();
         }
         else
         {
            this.setDefaultMutableAnimalState();
         }
      }
      
      public function setMutableAnimalStateFromMetaData(metadata:String) : void
      {
         this.m_mutableAnimalState = MutableAnimalState.createFromPhpString("",metadata);
         this.setAnimalState();
      }
      
      private function setDefaultMutableAnimalState() : void
      {
         var jsonVariant:String = Global.animalBreedingSettings.getVariantJSONByItemName(this.m_itemName,this.m_itemName);
         if(jsonVariant != "" && jsonVariant != null && jsonVariant != "null")
         {
            this.setMutableAnimalStateFromMetaData(jsonVariant);
         }
         else
         {
            this.setRandomAnimalState();
         }
      }
      
      public function setMutableAnimalState(mutableAnimalState:MutableAnimalState) : void
      {
         this.m_mutableAnimalState = mutableAnimalState;
         this.setAnimalState();
      }
      
      protected function setAnimalState() : void
      {
         this.m_useAnimalBase = false;
         if(this.m_mutableAnimalState.hue() < 240)
         {
            this.m_animateBase = false;
            this.m_baseHSV = [this.m_mutableAnimalState.hue() / 40,this.m_mutableAnimalState.saturation() / 15,this.m_mutableAnimalState.intensity() / 15];
         }
         else
         {
            this.m_animateBase = true;
            this.m_baseHSV = [int(Math.random() * 240) / 40,this.m_mutableAnimalState.saturation() / 15,this.m_mutableAnimalState.intensity() / 15];
         }
         if(this.m_mutableAnimalState.hue(true) < 240)
         {
            this.m_animatePattern = false;
            this.m_patternHSV = [this.m_mutableAnimalState.hue(true) / 40,this.m_mutableAnimalState.saturation(true) / 15,this.m_mutableAnimalState.intensity(true) / 15];
         }
         else
         {
            this.m_animatePattern = true;
            this.m_patternHSV = [int(Math.random() * 240) / 40,this.m_mutableAnimalState.saturation(true) / 15,this.m_mutableAnimalState.intensity(true) / 15];
         }
         var featureName:String = Global.animalBreedingSettings.getFeatureNameByItem(this.getItem().name);
         m_pattern = Global.animalBreedingSettings.getPatternTrait(featureName,this.m_mutableAnimalState.pattern);
      }
      
      public function setRandomAnimalState() : void
      {
         this.m_useAnimalBase = false;
         this.m_animateBase = Math.random() < 0.01;
         if(this.m_animateBase)
         {
            this.m_baseHSV = [int(Math.random() * 240) / 40,int(4 + Math.random() * 12) / 15,int(4 + (1 - Math.pow(Math.random(),2)) * 12) / 15];
         }
         else
         {
            this.m_baseHSV = [int(Math.random() * 240) / 40,int(Math.random() * 16) / 15,int((1 - Math.pow(Math.random(),2)) * 16) / 15];
         }
         this.m_animatePattern = Math.random() < 0.01;
         if(this.m_animatePattern)
         {
            this.m_patternHSV = [int(Math.random() * 240) / 40,int(4 + Math.random() * 12) / 15,int(4 + Math.random() * 12) / 15];
         }
         else
         {
            this.m_patternHSV = [int(Math.random() * 240) / 40,int(Math.random() * 16) / 15,int(Math.random() * 16) / 15];
         }
         m_pattern = DEFAULT_PATTERN_NAME;
      }
      
      public function useBaseAnimalState() : void
      {
         this.m_useAnimalBase = true;
         m_pattern = "";
      }
      
      override public function preAddToInventoryCheck() : Boolean
      {
         return !AnimalBreedingManager.isMutableAnimal(this.m_item) || Global.storageSettings.inventoryCanTakeMoreMutableAnimals();
      }
      
      override public function preAddToInventoryCheckFailed() : void
      {
         UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","UGCCapacityOvershot")));
      }
      
      override protected function initializeFilters() : void
      {
         this.updateColorMatrix();
         if(this.m_animateBase || this.m_animatePattern)
         {
            this.m_lastTime = GlobalEngine.currentTime;
            m_content.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         if(this.m_imageLoadedCallback != null)
         {
            m_imageLoadedCallback();
            m_imageLoadedCallback = null;
         }
         this.m_contentReplaced = true;
      }
      
      override public function setImageLoadedCallback(callback:Function) : void
      {
         m_imageLoadedCallback = callback;
         if(this.m_contentReplaced)
         {
            m_imageLoadedCallback();
            m_imageLoadedCallback = null;
         }
      }
      
      protected function onEnterFrame(event:Event) : void
      {
         var deltaTime:Number = (GlobalEngine.currentTime - this.m_lastTime) / 1000;
         this.m_lastTime = GlobalEngine.currentTime;
         if(this.m_animateBase)
         {
            this.m_baseHSV[0] = (this.m_baseHSV[0] + deltaTime) % 6;
         }
         if(this.m_animatePattern)
         {
            this.m_patternHSV[0] -= deltaTime;
            if(this.m_patternHSV[0] < 0)
            {
               this.m_patternHSV[0] += 6;
            }
         }
         var maxDefconLevel:Number = Global.flashHotParams["MUTABLEANIMAL_FIX_FARM76351"] != null ? Number(Global.flashHotParams["MUTABLEANIMAL_FIX_FARM76351"]) : DefconManager.MAX_LEVEL;
         if(DefconManager.defconLevel <= maxDefconLevel)
         {
            this.updateColorMatrix();
         }
      }
      
      protected function updateColorMatrix() : void
      {
         var baseColor:Array = null;
         var patternColor:Array = null;
         var colorMatrix:Array = null;
         if(m_content != null)
         {
            if(!this.m_useAnimalBase)
            {
               baseColor = FarmGameUtil.hsvToRgb(this.m_baseHSV[0],this.m_baseHSV[1],this.m_baseHSV[2]);
               patternColor = FarmGameUtil.hsvToRgb(this.m_patternHSV[0],this.m_patternHSV[1],this.m_patternHSV[2]);
               colorMatrix = [baseColor[0],patternColor[0],2.64,0,0,baseColor[1],patternColor[1],1.9,0,0,baseColor[2],patternColor[2],1.2,0,0,0,0,0,1,0];
               m_colorMatrixFilter = new ColorMatrixFilter(colorMatrix);
               m_content.filters = [m_colorMatrixFilter];
            }
            else
            {
               m_content.filters = null;
            }
         }
      }
      
      public function getPackedMutableState() : String
      {
         var value:String = "";
         if(this.m_mutableAnimalState != null)
         {
            value = this.m_mutableAnimalState.getPackedMutableState();
         }
         return value;
      }
      
      override public function getMetadataKey() : String
      {
         var hashKey:String = "";
         if(null != this.m_mutableAnimalState)
         {
            hashKey = this.m_mutableAnimalState.getHashKey();
         }
         return this.getItem().code + ":" + hashKey;
      }
      
      override public function getMetadata() : Object
      {
         return this.getPackedMutableState();
      }
      
      override public function getInventoryCode() : String
      {
         var jsonVariant:String = null;
         var variantState:MutableAnimalState = null;
         var isVariantItem:Boolean = false;
         if(this.m_mutableAnimalState)
         {
            jsonVariant = Global.animalBreedingSettings.getVariantJSONByItemName(m_itemName,m_itemName);
            if(Boolean(jsonVariant) && jsonVariant != "null")
            {
               variantState = MutableAnimalState.createFromPhpString("",jsonVariant);
               if(this.m_mutableAnimalState.getHashKey() == variantState.getHashKey())
               {
                  isVariantItem = true;
               }
            }
         }
         var result:String = !isVariantItem ? this.getMetadataKey() : super.getInventoryCode();
         if(result.indexOf(":") == result.length - 1)
         {
            result = result.substring(0,result.length - 1);
         }
         return result;
      }
      
      override public function updatePersonalName(value:String) : void
      {
         if(!this.m_mutableAnimalState)
         {
            this.m_mutableAnimalState = new MutableAnimalState("",{},"");
         }
         this.m_mutableAnimalState.name = value;
      }
      
      override public function setMetadata(value:Object) : void
      {
         this.setMutableAnimalStateFromMetaData(String(value));
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case CHANGE_NAME:
                  UI.displayPopup(new BreedingRenameWindow(this,this.m_mutableAnimalState,false));
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override protected function buildTooltipText() : String
      {
         var animalName:String = null;
         var toolTip:String = super.buildTooltipText();
         if(this.m_mutableAnimalState != null && toolTip != null)
         {
            animalName = this.m_mutableAnimalState.name;
            if(animalName != this.getItem().name)
            {
               toolTip = animalName + "\n" + toolTip;
            }
         }
         return toolTip;
      }
      
      override public function cleanUp() : void
      {
         m_content.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.m_mutableAnimalState = null;
      }
      
      override public function packStoreItemMetaData() : Object
      {
         var metadata:Object = null;
         var mutableState:String = this.getPackedMutableState();
         if(Boolean(mutableState) && mutableState.length > 0)
         {
            metadata = {};
            metadata.type = mutableState;
            return metadata;
         }
         return null;
      }
      
      override protected function getMasteryFarmItem() : FarmItem
      {
         var item:FarmItem = m_item;
         var code:String = HarvestableStorageBuilding.getItemCodeForMasteryOverrideExportName(m_item.code);
         if(code != m_item.code)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(code);
         }
         return item;
      }
   }
}

