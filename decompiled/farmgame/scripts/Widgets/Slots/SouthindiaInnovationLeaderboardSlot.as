package Widgets.Slots
{
   import Managers.SouthindiaInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class SouthindiaInnovationLeaderboardSlot extends ZwSlotFrame
   {
      
      protected var m_leaderboardName:String;
      
      protected var m_highlightMc:MovieClip;
      
      public function SouthindiaInnovationLeaderboardSlot(element:DisplayObject, parentWindow:FarmWindow, leaderboardName:String)
      {
         super(element);
         this.m_leaderboardName = leaderboardName;
         if(m_element.number_tf != null)
         {
            addWidget(new ZwTextField(m_element.number_tf),false);
         }
         if(m_element.number2_tf != null)
         {
            addWidget(new ZwTextField(m_element.number2_tf),false);
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
         if(m_element.mc_highlight != null)
         {
            this.m_highlightMc = m_element.mc_highlight as MovieClip;
         }
      }
      
      private function get manager() : SouthindiaInnovationManager
      {
         return SouthindiaInnovationManager.getInstance();
      }
      
      override public function populate(data:Object) : void
      {
         var place:ZwTextField = null;
         var place2:ZwTextField = null;
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
               if(data["value"] != 0)
               {
                  place.text = data["rank"];
               }
               else
               {
                  place.text = "-";
               }
            }
            if(m_element.number2_tf != null)
            {
               place2 = getWidget(m_element.number2_tf) as ZwTextField;
               if(data["value"] != 0)
               {
                  place2.text = data["rank"];
               }
               else
               {
                  place2.text = "-";
               }
               if(data["rank"] > 999)
               {
                  place2.visible = true;
                  place.visible = false;
               }
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
               score.text = data["value"];
            }
            if(m_element.icon_mc != null)
            {
               icon = getWidget(m_element.icon_mc) as FarmIcon;
               icon.visible = true;
               icon.loadIcon(data["icon"]);
               icon.setIconSize(50,50);
            }
            if(data["uid"] == Global.player.uid)
            {
               this.m_highlightMc.visible = true;
            }
         }
      }
   }
}

