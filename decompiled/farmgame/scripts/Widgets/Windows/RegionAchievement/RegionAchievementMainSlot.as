package Widgets.Windows.RegionAchievement
{
   import Classes.RegionAchievement.Region;
   import Classes.util.ZLocUtils;
   import Managers.RegionAchievementManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class RegionAchievementMainSlot extends ZwSlotFrame
   {
      
      private static const SHIELD_MC:String = "shield_mc";
      
      private static const MAINTASK_MC:String = "mainTask_mc";
      
      private static const CURTAIN_MC:String = "curtain_mc";
      
      private static const REGION_TITLE_TF:String = "regionTitle_tf";
      
      private static const UNLOCK_DESCP_TF:String = "unlockInfo_tf";
      
      private static const ICON_MC:String = "icon_mc";
      
      private static const TROPHY_TITLE_TF:String = "trophyTitle_tf";
      
      private static const TASK_COUNT_TF:String = "taskCount_tf";
      
      private static const COUNT_TF:String = "counter_tf";
      
      private static const CLICK_VIEW_TF:String = "view_tf";
      
      private static const MOUSE_OUT_STATE:int = 1;
      
      private static const MOUSE_OVER_STATE:int = 2;
      
      private static const MOUSE_OUT_STATE_WON:int = 3;
      
      private static const MOUSE_OVER_STATE_WON:int = 4;
      
      private var m_sheid:MovieClip;
      
      private var m_taskContainerFrame:RegionAchievementMainTrophyFrame;
      
      private var m_curtainMc:ZwWidget;
      
      private var m_regionTitle:ZwTextField;
      
      private var m_unlockTxt:ZwTextField;
      
      private var m_trophyTitleTxt:ZwTextField;
      
      private var m_taskCountTxt:ZwTextField;
      
      private var m_countTxt:ZwTextField;
      
      private var m_clickToViewTxt:ZwTextField;
      
      private var m_region:Region;
      
      private var m_icon:FarmIcon;
      
      private var m_parentWindow:RegionAchievementWindow;
      
      private var m_featureName:String;
      
      public function RegionAchievementMainSlot(element:DisplayObject, parentWindow:RegionAchievementWindow, featureName:String)
      {
         this.m_parentWindow = parentWindow;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty(SHIELD_MC))
         {
            this.m_sheid = m_element[SHIELD_MC] as MovieClip;
            this.m_sheid.addEventListener(MouseEvent.CLICK,this.onClickShieldHandler);
            this.m_sheid.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverShieldHandler);
            this.m_sheid.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutShieldHandler);
            if(this.m_sheid.hasOwnProperty(ICON_MC))
            {
               addWidget(this.m_icon = new FarmIcon(this.m_sheid[ICON_MC]));
               if(this.m_icon.element as MovieClip)
               {
                  (this.m_icon.element as MovieClip).buttonMode = true;
               }
            }
            if(this.m_sheid.hasOwnProperty(TROPHY_TITLE_TF))
            {
               addWidget(this.m_trophyTitleTxt = new ZwTextField(this.m_sheid[TROPHY_TITLE_TF],""),false);
            }
            if(this.m_sheid.hasOwnProperty(TASK_COUNT_TF))
            {
               addWidget(this.m_taskCountTxt = new ZwTextField(this.m_sheid[TASK_COUNT_TF],""),true);
            }
            if(this.m_sheid.hasOwnProperty(COUNT_TF))
            {
               addWidget(this.m_countTxt = new ZwTextField(this.m_sheid[COUNT_TF],""),false);
            }
            if(this.m_sheid.hasOwnProperty(CLICK_VIEW_TF))
            {
               addWidget(this.m_clickToViewTxt = new ZwTextField(this.m_sheid[CLICK_VIEW_TF],ZLocUtils.t("Dialogs",this.m_featureName + "_click2view")),false);
            }
         }
         if(m_element.hasOwnProperty(MAINTASK_MC))
         {
            this.m_taskContainerFrame = addWidget(new RegionAchievementMainTrophyFrame(element[MAINTASK_MC],parentWindow,featureName)) as RegionAchievementMainTrophyFrame;
         }
         if(m_element.hasOwnProperty(CURTAIN_MC))
         {
            addWidget(this.m_curtainMc = new ZwWidget(m_element[CURTAIN_MC]));
         }
         if(m_element.hasOwnProperty(REGION_TITLE_TF))
         {
            addWidget(this.m_regionTitle = new ZwTextField(m_element[REGION_TITLE_TF],""));
         }
         if(m_element.hasOwnProperty(UNLOCK_DESCP_TF))
         {
            addWidget(this.m_unlockTxt = new ZwTextField(m_element[UNLOCK_DESCP_TF],""));
         }
      }
      
      private function onClickShieldHandler(eve:MouseEvent) : void
      {
         RegionAchievementManager.getInstance(this.m_featureName).showTabbedWindow(this.m_region.id);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_region = data as Region;
         this.toggleLockedScreen(true);
         if(this.m_region.unlocked)
         {
            this.m_trophyTitleTxt.text = this.m_region.chestName;
            this.m_taskCountTxt.text = this.taskMilestoneText();
            this.m_taskCountTxt.visible = true;
            this.m_countTxt.text = this.m_region.taskMilestoneCounterText;
            this.m_countTxt.visible = true;
            m_element.visible = true;
            if(this.m_sheid)
            {
               this.m_sheid.visible = true;
               if(this.m_icon)
               {
                  this.m_icon.loadIcon(this.m_region.chestIcon);
                  this.m_icon.visible = true;
               }
            }
            if(this.m_taskContainerFrame)
            {
               this.m_taskContainerFrame.visible = true;
            }
            if(this.m_regionTitle)
            {
               this.m_regionTitle.text = this.m_region.name;
            }
            this.m_taskContainerFrame.slotData = this.m_region.activeAchievements;
            this.m_taskContainerFrame.refresh();
            this.toggleLockedScreen(false);
         }
      }
      
      private function toggleLockedScreen(toggle:Boolean) : void
      {
         if(this.m_curtainMc)
         {
            this.m_curtainMc.visible = toggle;
         }
         if(this.m_unlockTxt)
         {
            this.m_unlockTxt.visible = toggle;
         }
         if(this.m_regionTitle)
         {
            this.m_regionTitle.visible = toggle;
         }
      }
      
      private function onMouseOverShieldHandler(e:MouseEvent) : void
      {
         this.m_trophyTitleTxt.visible = true;
         this.m_clickToViewTxt.visible = true;
         this.m_sheid.gotoAndStop(MOUSE_OVER_STATE);
      }
      
      private function onMouseOutShieldHandler(e:MouseEvent) : void
      {
         this.m_trophyTitleTxt.visible = false;
         this.m_clickToViewTxt.visible = false;
         this.m_sheid.gotoAndStop(MOUSE_OUT_STATE);
      }
      
      private function taskMilestoneText() : String
      {
         if(this.m_region.shieldWon)
         {
            return ZLocUtils.t("Dialogs",this.m_featureName + "_ChestName_rollover_won");
         }
         var shieldMileStone:int = this.m_region.shieldMilestone;
         return ZLocUtils.t("Dialogs",this.m_featureName + "_ChestName_rollover_" + this.m_region.id,{"milestone":shieldMileStone});
      }
   }
}

