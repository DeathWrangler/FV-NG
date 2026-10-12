package Widgets.Slots
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class GenericLeaderboardSlot extends ZwSlotFrame
   {
      
      protected var m_leaderboardName:String;
      
      public function GenericLeaderboardSlot(element:DisplayObject, parentWindow:FarmWindow, leaderboardName:String)
      {
         super(element);
         this.m_leaderboardName = leaderboardName;
         if(m_element.number_tf != null)
         {
            addWidget(new ZwTextField(m_element.number_tf),false);
         }
         if(m_element.name_tf != null)
         {
            addWidget(new ZwTextField(m_element.name_tf),false);
         }
         if(m_element.score_tf != null)
         {
            addWidget(new ZwTextField(m_element.score_tf),false);
         }
         if(m_element.icon_mc != null)
         {
            addWidget(new FarmIcon(m_element.icon_mc),false);
         }
         if(m_element.Number2_tf != null)
         {
            addWidget(new ZwTextField(m_element.Number2_tf),false);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var place:ZwTextField = null;
         var name:ZwTextField = null;
         var score:ZwTextField = null;
         var icon:FarmIcon = null;
         super.populate(data);
         if(data != null)
         {
            if(m_element.number_tf != null)
            {
               place = getWidget(m_element.number_tf) as ZwTextField;
               place.visible = true;
               place.text = data["rank"];
            }
            if(m_element.name_tf != null)
            {
               name = getWidget(m_element.name_tf) as ZwTextField;
               name.visible = true;
               name.text = data["name"];
            }
            if(m_element.score_tf != null)
            {
               score = getWidget(m_element.score_tf) as ZwTextField;
               score.visible = true;
               score.text = ZLocUtils.t_pk("Dialogs",this.m_leaderboardName + "Score",{"itemScore":data["value"]});
            }
            if(m_element.icon_mc != null)
            {
               icon = getWidget(m_element.icon_mc) as FarmIcon;
               icon.visible = true;
               icon.loadIcon(data["icon"]);
            }
         }
      }
   }
}

