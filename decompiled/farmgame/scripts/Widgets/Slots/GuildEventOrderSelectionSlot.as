package Widgets.Slots
{
   import Classes.Quest.FarmTask;
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.GuildEventOrderSelectionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuildEventOrderSelectionSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_owner:GuildEventOrderSelectionWindow;
      
      private const ICON_MC:String = "icon_mc";
      
      private const TASK_BT:String = "task_bt";
      
      private const POINTS_MC:String = "points_mc";
      
      private const COUNT_TF:String = "questdone_tf";
      
      private const HIT_AREA_MC:String = "hit_area_mc";
      
      private const HOVER_MC:String = "hover_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const QUESTTITLE_TF:String = "questtitle_tf";
      
      private const EXPANSION_TF:String = "expansion_tf";
      
      private var m_iconMc:FarmIcon;
      
      private var m_taskBt:FarmAnimatedTextButton;
      
      private var m_pointsMc:MovieClip;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_hitArea:MovieClip;
      
      private var m_hover:MovieClip;
      
      public var m_slotnumber:int;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      private var m_expansionTf:ZwTextField;
      
      private var m_isCallbackNull:Boolean = false;
      
      private var modifiedIconUrl:String;
      
      private var progress:int;
      
      private var total:int;
      
      private var m_questTitleTf:ZwTextField;
      
      private var m_slotHitWidget:ZwFrame;
      
      private var m_reqSlotNumber:int;
      
      public function GuildEventOrderSelectionSlot(featureName:String, element:DisplayObject, window:GuildEventOrderSelectionWindow, reqSlotNumber:int)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         this.m_reqSlotNumber = reqSlotNumber;
         super(element);
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element[this.ICON_MC]));
            this.m_slotHitWidget = new ZwFrame(m_element[this.ICON_MC]);
            this.m_slotHitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver());
            this.m_slotHitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
         }
         if(m_element.hasOwnProperty(this.TASK_BT))
         {
            addWidget(this.m_taskBt = new FarmAnimatedTextButton(m_element[this.TASK_BT],"Select",this.onClickTaskButton));
         }
         if(m_element.hasOwnProperty(this.POINTS_MC))
         {
            this.m_pointsMc = m_element[this.POINTS_MC] as MovieClip;
            if(m_element[this.POINTS_MC].hasOwnProperty(this.POINTS_TF))
            {
               this.m_pointsTf = new ZwTextField(m_element[this.POINTS_MC][this.POINTS_TF]);
            }
         }
         if(m_element.hasOwnProperty(this.COUNT_TF))
         {
            this.m_countTf = new ZwTextField(m_element[this.COUNT_TF]);
         }
         if(m_element.hasOwnProperty(this.EXPANSION_TF))
         {
            this.m_expansionTf = new ZwTextField(m_element[this.EXPANSION_TF]);
         }
         if(m_element.hasOwnProperty(this.HOVER_MC))
         {
            this.m_hover = m_element[this.HOVER_MC] as MovieClip;
            if(this.m_hover.hasOwnProperty(this.QUESTTITLE_TF))
            {
               this.m_questTitleTf = new ZwTextField(m_element[this.HOVER_MC][this.QUESTTITLE_TF]);
            }
         }
         if(m_element.hasOwnProperty(this.HIT_AREA_MC))
         {
         }
      }
      
      override public function populate(data:Object) : void
      {
         var expansionText:String = null;
         super.populate(data);
         this.resetAllButtonsAndTextFeilds();
         if(Boolean(data) && data.hasOwnProperty("questTaskSlotNumber"))
         {
            this.m_slotnumber = data.questTaskSlotNumber;
         }
         this.m_data = data;
         if(Boolean(data) && data.hasOwnProperty("questTask"))
         {
            this.m_task = data.questTask;
         }
         if(this.m_task.iconUrl)
         {
            this.modifiedIconUrl = this.getIconUrl();
            this.m_iconMc.visible = true;
            this.m_iconMc.loadIcon(this.modifiedIconUrl);
            this.m_iconMc.setIconSize(70,70);
            this.m_iconMc.setSmoothing(true);
         }
         if(this.m_expansionTf)
         {
            expansionText = "";
            if(this.eventManager.shouldTravelTask(this.m_task.action))
            {
               expansionText = this.eventManager.getExpansionName(this.m_task.action,this.m_task.type);
            }
            this.m_expansionTf.text = expansionText;
            this.m_expansionTf.visible = true;
         }
         if(Boolean(data) && data.hasOwnProperty("questText"))
         {
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("taskType")) && data.hasOwnProperty("helperText"))
         {
         }
         this.total = int(this.m_task.total);
         this.m_countTf.text = this.total.toString();
         this.m_countTf.visible = true;
         this.m_taskBt.enabled = true;
         this.m_taskBt.visible = !this.eventManager.allSlotsFull();
         this.m_taskBt.callback = this.onClickTaskButton;
         this.m_isCallbackNull = false;
         this.m_pointsMc.visible = true;
         this.m_pointsTf.visible = true;
         this.m_pointsTf.text = this.m_task.questPoints.toString();
      }
      
      public function onClickTaskButton(event:Event) : void
      {
         this.eventManager.selectNewOrder(this.m_slotnumber,this.m_reqSlotNumber);
      }
      
      private function getIconUrl() : String
      {
         var result:String = "";
         return this.m_task.iconUrl;
      }
      
      private function getQuestTitleText(titleText:String) : String
      {
         var result:String = "";
         return titleText;
      }
      
      private function get manager() : GuildManager
      {
         return GuildManager.getInstance(this.m_featureName);
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance(this.m_featureName);
      }
      
      public function onMouseOver() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(Boolean(m_data) && m_data.hasOwnProperty("questText"))
            {
               if(Boolean(m_hover) && Boolean(m_questTitleTf))
               {
                  m_hover.visible = true;
                  m_questTitleTf.text = getQuestTitleText(m_data.questText);
                  m_questTitleTf.visible = true;
               }
            }
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(Boolean(m_hover) && Boolean(m_questTitleTf))
            {
               m_hover.visible = false;
               m_questTitleTf.text = "";
               m_questTitleTf.visible = false;
            }
         };
      }
      
      private function resetAllButtonsAndTextFeilds() : void
      {
         this.m_taskBt.enabled = false;
         this.m_taskBt.visible = false;
         this.m_iconMc.visible = false;
         this.m_countTf.text = "";
         this.m_expansionTf.text = "";
         this.m_expansionTf.visible = false;
         this.m_countTf.visible = false;
         this.m_pointsMc.visible = false;
         this.m_pointsTf.text = "";
         this.m_pointsTf.visible = false;
         this.m_hover.visible = false;
         this.m_questTitleTf.text = "";
         this.m_questTitleTf.visible = false;
      }
   }
}

