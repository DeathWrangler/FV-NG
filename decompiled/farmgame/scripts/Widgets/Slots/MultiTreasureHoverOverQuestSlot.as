package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import Managers.PumpkinPartyInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class MultiTreasureHoverOverQuestSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE_X:int = 40;
      
      private static const ICON_SIZE_Y:int = 40;
      
      private var m_crossMark:ZwWidget;
      
      private var m_checkMark:ZwWidget;
      
      private var m_taskDescription:ZwTextField;
      
      private var m_taskHelperButton:FarmAnimatedTextButton;
      
      private var m_taskType:String;
      
      private var m_taskAction:String;
      
      private var m_task:FarmTask;
      
      private var m_taskIcon:FarmIcon;
      
      public function MultiTreasureHoverOverQuestSlot(element:DisplayObject)
      {
         super(element);
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_taskIcon = new FarmIcon(m_element.icon_mc),false);
            if(this.m_taskIcon)
            {
               this.m_taskIcon.setIconSize(ICON_SIZE_X,ICON_SIZE_Y);
            }
         }
         if(m_element.hasOwnProperty("task_tf"))
         {
            this.m_taskDescription = new ZwTextField(m_element.task_tf,"");
            addWidget(this.m_taskDescription);
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_element.task_tf);
            }
         }
         if(m_element.hasOwnProperty("check_mc"))
         {
            this.m_checkMark = addWidget(new ZwWidget(m_element.check_mc),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("cross_mc"))
         {
            this.m_crossMark = addWidget(new ZwWidget(m_element.cross_mc),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("show_bt"))
         {
            addWidget(this.m_taskHelperButton = new FarmAnimatedTextButton(m_element.show_bt,"",this.onClickHelper),false);
         }
      }
      
      private function onClickHelper(evt:Event) : void
      {
         var objs:Array = null;
         var obj:FeatureBuilding = null;
         if(this.m_taskType)
         {
            switch(this.m_taskAction)
            {
               case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
                  if(this.m_taskType)
                  {
                     objs = Global.world.getObjectsByCode(this.m_taskType);
                     if(objs[0])
                     {
                        obj = objs[0] as FeatureBuilding;
                        if(obj)
                        {
                           obj.displayStorageDialog();
                        }
                     }
                  }
                  break;
               case QuestConstants.TASK_COLLECT_ESCAPE_TOKENS:
                  switch(this.m_taskType)
                  {
                     case "TropicalMarketInnovation":
                        this.trackInnovationShowButtonClick("TropicalMarketInnovation");
                        TropicalMarketInnovationManager.getInstance().showMainWindow();
                        break;
                     case "PumpkinPartyInnovation":
                        this.trackInnovationShowButtonClick("PumpkinPartyInnovation");
                        PumpkinPartyInnovationManager.getInstance().showMainUI();
                  }
            }
         }
      }
      
      private function trackInnovationShowButtonClick(featureName:String) : void
      {
         StatsManager.count(featureName,"LandTile","unknown","Show");
      }
      
      private function isTropicalMarketActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("tropical_market_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(TropicalMarketInnovationManager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ALOHA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isPumpkinPartyInnovationActive() : Boolean
      {
         var pumpkinpartyInnovationManager:PumpkinPartyInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("pumpkinparty_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            pumpkinpartyInnovationManager = PumpkinPartyInnovationManager.getInstance();
            if(Boolean(pumpkinpartyInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_PUMPKIN)
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function populate(data:Object) : void
      {
         var taskProgress:int = int(data["progress"]);
         this.m_task = data["task"] as FarmTask;
         this.m_taskAction = this.m_task.action;
         this.m_taskType = this.m_task.type;
         if(this.m_taskDescription)
         {
            this.m_taskDescription.text = this.m_task.titleText;
            this.m_taskDescription.visible = true;
         }
         if(Boolean(this.m_taskHelperButton) && this.m_taskAction == QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE)
         {
            this.m_taskHelperButton.text = ZLocUtils.t("Dialogs","Open");
            this.m_taskHelperButton.visible = true;
            this.m_taskHelperButton.enabled = true;
         }
         if(Boolean(this.m_taskHelperButton) && this.m_taskAction == QuestConstants.TASK_COLLECT_ESCAPE_TOKENS)
         {
            this.m_taskHelperButton.text = "Show";
            this.m_taskHelperButton.visible = this.isTropicalMarketActive() || this.isPumpkinPartyInnovationActive();
            this.m_taskHelperButton.enabled = this.isTropicalMarketActive() || this.isPumpkinPartyInnovationActive();
         }
         if(this.m_taskIcon)
         {
            this.m_taskIcon.loadIcon(this.m_task.iconUrl);
            this.m_taskIcon.visible = true;
         }
         if(Boolean(taskProgress) && taskProgress == 1)
         {
            this.m_checkMark.visible = true;
            this.m_crossMark.visible = false;
         }
         else
         {
            this.m_crossMark.visible = true;
            this.m_checkMark.visible = false;
         }
      }
   }
}

