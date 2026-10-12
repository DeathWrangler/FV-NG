package Widgets.Windows.MOTD
{
   import Classes.CommunityGoals.CommunityGoalsRewardContainer;
   import Classes.CommunityGoals.CommunityGoalsTask;
   import Classes.ImageLoader;
   import Managers.CommunityGoalsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class CommunityGoalsMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_task:CommunityGoalsTask;
      
      private var m_manager:CommunityGoalsManager;
      
      private var m_task_mc:MovieClip;
      
      private var m_meter_mc:MovieClip;
      
      private var m_task_tf:ZwTextField;
      
      private const TITLEBAR_MC_NAME:String = "mc_TitleBar_big";
      
      private const SLOT_V_NAME:String = "mc_Slot_V_1";
      
      private const SLOT_H_NAME:String = "mc_Slot_H_0";
      
      private var m_slotCGTitleIcon:DisplayObject;
      
      private var m_slotV100BGIcon:DisplayObject;
      
      private var m_slotH100BGIcon:DisplayObject;
      
      public function CommunityGoalsMOTDWindow(displayParams:Object = null)
      {
         var activeTask:CommunityGoalsTask = CommunityGoalsManager.getInstance().getActiveTask();
         var motdDialogPath:String = activeTask.getAssetPathFor(CommunityGoalsManager.MOTD_DIALOG_ASSET_KEY);
         if(motdDialogPath != null)
         {
            displayParams["dialog"] = motdDialogPath;
         }
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var bgPath:String = null;
         var npcPath:String = null;
         super.postLoadComplete();
         this.m_manager = CommunityGoalsManager.getInstance();
         this.m_task = this.m_manager.getActiveTask();
         if(this.m_task)
         {
            this.initializeTaskMC();
            this.initializeRewards(this.m_task.rewards);
            m_accept_bt.visible = true;
            bgPath = this.m_task.getAssetPathFor(CommunityGoalsManager.MOTD_DIALOG_BG_KEY);
            npcPath = this.m_task.getAssetPathFor(CommunityGoalsManager.NPC_URL);
            if(bgPath)
            {
               addWidget(new FarmIcon(m_window.mainWindow.loader_mc,Global.getAssetURL(bgPath)));
            }
            if(Boolean(npcPath) && m_window.mainWindow.mc_NPC != null)
            {
               addWidget(new FarmIcon(m_window.mainWindow.mc_NPC,Global.getAssetURL(npcPath)));
            }
         }
         if(Boolean(m_window.mainWindow["body_tf"]) && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_window.mainWindow["body_tf"]);
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.mainWindow["title_tf"]);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.mainWindow["title_tf"]);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.mainWindow["title_tf"]);
         }
      }
      
      private function initializeTaskMC() : void
      {
         this.m_task_mc = m_window.mainWindow.task_mc;
         if(this.m_task_mc)
         {
            this.m_task_tf = new ZwTextField(this.m_task_mc.task_tf,this.m_task.description);
            addWidget(this.m_task_tf);
            this.m_task_mc.visible = true;
         }
         if(this.m_task_mc.icon_mc)
         {
            addWidget(new FarmIcon(this.m_task_mc.icon_mc,this.m_task.iconUrl));
         }
         var titleBarPath:String = Global.worldSettingsManager.getSlotBGImagePath("CGTitleBar");
         if(titleBarPath)
         {
            ImageLoader.getInstance(Global.getAssetURL(titleBarPath)).getContent(this.onCGTitleBarLoaded);
         }
         var verticalSlotBGPath:String = Global.worldSettingsManager.getSlotBGImagePath("V100");
         if(verticalSlotBGPath)
         {
            ImageLoader.getInstance(Global.getAssetURL(verticalSlotBGPath)).getContent(this.onV100UrlLoaded);
         }
         var horizontalSlotBGPath:String = Global.worldSettingsManager.getSlotBGImagePath("H100");
         if(horizontalSlotBGPath)
         {
            ImageLoader.getInstance(Global.getAssetURL(horizontalSlotBGPath)).getContent(this.onH100Loaded);
         }
         if(Boolean(this.m_task_mc["task_tf"]) && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(this.m_task_mc["task_tf"]);
         }
      }
      
      private function onCGTitleBarLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotCGTitleIcon = dispObj;
         if(Boolean(this.m_slotCGTitleIcon) && Boolean(this.m_task_mc) && this.m_task_mc.hasOwnProperty(this.TITLEBAR_MC_NAME))
         {
            this.m_task_mc[this.TITLEBAR_MC_NAME].addChildAt(this.m_slotCGTitleIcon,1);
            this.m_task_mc[this.TITLEBAR_MC_NAME].removeChildAt(0);
            this.m_task_mc[this.TITLEBAR_MC_NAME].visible = true;
         }
      }
      
      private function onV100UrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotV100BGIcon = dispObj;
         if(Boolean(this.m_slotV100BGIcon) && Boolean(this.m_task_mc) && this.m_task_mc.hasOwnProperty(this.SLOT_V_NAME))
         {
            this.m_task_mc[this.SLOT_V_NAME].addChildAt(this.m_slotV100BGIcon,1);
            this.m_task_mc[this.SLOT_V_NAME].removeChildAt(0);
            this.m_task_mc[this.SLOT_V_NAME].visible = true;
         }
      }
      
      private function onH100Loaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotH100BGIcon = dispObj;
         if(Boolean(this.m_slotH100BGIcon) && Boolean(this.m_task_mc) && this.m_task_mc.hasOwnProperty(this.SLOT_H_NAME))
         {
            this.m_task_mc[this.SLOT_H_NAME].addChildAt(this.m_slotH100BGIcon,1);
            this.m_task_mc[this.SLOT_H_NAME].removeChildAt(0);
            this.m_task_mc[this.SLOT_H_NAME].visible = true;
         }
      }
      
      private function initializeRewards(rewards:XMLList) : void
      {
         var mcName:String = null;
         var i:int = 0;
         this.m_meter_mc = m_window.mainWindow.meter_mc;
         if(this.m_meter_mc)
         {
            for(i = 1; i <= CommunityGoalsManager.NUM_STAGES; i++)
            {
               mcName = "reward_" + i.toString() + "_mc";
               if(this.m_meter_mc[mcName])
               {
                  new CommunityGoalsRewardContainer(rewards[i - 1],this.m_meter_mc[mcName]);
               }
            }
         }
      }
   }
}

