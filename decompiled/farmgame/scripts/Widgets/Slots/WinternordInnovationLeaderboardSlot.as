package Widgets.Slots
{
   import Managers.WinternordInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class WinternordInnovationLeaderboardSlot extends ZwSlotFrame
   {
      
      private static const BADGE_ICONS:Array = ["assets/newsfeed/specialsnowflakebadge_icon.png","assets/newsfeed/outstandingornamentbadge_icon.png","assets/newsfeed/wreathofwonderbadge_icon.png"];
      
      protected var m_leaderboardName:String;
      
      protected var m_highlightMc:MovieClip;
      
      private var m_badge0IconMC:FarmIcon;
      
      private var m_badge1IconMC:FarmIcon;
      
      private var m_badge2IconMC:FarmIcon;
      
      private var m_communityBadge0_mc:MovieClip;
      
      private var m_communityBadge1_mc:MovieClip;
      
      private var m_communityBadge2_mc:MovieClip;
      
      public function WinternordInnovationLeaderboardSlot(element:DisplayObject, parentWindow:FarmWindow, leaderboardName:String)
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
         if(m_element.lscore_tf != null)
         {
            addWidget(new ZwTextField(m_element.lscore_tf),false);
         }
         if(m_element.icon_mc != null)
         {
            addWidget(new FarmIcon(m_element.icon_mc),false);
         }
         if(m_element.mc_highlight != null)
         {
            this.m_highlightMc = m_element.mc_highlight as MovieClip;
         }
         if(m_element.hasOwnProperty("badge0_mc"))
         {
            this.m_badge0IconMC = new FarmIcon(m_element["badge0_mc"]);
         }
         if(m_element.hasOwnProperty("badge1_mc"))
         {
            this.m_badge1IconMC = new FarmIcon(m_element["badge1_mc"]);
         }
         if(m_element.hasOwnProperty("badge2_mc"))
         {
            this.m_badge2IconMC = new FarmIcon(m_element["badge2_mc"]);
         }
      }
      
      private function get manager() : WinternordInnovationManager
      {
         return WinternordInnovationManager.getInstance();
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
               if(data["value"] != 0)
               {
                  place.text = data["rank"];
               }
               else
               {
                  place.text = "-";
               }
            }
            if(m_element.name_tf != null)
            {
               name = getWidget(m_element.name_tf) as ZwTextField;
               name.visible = true;
               name.text = data["name"];
            }
            if(m_element.lscore_tf != null)
            {
               score = getWidget(m_element.lscore_tf) as ZwTextField;
               score.visible = true;
               if(data["value"] != 0)
               {
                  score.text = data["value"];
               }
               else
               {
                  score.text = "-";
               }
            }
            if(m_element.icon_mc != null)
            {
               icon = getWidget(m_element.icon_mc) as FarmIcon;
               icon.visible = true;
               icon.loadIcon(data["icon"]);
               icon.setIconSize(25,25);
            }
            if(data["value"] >= 50)
            {
               this.m_badge0IconMC.loadIcon(BADGE_ICONS[0]);
               this.m_badge0IconMC.setIconSize(35,35);
               this.m_badge0IconMC.setSmoothing(true);
               this.m_badge0IconMC.visible = true;
            }
            if(data["value"] >= 100)
            {
               this.m_badge1IconMC.loadIcon(BADGE_ICONS[1]);
               this.m_badge1IconMC.setIconSize(35,35);
               this.m_badge1IconMC.setSmoothing(true);
               this.m_badge1IconMC.visible = true;
            }
            if(data["value"] >= 250)
            {
               this.m_badge2IconMC.loadIcon(BADGE_ICONS[2]);
               this.m_badge2IconMC.setIconSize(35,35);
               this.m_badge2IconMC.setSmoothing(true);
               this.m_badge2IconMC.visible = true;
            }
            if(data["uid"] == Global.player.uid)
            {
               this.m_highlightMc.visible = true;
            }
         }
      }
   }
}

