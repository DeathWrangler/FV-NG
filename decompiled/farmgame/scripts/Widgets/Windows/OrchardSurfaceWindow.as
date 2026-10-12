package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.MapResource;
   import Classes.Tree;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OrchardSurfaceWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_harvestPrompt_orchards.swf";
      
      private static const ORCHARD_NAME_HOME:String = "orchard";
      
      private static const ORCHARD_NAME_EC:String = "xukorchard";
      
      private static const ORCHARD_NAME_FC:String = "xcoveorchard";
      
      private static const ORCHARD_NAME_WW:String = "xwworchard";
      
      private static const ORCHARD_NAME_HI:String = "xhiorchard";
      
      private static const FEATURE_SURFACING_FLAG:String = "fv_tree_orchard_prompt";
      
      private static const BACK_OFF_TIME_IN_SEC:Number = 30 * FarmGameUtil.NUM_SECS_IN_DAY;
      
      protected var m_buildingItem:FarmItem = null;
      
      protected var m_targetItem:FarmItem = null;
      
      private var m_hasOrchard:Boolean = false;
      
      public function OrchardSurfaceWindow(breedingPenItem:FarmItem, treeItem:FarmItem, hasOrchard:Boolean)
      {
         super(ASSET_URL);
         this.m_buildingItem = breedingPenItem;
         this.m_targetItem = treeItem;
         this.m_hasOrchard = hasOrchard;
         FarmStatsManager.count("dialog",this.getStatsKingdom(),"view",this.m_buildingItem.name);
      }
      
      private static function getFeatureFreqKey() : String
      {
         return FEATURE_SURFACING_FLAG + "_" + Global.worldManager.currentWorldType;
      }
      
      public static function conditionallyShowPrompt(tree:Tree) : Boolean
      {
         var now:Number = NaN;
         var coolDown:Number = NaN;
         var hasFinishedOrchardWithCapacity:Boolean = false;
         var finishedOrchards:Array = null;
         var finishedOrchard:Object = null;
         var hasOrchardUnderConstruction:Boolean = false;
         var orchardsUnderConstruction:Array = null;
         var orchardFarmItem:FarmItem = null;
         var hasOrchardOnFarm:Boolean = false;
         var showedUi:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TREE_HARVEST_ORCHARD_PROMO) > 1)
         {
            now = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            coolDown = Global.player.getFeatureLastShown(OrchardSurfaceWindow.getFeatureFreqKey()) + BACK_OFF_TIME_IN_SEC;
            if(coolDown <= now)
            {
               hasFinishedOrchardWithCapacity = false;
               finishedOrchards = FeatureBuildingSurfacingManager.getInstance().searchForStorageBuildingsInWorld(tree);
               for each(finishedOrchard in finishedOrchards)
               {
                  if(finishedOrchard.isFull() == false)
                  {
                     hasFinishedOrchardWithCapacity = true;
                     break;
                  }
               }
               hasOrchardUnderConstruction = false;
               orchardsUnderConstruction = FeatureBuildingSurfacingManager.getInstance().searchForConstructionBuildingsInWorld(tree);
               if(orchardsUnderConstruction.length > 0)
               {
                  hasOrchardUnderConstruction = true;
               }
               if(hasFinishedOrchardWithCapacity == false && hasOrchardUnderConstruction == false)
               {
                  orchardFarmItem = OrchardSurfaceWindow.getOrchardFrameByWorld(Global.worldManager.currentWorldType);
                  if(orchardFarmItem != null && surfacedItemCanTake(tree,orchardFarmItem) && !orchardFarmItem.checkItemLimit())
                  {
                     showedUi = true;
                     Global.player.setFeatureLastShown(OrchardSurfaceWindow.getFeatureFreqKey(),GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
                     hasOrchardOnFarm = finishedOrchards.length + orchardsUnderConstruction.length > 0 ? true : false;
                     UI.displayPopup(new OrchardSurfaceWindow(orchardFarmItem,tree.getItem(),hasOrchardOnFarm));
                  }
               }
            }
         }
         return showedUi;
      }
      
      private static function surfacedItemCanTake(itemToContain:MapResource, surfacedItem:FarmItem) : Boolean
      {
         var finishedItem:FarmItem = null;
         var storageName:String = null;
         var result:Boolean = false;
         var finishedName:String = surfacedItem.getFinishedName();
         if(Boolean(finishedName) && finishedName != "")
         {
            finishedItem = Global.farmGameSettingsManager.getFarmItemByName(finishedName);
            if(finishedItem)
            {
               storageName = finishedItem.storageClass;
               result = Global.storageSettings.storageCanTake(storageName,itemToContain);
            }
         }
         return result;
      }
      
      public static function getOrchardFrameByWorld(worldType:String) : FarmItem
      {
         var result:FarmItem = null;
         switch(worldType)
         {
            case WorldsConstants.WORLD_ID_HOME:
               result = Global.farmGameSettingsManager.getFarmItemByName(ORCHARD_NAME_HOME);
               break;
            case WorldsConstants.WORLD_ID_ENGLAND:
               result = Global.farmGameSettingsManager.getFarmItemByName(ORCHARD_NAME_EC);
               break;
            case WorldsConstants.WORLD_ID_FISHERMAN:
               result = Global.farmGameSettingsManager.getFarmItemByName(ORCHARD_NAME_FC);
               break;
            case WorldsConstants.WORLD_ID_WINTER_WONDERLAND:
               result = Global.farmGameSettingsManager.getFarmItemByName(ORCHARD_NAME_WW);
               break;
            case WorldsConstants.WORLD_ID_HAWAII:
               result = Global.farmGameSettingsManager.getFarmItemByName(ORCHARD_NAME_HI);
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var titleLocKey:String = null;
         var message:String = null;
         super.postLoadComplete();
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","TreeHarvestOrchard_accept"),this.onAccept));
         var buildingImageHolder:ZwFrame = new ZwFrame(m_window.container_mc);
         addWidget(buildingImageHolder);
         this.setBuildingMovieclipFrame(buildingImageHolder.element as MovieClip,this.m_buildingItem.name);
         if(this.m_targetItem != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","TreeHarvestOrchardSurfacing_title")));
            if(this.m_hasOrchard)
            {
               titleLocKey = "TreeHarvestOrchardSurfacing_body_full_orchard";
            }
            else
            {
               titleLocKey = "TreeHarvestOrchardSurfacing_body_no_orchard";
            }
            message = ZLocUtils.t("Dialogs",titleLocKey,{
               "itemName":ZLocUtils.tk_pk(this.m_targetItem.friendlyName),
               "buildingName":ZLocUtils.tk_pk(this.m_buildingItem.friendlyName)
            });
            addWidget(new ZwTextField(m_window.popupBox_tf,message));
            addWidget(new FarmIcon(m_window.icon_mc,this.m_targetItem.icon));
            addWidget(new ZwFrame(m_window.select_mc));
         }
      }
      
      protected function setBuildingMovieclipFrame(movieClip:MovieClip, buildingName:String) : void
      {
         var frameName:String = "";
         switch(buildingName)
         {
            case ORCHARD_NAME_HOME:
               frameName = "bldg_orchard";
               break;
            case ORCHARD_NAME_EC:
               frameName = "xuk_bldg_orchard";
               break;
            case ORCHARD_NAME_FC:
               frameName = "xcove_bldg_orchard";
               break;
            case ORCHARD_NAME_FC:
               frameName = "xww_bldg_orchard";
               break;
            case ORCHARD_NAME_HI:
               frameName = "xhi_bldg_orchard";
         }
         movieClip.gotoAndStop(frameName);
      }
      
      protected function onAccept(event:Event) : void
      {
         close();
         var constructionBuildingName:String = this.m_buildingItem.name;
         var fromMarket:Boolean = Global.player.getGiftCountForItem(constructionBuildingName) > 0 ? false : true;
         Global.world.enterForcePlaceMode(constructionBuildingName,fromMarket,0,true,!fromMarket);
         FarmStatsManager.count("dialog",this.getStatsKingdom(),"place",constructionBuildingName);
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         FarmStatsManager.count("dialog",this.getStatsKingdom(),"x",this.m_buildingItem.name);
      }
      
      private function getStatsKingdom() : String
      {
         var result:String = "";
         if(this.m_hasOrchard == false)
         {
            result = "tree_harvest_orchardpromo_first";
         }
         else
         {
            result = "tree_harvest_orchardpromo_another";
         }
         return result;
      }
   }
}

