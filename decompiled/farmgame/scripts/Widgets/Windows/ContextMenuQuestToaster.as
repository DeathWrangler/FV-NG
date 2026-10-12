package Widgets.Windows
{
   import Classes.FarmGameObject;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Managers.ContextMenuQuestManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class ContextMenuQuestToaster extends ToasterWindow
   {
      
      private static const DEFAULT_ASSET_PATH:String = "assets/dialogs/fv_contextQuest_Orchard_toaster.swf";
      
      public static const STATE_TASK_COMPLETED:String = "completed";
      
      public static const STATE_REACTIVATE:String = "reactivate";
      
      private static const ICON_SIZE:int = 100;
      
      private var m_quest:FarmQuest;
      
      private var m_taskIndex:int;
      
      private var m_state:String;
      
      private var m_shouldClose:Boolean = false;
      
      public function ContextMenuQuestToaster(quest:FarmQuest, taskIndex:int, state:String = "completed")
      {
         var firstTimeSeenFlag:String = null;
         var settingName:String = null;
         var centerOnItemName:String = null;
         var worldObjects:Array = null;
         var centerOnItem:FarmGameObject = null;
         var windowAssetPath:String = Global.farmGameSettingsManager.getString("ContextMenuQuestToasterUrl_" + quest.chain);
         if(!windowAssetPath)
         {
            windowAssetPath = DEFAULT_ASSET_PATH;
         }
         super(windowAssetPath);
         this.m_quest = quest;
         this.m_taskIndex = taskIndex;
         this.m_state = state;
         m_allowToasterManangerToClose = false;
         var mainUIOpenSessionSeenFlag:String = ContextMenuQuestManager.instance.mainUIOpenFlag(this.m_quest);
         if(Global.player.getSeenSessionFlag(mainUIOpenSessionSeenFlag))
         {
            this.m_shouldClose = true;
         }
         else
         {
            firstTimeSeenFlag = this.m_quest.chain + "_firstTaskCompletion";
            if(!Global.player.getSeenFlag(firstTimeSeenFlag))
            {
               TutorialUI.displayBundleTutorialWindow("Dialogs",this.m_quest.chain,"assets/dialogs/4d_elements/" + this.m_quest.chain + "/" + this.m_quest.chain,false,this.generateOnCloseTutorial());
               Global.player.setSeenFlag(firstTimeSeenFlag);
               this.m_shouldClose = true;
               settingName = "ContextMenuQuestCenterOn_" + quest.chain;
               centerOnItemName = Global.farmGameSettingsManager.getString(settingName);
               if(centerOnItemName)
               {
                  worldObjects = Global.world.getObjectsByName(centerOnItemName);
                  if(Boolean(worldObjects) && worldObjects.length > 0)
                  {
                     centerOnItem = worldObjects[0] as FarmGameObject;
                     if(centerOnItem)
                     {
                        centerOnItem.centerOn();
                     }
                  }
               }
               FarmStatsManager.count("fv_contextQuest",this.m_quest.chain,"firstTaskComplete","view",String(this.m_taskIndex));
            }
         }
         if(this.m_shouldClose)
         {
            this.close();
         }
         ContextMenuQuestManager.instance.setWindowOpenBackoff(this.m_quest.chain);
      }
      
      override protected function postLoadComplete() : void
      {
         var description:String = null;
         var iconUrl:String = null;
         var task:FarmTask = null;
         super.postLoadComplete();
         var bundlePrefix:String = "ContextMenuQuestCompletionToaster_" + this.m_quest.chain + "_";
         if(this.m_state == STATE_TASK_COMPLETED)
         {
            description = ZLocUtils.t("Dialogs",bundlePrefix + "description");
            task = this.m_quest.farmTasks[this.m_taskIndex];
            iconUrl = task.iconUrl;
            addWidget(new ZwWidget(m_window.checkMark_mc));
         }
         else
         {
            iconUrl = this.m_quest.avatarHeadImage;
            description = ZLocUtils.t("Dialogs",bundlePrefix + "reactivateDescription");
         }
         var icon:FarmIcon = new FarmIcon(m_window.icon_mc,iconUrl);
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
         icon.setSmoothing(true);
         addWidget(icon);
         addWidget(new FarmTextField(m_window.description_tf,description));
         addWidget(new FarmAnimatedTextButton(m_window.view_bt,ZLocUtils.t("Dialogs",bundlePrefix + "viewbt"),this.onViewCallback));
      }
      
      override public function show() : void
      {
         if(FarmQuestManager.getInstance().isQuestComplete(this.m_quest.name) || this.m_shouldClose)
         {
            close();
         }
         else
         {
            super.show();
            FarmStatsManager.count("fv_contextQuest",this.m_quest.chain,"showToaster",this.m_state);
         }
      }
      
      private function onViewCallback(e:Event) : void
      {
         if(FarmQuestManager.getInstance().isQuestActive(this.m_quest.name))
         {
            FarmStatsManager.count("fv_contextQuest",this.m_quest.chain,"toasterToUI",this.m_state);
            this.m_quest.showProgress();
         }
         this.close();
      }
      
      private function generateOnCloseTutorial() : Function
      {
         return function():void
         {
            m_quest.showProgress();
            FarmStatsManager.count("fv_contextQuest",m_quest.chain,"firstTaskComplete","close",String(m_taskIndex));
         };
      }
   }
}

