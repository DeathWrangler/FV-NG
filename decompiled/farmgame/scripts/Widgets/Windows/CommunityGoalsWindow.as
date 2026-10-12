package Widgets.Windows
{
   import Classes.CommunityGoals.CommunityGoalsRewardContainer;
   import Classes.CommunityGoals.CommunityGoalsTask;
   import Classes.ImageLoader;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericButton;
   import Display.TutorialUI;
   import Managers.CommunityGoalsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   
   public class CommunityGoalsWindow extends FarmWindow
   {
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 680;
      
      private var m_featureName:String = null;
      
      private var m_manager:CommunityGoalsManager;
      
      private var m_task_mc:MovieClip;
      
      private var m_meter_mc:MovieClip;
      
      private var m_whatIsThis:GenericButton;
      
      private var m_title_tf:ZwTextField;
      
      private var m_description_tf:ZwTextField;
      
      private var m_eligibility_tf:ZwTextField;
      
      private var m_task_tf:ZwTextField;
      
      private var m_con_tf:ZwTextField;
      
      private var m_timer_tf:ZwTextField;
      
      private var m_percent_tf:ZwTextField;
      
      private var m_task:CommunityGoalsTask;
      
      private var m_progressPercent:Number = 0;
      
      private var m_playerCount:Number;
      
      private var m_progress_tf:ZwTextField;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_npcIconMc:FarmIcon;
      
      private var m_npcUrl:String;
      
      private var m_npcLoader:ImageLoader = null;
      
      private var m_npcIcon:DisplayObject = null;
      
      private const TITLEBAR_MC_NAME:String = "mc_TitleBar_big";
      
      private const SLOT_V_NAME:String = "mc_Slot_V_1";
      
      private const SLOT_H_NAME:String = "mc_Slot_H_0";
      
      private var m_slotBGIcon:DisplayObject;
      
      public function CommunityGoalsWindow(task:CommunityGoalsTask, assetUrl:String = "assets/dialogs/FV_xtl_CommunityGoals.swf", dialogBackground:String = null, npcUrl:String = null)
      {
         super(assetUrl);
         this.m_task = task;
         this.m_manager = CommunityGoalsManager.getInstance();
         this.m_dialogBackground = dialogBackground;
         if(this.m_dialogBackground)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         this.m_npcUrl = npcUrl;
         if(this.m_npcUrl)
         {
            this.m_npcLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_npcUrl));
            this.m_npcLoader.getContent(this.onNpcLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function onNpcLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_npcIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.initializeUI();
      }
      
      public function isEligibleForRewards() : Boolean
      {
         var result:Boolean = false;
         var playerCount:Number = this.m_manager.getPlayerCountForTask(this.m_task.name);
         if(playerCount >= this.m_task.playerGoal)
         {
            result = true;
         }
         return result;
      }
      
      private function initializeUI() : void
      {
         var eligibility_text:String = null;
         var title_text:String = ZLocUtils.t("Dialogs","community_goals_Title");
         this.m_title_tf = new ZwTextField(m_window.title_tf,title_text);
         addWidget(this.m_title_tf);
         var description_text:String = ZLocUtils.t("Dialogs","community_goals_Text");
         this.m_description_tf = new ZwTextField(m_window.description_tf,description_text);
         addWidget(this.m_description_tf);
         if(!this.isEligibleForRewards())
         {
            if(this.m_task)
            {
               eligibility_text = ZLocUtils.t("Dialogs","community_goals_" + this.m_task.name + "_EligibilityText",{"playerGoal":this.m_task.playerGoal});
               this.m_eligibility_tf = new ZwTextField(m_window.eligibility_tf,eligibility_text);
               addWidget(this.m_eligibility_tf);
            }
         }
         else
         {
            m_window.eligibility_tf.visible = false;
         }
         if(m_window.task_mc)
         {
            this.m_task_mc = m_window.task_mc;
            this.initializeTaskMC();
         }
         if(m_window.meter_mc)
         {
            this.m_meter_mc = m_window.meter_mc;
            this.initializeMeterMC();
         }
         if(m_window.whatisthis_mc)
         {
            this.m_whatIsThis = new GenericButton(m_window.whatisthis_mc,this.onWhatIsThisClick);
            this.m_whatIsThis.turnOn();
         }
         if(Boolean(m_window.mc_AnimalFrame_big) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_AnimalFrame_big));
         }
         if(Boolean(this.m_npcIcon) && m_window.mc_NPC != null)
         {
            addWidget(this.m_npcIconMc = new FarmIcon(m_window.mc_NPC));
            this.m_npcIconMc.loadIcon(this.m_npcUrl);
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.description_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_window.eligibility_tf);
         }
      }
      
      private function onWhatIsThisClick(evt:MouseEvent = null) : void
      {
         TutorialUI.displayCommunityGoalsTutorialWindow();
      }
      
      private function initializeProgressBar() : void
      {
         if(this.m_meter_mc)
         {
            this.m_meter_mc.visible = true;
            this.updateProgressBar(0);
         }
      }
      
      private function initializeTaskMC() : void
      {
         var titleBarPath:String = null;
         var verticalSlotBGPath:String = null;
         var horizontalSlotBGPath:String = null;
         var contribution_text:String = null;
         var endDate:Number = NaN;
         if(Boolean(this.m_task_mc) && Boolean(this.m_task))
         {
            this.m_task_mc.visible = true;
            if(this.m_task_mc.task_tf)
            {
               this.m_task_tf = new ZwTextField(this.m_task_mc.task_tf,this.m_task.description);
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(this.m_task_mc.task_tf);
               }
               addWidget(this.m_task_tf);
            }
            if(this.m_task_mc.con_tf)
            {
               contribution_text = ZLocUtils.t("Dialogs","community_goals_Contribution");
               this.m_con_tf = new ZwTextField(this.m_task_mc.con_tf,contribution_text);
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(this.m_task_mc.con_tf);
               }
               addWidget(this.m_con_tf);
            }
            if(this.m_task_mc.icon_mc)
            {
               addWidget(new FarmIcon(this.m_task_mc.icon_mc,this.m_task.iconUrl));
            }
            if(this.m_task_mc.timer_tf)
            {
               endDate = FarmGameUtil.synchronizedDateTimeToNumber(this.m_task.endDate) / 1000;
               if(endDate)
               {
                  this.m_timer_tf = new ZwTextField(this.m_task_mc.timer_tf,FarmGameUtil.getTimeLeftText(endDate));
                  addWidget(this.m_timer_tf);
               }
            }
            if(this.m_task_mc.progress_tf)
            {
               this.m_playerCount = this.m_manager.getPlayerCountForTask(this.m_task.name);
               this.m_progress_tf = new ZwTextField(this.m_task_mc.progress_tf,this.m_playerCount.toString());
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(this.m_task_mc.progress_tf);
               }
               if(this.m_task.name == "coin_exp_week1")
               {
                  this.m_progress_tf.text = "ACHIEVED!";
               }
            }
            if(this.m_task_mc.market_bt)
            {
               this.m_task_mc.market_bt.visible = false;
            }
            titleBarPath = Global.worldSettingsManager.getSlotBGImagePath("CGTitleBar");
            if(titleBarPath)
            {
               ImageLoader.getInstance(Global.getAssetURL(titleBarPath)).getContent(this.onSlotUrlLoaded);
               if(Boolean(this.m_slotBGIcon) && this.m_task_mc.hasOwnProperty(this.TITLEBAR_MC_NAME))
               {
                  this.m_task_mc[this.TITLEBAR_MC_NAME].addChildAt(this.m_slotBGIcon,1);
                  this.m_task_mc[this.TITLEBAR_MC_NAME].removeChildAt(0);
                  this.m_task_mc[this.TITLEBAR_MC_NAME].visible = true;
               }
            }
            verticalSlotBGPath = Global.worldSettingsManager.getSlotBGImagePath("V100");
            if(verticalSlotBGPath)
            {
               this.m_slotBGIcon = null;
               ImageLoader.getInstance(Global.getAssetURL(verticalSlotBGPath)).getContent(this.onSlotUrlLoaded);
               if(Boolean(this.m_slotBGIcon) && this.m_task_mc.hasOwnProperty(this.SLOT_V_NAME))
               {
                  this.m_task_mc[this.SLOT_V_NAME].addChildAt(this.m_slotBGIcon,1);
                  this.m_task_mc[this.SLOT_V_NAME].removeChildAt(0);
                  this.m_task_mc[this.SLOT_V_NAME].visible = true;
               }
            }
            horizontalSlotBGPath = Global.worldSettingsManager.getSlotBGImagePath("H100");
            if(horizontalSlotBGPath)
            {
               this.m_slotBGIcon = null;
               ImageLoader.getInstance(Global.getAssetURL(horizontalSlotBGPath)).getContent(this.onSlotUrlLoaded);
               if(Boolean(this.m_slotBGIcon) && this.m_task_mc.hasOwnProperty(this.TITLEBAR_MC_NAME))
               {
                  this.m_task_mc[this.SLOT_H_NAME].addChildAt(this.m_slotBGIcon,1);
                  this.m_task_mc[this.SLOT_H_NAME].removeChildAt(0);
                  this.m_task_mc[this.SLOT_H_NAME].visible = true;
               }
            }
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      private function markStageComplete(stage:int, isComplete:Boolean = true) : void
      {
         var mc_name:String = null;
         if(this.m_meter_mc)
         {
            mc_name = "completeIcon_" + stage.toString() + "_mc";
            if(this.m_meter_mc[mc_name])
            {
               (this.m_meter_mc[mc_name] as MovieClip).visible = isComplete;
            }
         }
      }
      
      private function markAllStagesIncomplete() : void
      {
         var stage:int = 0;
         if(this.m_meter_mc)
         {
            for(stage = 1; stage <= CommunityGoalsManager.NUM_STAGES; stage++)
            {
               this.markStageComplete(stage,false);
            }
         }
      }
      
      private function initializeRewards(rewards:XMLList) : void
      {
         var mcName:String = null;
         for(var i:int = 1; i <= CommunityGoalsManager.NUM_STAGES; i++)
         {
            mcName = "reward_" + i.toString() + "_mc";
            if(this.m_meter_mc[mcName])
            {
               new CommunityGoalsRewardContainer(rewards[i - 1],this.m_meter_mc[mcName]);
            }
         }
      }
      
      private function initializeMeterMC() : void
      {
         if(this.m_meter_mc)
         {
            this.initializeProgressBar();
            if(this.m_meter_mc.percent_tf)
            {
               this.m_percent_tf = new ZwTextField(this.m_meter_mc.percent_tf,ZLocUtils.t("Dialogs","community_goals_Loading"));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(this.m_meter_mc.percent_tf);
               }
               this.m_manager.getCommunityProgressForTask(this.m_task.name,this.updateProgressBar);
            }
            this.markAllStagesIncomplete();
            this.initializeRewards(this.m_task.rewards);
            if(!this.isEligibleForRewards())
            {
               this.m_meter_mc.filters = [new ColorMatrixFilter(FarmGameUtil.getSaturationMatrix(0))];
            }
         }
      }
      
      private function showCompletedStages(percentValue:Number) : void
      {
         var stagePercent:Number = 0;
         for(var i:int = 0; i < CommunityGoalsManager.NUM_STAGES; i++)
         {
            stagePercent = 100 * (i + 1) / CommunityGoalsManager.NUM_STAGES;
            if(percentValue >= stagePercent)
            {
               if(this.m_manager.isRewardGrantedForStage(this.m_task.name,i + 1))
               {
                  this.markStageComplete(i + 1);
               }
            }
         }
      }
      
      private function updateProgressBar(percentValue:Number) : void
      {
         percentValue = Math.floor(percentValue / this.m_task.communityGoal * 100);
         if(percentValue > 100)
         {
            percentValue = 100;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / 100;
         if(this.m_meter_mc.bar_fill_mc)
         {
            if(percentValue == 0)
            {
               (this.m_meter_mc.bar_fill_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(this.m_meter_mc.bar_fill_mc,2,{"width":barWidth});
            }
         }
         if(this.m_meter_mc.percent_tf)
         {
            (this.m_meter_mc.percent_tf as TextField).text = percentValue + "%";
         }
         this.showCompletedStages(percentValue);
      }
      
      protected function onActivate(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         close();
      }
   }
}

