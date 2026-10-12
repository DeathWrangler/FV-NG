package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.OlyInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class OlyInnovationSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:OlyInnovationWindow;
      
      private var m_hoverWidget:ZwWidget;
      
      private var m_tileWidget:ZwWidget;
      
      private var m_restoreButton:FarmAnimatedCashButton;
      
      private var m_viewTileButton:FarmAnimatedTextButton;
      
      private var m_goToButton:FarmAnimatedTextButton;
      
      private var m_count_tf:FarmTextField;
      
      private var m_check_mc:ZwWidget;
      
      private var m_buildingDesc:FarmTextField;
      
      private var m_tileTitle:FarmTextField;
      
      private var m_tileDesc:FarmTextField;
      
      private var m_buildingTitle:FarmTextField;
      
      private var m_slotType:String;
      
      private var m_tileCode:String;
      
      private var m_totemCode:String;
      
      private var m_buildingId:String;
      
      private var m_restoreCost:int;
      
      private var m_maxLevel:int;
      
      private const HOVER_MC:String = "hover_mc";
      
      private const TILE_MC:String = "tile_mc";
      
      private const COUNT_TF:String = "generic_tf";
      
      private const CHECK_MC:String = "check_mc";
      
      private const VIEW_BT:String = "view_bt";
      
      private const RESTORE_BT:String = "cashbuy0_bt";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBHEADER_TF:String = "subheader_tf";
      
      private const GOTO_BT:String = "goto_bt";
      
      private const TEXT_NOTENOUGHGOLD:String = "_notenoughgold";
      
      private const TEXT_VIEWTILE:String = "_viewtile";
      
      private const TEXT_RESTORE:String = "_restore";
      
      private const TEXT_TILELOCKEDTITLE:String = "_tilelockedtitle";
      
      private const TEXT_TILELOCKEDDESC:String = "_tilelockeddesc";
      
      private const TEXT_GOTOBUILDING:String = "_gotobuilding";
      
      private const TEXT_BUILDINGLOCKEDTITLE:String = "_buildinglockedtitle";
      
      private const TEXT_BUILDINGLOCKEDDESC:String = "_buildinglockeddesc";
      
      private const TEXT_TOTEMLOCKEDTITLE:String = "_totemlockedtitle";
      
      private const TEXT_TOTEMLOCKEDDESC:String = "_totemlockeddesc";
      
      private const TEXT_TOTEMRESTOREDTITLE:String = "_totemrestoredtitle";
      
      private const TEXT_TOTEMRESTOREDDESC:String = "_totemrestoreddesc";
      
      private const TEXT_BUILDINGCOMPLETETITLE:String = "_buildingcompletetitle";
      
      private const TEXT_BUILDINGCOMPLETEDESC:String = "_buildingcompletedesc";
      
      public function OlyInnovationSlot(element:MovieClip, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow as OlyInnovationWindow;
         m_element.addEventListener(MouseEvent.MOUSE_OVER,this.onTileMouseRollOver);
         m_element.addEventListener(MouseEvent.MOUSE_OUT,this.onTileMouseRollOut);
         if(m_element.hasOwnProperty(this.HOVER_MC))
         {
            this.m_hoverWidget = new ZwWidget(m_element[this.HOVER_MC]);
            addWidget(this.m_hoverWidget,false);
         }
         if(m_element.hasOwnProperty(this.TILE_MC))
         {
            this.m_tileWidget = new ZwWidget(m_element[this.TILE_MC]);
            addWidget(this.m_tileWidget);
         }
         if(m_element[this.COUNT_TF])
         {
            this.m_count_tf = new FarmTextField(m_element[this.COUNT_TF],"");
            addWidget(this.m_count_tf);
         }
         if(m_element[this.CHECK_MC])
         {
            this.m_check_mc = addWidget(new ZwWidget(m_element[this.CHECK_MC]),false) as ZwWidget;
         }
         this.loadTile();
         this.loadBuilding();
      }
      
      private function loadTile() : void
      {
         if(this.m_hoverWidget.element[this.RESTORE_BT])
         {
            addWidget(this.m_restoreButton = new FarmAnimatedCashButton(this.m_hoverWidget.element[this.RESTORE_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_RESTORE),"x" + this.m_restoreCost,this.restoreTotem,false,false,true,ZLocUtils.t("Dialogs","OlympusGoldBuyConfirmation",{"price":this.m_restoreCost.toString()}),1),true);
         }
         if(this.m_hoverWidget.element[this.TITLE_TF])
         {
            this.m_tileTitle = new FarmTextField(this.m_hoverWidget.element[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_TILELOCKEDTITLE));
            this.m_tileTitle.visible = true;
         }
         if(this.m_hoverWidget.element[this.SUBHEADER_TF])
         {
            this.m_tileDesc = new FarmTextField(this.m_hoverWidget.element[this.SUBHEADER_TF],"");
            this.m_tileDesc.visible = true;
         }
      }
      
      private function loadBuilding() : void
      {
         if(this.m_hoverWidget.element.hasOwnProperty(this.GOTO_BT))
         {
            this.m_goToButton = new FarmAnimatedTextButton(this.m_hoverWidget.element[this.GOTO_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_GOTOBUILDING),this.openBuildingUI);
            this.m_goToButton.visible = true;
         }
         if(this.m_hoverWidget.element.hasOwnProperty(this.TITLE_TF))
         {
            this.m_buildingTitle = new FarmTextField(this.m_hoverWidget.element[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_BUILDINGLOCKEDTITLE));
            this.m_buildingTitle.visible = true;
         }
         if(this.m_hoverWidget.element.hasOwnProperty(this.SUBHEADER_TF))
         {
            this.m_buildingDesc = new FarmTextField(this.m_hoverWidget.element[this.SUBHEADER_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_BUILDINGLOCKEDDESC));
            this.m_buildingDesc.visible = true;
         }
      }
      
      private function onTileMouseRollOver(e:MouseEvent) : void
      {
         this.m_hoverWidget.visible = true;
         var containerFrame:GenericSlotContainerFrame = this.m_parent as GenericSlotContainerFrame;
         containerFrame.element.setChildIndex(this.m_element as DisplayObject,containerFrame.element.numChildren - 1);
      }
      
      private function onTileMouseRollOut(e:MouseEvent) : void
      {
         this.m_hoverWidget.visible = false;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_slotType = data.type;
         if(this.m_slotType == "tile")
         {
            this.m_tileCode = data.name;
            this.m_totemCode = data.totemCode;
            this.m_restoreCost = data.restoreCost;
         }
         else if(this.m_slotType == "building")
         {
            this.m_buildingId = data.name;
            this.m_maxLevel = data.maxLevel;
         }
         this.m_tileWidget.visible = true;
         this.refreshSlot();
      }
      
      private function refreshSlot() : void
      {
         if(this.m_slotType == "tile")
         {
            this.refreshTile();
         }
         else if(this.m_slotType == "building")
         {
            this.refreshBuilding();
         }
      }
      
      private function refreshTile() : void
      {
         if(Boolean(this.m_hoverWidget.element[this.VIEW_BT]) && !this.m_viewTileButton)
         {
            addWidget(this.m_viewTileButton = new FarmAnimatedTextButton(this.m_hoverWidget.element[this.VIEW_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_VIEWTILE),this.viewTile));
         }
         if(!OlyInnovationManager.getInstance().isTileUnlocked(this.m_tileCode))
         {
            this.m_tileWidget.element.gotoAndStop(1);
            this.m_hoverWidget.element.gotoAndStop(1);
            this.m_restoreButton.toggleClickableButton(false);
            this.m_tileTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_TILELOCKEDTITLE);
            this.m_tileDesc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_TILELOCKEDDESC,{"tileName":ZLocUtils.tk_pk_asTitle("Items:" + this.m_tileCode + "_friendlyName")});
            this.m_count_tf.text = "0/1";
            this.m_viewTileButton.visible = true;
            this.m_restoreButton.visible = true;
         }
         else if(!OlyInnovationManager.getInstance().isTotemRestored(this.m_totemCode))
         {
            this.m_tileWidget.element.gotoAndStop(2);
            this.m_hoverWidget.element.gotoAndStop(1);
            this.m_restoreButton.toggleClickableButton(true);
            this.m_tileTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_TOTEMLOCKEDTITLE);
            this.m_tileDesc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_TOTEMLOCKEDDESC);
            this.m_count_tf.text = "0/1";
            this.m_viewTileButton.visible = true;
            this.m_restoreButton.visible = true;
         }
         else
         {
            this.m_tileWidget.element.gotoAndStop(3);
            this.m_hoverWidget.element.gotoAndStop(2);
            this.m_check_mc.visible = true;
            this.m_tileTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_TOTEMRESTOREDTITLE);
            this.m_tileDesc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_TOTEMRESTOREDDESC);
            this.m_count_tf.text = "1/1";
            this.m_viewTileButton.visible = false;
            this.m_restoreButton.visible = false;
         }
         this.m_count_tf.visible = true;
         this.m_restoreButton.setAmountText(this.m_restoreCost.toString());
         this.m_restoreButton.buyConfirmationText = ZLocUtils.t("Dialogs","OlympusGoldBuyConfirmation",{"price":this.m_restoreCost.toString()});
         if(OlyInnovationManager.getInstance().getcurrencyCount() < this.m_restoreCost)
         {
            this.m_restoreButton.toggleClickableButton(false,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_NOTENOUGHGOLD));
         }
      }
      
      private function refreshBuilding() : void
      {
         var maxLevel:int = this.m_maxLevel;
         var currentLevel:int = OlyInnovationManager.getInstance().getCurrentBuildingLevel(this.m_buildingId);
         if(this.m_count_tf)
         {
            this.m_count_tf.text = currentLevel + "/" + maxLevel;
            this.m_count_tf.visible = true;
         }
         if(currentLevel == maxLevel)
         {
            this.m_check_mc.visible = true;
            this.m_tileWidget.element.gotoAndStop(2);
            this.m_goToButton.visible = false;
            this.m_buildingTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_BUILDINGCOMPLETETITLE);
            this.m_buildingDesc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_parentWindow.featureName + this.TEXT_BUILDINGCOMPLETEDESC);
         }
      }
      
      private function openBuildingUI(e:Event) : void
      {
         this.m_parentWindow.close();
         switch(this.m_buildingId)
         {
            case OlyInnovationManager.ELITEHORSES_BUILDING:
               FeatureCraftingManager.instance.showUI(this.m_buildingId);
               break;
            case OlyInnovationManager.BIGBUILDABLE_BUILDING:
            case OlyInnovationManager.HARVESTBUILDABLE_BUILDING:
               GivingBuildingWindow.openBuildingUI(this.m_buildingId);
         }
         FarmStatsManager.count("olympus_innovation",this.m_buildingId,"go_to_building","click");
      }
      
      private function restoreTotem(e:Event) : void
      {
         OlyInnovationManager.getInstance().restoreTotem(this.m_totemCode);
         this.m_parentWindow.close();
      }
      
      private function viewTile(e:Event) : void
      {
         if(OlyInnovationManager.getInstance().isTileUnlocked(this.m_tileCode))
         {
            OlyInnovationManager.getInstance().panToTotem(this.m_totemCode);
         }
         else if(OlyInnovationManager.getInstance().highlightItemsByName(this.m_tileCode))
         {
            this.m_parentWindow.close();
         }
         FarmStatsManager.count("olympus_innovation",this.m_tileCode,"view_tile","click");
      }
   }
}

