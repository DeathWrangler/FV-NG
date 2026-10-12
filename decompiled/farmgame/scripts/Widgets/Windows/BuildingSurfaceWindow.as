package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.ItemInstance;
   import Classes.MapResource;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class BuildingSurfaceWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_harvestPromptDynamic.swf";
      
      private static const BUILDING_SCALE:Number = 1.75;
      
      private static const BUILDING_TOP_Y:int = 30;
      
      public static const ZLOC_PREFIX_DEFAULT:String = "AnimalBreedingSurfacing";
      
      public static const ZLOC_PREFIX_ORCHARDS_NEW:String = "OrchardFeatureBuildingSurfacingNew";
      
      public static const ZLOC_PREFIX_ORCHARDS_FULL:String = "OrchardFeatureBuildingSurfacingFull";
      
      public static const PLACEMENT_PROMPT_DAILY_COUNT:String = "placement_prompt_daily_count";
      
      protected var m_buildingItem:FarmItem = null;
      
      protected var m_targetInstance:ItemInstance = null;
      
      protected var m_showClose:Boolean = true;
      
      protected var m_closeCallback:Function = null;
      
      private var m_itemNameToPlace:String = null;
      
      private var m_zLocPrefix:String;
      
      private var m_partPlacementPrompt:Boolean;
      
      private var m_contextualPlacementPrompt:Boolean;
      
      private var m_buildingIcon:ObjectPreviewFrame;
      
      public function BuildingSurfaceWindow(buildingItem:FarmItem, targetInstance:ItemInstance = null, showClose:Boolean = true, closeCallback:Function = null, itemNameToPlace:String = null, zLocPrefix:String = null, partPlacementPrompt:Boolean = false, contextualPlacementPrompt:Boolean = false)
      {
         super(ASSET_URL);
         this.m_buildingItem = buildingItem;
         this.m_targetInstance = targetInstance;
         this.m_showClose = showClose;
         this.m_closeCallback = closeCallback;
         this.m_partPlacementPrompt = partPlacementPrompt;
         this.m_contextualPlacementPrompt = contextualPlacementPrompt;
         this.m_zLocPrefix = zLocPrefix == null ? ZLOC_PREFIX_DEFAULT : zLocPrefix;
         if(itemNameToPlace)
         {
            this.m_itemNameToPlace = itemNameToPlace;
         }
         else
         {
            this.m_itemNameToPlace = this.m_buildingItem.name.substring(0,this.m_buildingItem.name.lastIndexOf("_finished"));
         }
         FarmStatsManager.count("dialog","breedable_animal_harvest","view",this.m_buildingItem.name);
      }
      
      public static function setPlacementPromptFeatureLastShown() : void
      {
         Global.player.setFeatureLastShown(PLACEMENT_PROMPT_DAILY_COUNT,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
      }
      
      private static function getPlacementPromptCount(building:FarmItem) : int
      {
         var actionName:String = building.name + "_placement_prompt_count";
         return Global.player.getActionCount(actionName);
      }
      
      public static function conditionallyShowPrompt(resource:MapResource, surfacingKeyword:String, zLocPrefixWhenNew:String = "AnimalBreedingSurfacing", zLocPrefixWhenFull:String = null) : Boolean
      {
         var result:Boolean = false;
         var zLocPrefix:String = zLocPrefixWhenNew;
         var building:FarmItem = FeatureBuildingSurfacingManager.getInstance().conditionallyGetBuildingToSurface(resource,surfacingKeyword);
         if(!building && Boolean(zLocPrefixWhenFull))
         {
            zLocPrefix = zLocPrefixWhenFull;
            building = FeatureBuildingSurfacingManager.getInstance().conditionallyGetBuildingToSurface(resource,surfacingKeyword,true);
         }
         if(building)
         {
            UI.displayPopup(new BuildingSurfaceWindow(building,resource,true,null,null,zLocPrefix));
            result = true;
         }
         return result;
      }
      
      public static function checkShouldDisplayPlacementPrompt(building:BuildingItem) : Boolean
      {
         var currentCount:int = 0;
         var shouldDisplayPrompt:Boolean = false;
         var featureBuildingManager:FeatureBuildingSurfacingManager = FeatureBuildingSurfacingManager.getInstance();
         var buildings:Array = featureBuildingManager.getBuildingsByName(building,true);
         if(buildings.length == 0)
         {
            shouldDisplayPrompt = true;
         }
         var worlds:Array = building.worldRestrictions;
         if(worlds.length > 0 && worlds.indexOf(Global.worldManager.currentWorldType) == -1)
         {
            shouldDisplayPrompt = false;
         }
         if(shouldDisplayPrompt)
         {
            if(!featureBuildingManager.canPlaceBuilding(building))
            {
               shouldDisplayPrompt = false;
            }
         }
         if(shouldDisplayPrompt)
         {
            buildings = featureBuildingManager.getConstructionsBuildingsByName(building);
            if(buildings.length > 0)
            {
               shouldDisplayPrompt = false;
            }
         }
         var featureLastShown:int = Global.player.getFeatureLastShown(PLACEMENT_PROMPT_DAILY_COUNT);
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var timeElapsed:Number = currentTime - featureLastShown;
         if(timeElapsed < FarmGameUtil.NUM_SECS_IN_DAY)
         {
            shouldDisplayPrompt = false;
         }
         else
         {
            currentCount = getPlacementPromptCount(building);
            if(currentCount >= Global.farmGameSettingsManager.getNumber("ContextualPlacementPromptMaxCount"))
            {
               shouldDisplayPrompt = false;
            }
         }
         return shouldDisplayPrompt;
      }
      
      public static function isOnContextualPlacementPromptExperiement() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CONTEXTUAL_PLACEMENT) > 1;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var buttonLabel:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_accept_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_accept"),new ZLocFailoverEntry("Dialogs",ZLOC_PREFIX_DEFAULT + "_accept")]);
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,buttonLabel,this.onAccept));
         var buildingImageHolder:ZwFrame = new ZwFrame(m_window.container_mc);
         addWidget(buildingImageHolder);
         this.m_buildingIcon = new ObjectPreviewFrame(m_window.pen_mc,this.m_buildingItem,null,[BUILDING_SCALE]);
         this.m_buildingIcon.y += BUILDING_TOP_Y;
         addWidget(this.m_buildingIcon);
         this.setDialogText();
         if(this.m_targetInstance != null)
         {
            addWidget(new FarmIcon(m_window.icon_mc,this.m_targetInstance.getItem().icon));
            addWidget(new ZwFrame(m_window.select_mc));
         }
         else
         {
            addWidget(new ZwFrame(m_window.select_mc),false);
         }
         if(this.m_contextualPlacementPrompt)
         {
            setPlacementPromptFeatureLastShown();
            this.incrementPlacementPromptCount();
            StatsManager.count("ContextPrompt","DialogView",this.m_buildingItem.name);
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(!this.m_showClose)
         {
            m_closeButton.visible = false;
         }
      }
      
      protected function setDialogText() : void
      {
         var popupMessage:String = null;
         var hasItemTitle:String = null;
         var message:String = null;
         var noItemTitle:String = null;
         var noItemMessage:String = null;
         if(this.m_partPlacementPrompt)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",ZLOC_PREFIX_DEFAULT + "_part_prompt_title")));
            popupMessage = ZLocUtils.t("Dialogs",ZLOC_PREFIX_DEFAULT + "_part_prompt_body",{
               "buildingName":ZLocUtils.tk_pk(this.m_buildingItem.friendlyName),
               "itemName":ZLocUtils.tk_pk(this.m_targetInstance.getItemFriendlyName())
            });
            addWidget(new ZwTextField(m_window.popupBox_tf,popupMessage));
         }
         else if(this.m_contextualPlacementPrompt)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",ZLOC_PREFIX_DEFAULT + "_contextual_prompt_title")));
            popupMessage = ZLocUtils.t("Dialogs",ZLOC_PREFIX_DEFAULT + "_contextual_prompt_body",{"buildingName":ZLocUtils.tk_pk(this.m_buildingItem.friendlyName)});
            addWidget(new ZwTextField(m_window.popupBox_tf,popupMessage));
         }
         else if(this.m_targetInstance != null)
         {
            hasItemTitle = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_title_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_title_noAnimal_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_title"),new ZLocFailoverEntry("Dialogs",ZLOC_PREFIX_DEFAULT + "_title_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",ZLOC_PREFIX_DEFAULT + "_title")],{
               "buildingName":ZLocUtils.tk_pk(this.m_buildingItem.friendlyName),
               "itemName":ZLocUtils.tk_pk(this.m_targetInstance.getItemFriendlyName())
            });
            addWidget(new ZwTextField(m_window.title_tf,hasItemTitle));
            message = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_body_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_body_noAnimal_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_body"),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_body_noAnimal"),new ZLocFailoverEntry("Dialogs",ZLOC_PREFIX_DEFAULT + "_body_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",ZLOC_PREFIX_DEFAULT + "_body")],{
               "buildingName":ZLocUtils.tk_pk(this.m_buildingItem.friendlyName),
               "itemName":ZLocUtils.tk_pk(this.m_targetInstance.getItemFriendlyName())
            });
            addWidget(new ZwTextField(m_window.popupBox_tf,message));
         }
         else
         {
            noItemTitle = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_title_noAnimal_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_title_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_title"),new ZLocFailoverEntry("Dialogs",ZLOC_PREFIX_DEFAULT + "_title")],{"buildingName":ZLocUtils.tk_pk(this.m_buildingItem.friendlyName)});
            addWidget(new ZwTextField(m_window.title_tf,noItemTitle));
            noItemMessage = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_body_noAnimal_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",this.m_zLocPrefix + "_body_noAnimal"),new ZLocFailoverEntry("Dialogs",ZLOC_PREFIX_DEFAULT + "_body_noAnimal_" + this.m_buildingItem.name),new ZLocFailoverEntry("Dialogs",ZLOC_PREFIX_DEFAULT + "_body")],{"buildingName":ZLocUtils.tk_pk(this.m_buildingItem.friendlyName)});
            addWidget(new ZwTextField(m_window.popupBox_tf,noItemMessage));
         }
      }
      
      protected function onAccept(event:Event) : void
      {
         if(this.m_partPlacementPrompt)
         {
            FarmStatsManager.count("Gbplacement","Place",this.m_buildingItem.name);
         }
         this.close();
         var fromMarket:Boolean = Global.player.getGiftCountForItem(this.m_itemNameToPlace) > 0 ? false : true;
         Global.world.enterForcePlaceMode(this.m_itemNameToPlace,fromMarket,0,true,!fromMarket);
         FarmStatsManager.count("dialog","breedable_animal_harvest","place",this.m_buildingItem.name);
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         Global.player.incrementActionCount(FeatureBuildingSurfacingManager.PEN_SURFACE_KEY + Global.worldManager.currentWorldType,true);
         FarmStatsManager.count("dialog","breedable_animal_harvest","x",this.m_buildingItem.name);
      }
      
      override public function close() : void
      {
         super.close();
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
      
      private function incrementPlacementPromptCount() : void
      {
         var actionName:String = this.m_buildingItem.name + "_placement_prompt_count";
         Global.player.incrementActionCount(actionName,true);
      }
   }
}

