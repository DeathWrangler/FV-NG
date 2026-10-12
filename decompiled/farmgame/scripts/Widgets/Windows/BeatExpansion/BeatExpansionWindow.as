package Widgets.Windows.BeatExpansion
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.BeatExpansion.BeatExpansionBaseManager;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.BeatExpansion.BeatExpansionMasterySlot;
   import Widgets.Slots.BeatExpansion.BeatExpansionSlot;
   import Widgets.Windows.*;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BeatExpansionWindow extends FarmWindowWithTutorial
   {
      
      private var m_tasks:Array;
      
      private var m_rewards:Array;
      
      private var m_masteryFrame:GenericSlotContainerFrame;
      
      private var m_beatManager:BeatExpansionBaseManager;
      
      private var m_taskFrame:BeatExpansionTaskContainerFrame = null;
      
      private var m_check1:MovieClip;
      
      private var m_check2:MovieClip;
      
      private var m_dialogBackground:String;
      
      private const VERTICAL_SLOT_MC:String = "mc_Slot_V_0";
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_slotBGIcon:DisplayObject;
      
      public function BeatExpansionWindow(dialogAsset:String, beatManager:BeatExpansionBaseManager, tasks:Array, rewards:Array, featureName:String = null, totalNumScenes:int = -1, dialogBackground:String = null)
      {
         this.m_beatManager = beatManager;
         this.m_tasks = tasks;
         this.m_rewards = rewards;
         super(featureName,dialogAsset,totalNumScenes);
         this.m_dialogBackground = dialogBackground;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override public function show() : void
      {
         this.m_beatManager.ztrack("impressions");
         super.show();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.header_tf != null)
         {
            addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs",this.m_beatManager.windowLocalizationPrefix + "title")));
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionTextColor(m_window.header_tf);
               TemplateUIUtility.applyExpansionBevelFilter(m_window.header_tf);
               TemplateUIUtility.applyExpansionDropShadowFilter(m_window.header_tf);
            }
         }
         if(m_window.subHeader_mc != null)
         {
            addWidget(new ZwTextField(m_window.subHeader_mc,ZLocUtils.t("Dialogs",this.m_beatManager.windowLocalizationPrefix + "subtitle")));
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.subHeader_mc);
            }
         }
         if(!this.m_beatManager.isQuestActive())
         {
            this.initializeRewardCheckMarks();
         }
         this.initTaskSlots();
         this.initRewards();
         if(Boolean(m_window.mc_AnimalFrame) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_AnimalFrame));
         }
      }
      
      private function initTaskSlots() : void
      {
         var i:int = 0;
         var elementName:String = null;
         var taskName:String = null;
         if(m_window.main_mc)
         {
            this.m_taskFrame = addWidget(new BeatExpansionTaskContainerFrame(m_window.main_mc,this.m_beatManager,this)) as BeatExpansionTaskContainerFrame;
            this.m_taskFrame.items = this.m_tasks;
            this.m_taskFrame.visible = true;
         }
         else
         {
            i = 0;
            for(taskName in this.m_tasks)
            {
               elementName = "cell" + i + "_mc";
               if(!m_window[elementName])
               {
                  break;
               }
               addWidget(new BeatExpansionSlot(m_window[elementName],this.m_beatManager,this,this.m_tasks[taskName]));
               i++;
            }
         }
      }
      
      private function initRewards() : void
      {
         var elementNameMc:String = null;
         var elementNameTf:String = null;
         var reward:FarmItem = null;
         var rewardName:String = null;
         var rewardIcon:FarmIcon = null;
         var i:int = 1;
         for(rewardName in this.m_rewards)
         {
            elementNameMc = "prize" + i + "_mc";
            elementNameTf = "prize" + i + "_tf";
            if(!m_window[elementNameMc])
            {
               break;
            }
            rewardIcon = addWidget(new FarmIcon(m_window[elementNameMc],this.m_rewards[rewardName])) as FarmIcon;
            rewardIcon.setSmoothing(true);
            addWidget(new ZwTextField(m_window[elementNameTf],ZLocUtils.t("Dialogs",this.m_beatManager.windowLocalizationPrefix + "reward_" + rewardName)));
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window[elementNameTf]);
            }
            i++;
         }
         addWidget(new ZwTextField(m_window["win_tf"],ZLocUtils.t("Dialogs",this.m_beatManager.windowLocalizationPrefix + "winText")));
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionSubTextColor(m_window.win_tf);
         }
      }
      
      private function initializeRewardCheckMarks() : void
      {
         if(m_window.check1_mc != null)
         {
            this.m_check1 = m_window.check1_mc as MovieClip;
            this.m_check1.visible = true;
         }
         if(m_window.check2_mc != null)
         {
            this.m_check2 = m_window.check2_mc as MovieClip;
            this.m_check2.visible = true;
         }
      }
      
      public function showMasteryFrame(itemCodes:Array) : void
      {
         var loader_V80:Loader = null;
         var levelIndex:int = 0;
         var verticalSlotBGPath:String = null;
         this.m_beatManager.ztrack("show_mastery");
         if(this.m_masteryFrame)
         {
            this.m_masteryFrame.setData(itemCodes);
            this.m_masteryFrame.visible = true;
         }
         else
         {
            this.m_masteryFrame = addWidget(new GenericSlotContainerFrame(m_window.overlay_mc,BeatExpansionMasterySlot,itemCodes,this)) as GenericSlotContainerFrame;
            levelIndex = 0;
            while(m_window.overlay_mc.hasOwnProperty("slot_" + levelIndex + "_mc"))
            {
               if(m_window.overlay_mc["slot_" + levelIndex + "_mc"].hasOwnProperty(this.VERTICAL_SLOT_MC))
               {
                  verticalSlotBGPath = Global.worldSettingsManager.getSlotBGImagePath("V80");
                  if(verticalSlotBGPath)
                  {
                     ImageLoader.getInstance(Global.getAssetURL(verticalSlotBGPath)).getContent(this.onSlotUrlLoaded);
                     if(this.m_slotBGIcon)
                     {
                        m_window.overlay_mc["slot_" + levelIndex + "_mc"][this.VERTICAL_SLOT_MC].addChild(this.m_slotBGIcon);
                        m_window.overlay_mc["slot_" + levelIndex + "_mc"][this.VERTICAL_SLOT_MC].visible = true;
                     }
                  }
               }
               levelIndex++;
            }
            if(this.m_masteryFrame.element.close_bt)
            {
               this.m_masteryFrame.addWidget(new ZwButton(this.m_masteryFrame.element.close_bt,this.closeMasteryFrame));
            }
            if(this.m_masteryFrame.element.title_tf)
            {
               this.m_masteryFrame.addWidget(new ZwTextField(this.m_masteryFrame.element.title_tf,ZLocUtils.t("Dialogs",this.m_beatManager.windowLocalizationPrefix + "master_crops_title")));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(this.m_masteryFrame.element.title_tf);
               }
            }
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      private function closeMasteryFrame(event:Event) : void
      {
         this.m_masteryFrame.visible = false;
      }
      
      public function refreshData() : void
      {
         var i:int = 0;
         var elementName:String = null;
         var widget:BeatExpansionSlot = null;
         var taskName:String = null;
         this.m_tasks = this.m_beatManager.getTaskData();
         if(this.m_taskFrame)
         {
            this.m_taskFrame.items = this.m_tasks;
         }
         else
         {
            i = 0;
            for(taskName in this.m_tasks)
            {
               elementName = "cell" + i + "_mc";
               widget = this.getWidget(elementName) as BeatExpansionSlot;
               if(!widget)
               {
                  break;
               }
               widget.setProgressAndPurchaseButton(this.m_tasks[taskName]);
               i++;
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_masteryFrame = null;
         this.m_check1 = null;
         this.m_check2 = null;
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         this.m_beatManager.ztrack("close");
         super.onClose(event);
      }
   }
}

