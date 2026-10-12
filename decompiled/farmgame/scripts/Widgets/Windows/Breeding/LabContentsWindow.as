package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.AnimalItem;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.UGCAnimalItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.SoundManager;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.LabBuildingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Breeding.AnimalBreedingContentsSlotFrame;
   import Widgets.Frames.Crafting.LabRecipeFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import com.adobe.utils.ArrayUtil;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class LabContentsWindow extends BaseContentsWindow
   {
      
      public static const VIEW_PEN:int = 0;
      
      public static const VIEW_LAB:int = 1;
      
      private static const DISPLAY_SETTINGS_DIALOG_NAME:String = "content";
      
      private static var m_state:int = VIEW_LAB;
      
      private static const LAB_DEFAULT_STATS_RATE:int = 100;
      
      private var m_labSampleRate:int;
      
      private var m_title:ZwTextField = null;
      
      private var m_capacity_tf:ZwTextField = null;
      
      private var m_current_tf:ZwTextField = null;
      
      private var m_howDoesThisWork:FarmAnimatedTextButton = null;
      
      protected var m_animals_mc:FarmSlotContainerFrame = null;
      
      protected var m_recipeFrame:LabRecipeFrame = null;
      
      private var m_penButton:FarmAnimatedTextButton = null;
      
      private var m_recipeButton:FarmAnimatedTextButton = null;
      
      private var m_contents:Dictionary;
      
      protected var m_storageItems:Array;
      
      protected var m_animals:Array;
      
      private var m_toggleManager:ZwToggleManager;
      
      private var m_recipeItem:RecipeItem = null;
      
      private var m_labConfig:XML;
      
      public function LabContentsWindow(building:FeatureBuilding)
      {
         var sampleStr:String;
         var sampleRate:int;
         var dialogConfig:Object;
         var showOnlyAnimalsCreated:Boolean;
         this.m_contents = new Dictionary();
         this.m_storageItems = new Array();
         this.m_animals = new Array();
         m_building = building;
         this.m_labConfig = LabBuildingManager.getInstance().getLabBuilding(m_building.bldgName);
         if(this.m_labConfig.hasOwnProperty(CraftingConstants.CRAFT_COMPLETE_SOUND))
         {
            if(!SoundManager.isMuted())
            {
               if(!SoundManager.getSoundById(CraftingConstants.CRAFT_COMPLETE_SOUND))
               {
                  SoundManager.addSound(CraftingConstants.CRAFT_COMPLETE_SOUND,Global.getAssetURL(this.m_labConfig[CraftingConstants.CRAFT_COMPLETE_SOUND]),false);
               }
            }
         }
         sampleStr = GlobalEngine.getFlashVar("FLASHVAR_LAB_SAMPLE") as String;
         sampleRate = LAB_DEFAULT_STATS_RATE;
         try
         {
            sampleRate = parseInt(sampleStr);
         }
         catch(err:Error)
         {
            ErrorManager.addError("Error parsing FLASHVAR_LAB_SAMPLE");
         }
         this.m_labSampleRate = sampleRate;
         FarmStatsManager.sample(this.m_labSampleRate,"dialog",m_building.getItemName(),"view");
         dialogConfig = m_building.getItem().getDialogConfig("storage");
         if(dialogConfig == null)
         {
            dialogConfig = Global.farmGameSettingsManager.getBuildingDialogConfig(m_building.getItemName());
         }
         if(dialogConfig != null && dialogConfig.path != "")
         {
            super(dialogConfig.path);
         }
         this.m_contents = m_building.contents;
         showOnlyAnimalsCreated = this.m_labConfig.hasOwnProperty("showOnlyAnimalsCreated") && this.m_labConfig["showOnlyAnimalsCreated"] == 1;
         this.m_animals = this.loadContents(showOnlyAnimalsCreated);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.initFeatureWidgets();
      }
      
      override protected function release() : void
      {
         super.release();
         m_building = null;
         this.m_title = null;
         this.m_capacity_tf = null;
         this.m_current_tf = null;
         this.m_howDoesThisWork = null;
         this.m_animals_mc = null;
         this.m_recipeFrame = null;
         this.m_penButton = null;
         this.m_recipeButton = null;
         this.m_toggleManager = null;
         m_state = LabContentsWindow.VIEW_LAB;
      }
      
      protected function initFeatureWidgets() : void
      {
         var animalSlotFrameClass:Class = null;
         var callBackObject:Object = null;
         this.m_title = addWidget(new ZwTextField(m_window.title_tf,getLocalizedString("_Title"))) as ZwTextField;
         var capacityString:String = ZLocUtils.t("Dialogs","Capacity",{"quantity":m_building.capacity});
         var currentString:String = ZLocUtils.t("Dialogs","Current",{"quantity":m_building.count});
         this.m_capacity_tf = addWidget(new ZwTextField(m_window.capacity_tf,capacityString)) as ZwTextField;
         this.m_current_tf = addWidget(new ZwTextField(m_window.current_tf,currentString)) as ZwTextField;
         this.m_howDoesThisWork = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick)) as FarmAnimatedTextButton;
         var animalSlotFrame:* = null;
         if(this.m_labConfig.hasOwnProperty("animalSlotFrame"))
         {
            animalSlotFrameClass = getDefinitionByName(this.m_labConfig["animalSlotFrame"]) as Class;
            animalSlotFrame = new animalSlotFrameClass(m_window.animals_mc,this.m_animals,this,this.m_labConfig);
         }
         else
         {
            animalSlotFrame = new AnimalBreedingContentsSlotFrame(m_window.animals_mc,this.m_animals,this,this.m_labConfig);
         }
         this.m_animals_mc = animalSlotFrame;
         addWidget(this.m_animals_mc);
         if(m_window.hasOwnProperty("frameRecipes_mc"))
         {
            callBackObject = {
               "makeRecipe":this.makeRecipe,
               "buyIngredients":this.buyIngredients,
               "buyBushel":this.buyBushel
            };
            this.m_recipeFrame = addWidget(new LabRecipeFrame(m_window.frameRecipes_mc,callBackObject,this.m_labConfig)) as LabRecipeFrame;
            this.m_penButton = new FarmAnimatedTextButton(m_window.rightTab_mc,ZLocUtils.t("Dialogs",m_building.bldgName + "_Pen"),this.onShowAnimals);
            addWidget(this.m_penButton);
            this.m_recipeButton = new FarmAnimatedTextButton(m_window.leftTab_mc,ZLocUtils.t("Dialogs",m_building.bldgName + "_Lab"),this.onShowAnimals);
            addWidget(this.m_recipeButton);
            if(m_window.strings_mc)
            {
               addWidget(new ZwBaseWidget(m_window.strings_mc));
            }
         }
         this.m_toggleManager = new ZwToggleManager();
         if(LabContentsWindow.m_state == LabContentsWindow.VIEW_LAB && Boolean(this.m_penButton))
         {
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_recipeButton,this.m_recipeFrame),true);
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_penButton,this.m_animals_mc));
         }
         else if(this.m_penButton)
         {
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_recipeButton,this.m_recipeFrame));
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_penButton,this.m_animals_mc),true);
         }
         else
         {
            this.m_animals_mc.visible = true;
         }
      }
      
      private function onShowAnimals(event:Event) : void
      {
         LabContentsWindow.m_state = LabContentsWindow.VIEW_PEN;
      }
      
      protected function generateMetadataArrContents(metadataList:Array, contents:Array, itemCode:String) : Array
      {
         var meta:Object = null;
         var dataArray:Array = null;
         var quantity:int = 0;
         var friendlyName:String = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         for each(meta in metadataList)
         {
            dataArray = meta.data as Array;
            quantity = 1;
            friendlyName = null;
            if(dataArray)
            {
               quantity = int(dataArray.length);
               friendlyName = farmItem.getInstanceName(dataArray[0]);
            }
            else
            {
               friendlyName = farmItem.getInstanceName(meta.data);
            }
            contents.push({
               "code":itemCode,
               "quantity":quantity,
               "itemName":farmItem.name,
               "name":farmItem.friendlyTitle,
               "metadataHash":meta.key,
               "displayName":friendlyName,
               "unique":true
            });
         }
         return contents;
      }
      
      protected function sortByWorld(object1:Object, object2:Object) : int
      {
         var result:int = 0;
         var currentWorld:String = Global.worldManager.currentWorldUniqueMarketCard;
         if(object1.world == currentWorld && object2.world == currentWorld || object1.world != currentWorld && object2.world != currentWorld)
         {
            if(Boolean(object1.market) && Boolean(object2.market) || !object1.market && !object2.market)
            {
               if(object1.name > object2.name)
               {
                  result = 1;
               }
               else
               {
                  result = -1;
               }
            }
            else if(object1.market)
            {
               result = -1;
            }
            else
            {
               result = 1;
            }
         }
         else if(object1.world == currentWorld)
         {
            result = -1;
         }
         else
         {
            result = 1;
         }
         return result;
      }
      
      protected function loadContents(showOnlyAnimalsCreated:Boolean = false) : Array
      {
         var itemCode:String = null;
         var metadataList:Array = null;
         var labBuildingFeatureOptions:Object = null;
         var code:String = null;
         var storageItemNames:Array = null;
         var storableItem:String = null;
         var resultItem:Object = null;
         var extraDataKey:String = null;
         this.m_storageItems = Global.storageSettings.getStorageItems(m_building.getItem().storageClass,false,false,showOnlyAnimalsCreated);
         var tmpItemDisplaySettings:Object = Global.farmGameSettingsManager.getDialogDisplaySettings(m_building.getItem().name,DISPLAY_SETTINGS_DIALOG_NAME);
         var farmItem:FarmItem = null;
         var result:Array = new Array();
         var nonStoredAnimals:Array = new Array();
         var ugc:Array = new Array();
         for(itemCode in m_building.contents)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(this.m_contents[itemCode] != 0)
            {
               metadataList = m_building.getStorageMetaDataForCode(itemCode);
               if(Boolean(metadataList) && Boolean(metadataList.length))
               {
                  ugc = this.generateMetadataArrContents(metadataList,ugc,itemCode);
               }
               else
               {
                  result.push({
                     "code":itemCode,
                     "quantity":this.m_contents[itemCode],
                     "itemName":farmItem.name,
                     "name":farmItem.friendlyTitle,
                     "useOverrideIcon":true
                  });
               }
            }
         }
         result.sortOn(["name"],[Array.CASEINSENSITIVE]);
         if(Global.flashHotParams["SORT_STORAGE_BY_WORLD"])
         {
            result.sort(this.sortByWorld);
         }
         else
         {
            result.sortOn(["name"],[Array.CASEINSENSITIVE]);
         }
         result = ArrayUtil.createUniqueCopy(ugc.concat(result));
         var storedAnimals:Array = ArrayUtil.createUniqueCopy(result);
         for(var key:int = 0; key < this.m_storageItems.length; key++)
         {
            if(this.m_storageItems[key] is AnimalItem && !(this.m_storageItems[key] is UGCAnimalItem))
            {
               farmItem = this.m_storageItems[key];
               if((this.m_contents.hasOwnProperty(farmItem.code) == false || this.m_contents[farmItem.code] == 0) && farmItem.canShow())
               {
                  nonStoredAnimals.push({
                     "code":farmItem.code,
                     "quantity":0,
                     "itemName":farmItem.name,
                     "name":farmItem.friendlyTitle,
                     "market":farmItem.canPurchase,
                     "useOverrideIcon":true
                  });
               }
            }
         }
         if(showOnlyAnimalsCreated)
         {
            labBuildingFeatureOptions = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LAB_BUILDING);
            if(labBuildingFeatureOptions)
            {
               for(code in labBuildingFeatureOptions)
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
                  if(farmItem)
                  {
                     if((this.m_contents.hasOwnProperty(farmItem.code) == false || this.m_contents[farmItem.code] == 0) && farmItem.canShow())
                     {
                        storageItemNames = Global.storageSettings.getStorageItemNames(m_building.getItem().storageClass);
                        for each(storableItem in storageItemNames)
                        {
                           if(storableItem == farmItem.name)
                           {
                              nonStoredAnimals.push({
                                 "code":farmItem.code,
                                 "quantity":0,
                                 "itemName":farmItem.name,
                                 "name":farmItem.friendlyTitle,
                                 "market":farmItem.canPurchase,
                                 "useOverrideIcon":true
                              });
                              break;
                           }
                        }
                     }
                  }
               }
            }
         }
         nonStoredAnimals.sortOn(["market","name"],[Array.NUMERIC | Array.DESCENDING,Array.CASEINSENSITIVE]);
         result = ArrayUtil.createUniqueCopy(result.concat(nonStoredAnimals));
         if(tmpItemDisplaySettings != null)
         {
            for each(resultItem in result)
            {
               if(Boolean(tmpItemDisplaySettings[resultItem.itemName]) && Boolean(tmpItemDisplaySettings[resultItem.itemName].hasOwnProperty("image")))
               {
                  for(extraDataKey in tmpItemDisplaySettings[resultItem.itemName].image)
                  {
                     resultItem[extraDataKey] = tmpItemDisplaySettings[resultItem.itemName].image[extraDataKey];
                  }
               }
            }
         }
         return result;
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         FarmStatsManager.sample(this.m_labSampleRate,"dialog",m_building.getItemName(),"what_is_this");
         var prefixUrl:String = m_building.getItem().prefixUrl;
         TutorialUI.displayBuildingTutorialWindow(m_building,prefixUrl,false,null);
      }
      
      public function makeRecipe(recipeId:String) : void
      {
         var trackMadeRecipe:Boolean = false;
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         if(recipeItem)
         {
            this.pause();
            trackMadeRecipe = this.m_labConfig.hasOwnProperty("trackMadeRecipe") && this.m_labConfig["trackMadeRecipe"] == 1;
            CraftingManager.getInstance().craftInstantItem(this.unpause,recipeItem,trackMadeRecipe);
         }
      }
      
      public function buyIngredients(recipeId:String) : void
      {
         this.setRecipeItem(recipeId);
         CraftingManager.getInstance().beginPurchaseRecipeBundle(this.m_recipeItem,this.onBuyAllClose,this.onBuyAllPurchase);
         this.pause();
         FarmStatsManager.sample(this.m_labSampleRate,m_building.bldgName,"buy_ingredient_event",this.m_recipeItem.name);
      }
      
      public function buyBushel(bushel:String, recipeId:String) : void
      {
         CraftingManager.getInstance().onPurchaseBushel(bushel,recipeId);
         this.m_recipeFrame.refreshRecipe(recipeId,true);
      }
      
      public function setRecipeItem(recipeId:String) : void
      {
         this.m_recipeItem = CraftingManager.getRecipeItemFromId(recipeId,this.m_labConfig["skillType"]);
      }
      
      private function onBuyAllClose(evt:Event = null) : void
      {
         this.unpause();
      }
      
      private function onBuyAllPurchase(recipeId:String) : void
      {
         this.unpause();
      }
      
      public function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      public function unpause(recipeId:String = "", openNextSlot:Boolean = false) : void
      {
         if(m_window)
         {
            this.update(recipeId,openNextSlot);
            untintWindow();
            enableInput = true;
         }
      }
      
      public function update(recipeId:String = "", openNextSlot:Boolean = false) : void
      {
         this.m_recipeFrame.update();
         this.m_recipeFrame.refreshRecipe(recipeId,openNextSlot);
      }
   }
}

