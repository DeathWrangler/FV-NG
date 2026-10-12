package Display
{
   import Classes.CommunityGoals.CommunityGoalsTask;
   import Classes.Constants.ZLocConstants;
   import Classes.EmbeddedArt;
   import Classes.FeatureBuilding;
   import Classes.Growable.GrowableContest;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.CloseEvent;
   import Managers.CommunityGoalsManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.GrowableContestManager;
   import Widgets.Windows.BuildingSurfaceWindow;
   import Widgets.Windows.Crafting.CraftingTutorialWindow;
   import Widgets.Windows.Crafting.TutorialOnePageWindow;
   import Widgets.Windows.IrrigationFTUEWindow;
   import Widgets.Windows.TutorialAcceptButtonWindow;
   import Widgets.Windows.TutorialTitleButtonWindow;
   import Widgets.Windows.TutorialWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class TutorialUI extends UI
   {
      
      private static var m_tutorialOnePageWindow:TutorialOnePageWindow = null;
      
      private static var m_closeTutorialOnePageWindowCallback:Function = null;
      
      private static var m_closeTutorialAssetCallback:Function = null;
      
      private static var m_craftingTutorialWindow:CraftingTutorialWindow = null;
      
      private static var m_tutorialWindowFunctionQueue:Vector.<Function> = new Vector.<Function>();
      
      private static var m_tutorialWindow:TutorialWindow = null;
      
      private static var m_tutorialAcceptButtonWindow:TutorialAcceptButtonWindow = null;
      
      private static var m_tutorialTitleButtonWindow:TutorialTitleButtonWindow = null;
      
      private static var m_bouncingArrow1:DisplayObject = null;
      
      private static var m_bouncingArrow2:DisplayObject = null;
      
      private static var m_breedingArrow1:DisplayObject = null;
      
      private static var m_breedingArrow2:DisplayObject = null;
      
      public function TutorialUI()
      {
         super();
      }
      
      public static function updateGrowableContestTutorialState(building:FeatureBuilding) : void
      {
         var contest:GrowableContest = null;
         var contestId:String = GrowableContestManager.instance.getContestIdForBuildingCode(building.getItem().code);
         if(contestId != null)
         {
            contest = GrowableContestManager.instance.getContest(contestId);
            if(contest != null)
            {
               contest.getTutorial().updateState();
            }
         }
      }
      
      public static function showIrrigationFTUEWindow(windowSrc:String, itemPlaceOnAccept:String) : void
      {
         UI.displayPopup(new IrrigationFTUEWindow(windowSrc,itemPlaceOnAccept));
      }
      
      public static function forcePlaceGiftboxDialog(itemName:String, message:String, button:String, seenFlag:String, isFromMarket:Boolean = false) : void
      {
         var prompt:GenericXMLDialog = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName(itemName,"icon",false),100,100,ZLocUtils.t_pk(message),null,false,ZLocUtils.t_pk(button),function(event:Event):void
         {
            Global.world.enterForcePlaceMode(itemName,isFromMarket,0,false,!isFromMarket,{
               "suppressGiftRepop":true,
               "isGift":!isFromMarket
            });
         });
         UI.displayPopup(prompt,true,seenFlag,true);
      }
      
      public static function surfaceStorageBuilding(item:MapResource, surfacingKeyword:String) : Boolean
      {
         var tutorialShown:Boolean = false;
         var building:FarmItem = FeatureBuildingSurfacingManager.getInstance().conditionallyGetBuildingToSurface(item,surfacingKeyword);
         if(building)
         {
            tutorialShown = true;
            UI.displayPopup(new BuildingSurfaceWindow(building,null,true),UI.isShowingPopup());
         }
         return tutorialShown;
      }
      
      public static function displayCraftingCottageTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"Onboarding_SlotOOverview",
            "title":"Onboarding_SlotOTitle",
            "body":"Onboarding_SlotOBody",
            "imageUrl":"assets/crafting_cottages/Craft_tut_slot0_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"Onboarding_Slot1Overview",
            "title":"Onboarding_Slot1Title",
            "body":"Onboarding_Slot1Body",
            "imageUrl":"assets/crafting_cottages/Craft_tut_slot1_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"Onboarding_Slot2Overview",
            "title":"Onboarding_Slot2Title",
            "body":"Onboarding_Slot2Body",
            "imageUrl":"assets/crafting_cottages/Craft_tut_slot2_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"Onboarding_Slot3Overview",
            "title":"Onboarding_Slot3Title",
            "body":"Onboarding_Slot3Body",
            "imageUrl":"assets/crafting_cottages/Craft_tut_slot3_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Crafting","Onboarding_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayCraftingCottageTutorial2Window(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"CraftingMoreInfo_SlotOOverview",
            "title":"CraftingMoreInfo_SlotOTitle",
            "body":"CraftingMoreInfo_SlotOBody",
            "imageUrl":"assets/crafting_cottages/Craft2_tut_slot0_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"CraftingMoreInfo_Slot1Overview",
            "title":"CraftingMoreInfo_Slot1Title",
            "body":"CraftingMoreInfo_Slot1Body",
            "imageUrl":"assets/crafting_cottages/Craft2_tut_slot1_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"CraftingMoreInfo_Slot2Overview",
            "title":"CraftingMoreInfo_Slot2Title",
            "body":"CraftingMoreInfo_Slot2Body",
            "imageUrl":"assets/crafting_cottages/Craft2_tut_slot2_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"CraftingMoreInfo_Slot3Overview",
            "title":"CraftingMoreInfo_Slot3Title",
            "body":"CraftingMoreInfo_Slot3Body",
            "imageUrl":"assets/crafting_cottages/Craft2_tut_slot3_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Crafting","CraftingMoreInfo_Title"),true,addToQueue,closeCallback);
      }
      
      public static function displayCraftingSiloMoreInfoWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"CraftingSiloMoreInfo_Slot0Overview",
            "title":"CraftingSiloMoreInfo_Slot0Title",
            "body":"CraftingSiloMoreInfo_Slot0Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_Craft_Silo/CraftSilo_tut_00.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"CraftingSiloMoreInfo_Slot1Overview",
            "title":"CraftingSiloMoreInfo_Slot1Title",
            "body":"CraftingSiloMoreInfo_Slot1Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_Craft_Silo/CraftSilo_tut_01.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"CraftingSiloMoreInfo_Slot2Overview",
            "title":"CraftingSiloMoreInfo_Slot2Title",
            "body":"CraftingSiloMoreInfo_Slot2Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_Craft_Silo/CraftSilo_tut_02.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"CraftingSiloMoreInfo_Slot3Overview",
            "title":"CraftingSiloMoreInfo_Slot3Title",
            "body":"CraftingSiloMoreInfo_Slot3Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_Craft_Silo/CraftSilo_tut_03.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Crafting","CraftingSiloMoreInfo_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayNewMarketStallTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"NewMarketStallTutorial_SlotOOverview",
            "title":"NewMarketStallTutorial_SlotOTitle",
            "body":"NewMarketStallTutorial_SlotOBody",
            "imageUrl":"assets/crafting_cottages/Market_tut_slot0_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"NewMarketStallTutorial_Slot1Overview",
            "title":"NewMarketStallTutorial_Slot1Title",
            "body":"NewMarketStallTutorial_Slot1Body",
            "imageUrl":"assets/crafting_cottages/Market_tut_slot1_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"NewMarketStallTutorial_Slot2Overview",
            "title":"NewMarketStallTutorial_Slot2Title",
            "body":"NewMarketStallTutorial_Slot2Body",
            "imageUrl":"assets/crafting_cottages/Market_tut_slot2_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         },{
            "overview":"NewMarketStallTutorial_Slot3Overview",
            "title":"NewMarketStallTutorial_Slot3Title",
            "body":"NewMarketStallTutorial_Slot3Body",
            "imageUrl":"assets/crafting_cottages/Market_tut_slot3_image.jpg",
            "buttonTitle":"",
            "buttonUrl":""
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Crafting","NewMarketStallTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayCraftingTutorialWindow(craftType:String, acceptCallback:Function, closeCallback:Function = null) : void
      {
         if(m_craftingTutorialWindow == null)
         {
            m_craftingTutorialWindow = new CraftingTutorialWindow(craftType,acceptCallback,closeCallback);
            m_craftingTutorialWindow.addEventListener(CloseEvent.CLOSE,onCraftingTutorialWindowClose);
            UI.displayPopup(m_craftingTutorialWindow,false);
            UI.stopPopups(true);
         }
      }
      
      public static function displayOrchardsTutorialWindow(building:StorageBuilding, addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var itemXml:XML = null;
         var prefix:String = "Orchard";
         var prefixUrl:String = "assets/dialogs/4d_elements/Orchard/orchards";
         var buildingName:String = "";
         if(building.getItem())
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               buildingName = building.getItem().getStringFromDataSource("buildingName");
            }
            else
            {
               itemXml = building.getItem().xml;
               if(Boolean(itemXml != null) && Boolean(itemXml.hasOwnProperty("@buildingName")) && Boolean(itemXml.@buildingName.length()))
               {
                  buildingName = itemXml.@buildingName;
               }
            }
            if(buildingName)
            {
               if(buildingName != "" && ZLocUtils.hasString("Dialogs",buildingName + "Tutorial_Title"))
               {
                  prefix = buildingName;
               }
               else if(building.getItem().getFinishedName() != "")
               {
                  buildingName = getFinishedBuildingName(building);
                  if(buildingName != "" && ZLocUtils.hasString("Dialogs",buildingName + "Tutorial_Title"))
                  {
                     prefix = buildingName;
                  }
               }
            }
            if(building.getItem().prefixUrl)
            {
               prefixUrl = building.getItem().prefixUrl;
            }
         }
         var items:Array = [{
            "overview":prefix + "Tutorial_SlotOOverview",
            "title":prefix + "Tutorial_SlotOTitle",
            "body":prefix + "Tutorial_SlotOBody",
            "imageUrl":prefixUrl + "_tut_01.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":prefix + "Tutorial_Slot1Overview",
            "title":prefix + "Tutorial_Slot1Title",
            "body":prefix + "Tutorial_Slot1Body",
            "imageUrl":prefixUrl + "_tut_02.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":prefix + "Tutorial_Slot2Overview",
            "title":prefix + "Tutorial_Slot2Title",
            "body":prefix + "Tutorial_Slot2Body",
            "imageUrl":prefixUrl + "_tut_03.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":prefix + "Tutorial_Slot3Overview",
            "title":prefix + "Tutorial_Slot3Title",
            "body":prefix + "Tutorial_Slot3Body",
            "imageUrl":prefixUrl + "_tut_04.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs",prefix + "Tutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function getFinishedBuildingName(building:StorageBuilding) : String
      {
         var finishedItem:FarmItem = null;
         var itemXml:XML = null;
         var result:String = "";
         if(building.getItem() != null && building.getItem().getFinishedName() != "")
         {
            finishedItem = Global.farmGameSettingsManager.getFarmItemByName(building.getItem().getFinishedName());
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(finishedItem.hasPropertyInDataSource("buildingName"))
               {
                  result = finishedItem.getStringFromDataSource("buildingName");
               }
            }
            else
            {
               itemXml = finishedItem.xml;
               if(Boolean(itemXml != null) && Boolean(itemXml.hasOwnProperty("@buildingName")) && Boolean(itemXml.@buildingName.length()))
               {
                  result = itemXml.@buildingName;
               }
            }
         }
         return result;
      }
      
      public static function displaySheepPenTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"sheep_penTutorial_SlotOOverview",
            "title":"sheep_penTutorial_SlotOTitle",
            "body":"sheep_penTutorial_SlotOBody",
            "imageUrl":"assets/dialogs/FV_Support/FV_SheepPen/SheepPen_tut_01.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"sheep_penTutorial_Slot1Overview",
            "title":"sheep_penTutorial_Slot1Title",
            "body":"sheep_penTutorial_Slot1Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_SheepPen/SheepPen_tut_02.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"sheep_penTutorial_Slot2Overview",
            "title":"sheep_penTutorial_Slot2Title",
            "body":"sheep_penTutorial_Slot2Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_SheepPen/SheepPen_tut_04.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"sheep_penTutorial_Slot3Overview",
            "title":"sheep_penTutorial_Slot3Title",
            "body":"sheep_penTutorial_Slot3Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_SheepPen/SheepPen_tut_05.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","sheep_penTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayPigPenTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"pigpenv2Tutorial_SlotOOverview",
            "title":"pigpenv2Tutorial_SlotOTitle",
            "body":"pigpenv2Tutorial_SlotOBody",
            "imageUrl":"assets/dialogs/FV_Support/FV_PigPen/PigPen_tut_01.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"pigpenv2Tutorial_Slot1Overview",
            "title":"pigpenv2Tutorial_Slot1Title",
            "body":"pigpenv2Tutorial_Slot1Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_PigPen/PigPen_tut_02.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"pigpenv2Tutorial_Slot2Overview",
            "title":"pigpenv2Tutorial_Slot2Title",
            "body":"pigpenv2Tutorial_Slot2Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_PigPen/PigPen_tut_04.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"pigpenv2Tutorial_Slot3Overview",
            "title":"pigpenv2Tutorial_Slot3Title",
            "body":"pigpenv2Tutorial_Slot3Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_PigPen/PigPen_tut_05.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","pigpenv2Tutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function turtlepen_finishedTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"turtlepen_finishedTutorial_SlotOOverview",
            "title":"turtlepen_finishedTutorial_SlotOTitle",
            "body":"turtlepen_finishedTutorial_SlotOBody",
            "imageUrl":"assets/dialogs/4d_elements/TurtleBreeding/TurtleBreeding_tut_01.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"turtlepen_finishedTutorial_Slot1Overview",
            "title":"turtlepen_finishedTutorial_Slot1Title",
            "body":"turtlepen_finishedTutorial_Slot1Body",
            "imageUrl":"assets/dialogs/4d_elements/TurtleBreeding/TurtleBreeding_tut_02.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"turtlepen_finishedTutorial_Slot2Overview",
            "title":"turtlepen_finishedTutorial_Slot2Title",
            "body":"turtlepen_finishedTutorial_Slot2Body",
            "imageUrl":"assets/dialogs/4d_elements/TurtleBreeding/TurtleBreeding_tut_03.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"turtlepen_finishedTutorial_Slot3Overview",
            "title":"turtlepen_finishedTutorial_Slot3Title",
            "body":"turtlepen_finishedTutorial_Slot3Body",
            "imageUrl":"assets/dialogs/4d_elements/TurtleBreeding/TurtleBreeding_tut_04.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","turtlepen_finishedTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayTutorialWindowForItem(itemName:String, itemTitleKey:String, prefixUrl:String, addToQueue:Boolean = false, closeCallback:Function = null, buttonTextKey:String = null, hideCloseButton:Boolean = false) : void
      {
         var items:Array = null;
         var genericName:String = "AnimalBreedingGeneric";
         var locParams:Object = {
            "itemName":(itemTitleKey.indexOf("elitehorse") >= 0 ? itemName : ZLocUtils.tk_pk_asTitle(itemTitleKey)),
            "animalType":ZLocUtils.t("Dialogs",itemName + "_animalType")
         };
         var buttonText:String = null;
         if(buttonTextKey != null)
         {
            buttonText = ZLocUtils.t_pk(buttonTextKey);
         }
         else if(ZLocUtils.hasString("Dialogs",itemName + "_ButtonText"))
         {
            buttonText = ZLocUtils.t("Dialogs",itemName + "_ButtonText");
         }
         if(itemTitleKey.indexOf("harvestbuildable") >= 0)
         {
            items = [{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_SlotOOverview","harvestbuildable_SlotOOverview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_SlotOTitle","harvestbuildable_SlotOTitle"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_SlotOBody","harvestbuildable_SlotOBody"),
               "imageUrl":prefixUrl + "_tut_01.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot1Overview","harvestbuildable_Slot1Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot1Title","harvestbuildable_Slot1Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot1Body","harvestbuildable_Slot1Body"),
               "imageUrl":prefixUrl + "_tut_02.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot2Overview","harvestbuildable_Slot2Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot2Title","harvestbuildable_Slot2Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot2Body","harvestbuildable_Slot2Body"),
               "imageUrl":prefixUrl + "_tut_03.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot3Overview","harvestbuildable_Slot3Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot3Title","harvestbuildable_Slot3Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs","harvestbuildable_Slot3Body","harvestbuildable_Slot3Body"),
               "imageUrl":prefixUrl + "_tut_04.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            }];
         }
         else if(itemTitleKey.indexOf("elitehorse") >= 0)
         {
            items = [{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_SlotOOverview","elitehorses_SlotOOverview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_SlotOTitle","elitehorses_SlotOTitle"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_SlotOBody","elitehorses_SlotOBody"),
               "imageUrl":prefixUrl + "_tut_01.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot1Overview","elitehorses_Slot1Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot1Title","elitehorses_Slot1Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot1Body","elitehorses_Slot1Body"),
               "imageUrl":prefixUrl + "_tut_02.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot2Overview","elitehorses_Slot2Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot2Title","elitehorses_Slot2Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot2Body","elitehorses_Slot2Body"),
               "imageUrl":prefixUrl + "_tut_03.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot3Overview","elitehorses_Slot3Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot3Title","elitehorses_Slot3Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs","elitehorses_Slot3Body","elitehorses_Slot3Body"),
               "imageUrl":prefixUrl + "_tut_04.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            }];
         }
         else
         {
            items = [{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_SlotOOverview",genericName + "_SlotOOverview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_SlotOTitle",genericName + "_SlotOTitle"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_SlotOBody",genericName + "_SlotOBody"),
               "imageUrl":prefixUrl + "_tut_01.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot1Overview",genericName + "_Slot1Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot1Title",genericName + "_Slot1Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot1Body",genericName + "_Slot1Body"),
               "imageUrl":prefixUrl + "_tut_02.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot2Overview",genericName + "_Slot2Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot2Title",genericName + "_Slot2Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot2Body",genericName + "_Slot2Body"),
               "imageUrl":prefixUrl + "_tut_03.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            },{
               "overview":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot3Overview",genericName + "_Slot3Overview"),
               "title":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot3Title",genericName + "_Slot3Title"),
               "body":ZLocUtils.getExistingLocalizationKey("Dialogs",itemName + "_Slot3Body",genericName + "_Slot3Body"),
               "imageUrl":prefixUrl + "_tut_04.jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs",
               "params":locParams
            }];
         }
         displayTutorialOnePageWindow(items,locParams.itemName,false,addToQueue,closeCallback,buttonText,hideCloseButton);
      }
      
      public static function displayBuildingTutorialWindow(building:FeatureBuilding, prefixUrl:String, addToQueue:Boolean = false, closeCallback:Function = null, buttonTextKey:String = null, hideCloseButton:Boolean = false) : void
      {
         TutorialUI.displayTutorialWindowForItem(building.bldgName,building.getFarmItem().friendlyName,prefixUrl,addToQueue,closeCallback,buttonTextKey,hideCloseButton);
      }
      
      public static function displayEvolutionTutorialWindow(assets:Array, addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = null;
         items = [{
            "overview":"EvolutionTutorial_Slot1Overview",
            "title":"EvolutionTutorial_Slot1Overview",
            "body":"EvolutionTutorial_Slot1Body",
            "imageUrl":assets[0],
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"EvolutionTutorial_Slot2Overview",
            "title":"EvolutionTutorial_Slot2Overview",
            "body":"EvolutionTutorial_Slot2Body",
            "imageUrl":assets[1],
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"EvolutionTutorial_Slot3Overview",
            "title":"EvolutionTutorial_Slot3Overview",
            "body":"EvolutionTutorial_Slot3Body",
            "imageUrl":assets[2],
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"EvolutionTutorial_Slot4Overview",
            "title":"EvolutionTutorial_Slot4Overview",
            "body":"EvolutionTutorial_Slot4Body",
            "imageUrl":assets[3],
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","EvolutionTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayTradingPostTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"tradingPostTutorial_SlotOOverview",
            "title":"tradingPostTutorial_SlotOTitle",
            "body":"tradingPostTutorial_SlotOBody",
            "imageUrl":"assets/dialogs/FV_Support/FV_TradingPost/TradingPost_tut_01.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"tradingPostTutorial_Slot1Overview",
            "title":"tradingPostTutorial_Slot1Title",
            "body":"tradingPostTutorial_Slot1Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_TradingPost/TradingPost_tut_02.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"tradingPostTutorial_Slot2Overview",
            "title":"tradingPostTutorial_Slot2Title",
            "body":"tradingPostTutorial_Slot2Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_TradingPost/TradingPost_tut_03.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"tradingPostTutorial_Slot3Overview",
            "title":"tradingPostTutorial_Slot3Title",
            "body":"tradingPostTutorial_Slot3Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_TradingPost/TradingPost_tut_04.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","tradingPostTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayCommunityGoalsTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var activeTask:CommunityGoalsTask = CommunityGoalsManager.getInstance().getActiveTask();
         var taskName:String = activeTask.name;
         var tutKey:String = "communityGoalsTutorial_" + taskName + "_SlotOOverview";
         var taskStr:String = "";
         if(ZLocUtils.hasString(ZLocConstants.DIALOG_UTIL_PKG,tutKey))
         {
            taskStr = "_" + taskName + "_";
         }
         else
         {
            taskStr = "_";
         }
         var tut0Img:String = activeTask.getAssetPathFor(CommunityGoalsManager.TUT_O_ASSET_KEY) != null ? activeTask.getAssetPathFor(CommunityGoalsManager.TUT_O_ASSET_KEY) : "assets/dialogs/FV_Support/FV_Expansions_Features/ToyLand/CommunityGoals/xtl_communitygoals_tut_01.jpg";
         var tut1Img:String = activeTask.getAssetPathFor(CommunityGoalsManager.TUT_1_ASSET_KEY) != null ? activeTask.getAssetPathFor(CommunityGoalsManager.TUT_1_ASSET_KEY) : "assets/dialogs/FV_Support/FV_Expansions_Features/ToyLand/CommunityGoals/xtl_communitygoals_tut_02.jpg";
         var tut2Img:String = activeTask.getAssetPathFor(CommunityGoalsManager.TUT_2_ASSET_KEY) != null ? activeTask.getAssetPathFor(CommunityGoalsManager.TUT_2_ASSET_KEY) : "assets/dialogs/FV_Support/FV_Expansions_Features/ToyLand/CommunityGoals/xtl_communitygoals_tut_03.jpg";
         var tut3Img:String = activeTask.getAssetPathFor(CommunityGoalsManager.TUT_3_ASSET_KEY) != null ? activeTask.getAssetPathFor(CommunityGoalsManager.TUT_3_ASSET_KEY) : "assets/dialogs/FV_Support/FV_Expansions_Features/ToyLand/CommunityGoals/xtl_communitygoals_tut_04.jpg";
         var items:Array = [{
            "overview":"communityGoalsTutorial" + taskStr + "SlotOOverview",
            "title":"communityGoalsTutorial" + taskStr + "SlotOTitle",
            "body":"communityGoalsTutorial_SlotOBody",
            "imageUrl":tut0Img,
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"communityGoalsTutorial" + taskStr + "Slot1Overview",
            "title":"communityGoalsTutorial" + taskStr + "Slot1Title",
            "body":"communityGoalsTutorial_Slot1Body",
            "imageUrl":tut1Img,
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"communityGoalsTutorial" + taskStr + "Slot2Overview",
            "title":"communityGoalsTutorial" + taskStr + "Slot2Title",
            "body":"communityGoalsTutorial_Slot2Body",
            "imageUrl":tut2Img,
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"communityGoalsTutorial" + taskStr + "Slot3Overview",
            "title":"communityGoalsTutorial" + taskStr + "Slot3Title",
            "body":"communityGoalsTutorial_Slot3Body",
            "imageUrl":tut3Img,
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","communityGoalsTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayLotteryTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"SweepstakesTutorial_SlotOOverview",
            "title":"SweepstakesTutorial_SlotOTitle",
            "body":"SweepstakesTutorial_SlotOBody",
            "imageUrl":"assets/dialogs/4d_elements/Sweepstakes/Sweepstakes_tut_01.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"SweepstakesTutorial_Slot1Overview",
            "title":"SweepstakesTutorial_Slot1Title",
            "body":"SweepstakesTutorial_Slot1Body",
            "imageUrl":"assets/dialogs/4d_elements/Sweepstakes/Sweepstakes_tut_02.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"SweepstakesTutorial_Slot2Overview",
            "title":"SweepstakesTutorial_Slot2Title",
            "body":"SweepstakesTutorial_Slot2Body",
            "imageUrl":"assets/dialogs/4d_elements/Sweepstakes/Sweepstakes_tut_03.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"SweepstakesTutorial_Slot3Overview",
            "title":"SweepstakesTutorial_Slot3Title",
            "body":"SweepstakesTutorial_Slot3Body",
            "imageUrl":"assets/dialogs/4d_elements/Sweepstakes/Sweepstakes_tut_04.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","SweepstakesTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayAmexTreeWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var locParams:Object = {"thirdPartyId":Global.player.thirdPartyID};
         var urlLinkButton4:String = "http://www.serve.com/zynga/?extlink=us-serve-zynga15-whatsthis-microsite-201205";
         var urlLink:String = "http://www.serve.com/farmville?zgid=63&zguid=" + Global.player.thirdPartyID + "&extlink=us-serve-zynga15-whatsthis-landing-201205&OfferCode=Zyn_A_Reg";
         var items:Array = [{
            "overview":"amextreeTutorial_SlotOOverview",
            "title":"amextreeTutorial_SlotOTitle",
            "body":"amextreeTutorial_SlotOBody",
            "imageUrl":"assets/dialogs/4d_elements/AMEXServeTree/SERVETree_tut_01.jpg",
            "buttonTitle":"amextreeTutorial_ButtonTitle",
            "localiztionBundle":"Dialogs",
            "params":locParams,
            "buttonUrl":urlLink
         },{
            "overview":"amextreeTutorial_Slot1Overview",
            "title":"amextreeTutorial_Slot1Title",
            "body":"amextreeTutorial_Slot1Body",
            "imageUrl":"assets/dialogs/4d_elements/AMEXServeTree/SERVETree_tut_02.jpg",
            "buttonTitle":"amextreeTutorial_ButtonTitle",
            "localiztionBundle":"Dialogs",
            "params":locParams,
            "buttonUrl":urlLink
         },{
            "overview":"amextreeTutorial_Slot2Overview",
            "title":"amextreeTutorial_Slot2Title",
            "body":"amextreeTutorial_Slot2Body",
            "imageUrl":"assets/dialogs/4d_elements/AMEXServeTree/SERVETree_tut_03.jpg",
            "buttonTitle":"amextreeTutorial_ButtonTitle",
            "localiztionBundle":"Dialogs",
            "params":locParams,
            "buttonUrl":urlLink
         },{
            "overview":"amextreeTutorial_Slot3Overview",
            "title":"amextreeTutorial_Slot3Title",
            "body":"amextreeTutorial_Slot3Body",
            "imageUrl":"assets/dialogs/4d_elements/AMEXServeTree/SERVETree_tut_04.jpg",
            "buttonTitle":"amextreeTutorial_ButtonTitle_SeeTerms",
            "localiztionBundle":"Dialogs",
            "params":locParams,
            "buttonUrl":urlLinkButton4
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","amextreeTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayRaffleTutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null) : void
      {
         var items:Array = [{
            "overview":"socialrafflebuildingTutorial_SlotOOverview",
            "title":"socialrafflebuildingTutorial_SlotOTitle",
            "body":"socialrafflebuildingTutorial_SlotOBody",
            "imageUrl":"assets/dialogs/FV_Support/FV_SocialRaffle/SocialRaffle_tut_imgs1.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"socialrafflebuildingTutorial_Slot1Overview",
            "title":"socialrafflebuildingTutorial_Slot1Title",
            "body":"socialrafflebuildingTutorial_Slot1Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_SocialRaffle/SocialRaffle_tut_imgs2.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"socialrafflebuildingTutorial_Slot2Overview",
            "title":"socialrafflebuildingTutorial_Slot2Title",
            "body":"socialrafflebuildingTutorial_Slot2Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_SocialRaffle/SocialRaffle_tut_imgs3.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":"socialrafflebuildingTutorial_Slot3Overview",
            "title":"socialrafflebuildingTutorial_Slot3Title",
            "body":"socialrafflebuildingTutorial_Slot3Body",
            "imageUrl":"assets/dialogs/FV_Support/FV_SocialRaffle/SocialRaffle_tut_imgs4.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs","socialrafflebuildingTutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayCraftingV2TutorialWindow(addToQueue:Boolean = false, closeCallback:Function = null, craftType:String = "craftshop", farmItem:FarmItem = null) : void
      {
         if(!farmItem)
         {
            farmItem = Global.craftConfigSettings.getCottageItemForSkill(craftType);
         }
         var tut1:String = farmItem.getImageByName("tut1");
         var tut2:String = farmItem.getImageByName("tut2");
         var tut3:String = farmItem.getImageByName("tut3");
         var tut4:String = farmItem.getImageByName("tut4");
         var items:Array = [{
            "overview":craftType + "v2Tutorial_Slot0Overview",
            "title":craftType + "v2Tutorial_Slot0Title",
            "body":craftType + "v2Tutorial_Slot0Body",
            "imageUrl":tut1,
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":craftType + "v2Tutorial_Slot1Overview",
            "title":craftType + "v2Tutorial_Slot1Title",
            "body":craftType + "v2Tutorial_Slot1Body",
            "imageUrl":tut2,
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":craftType + "v2Tutorial_Slot2Overview",
            "title":craftType + "v2Tutorial_Slot2Title",
            "body":craftType + "v2Tutorial_Slot2Body",
            "imageUrl":tut3,
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         },{
            "overview":craftType + "v2Tutorial_Slot3Overview",
            "title":craftType + "v2Tutorial_Slot3Title",
            "body":craftType + "v2Tutorial_Slot3Body",
            "imageUrl":tut4,
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":"Dialogs"
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs",craftType + "v2Tutorial_Title"),false,addToQueue,closeCallback);
      }
      
      public static function displayBundleTutorialWindow(bundle:String, bundlePrefix:String, assetPrefix:String, addToQueue:Boolean = false, closeCallback:Function = null, assetPostFix:String = "tut_imgs") : void
      {
         var items:Array = [{
            "overview":bundlePrefix + "Tutorial_SlotOOverview",
            "title":bundlePrefix + "Tutorial_SlotOTitle",
            "body":bundlePrefix + "Tutorial_SlotOBody",
            "imageUrl":assetPrefix + "_" + assetPostFix + "1.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":bundle
         },{
            "overview":bundlePrefix + "Tutorial_Slot1Overview",
            "title":bundlePrefix + "Tutorial_Slot1Title",
            "body":bundlePrefix + "Tutorial_Slot1Body",
            "imageUrl":assetPrefix + "_" + assetPostFix + "2.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":bundle
         },{
            "overview":bundlePrefix + "Tutorial_Slot2Overview",
            "title":bundlePrefix + "Tutorial_Slot2Title",
            "body":bundlePrefix + "Tutorial_Slot2Body",
            "imageUrl":assetPrefix + "_" + assetPostFix + "3.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":bundle
         },{
            "overview":bundlePrefix + "Tutorial_Slot3Overview",
            "title":bundlePrefix + "Tutorial_Slot3Title",
            "body":bundlePrefix + "Tutorial_Slot3Body",
            "imageUrl":assetPrefix + "_" + assetPostFix + "4.jpg",
            "buttonTitle":"",
            "buttonUrl":"",
            "localiztionBundle":bundle
         }];
         displayTutorialOnePageWindow(items,ZLocUtils.t(bundle,bundlePrefix + "Tutorial_Title"),false,addToQueue,closeCallback);
      }
      
      private static function onCraftingTutorialWindowClose(event:Event) : void
      {
         if(m_craftingTutorialWindow)
         {
            m_craftingTutorialWindow.removeEventListener(CloseEvent.CLOSE,onCraftingTutorialWindowClose);
            m_craftingTutorialWindow = null;
            UI.stopPopups(false);
         }
      }
      
      public static function displayTutorialOnePageWindow(items:Array, title:String, version2:Boolean, addToQueue:Boolean = false, closeCallback:Function = null, buttonText:String = null, hideCloseButton:Boolean = false, faqLink:String = "") : void
      {
         if(null == m_tutorialOnePageWindow)
         {
            m_closeTutorialOnePageWindowCallback = closeCallback;
            m_tutorialOnePageWindow = new TutorialOnePageWindow(items,title,version2,buttonText,hideCloseButton,faqLink);
            m_tutorialOnePageWindow.addEventListener(CloseEvent.CLOSE,onTutorialOnePageWindowClose);
            UI.displayPopup(m_tutorialOnePageWindow,addToQueue);
            if(!addToQueue)
            {
               UI.stopPopups(true);
            }
         }
      }
      
      private static function onTutorialOnePageWindowClose(event:Event) : void
      {
         if(m_tutorialOnePageWindow)
         {
            m_tutorialOnePageWindow.removeEventListener(CloseEvent.CLOSE,onTutorialOnePageWindowClose);
            m_tutorialOnePageWindow = null;
            UI.stopPopups(false);
            if(m_closeTutorialOnePageWindowCallback != null)
            {
               m_closeTutorialOnePageWindowCallback();
               m_closeTutorialOnePageWindowCallback = null;
            }
         }
      }
      
      public static function displayTutorialWindow(message:String, offset:Point, closeCallback:Function = null) : void
      {
         if(allWindowsClosed())
         {
            m_tutorialWindow = new TutorialWindow(message,offset,closeCallback);
            m_tutorialWindow.addEventListener(CloseEvent.CLOSE,onTutorialWindowClose);
            UI.displayPopup(m_tutorialWindow,false);
            UI.stopPopups(true);
            if(offset != null)
            {
               m_tutorialWindow.x += offset.x;
               m_tutorialWindow.y += offset.y;
            }
         }
         else
         {
            m_tutorialWindowFunctionQueue.push(function():void
            {
               TutorialUI.displayTutorialWindow(message,offset,closeCallback);
            });
         }
      }
      
      public static function displayDragonBreedingTutorialWindow(message:String, offset:Point, dialogUrl:String = "") : void
      {
         if(allWindowsClosed())
         {
            m_tutorialWindow = new TutorialWindow(message,offset,null,dialogUrl);
            m_tutorialWindow.addEventListener(CloseEvent.CLOSE,onTutorialWindowClose);
            UI.displayPopup(m_tutorialWindow,false);
            UI.stopPopups(true);
            if(offset != null)
            {
               m_tutorialWindow.x += offset.x;
               m_tutorialWindow.y += offset.y;
            }
         }
         else
         {
            m_tutorialWindowFunctionQueue.push(function():void
            {
               TutorialUI.displayDragonBreedingTutorialWindow(message,offset,dialogUrl);
            });
         }
      }
      
      private static function onTutorialWindowClose(event:Event) : void
      {
         if(m_tutorialWindow)
         {
            m_tutorialWindow.removeEventListener(CloseEvent.CLOSE,onTutorialWindowClose);
            m_tutorialWindow = null;
            UI.stopPopups(false);
         }
      }
      
      public static function closeTutorialWindow() : void
      {
         if(m_tutorialWindow != null)
         {
            m_tutorialWindow.close();
         }
      }
      
      public static function displayTutorialAcceptButtonWindow(message:String, buttonString:String, offset:Point, acceptCallback:Function = null, closeCallback:Function = null) : void
      {
         if(allWindowsClosed())
         {
            m_tutorialAcceptButtonWindow = new TutorialAcceptButtonWindow(message,buttonString,offset,acceptCallback,closeCallback);
            m_tutorialAcceptButtonWindow.addEventListener(CloseEvent.CLOSE,onTutorialAcceptButtonWindowClose);
            UI.displayPopup(m_tutorialAcceptButtonWindow,false);
            UI.stopPopups(true);
         }
         else
         {
            m_tutorialWindowFunctionQueue.push(function():void
            {
               TutorialUI.displayTutorialAcceptButtonWindow(message,buttonString,offset,acceptCallback,closeCallback);
            });
         }
      }
      
      private static function onTutorialAcceptButtonWindowClose(event:Event) : void
      {
         if(m_tutorialAcceptButtonWindow)
         {
            m_tutorialAcceptButtonWindow.removeEventListener(CloseEvent.CLOSE,onTutorialAcceptButtonWindowClose);
            m_tutorialAcceptButtonWindow = null;
            UI.stopPopups(false);
         }
      }
      
      public static function closeTutorialAcceptButtonWindow() : void
      {
         if(m_tutorialAcceptButtonWindow != null)
         {
            m_tutorialAcceptButtonWindow.close();
         }
      }
      
      public static function displayTutorialTitleButtonWindow(title:String, message:String, buttonString:String, closeCallback:Function = null) : void
      {
         if(allWindowsClosed())
         {
            m_tutorialTitleButtonWindow = new TutorialTitleButtonWindow(title,message,buttonString);
            m_tutorialTitleButtonWindow.addEventListener(CloseEvent.CLOSE,onTutorialTitleButtonWindowClose);
            UI.displayPopup(m_tutorialTitleButtonWindow,false);
            UI.stopPopups(true);
            m_closeTutorialAssetCallback = closeCallback;
         }
         else
         {
            m_tutorialWindowFunctionQueue.push(function():void
            {
               TutorialUI.displayTutorialTitleButtonWindow(title,message,buttonString,closeCallback);
            });
         }
      }
      
      public static function displayTutorialTitleButtonWindowWithAsset(title:String, message:String, buttonString:String, asset:String, callback:Function = null) : void
      {
         if(allWindowsClosed())
         {
            m_tutorialTitleButtonWindow = new TutorialTitleButtonWindow(title,message,buttonString,asset);
            m_tutorialTitleButtonWindow.addEventListener(CloseEvent.CLOSE,onTutorialTitleButtonWindowClose);
            UI.displayPopup(m_tutorialTitleButtonWindow,false);
            UI.stopPopups(true);
            m_closeTutorialAssetCallback = callback;
         }
         else
         {
            m_tutorialWindowFunctionQueue.push(function():void
            {
               TutorialUI.displayTutorialTitleButtonWindowWithAsset(title,message,buttonString,asset,callback);
            });
         }
      }
      
      private static function allWindowsClosed() : Boolean
      {
         return m_tutorialWindow == null && m_tutorialAcceptButtonWindow == null && m_tutorialTitleButtonWindow == null;
      }
      
      private static function onTutorialTitleButtonWindowClose(event:Event) : void
      {
         if(m_tutorialTitleButtonWindow)
         {
            m_tutorialTitleButtonWindow.removeEventListener(CloseEvent.CLOSE,onTutorialTitleButtonWindowClose);
            m_tutorialTitleButtonWindow = null;
            if(m_closeTutorialAssetCallback != null)
            {
               m_closeTutorialAssetCallback(event);
            }
            UI.stopPopups(false);
         }
      }
      
      public static function closeTutorialTitleButtonWindow() : void
      {
         if(m_tutorialTitleButtonWindow != null)
         {
            m_tutorialTitleButtonWindow.close();
         }
      }
      
      public static function addBouncingArrows(mc:MovieClip, mat1:Matrix, mat2:Matrix = null) : void
      {
         if(!m_bouncingArrow1)
         {
            m_bouncingArrow1 = new EmbeddedArt.bouncing_arrow() as DisplayObject;
            m_bouncingArrow1.transform.matrix = mat1;
            mc.addChild(m_bouncingArrow1);
         }
         if(Boolean(mat2) && !m_bouncingArrow2)
         {
            m_bouncingArrow2 = new EmbeddedArt.bouncing_arrow() as DisplayObject;
            m_bouncingArrow2.transform.matrix = mat2;
            mc.addChild(m_bouncingArrow2);
         }
      }
      
      public static function addBouncingArrowsForDragonBreeding(mc:MovieClip, mat1:Matrix, mat2:Matrix = null) : void
      {
         if(!m_breedingArrow1)
         {
            m_breedingArrow1 = new EmbeddedArt.bouncing_breeding_arrow() as DisplayObject;
            m_breedingArrow1.transform.matrix = mat1;
            mc.addChild(m_breedingArrow1);
         }
         if(Boolean(mat2) && !m_breedingArrow2)
         {
            m_breedingArrow2 = new EmbeddedArt.bouncing_breeding_arrow() as DisplayObject;
            m_breedingArrow2.transform.matrix = mat2;
            mc.addChild(m_breedingArrow2);
         }
      }
      
      public static function addBouncingArrowsForStage(mat1:Matrix, mat2:Matrix = null) : void
      {
         if(!m_breedingArrow1)
         {
            m_breedingArrow1 = new EmbeddedArt.bouncing_breeding_arrow() as DisplayObject;
            m_breedingArrow1.transform.matrix = mat1;
            GlobalEngine.stage.addChild(m_breedingArrow1);
         }
      }
      
      public static function removeBouncingArrowsForDragonBreeding(mc:MovieClip) : void
      {
         if(m_breedingArrow1)
         {
            if(mc.contains(m_breedingArrow1))
            {
               mc.removeChild(m_breedingArrow1);
            }
            m_breedingArrow1 = null;
         }
         if(m_breedingArrow2)
         {
            if(mc.contains(m_breedingArrow2))
            {
               mc.removeChild(m_breedingArrow2);
            }
            m_breedingArrow2 = null;
         }
      }
      
      public static function removeBouncingArrowsForStage() : void
      {
         if(m_breedingArrow1)
         {
            if(GlobalEngine.stage.contains(m_breedingArrow1))
            {
               GlobalEngine.stage.removeChild(m_breedingArrow1);
            }
            m_breedingArrow1 = null;
         }
      }
      
      public static function removeBouncingArrows(mc:MovieClip) : void
      {
         if(m_bouncingArrow1)
         {
            if(mc.contains(m_bouncingArrow1))
            {
               mc.removeChild(m_bouncingArrow1);
            }
            m_bouncingArrow1 = null;
         }
         if(m_bouncingArrow2)
         {
            if(mc.contains(m_bouncingArrow2))
            {
               mc.removeChild(m_bouncingArrow2);
            }
            m_bouncingArrow2 = null;
         }
      }
      
      public static function enterFrame() : void
      {
         var func:Function = null;
         if(m_tutorialWindowFunctionQueue.length > 0 && m_tutorialWindow == null && m_tutorialAcceptButtonWindow == null && m_tutorialTitleButtonWindow == null)
         {
            func = m_tutorialWindowFunctionQueue.shift();
            func();
         }
         if(m_tutorialWindow != null)
         {
            m_tutorialWindow.enterFrame();
         }
         if(m_tutorialAcceptButtonWindow != null)
         {
            m_tutorialAcceptButtonWindow.enterFrame();
         }
         if(m_tutorialTitleButtonWindow != null)
         {
            m_tutorialTitleButtonWindow.enterFrame();
         }
      }
   }
}

