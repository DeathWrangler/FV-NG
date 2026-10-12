package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.WeekendDelightManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class WeekendDelightSlot extends GenericTimedSlot
   {
      
      private var m_index:int = -1;
      
      private const ICON_WITH_QUESTION:String = "qicon";
      
      public function WeekendDelightSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
         if(Boolean(!isTemplateUIEnabled()) && Boolean(m_element) && m_element.icon_mc != null)
         {
            addWidget(new FarmIcon(m_element.icon_mc));
         }
         if(m_element.collected_mc != null)
         {
            addWidget(new ZwFrame(m_element.collected_mc));
         }
         if(Boolean(m_element) && Boolean(m_element["date_tf"]))
         {
            addWidget(new ZwTextField(m_element.date_tf,WeekendDelightManager.getInstance().getStartDate().toDateString()));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var itemReward:FarmIcon = null;
         var itemName:ZwTextField = null;
         var dateText:ZwTextField = null;
         var date:Date = null;
         this.m_index = uint(data);
         if(m_item == null)
         {
            m_item = this.getCurrentItem(null);
         }
         if(Boolean(m_element) && m_element.icon_mc != null)
         {
            itemReward = getWidget(m_element.icon_mc) as FarmIcon;
            itemReward.loadIcon(m_item.icon);
            if(this.m_index - WeekendDelightManager.getInstance().getCurrentDayNumber() > 1)
            {
               itemReward.loadIcon(m_item.getImageByName(this.ICON_WITH_QUESTION));
            }
            itemReward.visible = true;
            if(!itemReward.element["bounds_mc"])
            {
               itemReward.setIconSize(100,100);
            }
            if(WeekendDelightManager.getInstance().getCurrentDayNumber() > this.m_index && WeekendDelightManager.getInstance().isItemeCollected(this.m_index) == false)
            {
               itemReward.applyGrayOut = true;
            }
         }
         if(this.m_index - WeekendDelightManager.getInstance().getCurrentDayNumber() <= 1)
         {
            if(m_element.itemTitle_tf != null)
            {
               itemName = getWidget(m_element.itemTitle_tf) as ZwTextField;
               itemName.text = m_item.friendlyTitle;
               itemName.visible = true;
            }
            if(m_element.date_tf != null)
            {
               dateText = getWidget(m_element.date_tf) as ZwTextField;
               dateText.visible = true;
               date = WeekendDelightManager.getInstance().getStartDate();
               date.setDate(date.getDate() + this.m_index);
               dateText.text = date.toDateString();
               dateText.text = dateText.text.substring(3,dateText.text.length);
               if(this.m_index == WeekendDelightManager.getInstance().getCurrentDayNumber())
               {
                  dateText.text = "Today";
               }
               if(this.m_index == WeekendDelightManager.getInstance().getCurrentDayNumber() + 1)
               {
                  dateText.text = "Tomorrow";
               }
            }
         }
         if(m_element.collected_mc != null)
         {
            getWidget(m_element.collected_mc).visible = false;
         }
         if(this.hasFinishedSlot())
         {
            this.popFinishedSlot();
         }
         else
         {
            this.popNotFinishedSlot();
         }
      }
      
      override protected function hasFinishedSlot() : Boolean
      {
         return WeekendDelightManager.getInstance().isItemeCollected(this.m_index);
      }
      
      override protected function popNotFinishedSlot() : void
      {
         super.popNotFinishedSlot();
      }
      
      override protected function popFinishedSlot() : void
      {
         if(m_element.collected_mc != null)
         {
            getWidget(m_element.collected_mc).visible = true;
         }
      }
      
      override protected function getCurrentItem(data:Object) : FarmItem
      {
         return WeekendDelightManager.getInstance().getItemForSlot(this.m_index);
      }
   }
}

