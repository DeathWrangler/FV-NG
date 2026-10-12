package Widgets.Windows
{
   import Classes.Animal;
   import Classes.Constants.ZLocConstants;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.AOEManager;
   import Managers.CommunityGoalsManager;
   import Managers.FestivalOfColorManager;
   import Transactions.TUnlockFestivalOfColorGraphic;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FestivalOfColorSlotFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.setTimeout;
   
   public class FestivalOfColorWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const X:String = "x";
      
      protected var m_featureName:String = "FestivalOfColor";
      
      protected var m_object:MapResource;
      
      protected var m_item:FarmItem;
      
      protected var m_whatIsThis_mc:FarmAnimatedButton;
      
      protected var m_colorSlotsFrame:FestivalOfColorSlotFrame;
      
      protected var m_colorPackMc:ZwFrame;
      
      protected var m_colorBuyButton:FarmAnimatedTextButton;
      
      protected var m_animalSlotMc:MovieClip;
      
      protected var m_icon:ResourcePreviewFrame;
      
      protected var m_resetBt:FarmAnimatedTextButton;
      
      protected var m_unlockBt:FarmAnimatedTextButton;
      
      private var m_colorBurstMc:MovieClip;
      
      private var m_colorPackIconMc:MovieClip;
      
      private var m_communityGoalsBt:FarmAnimatedTextButton;
      
      private var m_descTf:ZwTextField;
      
      private const COLORBURST_MC:String = "colorBurst_mc";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const COLORPACK_MC:String = "colorPacks_mc";
      
      private const COLORPACK_ICON_MC:String = "colorPackIcon_mc";
      
      private const COMMUNITYGOALS_BT:String = "community_bt";
      
      private const COLORSLOT_MC:String = "colorSlots_mc";
      
      private const ANIMAL_MC:String = "animalSlot_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const RESET_BT:String = "reset_bt";
      
      private const UNLOCK_BT:String = "unlockColor_bt";
      
      private const BUY_BT:String = "buy_bt";
      
      private const TITLE_TF:String = "title_tf";
      
      private const COUNT_TF:String = "count_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const OKAY_BT:String = "okay_bt";
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_DESC_LOCKED:String = "_description_locked";
      
      private const TEXT_DESC_UNLOCKED:String = "_description_unlocked";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const TEXT_COLORPACK_TITLE:String = "_ColorPackTitle";
      
      private const TEXT_BUY_BTN:String = "_BuyBtn";
      
      private const TEXT_COMMUNITY_GOALS_BTN:String = "_CommunityGoalsBtn";
      
      private const TEXT_COMMUNITY_GOALS_BTN_TOOLTIP:String = "_CommunityGoalsBtnTooltip";
      
      private const TEXT_RESET_BTN:String = "_ResetBtn";
      
      private const TEXT_UNLOCK_BTN:String = "_UnlockBtn";
      
      private const TEXT_OKAY_BTN:String = "_OkayBtn";
      
      private const TEXT_RESET_BTN_TOOLTIP:String = "_ResetBtnTooltip";
      
      public function FestivalOfColorWindow(obj:MapResource, closeAfterTut:Boolean)
      {
         this.m_object = obj;
         if(obj)
         {
            this.m_item = obj.getItem();
         }
         var dialogPath:String = "assets/dialogs/India/FV_xin_RangDe2015.swf";
         super(FestivalOfColorManager.TUTORIAL_FLAG_2,dialogPath,NUM_TUTORIAL_SCENES,true,true,closeAfterTut);
      }
      
      override protected function postLoadComplete() : void
      {
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
         if(Boolean(this.m_object) && m_window.hasOwnProperty(this.COLORSLOT_MC))
         {
            addWidget(this.m_colorSlotsFrame = new FestivalOfColorSlotFrame(m_window[this.COLORSLOT_MC],this.m_object,this));
         }
         if(m_window.hasOwnProperty(this.COLORPACK_MC))
         {
            this.m_colorPackMc = addWidget(new ZwFrame(m_window[this.COLORPACK_MC]),true) as ZwFrame;
            if(this.m_colorPackMc.element.hasOwnProperty(this.TITLE_TF))
            {
               this.m_colorPackMc.element[this.TITLE_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COLORPACK_TITLE);
               this.m_colorPackMc.element[this.TITLE_TF].visible = true;
            }
            if(this.m_colorPackMc.element.hasOwnProperty(this.BUY_BT))
            {
               this.m_colorBuyButton = new FarmAnimatedTextButton(this.m_colorPackMc.element[this.BUY_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BUY_BTN),this.openBuyWindow);
               this.m_colorPackMc.addWidget(this.m_colorBuyButton,true);
            }
            if(this.m_colorPackMc.element.hasOwnProperty(this.COLORPACK_ICON_MC))
            {
               this.m_colorPackIconMc = this.m_colorPackMc.element[this.COLORPACK_ICON_MC];
               this.m_colorPackIconMc.visible = true;
            }
            if(this.m_colorPackMc.element.hasOwnProperty(this.COMMUNITYGOALS_BT))
            {
               this.m_communityGoalsBt = new FarmAnimatedTextButton(this.m_colorPackMc.element[this.COMMUNITYGOALS_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COMMUNITY_GOALS_BTN),this.onClickCommunityGoalsBtn);
               this.m_colorPackMc.addWidget(this.m_communityGoalsBt,true);
            }
         }
         if(Boolean(this.m_object) && Boolean(this.m_item) && m_window.hasOwnProperty(this.ANIMAL_MC))
         {
            this.m_animalSlotMc = m_window[this.ANIMAL_MC] as MovieClip;
            this.m_animalSlotMc.visible = true;
            if(this.m_animalSlotMc.hasOwnProperty(this.ICON_MC))
            {
               this.m_icon = getWidget(this.m_animalSlotMc[this.ICON_MC]) as ResourcePreviewFrame;
               addWidget(this.m_icon = new ResourcePreviewFrame(this.m_animalSlotMc[this.ICON_MC],this.getItemGraphicPath(),this.getItemExportName(),true,false),true);
            }
            if(this.m_animalSlotMc.hasOwnProperty(this.RESET_BT))
            {
               this.m_resetBt = new FarmAnimatedTextButton(this.m_animalSlotMc[this.RESET_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_RESET_BTN),this.resetColor);
               this.m_resetBt.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_RESET_BTN_TOOLTIP)));
               addWidget(this.m_resetBt,true);
            }
            if(this.m_animalSlotMc.hasOwnProperty(this.COLORBURST_MC))
            {
               this.m_colorBurstMc = this.m_animalSlotMc[this.COLORBURST_MC];
               this.m_colorBurstMc.stop();
               this.m_colorBurstMc.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.UNLOCK_BT))
         {
            this.m_unlockBt = new FarmAnimatedTextButton(m_window[this.UNLOCK_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_UNLOCK_BTN),this.unlockMagicColor);
            addWidget(this.m_unlockBt,true);
         }
         this.refreshWindow();
         super.postLoadComplete();
      }
      
      private function onClickCommunityGoalsBtn(e:Event) : void
      {
         CommunityGoalsManager.getInstance().displayDialog();
         this.close();
      }
      
      private function updateInventoryCount() : void
      {
         if(this.m_colorPackMc.element.hasOwnProperty(this.COUNT_TF))
         {
            this.m_colorPackMc.element[this.COUNT_TF].text = X + this.getColorPackCount();
            this.m_colorPackMc.element[this.COUNT_TF].visible = true;
         }
      }
      
      override public function refreshWindow() : void
      {
         if(this.atleastOneGraphicUnlocked())
         {
            this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC_UNLOCKED);
         }
         else
         {
            this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC_LOCKED);
         }
         if(Boolean(this.m_resetBt) && Boolean(this.m_object))
         {
            this.m_resetBt.enabled = this.m_object.altGraphic != "";
         }
         if(this.m_colorSlotsFrame)
         {
            this.m_colorSlotsFrame.refresh();
         }
         this.updateInventoryCount();
         if(this.m_icon)
         {
            this.m_icon.exportName = this.getItemExportName();
         }
         if(Boolean(this.m_unlockBt) && Boolean(this.m_object))
         {
            this.m_unlockBt.enabled = !AOEManager.getInstance().hasAOELicense(this.m_object) && this.getColorPackCount() > 0;
         }
         if(FestivalOfColorManager.getInstance().isCommunityGoalsActive())
         {
            if(this.m_communityGoalsBt)
            {
               this.m_communityGoalsBt.enabled = true;
               this.m_communityGoalsBt.detachTooltip();
            }
         }
         else if(this.m_communityGoalsBt)
         {
            FarmGameUtil.disableButtonAndShowTooltip(this.m_communityGoalsBt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COMMUNITY_GOALS_BTN_TOOLTIP));
         }
      }
      
      private function atleastOneGraphicUnlocked() : Boolean
      {
         var altGraphicsArray:Array = null;
         var i:Number = NaN;
         var result:Boolean = false;
         if(this.m_item)
         {
            altGraphicsArray = this.m_item.getAltGraphics();
            if(altGraphicsArray)
            {
               for(i = 0; i < altGraphicsArray.length; i++)
               {
                  result = Global.player.hasUnlimitedCredits(this.m_item.name + "_" + altGraphicsArray[i]);
                  if(result == true)
                  {
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function playColorBurstAnimation() : void
      {
         if(this.m_colorBurstMc)
         {
            this.m_colorBurstMc.gotoAndPlay(0);
            this.m_colorBurstMc.visible = true;
         }
      }
      
      private function getItemGraphicPath() : String
      {
         var graphicPrefix:String = null;
         var imagePath:String = "";
         if(Boolean(this.m_item) && Boolean(this.m_object))
         {
            graphicPrefix = this.m_object.altGraphic;
            if(graphicPrefix != "")
            {
               imagePath = this.m_item.imageRelativeUrl(Animal.STATE_FRONT_IDLE + "_" + graphicPrefix);
            }
            else
            {
               imagePath = this.m_item.imageRelativeUrl(Animal.STATE_FRONT_IDLE);
            }
         }
         return imagePath;
      }
      
      private function getItemExportName() : String
      {
         var overrideExportName:String = null;
         var graphicPrefix:String = null;
         var exportedName:String = "";
         if(this.m_item)
         {
            overrideExportName = this.m_item.overrideExportName;
            if(overrideExportName == "")
            {
               overrideExportName = this.m_item.name;
            }
            graphicPrefix = this.m_object.altGraphic;
            if(graphicPrefix != "")
            {
               exportedName = overrideExportName + "_" + Animal.STATE_FRONT_IDLE + "_" + graphicPrefix;
            }
            else
            {
               exportedName = overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
            }
         }
         return exportedName;
      }
      
      protected function resetColor(event:Event) : void
      {
         this.m_object.removeAlternativeGraphic(this.m_object.altGraphic,false,true);
         this.playColorBurstAnimation();
         setTimeout(function():void
         {
            refreshWindow();
         },FarmGameUtil.NUM_MSECS_IN_SECOND * 0.5);
      }
      
      protected function unlockMagicColor(event:Event) : void
      {
         tintWindow();
         enableInput = false;
         TransactionManager.addTransaction(new TUnlockFestivalOfColorGraphic(this.m_object,this.onUnlockMagicColor));
      }
      
      protected function onUnlockMagicColor(result:Object) : void
      {
         if(result)
         {
            if(result.hasOwnProperty("overlay"))
            {
               Global.player.setUnlimitedAltGraphicsCredits(this.m_item.name + "_" + result.overlay,true);
               FestivalOfColorManager.getInstance().deductColorPack();
            }
            if(result.hasOwnProperty("allStatesUnlocked"))
            {
               if(result.allStatesUnlocked)
               {
                  AOEManager.getInstance().setAOELicense(this.m_object);
                  FestivalOfColorManager.getInstance().conditionallyTriggerTutorialThree();
               }
            }
         }
         untintWindow();
         enableInput = true;
         this.refreshWindow();
         if(Boolean(result) && result.hasOwnProperty("overlay"))
         {
            this.m_colorSlotsFrame.playFireworksForSlot(result.overlay);
         }
      }
      
      protected function openBuyWindow(event:Event) : void
      {
         tintWindow();
         enableInput = false;
         FestivalOfColorManager.getInstance().openBuyWindow(this);
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

