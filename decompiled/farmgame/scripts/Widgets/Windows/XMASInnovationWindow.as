package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.XMASInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class XMASInnovationWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      private static const INNOVATION_FEATURE_SEEN_FLAG:String = "XMASInnovation_Tutorial";
      
      protected var m_featureName:String;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const COUNT_TF:String = "count_tf";
      
      private const NAME_TF:String = "name_tf";
      
      private const BT_HARVEST:String = "bt_harvest";
      
      private const BT_FCREADY:String = "bt_FCready";
      
      private const BT_SEETILE:String = "bt_seeTile";
      
      private const GIFTS_BUTTON:String = "bt_gifts";
      
      private const TEXT_TITLE:String = "_MainWindow_Title";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const TEXT_BODY:String = "_MainWindow_Body";
      
      private const TEXT_HARVEST:String = "_MainWindow_HarvestButton_Text";
      
      private const TEXT_MAKE_HARVEST_READY:String = "_MainWindow_MakeHarvestReadyButton_Text";
      
      private const TEXT_SEE_TILE:String = "_MainWindow_SeeTileButton_Text";
      
      private const TEXT_CHRISTMAS_BUTTON:String = "_MainWindow_ChristmasUIButton_Text";
      
      private var m_buildingsArray:Array;
      
      private var m_harvestReady_btArray:Array;
      
      private var m_harvest_btArray:Array;
      
      private var m_seeTile_btArray:Array;
      
      private var m_buildingNameArray:Array;
      
      private const PAN_TO_TILE_METHODS:Vector.<Function>;
      
      private const MAKE_READY_HARVEST_METHODS:Vector.<Function>;
      
      private const HARVEST_METHODS:Vector.<Function>;
      
      private var m_consumableArray:Array;
      
      private var m_consumableAddArray:Array;
      
      private var m_consumableIconArray:Array;
      
      private var m_xmasInnovationManager:XMASInnovationManager = XMASInnovationManager.getInstance();
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Cool!","Cool!","Next","Next","Next","Okay!"];
      
      public function XMASInnovationWindow(building:FeatureBuilding, featureName:String, assetPath:String = "")
      {
         this.PAN_TO_TILE_METHODS = new <Function>[this.PanToTile0,this.PanToTile1,this.PanToTile2];
         this.MAKE_READY_HARVEST_METHODS = new <Function>[this.MakeHarvestReadyBuilding0,this.MakeHarvestReadyBuilding1,this.MakeHarvestReadyBuilding2];
         this.HARVEST_METHODS = new <Function>[this.HarvestBuilding0,this.HarvestBuilding1,this.HarvestBuilding2];
         if(building != null)
         {
            assetPath = building.getItem().getDialogConfig("storage").path;
         }
         this.m_featureName = featureName;
         this.m_buildingNameArray = this.m_xmasInnovationManager.buildingNameArray;
         XMASInnovationManager.getInstance(this.m_featureName).initialize();
         this.m_harvestReady_btArray = new Array();
         this.m_harvest_btArray = new Array();
         this.m_seeTile_btArray = new Array();
         this.m_buildingsArray = new Array();
         this.m_consumableArray = new Array();
         this.m_consumableAddArray = new Array();
         this.m_consumableIconArray = new Array();
         super(this.m_featureName,assetPath,NUM_TUTORIAL_SCENES,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var buildingItem:FarmItem = null;
         var consumableCode:String = null;
         var ConsumableItem:FarmItem = null;
         var consumableToolTip:String = null;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY)));
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.GIFTS_BUTTON))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.GIFTS_BUTTON],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_CHRISTMAS_BUTTON),this.showMarketUI));
         }
         for(var buildingIndex:int = 0; buildingIndex < this.m_xmasInnovationManager.buildingNameArray.length; buildingIndex++)
         {
            if(m_window.hasOwnProperty("deco" + buildingIndex.toString() + "_mc"))
            {
               this.m_buildingsArray[buildingIndex] = m_window["deco" + buildingIndex.toString() + "_mc"] as MovieClip;
               if(this.m_buildingsArray[buildingIndex])
               {
                  this.m_buildingsArray[buildingIndex].visible = true;
                  if(this.m_buildingsArray[buildingIndex].hasOwnProperty(this.NAME_TF))
                  {
                     buildingItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_buildingNameArray[buildingIndex]);
                     this.m_buildingsArray[buildingIndex][this.NAME_TF].text = buildingItem.friendlyTitle;
                  }
                  this.m_harvestReady_btArray[buildingIndex] = new FarmAnimatedCashButton(this.m_buildingsArray[buildingIndex][this.BT_FCREADY],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_MAKE_HARVEST_READY),this.m_xmasInnovationManager.skipCost.toString(),this.MAKE_READY_HARVEST_METHODS[buildingIndex]);
                  this.m_harvest_btArray[buildingIndex] = new FarmAnimatedTextButton(this.m_buildingsArray[buildingIndex][this.BT_HARVEST],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_HARVEST),this.HARVEST_METHODS[buildingIndex]);
                  this.m_seeTile_btArray[buildingIndex] = new FarmAnimatedTextButton(this.m_buildingsArray[buildingIndex][this.BT_SEETILE],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_SEE_TILE),this.PAN_TO_TILE_METHODS[buildingIndex]);
               }
            }
            if(m_window.hasOwnProperty("collection" + buildingIndex.toString() + "_mc"))
            {
               this.m_consumableArray[buildingIndex] = m_window["collection" + buildingIndex.toString() + "_mc"] as MovieClip;
               if(this.m_consumableArray[buildingIndex])
               {
                  this.m_consumableArray[buildingIndex].visible = true;
                  if(this.m_consumableArray[buildingIndex].hasOwnProperty(this.COUNT_TF))
                  {
                     consumableCode = this.m_xmasInnovationManager.ConsumableList[buildingIndex];
                     this.m_consumableArray[buildingIndex][this.COUNT_TF].text = "x" + FeatureOptionsInventoryManager.getInstance().getCount(consumableCode).toString();
                     this.m_consumableIconArray[buildingIndex] = new FarmIcon(this.m_consumableArray[buildingIndex]);
                     ConsumableItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_xmasInnovationManager.ConsumableList[buildingIndex]);
                     consumableToolTip = ConsumableItem.friendlyTitle;
                     this.m_consumableIconArray[buildingIndex].visible = true;
                     (this.m_consumableIconArray[buildingIndex] as FarmIcon).attachTooltip(new FarmTextTooltip(consumableToolTip));
                  }
               }
            }
            if(m_window.hasOwnProperty("collection" + buildingIndex.toString() + "Add_mc"))
            {
               this.m_consumableAddArray[buildingIndex] = m_window["collection" + buildingIndex.toString() + "Add_mc"] as MovieClip;
               if(this.m_consumableAddArray[buildingIndex])
               {
                  this.m_consumableAddArray[buildingIndex].visible = false;
               }
            }
         }
         this.updateBuildingButtons();
         super.postLoadComplete();
      }
      
      public function updateConsumableCount() : void
      {
         var consumableCode:String = null;
         for(var buildingIndex:int = 0; buildingIndex < this.m_xmasInnovationManager.buildingNameArray.length; buildingIndex++)
         {
            if(this.m_consumableArray[buildingIndex])
            {
               this.m_consumableArray[buildingIndex].visible = true;
               if(this.m_consumableArray[buildingIndex].hasOwnProperty(this.COUNT_TF))
               {
                  consumableCode = this.m_xmasInnovationManager.ConsumableList[buildingIndex];
                  this.m_consumableArray[buildingIndex][this.COUNT_TF].text = "x" + FeatureOptionsInventoryManager.getInstance().getCount(consumableCode).toString();
               }
            }
         }
      }
      
      private function updateBuildingButtons() : void
      {
         var toolTip:String = null;
         var tileName:String = null;
         var tileItem:FarmItem = null;
         var toolTip2:String = null;
         for(var buildingIndex:int = 0; buildingIndex < this.m_xmasInnovationManager.buildingNameArray.length; buildingIndex++)
         {
            if(this.m_xmasInnovationManager.isTileUnlocked(XMASInnovationManager.getInstance().associatedTilesNameArray[buildingIndex]))
            {
               this.resetWindowButtons(buildingIndex);
               if(this.m_xmasInnovationManager.IsBuildingReadyToHarvest(buildingIndex))
               {
                  this.m_harvest_btArray[buildingIndex].visible = true;
                  this.m_harvest_btArray[buildingIndex].enabled = true;
                  (this.m_harvest_btArray[buildingIndex] as FarmAnimatedButton).detachTooltip();
                  this.m_harvest_btArray[buildingIndex].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_HARVEST);
                  this.m_harvest_btArray[buildingIndex].callback = this.HARVEST_METHODS[buildingIndex];
               }
               else
               {
                  this.m_harvest_btArray[buildingIndex].visible = true;
                  this.m_harvestReady_btArray[buildingIndex].visible = true;
                  this.m_harvestReady_btArray[buildingIndex].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_MAKE_HARVEST_READY);
                  this.m_harvestReady_btArray[buildingIndex].callback = this.MAKE_READY_HARVEST_METHODS[buildingIndex];
                  (this.m_harvest_btArray[buildingIndex] as FarmAnimatedTextButton).detachTooltip();
                  toolTip = HUD.getformattedTimeLeft(this.m_xmasInnovationManager.getTimeLeftForSlot(buildingIndex));
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_harvest_btArray[buildingIndex],toolTip);
               }
            }
            else
            {
               this.resetWindowButtons(buildingIndex);
               this.m_seeTile_btArray[buildingIndex].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_SEE_TILE);
               this.m_seeTile_btArray[buildingIndex].visible = true;
               this.m_seeTile_btArray[buildingIndex].callback = this.PAN_TO_TILE_METHODS[buildingIndex];
               (this.m_seeTile_btArray[buildingIndex] as FarmAnimatedButton).detachTooltip();
               tileName = XMASInnovationManager.getInstance().associatedTilesNameArray[buildingIndex];
               tileItem = Global.farmGameSettingsManager.getFarmItemByName(tileName);
               toolTip2 = tileItem.friendlyTitle;
               (this.m_seeTile_btArray[buildingIndex] as FarmAnimatedButton).attachTooltip(new FarmTextTooltip(toolTip2));
            }
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      private function showMarketUI(event:Event) : void
      {
         this.m_xmasInnovationManager.showRedeemUI();
      }
      
      private function PanToTile2(event:Event) : void
      {
         this.m_xmasInnovationManager.panToTile(XMASInnovationManager.getInstance().associatedTilesNameArray[2]);
         FarmStatsManager.count(this.m_featureName,"main_ui","PanToTile2","click");
      }
      
      private function PanToTile1(event:Event) : void
      {
         this.m_xmasInnovationManager.panToTile(XMASInnovationManager.getInstance().associatedTilesNameArray[1]);
         FarmStatsManager.count(this.m_featureName,"main_ui","PanToTile1","click");
      }
      
      private function PanToTile0(event:Event) : void
      {
         this.m_xmasInnovationManager.panToTile(XMASInnovationManager.getInstance().associatedTilesNameArray[0]);
         FarmStatsManager.count(this.m_featureName,"main_ui","PanToTile0","click");
      }
      
      private function HarvestBuilding0(event:Event) : void
      {
         this.m_xmasInnovationManager.HarvestBuilding(0);
      }
      
      private function HarvestBuilding1(event:Event) : void
      {
         this.m_xmasInnovationManager.HarvestBuilding(1);
      }
      
      private function HarvestBuilding2(event:Event) : void
      {
         this.m_xmasInnovationManager.HarvestBuilding(2);
      }
      
      private function MakeHarvestReadyBuilding0(event:Event) : void
      {
         this.m_xmasInnovationManager.MakeBuildingReadyToHarvest(0);
         this.refreshWindow();
      }
      
      private function MakeHarvestReadyBuilding1(event:Event) : void
      {
         this.m_xmasInnovationManager.MakeBuildingReadyToHarvest(1);
         this.refreshWindow();
      }
      
      private function MakeHarvestReadyBuilding2(event:Event) : void
      {
         this.m_xmasInnovationManager.MakeBuildingReadyToHarvest(2);
         this.refreshWindow();
      }
      
      override public function refreshWindow() : void
      {
         this.updateConsumableCount();
         this.updateBuildingButtons();
      }
      
      private function resetWindowButtons(buildingIndex:int) : void
      {
         this.m_harvest_btArray[buildingIndex].callback = null;
         this.m_seeTile_btArray[buildingIndex].callback = null;
         this.m_harvestReady_btArray[buildingIndex].callback = null;
         this.m_harvestReady_btArray[buildingIndex].visible = false;
         this.m_harvest_btArray[buildingIndex].visible = false;
         this.m_seeTile_btArray[buildingIndex].visible = false;
      }
      
      public function playHarvestanimation(buildingIndex:int) : void
      {
         if(this.m_consumableAddArray[buildingIndex])
         {
            this.m_consumableAddArray[buildingIndex].visible = true;
            (this.m_consumableAddArray[buildingIndex] as MovieClip).play();
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         super.onTutorialOkayButtonClick(event);
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber];
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber];
      }
   }
}

