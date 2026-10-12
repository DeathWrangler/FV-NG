package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureCraftingManager;
   import Managers.FestivalOfColorManager;
   import Managers.ItemFinderManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.setTimeout;
   
   public class FestivalOfColorHudWindow extends FarmWindowWithTutorial
   {
      
      protected static const FTUE_FLAG:String = "_ftue";
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const X:String = "x";
      
      private static const NUM_SLOTS:Number = 3;
      
      private static const BUILDINGSLOT:String = "buildingSlot_";
      
      private static const MC_SUFFIX:String = "_mc";
      
      protected var m_featureName:String = "FestivalOfColorHud";
      
      protected var m_ftue:MovieClip = null;
      
      protected var m_tutorialButton:FarmAnimatedTextButton;
      
      protected var m_tutorialScene:int;
      
      protected var m_whatIsThis_mc:FarmAnimatedButton;
      
      protected var m_colorPackMc:ZwFrame;
      
      protected var m_colorBuyButton:FarmAnimatedTextButton;
      
      private var m_communityGoalsBt:FarmAnimatedTextButton;
      
      private var m_colorPackIconMc:MovieClip;
      
      private var m_ftueOn:Boolean = false;
      
      private var m_buildingSlots:Array;
      
      private var m_descTf:ZwTextField;
      
      private var m_findButtons:Array;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const COLORPACK_MC:String = "colorPacks_mc";
      
      private const BUY_BT:String = "buy_bt";
      
      private const TITLE_TF:String = "title_tf";
      
      private const COUNT_TF:String = "count_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const COLORPACK_ICON_MC:String = "colorPackIcon_mc";
      
      private const PROGRESS_TF:String = "progress_tf";
      
      private const GOTOBUILDING_BT:String = "goToBuilding_bt";
      
      private const SHOWANIMALS_BT:String = "showAnimals_bt";
      
      private const COMMUNITYGOALS_BT:String = "community_bt";
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_DESC_LOCKED:String = "_description_locked";
      
      private const TEXT_DESC_UNLOCKED:String = "_description_unlocked";
      
      private const TEXT_COLORPACK_TITLE:String = "_ColorPackTitle";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const TEXT_BUY_BTN:String = "_BuyBtn";
      
      private const TEXT_COMMUNITY_GOALS_BTN:String = "_CommunityGoalsBtn";
      
      private const TEXT_GOTOBUILDING_BTN:String = "_GoToBuildingBtn";
      
      private const TEXT_FIND_ANIMALS_BTN:String = "_FindAnimalsBtn";
      
      private const TEXT_FIND_ANIMALS_BTN_TOOLTIP1:String = "_FindAnimalsBtn_t1";
      
      private const TEXT_FIND_ANIMALS_BTN_TOOLTIP2:String = "_FindAnimalsBtn_t2";
      
      private const TEXT_FIND_ANIMALS_BTN_TOOLTIP3:String = "_FindAnimalsBtn_t3";
      
      private const TEXT_BUILDING_SLOT_PREFIX:String = "_BuildingSlot_";
      
      private const TEXT_BUILDING_SLOT_SUFFIX:String = "_Title";
      
      private const TEXT_COMMUNITY_GOALS_BTN_TOOLTIP:String = "_CommunityGoalsBtnTooltip";
      
      public function FestivalOfColorHudWindow(closeAfterTut:Boolean)
      {
         this.initializeBuildingSlots();
         var dialogPath:String = "assets/dialogs/India/FV_xin_RangDeOverview2015.swf";
         super(FestivalOfColorManager.TUTORIAL_FLAG_1,dialogPath,NUM_TUTORIAL_SCENES,true,false,closeAfterTut);
      }
      
      private function initializeBuildingSlots() : void
      {
         this.m_buildingSlots = [];
         this.m_buildingSlots.push("xin_bigbuildable");
         this.m_buildingSlots.push("bldg_xin_harvestbuildable");
         this.m_buildingSlots.push("xin_elitehorses");
         this.m_findButtons = [];
      }
      
      override protected function postLoadComplete() : void
      {
         var slotName:String = null;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)),true);
         }
         if(m_window.hasOwnProperty(this.DESCRIPTION_TF))
         {
            this.m_descTf = addWidget(new ZwTextField(m_window[this.DESCRIPTION_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC_LOCKED)),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            this.m_whatIsThis_mc = addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick),true) as FarmAnimatedButton;
         }
         if(m_window.hasOwnProperty(this.COLORPACK_MC))
         {
            this.m_colorPackMc = addWidget(new ZwFrame(m_window[this.COLORPACK_MC]),true) as ZwFrame;
            if(this.m_colorPackMc.element.hasOwnProperty(this.TITLE_TF))
            {
               this.m_colorPackMc.element[this.TITLE_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COLORPACK_TITLE);
               this.m_colorPackMc.element[this.TITLE_TF].visible = true;
            }
            if(this.m_colorPackMc.element.hasOwnProperty(this.COLORPACK_ICON_MC))
            {
               this.m_colorPackIconMc = this.m_colorPackMc.element[this.COLORPACK_ICON_MC];
               this.m_colorPackIconMc.visible = true;
            }
            this.updateInventoryCount();
            if(this.m_colorPackMc.element.hasOwnProperty(this.BUY_BT))
            {
               this.m_colorPackMc.addWidget(this.m_colorBuyButton = new FarmAnimatedTextButton(this.m_colorPackMc.element[this.BUY_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BUY_BTN),this.onClickBuyButton),true);
            }
            if(this.m_colorPackMc.element.hasOwnProperty(this.COMMUNITYGOALS_BT))
            {
               this.m_communityGoalsBt = new FarmAnimatedTextButton(this.m_colorPackMc.element[this.COMMUNITYGOALS_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COMMUNITY_GOALS_BTN),this.onClickCommunityGoalsBtn);
               this.m_colorPackMc.addWidget(this.m_communityGoalsBt,true);
            }
         }
         for(var i:Number = 0; i < NUM_SLOTS; i++)
         {
            slotName = BUILDINGSLOT + i.toString() + MC_SUFFIX;
            this.setupBuildingSlot(slotName,i);
         }
         this.refreshWindow();
         super.postLoadComplete();
      }
      
      private function setupBuildingSlot(slotName:String, index:Number) : void
      {
         var buildingSlot:ZwFrame = null;
         if(m_window.hasOwnProperty(slotName))
         {
            buildingSlot = addWidget(new ZwFrame(m_window[slotName]),true) as ZwFrame;
            if(buildingSlot.element.hasOwnProperty(this.TITLE_TF))
            {
               buildingSlot.element[this.TITLE_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BUILDING_SLOT_PREFIX + index.toString() + this.TEXT_BUILDING_SLOT_SUFFIX);
               buildingSlot.element[this.TITLE_TF].visible = true;
            }
            if(buildingSlot.element.hasOwnProperty(this.PROGRESS_TF))
            {
               buildingSlot.element[this.PROGRESS_TF].text = FestivalOfColorManager.getInstance().getProgressByType(index).toString() + "/" + FestivalOfColorManager.getInstance().getTotalAnimalsOfType(index);
               buildingSlot.element[this.PROGRESS_TF].visible = true;
            }
            if(buildingSlot.element.hasOwnProperty(this.GOTOBUILDING_BT))
            {
               buildingSlot.addWidget(new FarmAnimatedTextButton(buildingSlot.element[this.GOTOBUILDING_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_GOTOBUILDING_BTN),function():void
               {
                  gotoBuildingAtIndex(index);
               }),true);
            }
            if(buildingSlot.element.hasOwnProperty(this.SHOWANIMALS_BT))
            {
               this.m_findButtons[index] = buildingSlot.addWidget(new FarmAnimatedTextButton(buildingSlot.element[this.SHOWANIMALS_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FIND_ANIMALS_BTN),function():void
               {
                  highlightItemsOfType(index);
               }),true) as FarmAnimatedTextButton;
            }
         }
      }
      
      private function highlightItemsOfType(index:Number) : void
      {
         var itemsArray:Array = FestivalOfColorManager.getInstance().getItemsByType(index);
         if(itemsArray)
         {
            if(ItemFinderManager.getInstance().highlightMultipleWorldItems(itemsArray).length > 0)
            {
               this.close();
            }
         }
      }
      
      private function updateInventoryCount() : void
      {
         if(this.m_colorPackMc.element.hasOwnProperty(this.COUNT_TF))
         {
            this.m_colorPackMc.element[this.COUNT_TF].text = X + this.getColorPackCount();
            this.m_colorPackMc.element[this.COUNT_TF].visible = true;
         }
      }
      
      private function gotoBuildingAtIndex(index:Number) : void
      {
         this.close();
         ItemFinderManager.getInstance().highlightWorldItems(this.m_buildingSlots[index]);
         setTimeout(function():void
         {
            showBuildingUI(index);
         },FarmGameUtil.NUM_MSECS_IN_SECOND);
      }
      
      private function displayBuildingDialog(itemName:String) : void
      {
         var obj:FeatureBuilding = null;
         var objs:Array = Global.world.getObjectsByName(itemName);
         if(objs[0])
         {
            obj = objs[0] as FeatureBuilding;
            if(obj)
            {
               obj.displayStorageDialog();
            }
         }
      }
      
      private function showBuildingUI(index:Number) : void
      {
         switch(index)
         {
            case 0:
            case 1:
               this.displayBuildingDialog(this.m_buildingSlots[index]);
               break;
            case 2:
               FeatureCraftingManager.instance.showUI(this.m_buildingSlots[index]);
         }
      }
      
      private function setStateForShowAnimalsButton(i:Number) : void
      {
         var items:Array = null;
         var btn:FarmAnimatedTextButton = null;
         if(Boolean(this.m_findButtons) && Boolean(this.m_findButtons[i]))
         {
            items = FestivalOfColorManager.getInstance().getItemsByType(i);
            btn = this.m_findButtons[i] as FarmAnimatedTextButton;
            if(btn)
            {
               if(items)
               {
                  btn.detachTooltip();
                  if(FestivalOfColorManager.getInstance().getProgressByType(i) > 0)
                  {
                     if(ItemFinderManager.getInstance().atleastOneItemPlacedOnWorld(items))
                     {
                        btn.enabled = true;
                     }
                     else if(ItemFinderManager.getInstance().atleastOneItemInGiftBox(items))
                     {
                        FarmGameUtil.disableButtonAndShowTooltip(btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FIND_ANIMALS_BTN_TOOLTIP1));
                     }
                     else
                     {
                        FarmGameUtil.disableButtonAndShowTooltip(btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FIND_ANIMALS_BTN_TOOLTIP2));
                     }
                  }
                  else
                  {
                     FarmGameUtil.disableButtonAndShowTooltip(btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FIND_ANIMALS_BTN_TOOLTIP3));
                  }
               }
               else
               {
                  btn.enabled = false;
                  btn.visible = false;
               }
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         if(FestivalOfColorManager.getInstance().allAnimalsUnlocked())
         {
            this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC_UNLOCKED);
         }
         else
         {
            this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC_LOCKED);
         }
         this.updateInventoryCount();
         if(FestivalOfColorManager.getInstance().isCommunityGoalsActive())
         {
            this.m_communityGoalsBt.enabled = true;
            this.m_communityGoalsBt.detachTooltip();
         }
         else
         {
            FarmGameUtil.disableButtonAndShowTooltip(this.m_communityGoalsBt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COMMUNITY_GOALS_BTN_TOOLTIP));
         }
         for(var i:Number = 0; i < this.m_findButtons.length; i++)
         {
            this.setStateForShowAnimalsButton(i);
         }
      }
      
      private function onClickBuyButton(e:Event) : void
      {
         tintWindow();
         enableInput = false;
         FestivalOfColorManager.getInstance().openBuyWindow(this);
      }
      
      private function onClickCommunityGoalsBtn(e:Event) : void
      {
         CommunityGoalsManager.getInstance().displayDialog();
         this.close();
      }
      
      protected function getColorPackCount() : int
      {
         return FestivalOfColorManager.getInstance().getColorPackCount();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
   }
}

