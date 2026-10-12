package Widgets.Slots.ThemedQuest
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Engine.Managers.StatsManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ThemedQuest.ThemedQuestToolTipFrame;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.ThemedQuestWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ThemedQuestPieceSlot extends ZwSlotFrame
   {
      
      private static const TOOLTIP_CLASSNAME:String = "PuzzleTooltip";
      
      public var m_parentWindow:ThemedQuestWindow;
      
      private var m_toolTipFrame:ThemedQuestToolTipFrame;
      
      private var m_currentQuest:FarmQuest;
      
      private var m_taskIndex:int;
      
      public function ThemedQuestPieceSlot(element:DisplayObject, window:ThemedQuestWindow)
      {
         super(element);
         this.m_parentWindow = window;
         m_element.buttonMode = true;
         m_element.mouseEnabled = true;
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
      }
      
      override public function populate(data:Object) : void
      {
         var mc:MovieClip = null;
         var toolTipMC:MovieClip = null;
         var toolTipMCClss:Class = null;
         var widgetToolTip:WidgetTooltip = null;
         super.populate(data);
         this.m_currentQuest = data.quest as FarmQuest;
         this.m_taskIndex = data.index as int;
         var task:FarmTask = this.m_currentQuest.farmTasks[this.m_taskIndex];
         if(task)
         {
            mc = m_element as MovieClip;
            mc.gotoAndStop(mc.totalFrames);
            detachTooltip();
            if(task.isComplete())
            {
               if(this.m_toolTipFrame)
               {
                  this.m_toolTipFrame.visible = false;
               }
            }
            else
            {
               mc.gotoAndStop(Math.floor(task.progressPercent * mc.totalFrames));
               try
               {
                  if(this.m_parentWindow.window.loaderInfo.applicationDomain.hasDefinition(TOOLTIP_CLASSNAME))
                  {
                     toolTipMCClss = this.m_parentWindow.window.loaderInfo.applicationDomain.getDefinition(TOOLTIP_CLASSNAME) as Class;
                     toolTipMC = new toolTipMCClss() as MovieClip;
                  }
               }
               catch(e:Error)
               {
               }
               if(toolTipMC)
               {
                  (m_element as MovieClip).addChild(toolTipMC);
                  this.m_toolTipFrame = new ThemedQuestToolTipFrame(toolTipMC,this);
                  toolTipMC.x = 0;
                  toolTipMC.y = -25;
                  toolTipMC.scaleX *= 1 / m_element.scaleX;
                  toolTipMC.scaleY *= 1 / m_element.scaleY;
                  widgetToolTip = new WidgetTooltip(this.m_toolTipFrame,this.changeOrderCallback);
                  widgetToolTip.fixed = true;
                  widgetToolTip.interactive = true;
                  attachTooltip(widgetToolTip);
                  this.m_toolTipFrame.setTaskData(this.m_currentQuest,this.m_taskIndex);
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
      }
      
      private function onMouseOver(e:Event) : void
      {
         StatsManager.count("fv_puzz_house","view_puzzhou_task",this.m_currentQuest.name,this.m_taskIndex.toString());
      }
      
      private function changeOrderCallback() : void
      {
         parent.element.setChildIndex(this.element,parent.element.numChildren - 1);
      }
   }
}

