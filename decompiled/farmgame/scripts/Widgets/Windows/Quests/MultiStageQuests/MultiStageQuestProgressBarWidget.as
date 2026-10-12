package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.ZItem.FarmItem;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class MultiStageQuestProgressBarWidget extends ZwFrame
   {
      
      public function MultiStageQuestProgressBarWidget(element:DisplayObject, stage:int, item:FarmItem, parentWindow:MultiStageQuestDialog)
      {
         super(element);
         addWidget(new ZwTextField(m_element.generic_tf,String(stage)));
         addWidget(new ZwBaseWidget(m_element.dot_mc));
         var dotWidget:ZwBaseWidget = addWidget(new ZwBaseWidget(m_element.dot_mc.color_mc)) as ZwBaseWidget;
         if(Boolean(parentWindow) && parentWindow.isTemplateUIEnabled())
         {
            TemplateUIUtility.applyBackgroundColor(dotWidget.element as DisplayObject,TemplateUIUtility.ESCAPADE,parentWindow.textColor);
         }
         addWidget(new ZwBaseWidget(m_element.lock_mc));
         addWidget(new FarmIcon(m_element.item_active_mc,item.iconUrl),false);
         addWidget(new FarmIcon(m_element.item_inactive_mc,item.iconUrl));
      }
      
      public function set active(value:Boolean) : void
      {
         this.getWidget(m_element.item_active_mc).visible = value;
         this.getWidget(m_element.item_inactive_mc).visible = !value;
      }
      
      public function set locked(value:Boolean) : void
      {
         this.getWidget(m_element.lock_mc).visible = value;
      }
   }
}

