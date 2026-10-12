package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.PrerequisiteUtility;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.utils.getDefinitionByName;
   
   public class AbstractStageWidget extends ZwFrame
   {
      
      private static const PREREQ_KEY_POSTFIX:String = "_storyBookPrereq";
      
      private static const CUSTOM_INTRO_WIDGET_PACKAGE:String = "Widgets.Windows.Quests.MultiStageQuests.";
      
      private static const INTRO_WIDGETS:Array = [StoryBookIntroWidget];
      
      protected var m_farmQuest:FarmQuest = null;
      
      protected var m_parentWindow:FarmWindow = null;
      
      protected var m_stage:int;
      
      protected var m_bookButton:FarmButton;
      
      protected var m_intro:ZwBaseWidget;
      
      public function AbstractStageWidget(element:DisplayObject, farmQuest:FarmQuest, parentWindow:FarmWindow, stage:int)
      {
         super(element);
         this.m_farmQuest = farmQuest;
         this.m_parentWindow = parentWindow;
         this.m_stage = stage;
         if(this.m_parentWindow.window.hasOwnProperty("bookIcon_mc") && this.isStoryBookActive(farmQuest.chain))
         {
            this.m_bookButton = addWidget(new FarmAnimatedTextButton(this.m_parentWindow.window.bookIcon_mc)) as FarmAnimatedTextButton;
            this.m_bookButton.registerEventListener(MouseEvent.CLICK,this.onBookIconClick);
         }
      }
      
      public function get parentWindow() : FarmWindow
      {
         return this.m_parentWindow;
      }
      
      protected function isStoryBookActive(questChain:String) : Boolean
      {
         var prereq:Object = null;
         var result:Boolean = false;
         var storyBookPrereqName:String = Global.farmGameSettingsManager.getAttribute(questChain + PREREQ_KEY_POSTFIX);
         if(storyBookPrereqName != null)
         {
            prereq = Global.farmGameSettingsManager.getPrereqByName(storyBookPrereqName);
            if(PrerequisiteUtility.isPrerequisiteMet(prereq))
            {
               result = true;
            }
         }
         return result;
      }
      
      private function onBookIconClick(event:MouseEvent) : void
      {
         var windowClassName:String = null;
         var windowClass:Class = null;
         if(this.m_parentWindow.window.hasOwnProperty("intro_mc"))
         {
            FarmStatsManager.count("dialog",this.m_farmQuest.name,"book","appeared","book");
            if(this.m_farmQuest.customIntroWidget != null)
            {
               windowClassName = CUSTOM_INTRO_WIDGET_PACKAGE + this.m_farmQuest.customIntroWidget;
               if(ApplicationDomain.currentDomain.hasDefinition(windowClassName))
               {
                  windowClass = getDefinitionByName(windowClassName) as Class;
                  this.m_intro = addWidget(new windowClass(this.m_parentWindow.window["intro_mc"],this.m_farmQuest,this.m_parentWindow,this.m_stage)) as ZwBaseWidget;
               }
            }
            else
            {
               this.m_intro = addWidget(new StageIntroWidget(this.m_parentWindow.window["intro_mc"],this.m_farmQuest,this.m_parentWindow,this.m_stage)) as ZwBaseWidget;
            }
            this.m_intro.addEventListener(Event.CLOSE,this.onIntroClick);
            this.m_bookButton.enabled = false;
         }
      }
      
      public function onIntroClick(event:Event) : void
      {
         this.m_intro.removeEventListener(Event.CLOSE,this.onIntroClick);
         this.m_bookButton.enabled = true;
         removeWidget(this.m_intro);
         this.m_intro = null;
      }
      
      override public function release() : void
      {
         super.release();
         if(this.m_bookButton != null)
         {
            this.m_bookButton.unregisterEventListener(MouseEvent.CLICK,this.onBookIconClick);
         }
         if(this.m_intro != null)
         {
            this.m_intro.removeEventListener(Event.CLOSE,this.onIntroClick);
         }
      }
   }
}

