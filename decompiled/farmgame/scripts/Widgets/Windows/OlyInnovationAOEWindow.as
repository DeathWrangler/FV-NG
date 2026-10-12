package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.CommunityGoalsManager;
   import Managers.FarmStatsManager;
   import Managers.OlyInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OlyInnovationAOEWindow extends FarmWindowWithTutorial
   {
      
      private var m_communityGoalsBt:FarmAnimatedTextButton;
      
      private var m_currencyFrame:ZwFrame;
      
      private var m_taskFrame:ZwFrame;
      
      private var m_totemFrame:ZwFrame;
      
      private var m_statueFrame:ZwFrame;
      
      private var m_restoreButton:FarmAnimatedTextButton;
      
      private var m_mapResource:MapResource;
      
      private var m_goldCount:FarmTextField;
      
      private var m_featureName:String;
      
      private var m_goldIcon:FarmIcon;
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const GOLD_MC:String = "gold_mc";
      
      private const PLAY_CG_BT:String = "play_bt";
      
      private const BUY_GOLD_BT:String = "buy_bt";
      
      private const RESTORE_BT:String = "restore_bt";
      
      private const TOTEM_MC:String = "totem_mc";
      
      private const GOLDCOUNT_TF:String = "goldcount_tf";
      
      private const GOLDCOST_TF:String = "goldcost_tf";
      
      private const TASK_MC:String = "task_mc";
      
      private const GOLD_DESC_TF:String = "description_1_tf";
      
      public const WINDOW_PATH:String = "assets/dialogs/mount/EscapeToOlympus2016/FV_EscapeToOlympus2016_UnlockAOE.swf";
      
      private const TEXT_CGINACTIVE:String = "_cginactive";
      
      private const TEXT_CGBUTTON:String = "_cgbutton";
      
      private const TEXT_BUYGOLD:String = "_buygold";
      
      private const TEXT_NOTENOUGHGOLD:String = "_notenoughgold";
      
      private const TEXT_AOE_TASK_DESC:String = "_aoetaskdesc";
      
      private const TEXT_AOE_DESC:String = "_aoewindowdescription";
      
      private const TEXT_TITLE:String = "_aoewindowtitle";
      
      public function OlyInnovationAOEWindow(building:FeatureBuilding, assetUrl:String = "assets/dialogs/mount/EscapeToOlympus2016/FV_EscapeToOlympus2016_UnlockAOE.swf", featureName:String = "olympus_innovation")
      {
         this.m_featureName = featureName;
         this.m_mapResource = building;
         super(featureName,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var allRegions:Array = null;
         var currentRegion:String = null;
         var index:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.DESCRIPTION_TF))
         {
            allRegions = OlyInnovationManager.getInstance().getAllRegionNames();
            currentRegion = OlyInnovationManager.getInstance().getRegionNameForTotem(this.m_mapResource.getItemName());
            allRegions = this.removeCurrentRegionFromRegionArray(currentRegion,allRegions);
            addWidget(new ZwTextField(m_window[this.DESCRIPTION_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_AOE_DESC,{
               "region1":allRegions[0],
               "region2":allRegions[1]
            })));
         }
         if(m_window.hasOwnProperty(this.TOTEM_MC))
         {
            addWidget(this.m_totemFrame = new ZwFrame(m_window[this.TOTEM_MC]));
            this.m_totemFrame.visible = true;
            if(this.m_totemFrame.element[this.RESTORE_BT])
            {
               this.m_restoreButton = addWidget(new FarmAnimatedTextButton(this.m_totemFrame.element[this.RESTORE_BT],"Restore",this.onRestoreClick)) as FarmAnimatedTextButton;
               if(this.m_restoreButton)
               {
                  if(OlyInnovationManager.getInstance().getcurrencyCount() < OlyInnovationManager.getInstance().getRestoreCostForTotem(this.m_mapResource.getItemName()))
                  {
                     this.m_restoreButton.toggleClickableButton(false,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_NOTENOUGHGOLD));
                  }
               }
            }
            if(this.m_totemFrame.element[this.GOLDCOST_TF])
            {
               new FarmTextField(this.m_totemFrame.element[this.GOLDCOST_TF],"x" + OlyInnovationManager.getInstance().getRestoreCostForTotem(this.m_mapResource.getItemName()).toString()).visible = true;
            }
            this.m_currencyFrame = this.loadCurrencyFrame();
            if(m_window[this.TASK_MC])
            {
               addWidget(this.m_taskFrame = new ZwFrame(m_window[this.TASK_MC]),false);
               if(this.m_taskFrame.element[this.GOLD_DESC_TF])
               {
                  new FarmTextField(this.m_taskFrame.element[this.GOLD_DESC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_AOE_TASK_DESC)).visible = true;
               }
            }
         }
         if(m_window["statue_mc"])
         {
            addWidget(this.m_statueFrame = new ZwFrame(m_window["statue_mc"]));
            index = OlyInnovationManager.getInstance().mapTaskNameToSlotIndex(this.m_mapResource.getItemName());
            (m_window["statue_mc"] as MovieClip).gotoAndStop(index);
         }
         this.refreshWindow();
      }
      
      private function removeCurrentRegionFromRegionArray(currentRegion:String, regionArray:Array) : Array
      {
         var resultArray:Array = new Array();
         for(var i:int = 0; i < regionArray.length; i++)
         {
            if(currentRegion != regionArray[i])
            {
               resultArray.push(regionArray[i]);
            }
         }
         return resultArray;
      }
      
      private function loadCurrencyFrame() : ZwFrame
      {
         var frame:ZwFrame = null;
         if(this.m_totemFrame.element.hasOwnProperty(this.GOLD_MC))
         {
            frame = new ZwFrame(this.m_totemFrame.element[this.GOLD_MC]);
            frame.visible = true;
         }
         if(frame.element["goldIcon_mc"])
         {
            addWidget(this.m_goldIcon = new FarmIcon(frame.element["goldIcon_mc"]));
            this.m_goldIcon.attachTooltip(new FarmTextTooltip("Use Olympus Gold on Morpheus statues to unleash transforming magic"));
         }
         if(frame.element.hasOwnProperty(this.PLAY_CG_BT))
         {
            this.m_communityGoalsBt = addWidget(new FarmAnimatedTextButton(frame.element[this.PLAY_CG_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_CGBUTTON),this.openCommunityGoalsUI)) as FarmAnimatedTextButton;
         }
         if(frame.element.hasOwnProperty(this.BUY_GOLD_BT))
         {
            addWidget(new FarmAnimatedTextButton(frame.element[this.BUY_GOLD_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BUYGOLD),this.openBuyCurrencyUI));
         }
         if(frame.element.hasOwnProperty(this.GOLDCOUNT_TF))
         {
            this.m_goldCount = new FarmTextField(frame.element[this.GOLDCOUNT_TF],"x" + OlyInnovationManager.getInstance().getcurrencyCount());
            this.m_goldCount.visible = true;
         }
         return frame;
      }
      
      protected function openCommunityGoalsUI(event:Event) : void
      {
         this.close();
         CommunityGoalsManager.getInstance().displayDialog();
         FarmStatsManager.count(this.m_featureName,"button_click","play_community_goals","click");
      }
      
      protected function openBuyCurrencyUI(event:Event) : void
      {
         OlyInnovationManager.getInstance().openBuyWindow(this);
      }
      
      private function onRestoreClick(e:Event) : void
      {
         var restoreCost:int = OlyInnovationManager.getInstance().getRestoreCostForTotem(this.m_mapResource.getItemName());
         var message:String = ZLocUtils.t("Dialogs","OlympusGoldBuyConfirmation",{"price":restoreCost.toString()});
         UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.restoreTotem,"OlympusGoldBuyConfirmation",true,true);
      }
      
      private function restoreTotem(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.ACCEPT)
         {
            OlyInnovationManager.getInstance().restoreTotem(this.m_mapResource.getItemName());
            this.close();
         }
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         if(OlyInnovationManager.getInstance().isCommunityGoalsActive())
         {
            this.m_communityGoalsBt.enabled = true;
            this.m_communityGoalsBt.detachTooltip();
         }
         else
         {
            this.m_communityGoalsBt.toggleClickableButton(false,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_CGINACTIVE));
         }
         this.m_goldCount.text = "x" + OlyInnovationManager.getInstance().getcurrencyCount();
         if(OlyInnovationManager.getInstance().isTotemRestored(this.m_mapResource.getItemName()))
         {
            this.m_totemFrame.visible = false;
            this.m_taskFrame.visible = false;
         }
         else if(OlyInnovationManager.getInstance().isFeatureRelatedTotem(this.m_mapResource.getItemName()))
         {
            this.m_taskFrame.visible = true;
         }
         if(this.m_restoreButton)
         {
            if(OlyInnovationManager.getInstance().getcurrencyCount() < OlyInnovationManager.getInstance().getRestoreCostForTotem(this.m_mapResource.getItemName()))
            {
               this.m_restoreButton.toggleClickableButton(false,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_NOTENOUGHGOLD));
            }
            else
            {
               this.m_restoreButton.toggleClickableButton(true);
            }
         }
      }
   }
}

