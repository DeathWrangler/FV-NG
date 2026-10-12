package Widgets.Slots.ThemedQuest
{
   import Classes.Quest.FarmQuest;
   import Classes.ZItem.FarmItem;
   import Managers.ThemedQuestManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.ThemedQuestWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ThemedQuestSelectorSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:ThemedQuestWindow;
      
      private var m_farmQuest:FarmQuest;
      
      private var m_selected:Boolean;
      
      private const SHOW_ICON:int = 2;
      
      private const DEFAULT:int = 0;
      
      public function ThemedQuestSelectorSlot(element:DisplayObject, window:FarmWindow)
      {
         var mcButtonHover:MovieClip = null;
         var mcButtonSelected:MovieClip = null;
         super(element);
         this.m_parentWindow = window as ThemedQuestWindow;
         GlobalEngine.assert(this.m_parentWindow != null,"[ThemedQuestSelectorSlot] :: window must be a ThemedQuestWindow");
         var mc:MovieClip = m_element as MovieClip;
         mc.gotoAndStop(this.DEFAULT);
         if(m_element.hasOwnProperty("buttonHover"))
         {
            mcButtonHover = m_element.buttonHover as MovieClip;
            mcButtonHover.visible = false;
         }
         if(m_element.hasOwnProperty("buttonSelected"))
         {
            mcButtonSelected = m_element.buttonSelected as MovieClip;
            mcButtonSelected.visible = false;
         }
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.registerEventListener(MouseEvent.MOUSE_UP,this.onSelect);
         mc.mouseEnabled = true;
         mc.mouseChildren = true;
      }
      
      override public function release() : void
      {
         this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.unregisterEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.unregisterEventListener(MouseEvent.MOUSE_UP,this.onSelect);
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var rewardItem:FarmItem = null;
         super.populate(data);
         this.m_farmQuest = data as FarmQuest;
         this.m_selected = false;
         if(this.m_farmQuest)
         {
            removeWidget(m_element.icon_mc);
            if(this.m_farmQuest.farmRewards.length > 0 && this.m_farmQuest.farmRewards[0].type == "item_grant")
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_farmQuest.farmRewards[0].value);
               if(m_element.hasOwnProperty("icon_mc") && Boolean(rewardItem))
               {
                  addWidget(new ObjectPreviewFrame(m_element.icon_mc,rewardItem,null,null,[75]));
               }
               if(this.m_parentWindow.hasCurrentThemedQuestBeenCompleted(this.m_farmQuest))
               {
                  this.showQuestReward();
               }
            }
            if(ThemedQuestManager.instance.isThemedUberQuest(this.m_parentWindow.getCurrentFeatureName(),this.m_farmQuest.name))
            {
               this.enabled = false;
            }
         }
      }
      
      private function onSelect(e:Event) : void
      {
         this.m_selected = true;
         this.m_parentWindow.setQuest(this.m_farmQuest,this);
         this.setSelectedVisibility(true);
      }
      
      private function onMouseOver(e:Event) : void
      {
         this.setHoverVisibility(true);
      }
      
      private function onMouseOut(e:Event) : void
      {
         if(!this.m_selected)
         {
            this.setHoverVisibility(false);
         }
      }
      
      public function deselect() : void
      {
         this.m_selected = false;
         this.setHoverVisibility(false);
         this.setSelectedVisibility(false);
      }
      
      public function showQuestReward() : void
      {
         var mc:MovieClip = m_element as MovieClip;
         mc.gotoAndStop(this.SHOW_ICON);
      }
      
      private function setHoverVisibility(visible:Boolean) : void
      {
         var mcButtonHover:MovieClip = null;
         if(m_element.hasOwnProperty("buttonHover"))
         {
            mcButtonHover = m_element.buttonHover as MovieClip;
            mcButtonHover.visible = visible;
         }
      }
      
      private function setSelectedVisibility(visible:Boolean) : void
      {
         var mcButtonSelected:MovieClip = null;
         if(m_element.hasOwnProperty("buttonSelected"))
         {
            mcButtonSelected = m_element.buttonSelected as MovieClip;
            mcButtonSelected.visible = visible;
         }
      }
   }
}

