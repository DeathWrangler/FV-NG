package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.MutableAnimal;
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.FarmGameUtil;
   import Managers.DefconManager;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.getDefinitionByName;
   
   public class FeaturedRenderFMutableObject extends FeaturedRenderFObject
   {
      
      private var m_assetName:String = "";
      
      private var m_metaData:String = "";
      
      private var m_baseHSV:Array;
      
      private var m_patternHSV:Array;
      
      private var m_animateBase:Boolean = false;
      
      private var m_animatePattern:Boolean = false;
      
      private var m_lastTime:int;
      
      private var m_patternArray:Array;
      
      private var m_needCustomRendering:Boolean = false;
      
      private var m_mutableAnimalState:MutableAnimalState = null;
      
      public function FeaturedRenderFMutableObject(itemName:String, building:FeatureBuilding, metadata:String = "")
      {
         var muteClass:Class = null;
         var tempClass:Object = null;
         var jsonVariant:String = null;
         this.m_baseHSV = [];
         this.m_patternHSV = [];
         this.m_patternArray = ["plain","dots","hood","splotch","stars","stripe"];
         super(itemName,building,metadata);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(farmItem != null)
         {
            try
            {
               muteClass = getDefinitionByName("Classes." + farmItem.className) as Class;
               tempClass = new muteClass(farmItem.name);
               if(tempClass is MutableAnimal)
               {
                  this.m_needCustomRendering = true;
               }
            }
            catch(e:Error)
            {
            }
         }
         this.m_metaData = metadata;
         if(this.m_needCustomRendering)
         {
            if(metadata != "" && metadata != "null" && metadata != null)
            {
               this.setMutableAnimalStateFromMetaData(metadata);
               this.m_metaData = metadata;
            }
            else
            {
               jsonVariant = Global.animalBreedingSettings.getVariantJSONByItemName(farmItem.name,this.m_itemName);
               if(jsonVariant != "" && jsonVariant != null && jsonVariant != "null")
               {
                  this.setMutableAnimalStateFromMetaData(jsonVariant);
               }
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var objClass:Class = null;
         var itemInstance:MapResource = null;
         var result:String = null;
         if(m_itemImageName != "" && Boolean(m_item))
         {
            if(!m_item.displayLoader.hasImageNameDefined(m_itemImageName))
            {
               objClass = m_item.getMapResourceClass();
               itemInstance = null;
               try
               {
                  itemInstance = new objClass(m_item.name,this.m_metaData);
               }
               catch(error:Error)
               {
                  itemInstance = new objClass(m_item.name);
               }
               m_itemImageName = itemInstance.getCurrentImageName();
            }
            result = m_itemImageName;
         }
         return result;
      }
      
      public function setMutableAnimalStateFromMetaData(metadata:String) : void
      {
         this.m_mutableAnimalState = MutableAnimalState.createFromPhpString("",metadata);
         this.setAnimalState();
      }
      
      public function setAnimalState() : void
      {
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
         m_pattern = this.m_patternArray[int(Math.random() * this.m_patternArray.length)];
      }
      
      override protected function initializeFilters() : void
      {
         if(this.m_needCustomRendering)
         {
            this.updateColorMatrix();
            if(this.m_animateBase || this.m_animatePattern)
            {
               this.m_lastTime = GlobalEngine.currentTime;
               m_content.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            }
         }
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var deltaTime:Number = NaN;
         var maxDefconLevel:Number = NaN;
         if(this.m_needCustomRendering)
         {
            deltaTime = (GlobalEngine.currentTime - this.m_lastTime) / 1000;
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
            maxDefconLevel = Global.flashHotParams["MUTABLEANIMAL_FIX_FARM76351"] != null ? Number(Global.flashHotParams["MUTABLEANIMAL_FIX_FARM76351"]) : DefconManager.MAX_LEVEL;
            if(DefconManager.defconLevel <= maxDefconLevel)
            {
               this.updateColorMatrix();
            }
         }
      }
      
      private function updateColorMatrix() : void
      {
         var baseColor:Array = null;
         var patternColor:Array = null;
         var colorMatrix:Array = null;
         if(m_content)
         {
            baseColor = FarmGameUtil.hsvToRgb(this.m_baseHSV[0],this.m_baseHSV[1],this.m_baseHSV[2]);
            patternColor = FarmGameUtil.hsvToRgb(this.m_patternHSV[0],this.m_patternHSV[1],this.m_patternHSV[2]);
            colorMatrix = [baseColor[0],patternColor[0],2.64,0,0,baseColor[1],patternColor[1],1.9,0,0,baseColor[2],patternColor[2],1.2,0,0,0,0,0,1,0];
            m_colorMatrixFilter = new ColorMatrixFilter(colorMatrix);
            m_content.filters = [m_colorMatrixFilter];
         }
      }
   }
}

