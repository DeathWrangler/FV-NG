package Widgets.Windows.NeighborVisit
{
   import Classes.NeighborActions.NeighborVisit;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class FriendSuggestRollOutWindow extends AbstractRolloutWindow
   {
      
      public static const EVENT_BUTTON_CLICK:String = "EventButtonClick";
      
      private var m_friendName:String = "";
      
      private var m_visitedUserName:String = "";
      
      private var m_level:int = 0;
      
      private var m_achievements:int = 0;
      
      private var m_masteries:int = 0;
      
      public function FriendSuggestRollOutWindow(visitedUserName:String, neighborVisit:NeighborVisit)
      {
         this.m_visitedUserName = visitedUserName;
         this.m_friendName = neighborVisit.name;
         this.m_level = neighborVisit.level;
         this.m_achievements = neighborVisit.achievements;
         this.m_masteries = neighborVisit.masteries;
         super("assets/dialogs/FV_friendSuggest_rollOut.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.rollOut_mc));
         addWidget(new ZwTextField(m_window.rollOut_mc.generic_tf,this.m_friendName + " is also a friend of " + this.m_visitedUserName));
         addWidget(new ZwTextField(m_window.rollOut_mc.level_tf,String(this.m_level)));
         addWidget(new ZwTextField(m_window.rollOut_mc.ribbon_tf,String(this.m_achievements)));
         addWidget(new ZwTextField(m_window.rollOut_mc.mastery_tf,String(this.m_masteries)));
         addWidget(new FarmAnimatedTextButton(m_window.rollOut_mc.add_bt,"Add Neighbor",this.onAddClick));
         addWidget(new FarmAnimatedTextButton(m_window.rollOut_mc.cancel_bt,"No Thanks",this.onDismissClick));
      }
      
      private function onAddClick(event:Event) : void
      {
         FarmStatsManager.count("mutual_neighbor_click_exp","avatar_action","add_as_neighbor");
         UI.displayMessage("Coming Soon",0,null);
         this.dispatchEvent(new Event(FriendSuggestRollOutWindow.EVENT_BUTTON_CLICK));
      }
      
      private function onDismissClick(event:Event) : void
      {
         FarmStatsManager.count("mutual_neighbor_click_exp","avatar_action","dismiss");
         this.dispatchEvent(new Event(FriendSuggestRollOutWindow.EVENT_BUTTON_CLICK));
      }
   }
}

